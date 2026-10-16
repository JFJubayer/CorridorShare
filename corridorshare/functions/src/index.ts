import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

interface VerifyDeliveryInput {
  deliveryId: string;
  inputPin: string;
}

interface HoldEscrowInput {
  deliveryId: string;
  senderId: string;
  amount: number;
}

interface TopUpWalletInput {
  userId: string;
  amount: number;
}

interface ResolveDisputeInput {
  deliveryId: string;
  resolution: "refundSender" | "payoutTraveller";
  adminNotes: string;
}

/**
 * Server-authoritative 4-digit PIN verification and escrow settlement.
 * Prevents client-side balance tampering and illegitimate state jumps.
 */
export const verifyDeliveryPin = functions.https.onCall(
  async (data: VerifyDeliveryInput, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required to verify delivery PIN."
      );
    }

    const { deliveryId, inputPin } = data;
    if (!deliveryId || !inputPin || inputPin.length !== 4) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "A valid deliveryId and 4-digit PIN must be provided."
      );
    }

    return await db.runTransaction(async (transaction) => {
      const deliveryRef = db.collection("deliveries").doc(deliveryId);
      const deliveryDoc = await transaction.get(deliveryRef);

      if (!deliveryDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Delivery document not found.");
      }

      const delivery = deliveryDoc.data()!;
      if (delivery.status !== "inTransit") {
        throw new functions.https.HttpsError(
          "failed-precondition",
          `Cannot verify delivery with status: ${delivery.status}. Expected inTransit.`
        );
      }

      // Security check: only traveller or authorized participant
      if (delivery.travellerId !== context.auth!.uid && !context.auth!.token.admin) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "Only the assigned traveller or admin can submit the verification PIN."
        );
      }

      if (delivery.verificationPin !== inputPin.trim()) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "Invalid 4-digit handover PIN. Handover cannot be completed."
        );
      }

      const senderId = delivery.senderId;
      const travellerId = delivery.travellerId;
      const amount = Number(delivery.agreedPrice);

      const senderWalletRef = db.collection("users").doc(senderId).collection("wallet").doc("ledger");
      const travellerWalletRef = db.collection("users").doc(travellerId).collection("wallet").doc("ledger");

      const senderWalletDoc = await transaction.get(senderWalletRef);
      const travellerWalletDoc = await transaction.get(travellerWalletRef);

      const senderEscrow = senderWalletDoc.exists ? (senderWalletDoc.data()!.escrow || 0) : 0;
      const travellerBalance = travellerWalletDoc.exists ? (travellerWalletDoc.data()!.balance || 0) : 0;

      // Update delivery record
      transaction.update(deliveryRef, {
        status: "delivered",
        deliveredAt: admin.firestore.FieldValue.serverTimestamp(),
        isDisputed: false,
      });

      // Update associated parcel
      if (delivery.parcelId) {
        transaction.update(db.collection("parcels").doc(delivery.parcelId), {
          status: "delivered",
        });
      }

      // Settle escrow atomically
      transaction.set(
        senderWalletRef,
        {
          escrow: Math.max(0, senderEscrow - amount),
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      transaction.set(
        travellerWalletRef,
        {
          balance: travellerBalance + amount,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      // Record immutable ledger transactions
      const now = admin.firestore.FieldValue.serverTimestamp();
      const senderTxRef = db.collection("users").doc(senderId).collection("wallet_transactions").doc();
      const travellerTxRef = db.collection("users").doc(travellerId).collection("wallet_transactions").doc();

      transaction.set(senderTxRef, {
        type: "escrow_release",
        amount: -amount,
        referenceId: deliveryId,
        createdAt: now,
      });

      transaction.set(travellerTxRef, {
        type: "payout",
        amount: amount,
        referenceId: deliveryId,
        createdAt: now,
      });

      return {
        success: true,
        deliveryId,
        status: "delivered",
        payoutAmount: amount,
      };
    });
  }
);

/**
 * Server-authoritative Escrow Hold when an offer is accepted.
 */
