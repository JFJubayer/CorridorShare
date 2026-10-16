// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CorridorShare';

  @override
  String get tabHome => 'Home';

  @override
  String get tabMyPosts => 'My posts';

  @override
  String get tabChats => 'Chats';

  @override
  String get tabProfile => 'Profile';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get phoneHint => '01XXXXXXXXX';

  @override
  String get phoneContinue => 'Continue';

  @override
  String get phoneInvalid => 'Enter a valid Bangladeshi mobile number.';

  @override
  String get otpTitle => 'Enter the 6-digit code';

  @override
  String get otpHint => '6-digit code';

  @override
  String get otpVerify => 'Verify';

  @override
  String get otpResend => 'Resend code';

  @override
  String get otpInvalid => 'The code is incorrect. Try again.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get logout => 'Log out';

  @override
  String get signIn => 'Sign in';

  @override
  String get profileNamePlaceholder => 'Your name';

  @override
  String get profileVerified => 'Verified';

  @override
  String get profileUnverified => 'Not verified';

  @override
  String get profileRating => 'Rating';

  @override
  String get homeGreeting => 'Welcome to CorridorShare';

  @override
  String get homeSubtitle =>
      'Peer-to-peer intercity shipping across Bangladesh';

  @override
  String get homeEmpty => 'No trips or parcels to show yet.';

  @override
  String get myPostsSending => 'Sending';

  @override
  String get myPostsCarrying => 'Carrying';

  @override
  String get chatsEmpty => 'No conversations yet.';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get postTripTitle => 'Post a Trip';

  @override
  String get postTripSubtitle => 'Earn while travelling between cities';

  @override
  String get postParcelTitle => 'Send a Parcel';

  @override
  String get postParcelSubtitle => 'Fast, affordable peer-to-peer delivery';

  @override
  String get fromDistrictLabel => 'Origin District';

  @override
  String get fromAreaLabel => 'Pickup Area (e.g. Uttara Sector 7)';

  @override
  String get toDistrictLabel => 'Destination District';

  @override
  String get toAreaLabel => 'Drop-off Area (e.g. Agrabad, GEC)';

  @override
  String get departureDateLabel => 'Departure Date';

  @override
  String get capacityLabel => 'Available Capacity (kg)';

  @override
  String get noCarryLabel => 'No-Carry Restriction Tags';

  @override
  String get noCarryHint =>
      'Items you will NOT carry (e.g. liquids, perishables)';

  @override
  String get tripNoteLabel => 'Travel Notes (train, bus, timing)';

  @override
  String get submitTrip => 'Publish Trip';

  @override
  String get parcelTitleLabel => 'Item Name / Description';

  @override
  String get parcelCategoryLabel => 'Category Tags';

  @override
  String get parcelCategoryHint => 'e.g. documents, clothes, books';

  @override
  String get parcelWeightLabel => 'Weight (kg)';

  @override
  String get parcelSizeLabel => 'Package Size';

  @override
  String get parcelDeadlineLabel => 'Must Deliver Before';

  @override
  String get offeredPriceLabel => 'Offered Reward (BDT)';

  @override
  String get prohibitedDeclaration =>
      'I confirm this parcel contains no illegal, contraband, or hazardous items under Bangladesh law.';

  @override
  String get submitParcel => 'Publish Parcel';

  @override
  String get tripCreatedSuccess => 'Trip published successfully!';

  @override
  String get parcelCreatedSuccess => 'Parcel published successfully!';

  @override
  String get availableTrips => 'Available Travellers';

  @override
  String get availableParcels => 'Parcels to Carry';

  @override
  String get noTripsFound => 'No trips currently available.';

  @override
  String get noParcelsFound => 'No parcels currently available.';

  @override
  String get statusOpen => 'Open';

  @override
  String get statusMatched => 'Matched';

  @override
  String get statusInTransit => 'In Transit';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusDisputed => 'Disputed';

  @override
  String get statusFull => 'Full';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get matchingTrips => 'Matching Travellers';

  @override
  String get matchingParcels => 'Compatible Parcels';

  @override
  String get noMatchingTrips =>
      'No compatible trips found for this parcel deadline and route.';

  @override
  String get noMatchingParcels =>
      'No compatible parcels waiting for this corridor.';

  @override
  String get noCarryAlert => 'Traveller will NOT carry: ';

  @override
  String get viewMatches => 'Find Matches';

  @override
  String get makeOffer => 'Make an Offer';

  @override
  String get counterOffer => 'Counter-Offer';

  @override
  String get acceptOffer => 'Accept Offer';

  @override
  String get rejectOffer => 'Decline';

  @override
  String get offerPrice => 'Proposed Price (BDT)';

  @override
  String get offerStatusPendingYou => 'Action Needed: Respond to Offer';

  @override
  String get offerStatusPendingOther => 'Waiting for Response';

  @override
  String get offerStatusAccepted => 'Deal Agreed!';

  @override
  String get offerStatusRejected => 'Declined';

  @override
  String get offerAcceptedSuccess => 'Offer accepted! Deal is now agreed.';

  @override
  String get chatInputHint => 'Type a message…';

  @override
  String get send => 'Send';

  @override
  String get dealAgreedBadge => 'Agreed Deal';

  @override
  String get deliveryTrackingTitle => 'Delivery Tracking';

  @override
  String get deliveryStepMatched => 'Matched & Agreed';

  @override
  String get deliveryStepInTransit => 'In Transit';

  @override
  String get deliveryStepDelivered => 'Delivered';

  @override
  String get deliveryPickedUpAt => 'Picked up at';

  @override
  String get deliveryCompletedAt => 'Handover completed at';

  @override
  String get deliveryAwaitingPickup => 'Awaiting pickup from sender';

  @override
  String get deliveryPendingHandover => 'Awaiting delivery to recipient';

  @override
  String get disputeRaisedTitle => 'Dispute Raised';

  @override
  String get pickupHandoverTitle => 'Confirm Parcel Pickup';

  @override
  String get pickupPhotoProofLabel => 'Pickup Proof Photo';

  @override
  String get pickupPhotoCaptured => 'Handover Proof Attached';

  @override
  String get pickupCheckCondition =>
      'Inspected parcel condition (no external tears or seal tampering)';

  @override
  String get pickupCheckNoLeaks =>
      'Verified package contains no prohibited or leaking items';

  @override
  String get pickupNotesHint => 'Optional condition notes';

  @override
  String get confirmPickupAction => 'Confirm Pickup Handover';

  @override
  String get recipientHandoverPinLabel => 'Recipient Delivery PIN';

  @override
  String get recipientPinSecurityNotice =>
      'Share this 4-digit PIN with the recipient. The traveller must enter it to verify delivery upon arrival.';

  @override
  String get completeDeliveryAction => 'Complete Delivery Handover';

  @override
  String get verifyDeliveryTitle => 'Verify Delivery Handover';

  @override
  String get verifyDeliveryHint =>
      'Enter the 4-digit verification code provided by the recipient to confirm delivery completion.';

  @override
  String get verifyAndComplete => 'Verify & Complete';

  @override
  String get reportDisputeTitle => 'Report Dispute / Issue';

  @override
  String get reportDisputeHint =>
      'Report any package damage, missing items, or handover failure to resolve with support.';

  @override
  String get reportDisputeAction => 'Report an Issue / Dispute';

  @override
  String get trackDelivery => 'Track Delivery';

  @override
  String get walletDemoBalanceTitle => 'Demo Wallet';

  @override
  String get walletAvailableBalance => 'Available Balance';

  @override
  String get walletEscrowHold => 'In Escrow (Held)';

  @override
  String get walletTopUpAction => 'Top Up Demo Balance';

  @override
  String get walletTopUpTitle => 'Add Demo Funds';

  @override
  String get walletTopUpNotice =>
      'This is simulated demo money for Bangladesh university project evaluation. No real payment gateway or funds are used.';

  @override
  String get walletAmountLabel => 'Deposit Amount (BDT)';

  @override
  String get walletLedgerAction => 'Ledger';

  @override
  String get walletLedgerTitle => 'Wallet Transaction History';

  @override
  String get walletNoTransactions => 'No transactions yet.';

  @override
  String get reviewsTitle => 'Ratings & Reviews';

  @override
  String get reviewsRateUserTitle => 'Rate & Review Partner';

  @override
  String get reviewsRatingFor => 'Rating for';

  @override
  String get reviewsCommentHint =>
      'Share your experience with this delivery...';

  @override
  String get reviewsSubmitAction => 'Submit Review';

  @override
  String get reviewsNoReviews =>
      'No reviews yet. Complete your first delivery to earn ratings!';

  @override
  String get adminDashboardTitle => 'Admin Dashboard';

  @override
  String get adminOverviewTitle => 'Platform Metrics & Health';

  @override
  String get adminTotalUsers => 'Total Users';

  @override
  String get adminTotalTrips => 'Active Trips';

  @override
  String get adminActiveDeliveries => 'Active In-Transit';

  @override
  String get adminTotalVolume => 'Total Handover Volume';

  @override
  String get adminDisputeQueueTitle => 'Dispute Escalations';

  @override
  String get adminNoOpenDisputes =>
      'All disputes resolved. No escalations pending.';

  @override
  String get adminDisputeReason => 'Dispute Reason';

  @override
  String get adminRefundSenderAction => 'Refund Sender';

  @override
  String get adminPayoutTravellerAction => 'Payout Traveller';

  @override
  String get quickActionTravelling => 'I am travelling';

  @override
  String get quickActionSending => 'I need to send';

  @override
  String get verifiedPeerBadge => 'Verified Peer';

  @override
  String get adminDashboardSubtitle => 'Metrics & Dispute Oversight';

  @override
  String get enterPriceError => 'Enter price';

  @override
  String get priceMustBePositive => 'Must be > 0 BDT';

  @override
  String get chatEmptyPrompt =>
      'Start the negotiation or arrange handover details.';

  @override
  String get verifyConditionChecklistPrompt =>
      'Please verify parcel condition checklist before pickup';

  @override
  String get defaultPickupInspectedNote =>
      'Inspected and collected in good condition.';

  @override
  String get disputeReasonRequired => 'Please describe the issue or dispute';

  @override
  String get disputeReasonExampleHint =>
      'e.g. Package damaged or recipient unreachable';

  @override
  String get authTitle => 'Welcome to CorridorShare';

  @override
  String get authSubtitle =>
      'Peer-to-peer intercity shipping across Bangladesh';

  @override
  String get tabPhone => 'Phone';

  @override
  String get tabEmail => 'Email';

  @override
  String get emailLabel => 'Email address';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailInvalid => 'Enter a valid email address.';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter password (min 6 characters)';

  @override
  String get passwordInvalid => 'Password must be at least 6 characters.';

  @override
  String get nameLabel => 'Full Name';

  @override
  String get nameHint => 'e.g. Tanvir Ahmed';

  @override
  String get nameInvalid => 'Please enter your full name.';

  @override
  String get signInAction => 'Sign In';

  @override
  String get signUpAction => 'Create Account';

  @override
  String get forgotPasswordAction => 'Forgot password?';

  @override
  String get passwordResetSent =>
      'Password reset email sent. Check your inbox.';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign up';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get signOutConfirmTitle => 'Log Out';

  @override
  String get signOutConfirmMessage =>
      'Are you sure you want to log out of your account?';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get registeredDemoAccounts => 'Registered Demo Accounts';
}