export const holdEscrow = functions.https.onCall(
  async (data: HoldEscrowInput, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
    }

    const { deliveryId, senderId, amount } = data;
    if (context.auth.uid !== senderId && !context.auth.token.admin) {
      throw new functions.https.HttpsError("permission-denied", "Unauthorized sender identity.");
    }

    return await db.runTransaction(async (transaction) => {
      const walletRef = db.collection("users").doc(senderId).collection("wallet").doc("ledger");
      const walletDoc = await transaction.get(walletRef);

      const currentBalance = walletDoc.exists ? (walletDoc.data()!.balance || 0) : 0;
      const currentEscrow = walletDoc.exists ? (walletDoc.data()!.escrow || 0) : 0;

      if (currentBalance < amount) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          `Insufficient balance (৳${currentBalance}). Required ৳${amount} for escrow lock.`
        );
      }

      transaction.set(
        walletRef,
        {
          balance: currentBalance - amount,
          escrow: currentEscrow + amount,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      const txRef = db.collection("users").doc(senderId).collection("wallet_transactions").doc();
      transaction.set(txRef, {
        type: "escrow_hold",
        amount: -amount,
        referenceId: deliveryId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { success: true, remainingBalance: currentBalance - amount, escrow: currentEscrow + amount };
    });
  }
);

/**
 * Server-side Demo Wallet Top-Up with ledger tracking.
 */
export const topUpWallet = functions.https.onCall(
  async (data: TopUpWalletInput, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
    }

    const { userId, amount } = data;
    if (context.auth.uid !== userId && !context.auth.token.admin) {
      throw new functions.https.HttpsError("permission-denied", "Cannot top up another user's balance.");
    }

    if (amount <= 0 || amount > 50000) {
      throw new functions.https.HttpsError("invalid-argument", "Amount must be between 1 and 50,000 BDT.");
    }

    return await db.runTransaction(async (transaction) => {
      const walletRef = db.collection("users").doc(userId).collection("wallet").doc("ledger");
      const walletDoc = await transaction.get(walletRef);
      const balance = walletDoc.exists ? (walletDoc.data()!.balance || 0) : 0;

      transaction.set(
        walletRef,
        {
          balance: balance + amount,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      const txRef = db.collection("users").doc(userId).collection("wallet_transactions").doc();
      transaction.set(txRef, {
        type: "deposit",
        amount: amount,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { success: true, newBalance: balance + amount };
    });
  }
);

/**
 * Admin Dispute Resolution with server-side escrow refund or payout.
 */
export const resolveDispute = functions.https.onCall(
  async (data: ResolveDisputeInput, context) => {
    if (!context.auth || !context.auth.token.admin) {
      throw new functions.https.HttpsError("permission-denied", "Admin privileges required.");
    }

    const { deliveryId, resolution, adminNotes } = data;

    return await db.runTransaction(async (transaction) => {
      const deliveryRef = db.collection("deliveries").doc(deliveryId);
      const deliveryDoc = await transaction.get(deliveryRef);

      if (!deliveryDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Delivery not found.");
      }

      const delivery = deliveryDoc.data()!;
      const amount = Number(delivery.agreedPrice);
      const senderId = delivery.senderId;
      const travellerId = delivery.travellerId;

      const senderWalletRef = db.collection("users").doc(senderId).collection("wallet").doc("ledger");
      const travellerWalletRef = db.collection("users").doc(travellerId).collection("wallet").doc("ledger");

      const senderWallet = await transaction.get(senderWalletRef);
      const travellerWallet = await transaction.get(travellerWalletRef);

      const sEscrow = senderWallet.exists ? (senderWallet.data()!.escrow || 0) : 0;
      const sBalance = senderWallet.exists ? (senderWallet.data()!.balance || 0) : 0;
      const tBalance = travellerWallet.exists ? (travellerWallet.data()!.balance || 0) : 0;

      if (resolution === "refundSender") {
        transaction.set(
          senderWalletRef,
          {
            balance: sBalance + amount,
            escrow: Math.max(0, sEscrow - amount),
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );
      } else {
        transaction.set(
          senderWalletRef,
          {
            escrow: Math.max(0, sEscrow - amount),
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );
        transaction.set(
          travellerWalletRef,
          {
            balance: tBalance + amount,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );
      }

      transaction.update(deliveryRef, {
        status: resolution === "refundSender" ? "cancelled" : "delivered",
        isDisputed: false,
        disputeResolvedAt: admin.firestore.FieldValue.serverTimestamp(),
        disputeResolution: resolution,
        adminNotes: adminNotes,
      });

      return { success: true, deliveryId, resolution };
    });
  }
);
