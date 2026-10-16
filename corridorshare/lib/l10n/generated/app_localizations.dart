import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CorridorShare'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabMyPosts.
  ///
  /// In en, this message translates to:
  /// **'My posts'**
  String get tabMyPosts;

  /// No description provided for @tabChats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get tabChats;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'01XXXXXXXXX'**
  String get phoneHint;

  /// No description provided for @phoneContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get phoneContinue;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Bangladeshi mobile number.'**
  String get phoneInvalid;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get otpTitle;

  /// No description provided for @otpHint.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get otpHint;

  /// No description provided for @otpVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerify;

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get otpResend;

  /// No description provided for @otpInvalid.
  ///
  /// In en, this message translates to:
  /// **'The code is incorrect. Try again.'**
  String get otpInvalid;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageBangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get languageBangla;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @profileNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get profileNamePlaceholder;

  /// No description provided for @profileVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get profileVerified;

  /// No description provided for @profileUnverified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get profileUnverified;

  /// No description provided for @profileRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get profileRating;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome to CorridorShare'**
  String get homeGreeting;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Peer-to-peer intercity shipping across Bangladesh'**
  String get homeSubtitle;

  /// No description provided for @homeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No trips or parcels to show yet.'**
  String get homeEmpty;

  /// No description provided for @myPostsSending.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get myPostsSending;

  /// No description provided for @myPostsCarrying.
  ///
  /// In en, this message translates to:
  /// **'Carrying'**
  String get myPostsCarrying;

  /// No description provided for @chatsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet.'**
  String get chatsEmpty;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @postTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Post a Trip'**
  String get postTripTitle;

  /// No description provided for @postTripSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Earn while travelling between cities'**
  String get postTripSubtitle;

  /// No description provided for @postParcelTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a Parcel'**
  String get postParcelTitle;

  /// No description provided for @postParcelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fast, affordable peer-to-peer delivery'**
  String get postParcelSubtitle;

  /// No description provided for @fromDistrictLabel.
  ///
  /// In en, this message translates to:
  /// **'Origin District'**
  String get fromDistrictLabel;

  /// No description provided for @fromAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup Area (e.g. Uttara Sector 7)'**
  String get fromAreaLabel;

  /// No description provided for @toDistrictLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination District'**
  String get toDistrictLabel;

  /// No description provided for @toAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Drop-off Area (e.g. Agrabad, GEC)'**
  String get toAreaLabel;

  /// No description provided for @departureDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Departure Date'**
  String get departureDateLabel;

  /// No description provided for @capacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Available Capacity (kg)'**
  String get capacityLabel;

  /// No description provided for @noCarryLabel.
  ///
  /// In en, this message translates to:
  /// **'No-Carry Restriction Tags'**
  String get noCarryLabel;

  /// No description provided for @noCarryHint.
  ///
  /// In en, this message translates to:
  /// **'Items you will NOT carry (e.g. liquids, perishables)'**
  String get noCarryHint;

  /// No description provided for @tripNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Travel Notes (train, bus, timing)'**
  String get tripNoteLabel;

  /// No description provided for @submitTrip.
  ///
  /// In en, this message translates to:
  /// **'Publish Trip'**
  String get submitTrip;

  /// No description provided for @parcelTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Item Name / Description'**
  String get parcelTitleLabel;

  /// No description provided for @parcelCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category Tags'**
  String get parcelCategoryLabel;

  /// No description provided for @parcelCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. documents, clothes, books'**
  String get parcelCategoryHint;

  /// No description provided for @parcelWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get parcelWeightLabel;

  /// No description provided for @parcelSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Package Size'**
  String get parcelSizeLabel;

  /// No description provided for @parcelDeadlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Must Deliver Before'**
  String get parcelDeadlineLabel;

  /// No description provided for @offeredPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Offered Reward (BDT)'**
  String get offeredPriceLabel;

  /// No description provided for @prohibitedDeclaration.
  ///
  /// In en, this message translates to:
  /// **'I confirm this parcel contains no illegal, contraband, or hazardous items under Bangladesh law.'**
  String get prohibitedDeclaration;

  /// No description provided for @submitParcel.
  ///
  /// In en, this message translates to:
  /// **'Publish Parcel'**
  String get submitParcel;

  /// No description provided for @tripCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Trip published successfully!'**
  String get tripCreatedSuccess;

  /// No description provided for @parcelCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Parcel published successfully!'**
  String get parcelCreatedSuccess;

  /// No description provided for @availableTrips.
  ///
  /// In en, this message translates to:
  /// **'Available Travellers'**
  String get availableTrips;

  /// No description provided for @availableParcels.
  ///
  /// In en, this message translates to:
  /// **'Parcels to Carry'**
  String get availableParcels;

  /// No description provided for @noTripsFound.
  ///
  /// In en, this message translates to:
  /// **'No trips currently available.'**
  String get noTripsFound;

  /// No description provided for @noParcelsFound.
  ///
  /// In en, this message translates to:
  /// **'No parcels currently available.'**
  String get noParcelsFound;

  /// No description provided for @statusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get statusOpen;

  /// No description provided for @statusMatched.
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get statusMatched;

  /// No description provided for @statusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get statusInTransit;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusDisputed.
  ///
  /// In en, this message translates to:
  /// **'Disputed'**
  String get statusDisputed;

  /// No description provided for @statusFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get statusFull;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @matchingTrips.
  ///
  /// In en, this message translates to:
  /// **'Matching Travellers'**
  String get matchingTrips;

  /// No description provided for @matchingParcels.
  ///
  /// In en, this message translates to:
  /// **'Compatible Parcels'**
  String get matchingParcels;

  /// No description provided for @noMatchingTrips.
  ///
  /// In en, this message translates to:
  /// **'No compatible trips found for this parcel deadline and route.'**
  String get noMatchingTrips;

  /// No description provided for @noMatchingParcels.
  ///
  /// In en, this message translates to:
  /// **'No compatible parcels waiting for this corridor.'**
  String get noMatchingParcels;

  /// No description provided for @noCarryAlert.
  ///
  /// In en, this message translates to:
  /// **'Traveller will NOT carry: '**
  String get noCarryAlert;

  /// No description provided for @viewMatches.
  ///
  /// In en, this message translates to:
  /// **'Find Matches'**
  String get viewMatches;

  /// No description provided for @makeOffer.
  ///
  /// In en, this message translates to:
  /// **'Make an Offer'**
  String get makeOffer;

  /// No description provided for @counterOffer.
  ///
  /// In en, this message translates to:
  /// **'Counter-Offer'**
  String get counterOffer;

  /// No description provided for @acceptOffer.
  ///
  /// In en, this message translates to:
  /// **'Accept Offer'**
  String get acceptOffer;

  /// No description provided for @rejectOffer.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get rejectOffer;

  /// No description provided for @offerPrice.
  ///
  /// In en, this message translates to:
  /// **'Proposed Price (BDT)'**
  String get offerPrice;

  /// No description provided for @offerStatusPendingYou.
  ///
  /// In en, this message translates to:
  /// **'Action Needed: Respond to Offer'**
  String get offerStatusPendingYou;

  /// No description provided for @offerStatusPendingOther.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Response'**
  String get offerStatusPendingOther;

  /// No description provided for @offerStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Deal Agreed!'**
  String get offerStatusAccepted;

  /// No description provided for @offerStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get offerStatusRejected;

  /// No description provided for @offerAcceptedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Offer accepted! Deal is now agreed.'**
  String get offerAcceptedSuccess;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get chatInputHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @dealAgreedBadge.
  ///
  /// In en, this message translates to:
  /// **'Agreed Deal'**
  String get dealAgreedBadge;

  /// No description provided for @deliveryTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery Tracking'**
  String get deliveryTrackingTitle;

  /// No description provided for @deliveryStepMatched.
  ///
  /// In en, this message translates to:
  /// **'Matched & Agreed'**
  String get deliveryStepMatched;

  /// No description provided for @deliveryStepInTransit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get deliveryStepInTransit;

  /// No description provided for @deliveryStepDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get deliveryStepDelivered;

  /// No description provided for @deliveryPickedUpAt.
  ///
  /// In en, this message translates to:
  /// **'Picked up at'**
  String get deliveryPickedUpAt;

  /// No description provided for @deliveryCompletedAt.
  ///
  /// In en, this message translates to:
  /// **'Handover completed at'**
  String get deliveryCompletedAt;

  /// No description provided for @deliveryAwaitingPickup.
  ///
  /// In en, this message translates to:
  /// **'Awaiting pickup from sender'**
  String get deliveryAwaitingPickup;

  /// No description provided for @deliveryPendingHandover.
  ///
  /// In en, this message translates to:
  /// **'Awaiting delivery to recipient'**
  String get deliveryPendingHandover;

  /// No description provided for @disputeRaisedTitle.
  ///
  /// In en, this message translates to:
  /// **'Dispute Raised'**
  String get disputeRaisedTitle;

  /// No description provided for @pickupHandoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Parcel Pickup'**
  String get pickupHandoverTitle;

  /// No description provided for @pickupPhotoProofLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup Proof Photo'**
  String get pickupPhotoProofLabel;

  /// No description provided for @pickupPhotoCaptured.
  ///
  /// In en, this message translates to:
  /// **'Handover Proof Attached'**
  String get pickupPhotoCaptured;

  /// No description provided for @pickupCheckCondition.
  ///
  /// In en, this message translates to:
  /// **'Inspected parcel condition (no external tears or seal tampering)'**
  String get pickupCheckCondition;

  /// No description provided for @pickupCheckNoLeaks.
  ///
  /// In en, this message translates to:
  /// **'Verified package contains no prohibited or leaking items'**
  String get pickupCheckNoLeaks;

  /// No description provided for @pickupNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Optional condition notes'**
  String get pickupNotesHint;

  /// No description provided for @confirmPickupAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm Pickup Handover'**
  String get confirmPickupAction;

  /// No description provided for @recipientHandoverPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipient Delivery PIN'**
  String get recipientHandoverPinLabel;

  /// No description provided for @recipientPinSecurityNotice.
  ///
  /// In en, this message translates to:
  /// **'Share this 4-digit PIN with the recipient. The traveller must enter it to verify delivery upon arrival.'**
  String get recipientPinSecurityNotice;

  /// No description provided for @completeDeliveryAction.
  ///
  /// In en, this message translates to:
  /// **'Complete Delivery Handover'**
  String get completeDeliveryAction;

  /// No description provided for @verifyDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Delivery Handover'**
  String get verifyDeliveryTitle;

  /// No description provided for @verifyDeliveryHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit verification code provided by the recipient to confirm delivery completion.'**
  String get verifyDeliveryHint;

  /// No description provided for @verifyAndComplete.
  ///
  /// In en, this message translates to:
  /// **'Verify & Complete'**
  String get verifyAndComplete;

  /// No description provided for @reportDisputeTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Dispute / Issue'**
  String get reportDisputeTitle;

  /// No description provided for @reportDisputeHint.
  ///
  /// In en, this message translates to:
  /// **'Report any package damage, missing items, or handover failure to resolve with support.'**
  String get reportDisputeHint;

  /// No description provided for @reportDisputeAction.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue / Dispute'**
  String get reportDisputeAction;

  /// No description provided for @trackDelivery.
  ///
  /// In en, this message translates to:
  /// **'Track Delivery'**
  String get trackDelivery;

  /// No description provided for @walletDemoBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo Wallet'**
  String get walletDemoBalanceTitle;

  /// No description provided for @walletAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get walletAvailableBalance;

  /// No description provided for @walletEscrowHold.
  ///
  /// In en, this message translates to:
  /// **'In Escrow (Held)'**
  String get walletEscrowHold;

  /// No description provided for @walletTopUpAction.
  ///
  /// In en, this message translates to:
  /// **'Top Up Demo Balance'**
  String get walletTopUpAction;

  /// No description provided for @walletTopUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Demo Funds'**
  String get walletTopUpTitle;

  /// No description provided for @walletTopUpNotice.
  ///
  /// In en, this message translates to:
  /// **'This is simulated demo money for Bangladesh university project evaluation. No real payment gateway or funds are used.'**
  String get walletTopUpNotice;

  /// No description provided for @walletAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Deposit Amount (BDT)'**
  String get walletAmountLabel;

  /// No description provided for @walletLedgerAction.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get walletLedgerAction;

  /// No description provided for @walletLedgerTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet Transaction History'**
  String get walletLedgerTitle;

  /// No description provided for @walletNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet.'**
  String get walletNoTransactions;

  /// No description provided for @reviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ratings & Reviews'**
  String get reviewsTitle;

  /// No description provided for @reviewsRateUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate & Review Partner'**
  String get reviewsRateUserTitle;

  /// No description provided for @reviewsRatingFor.
  ///
  /// In en, this message translates to:
  /// **'Rating for'**
  String get reviewsRatingFor;

  /// No description provided for @reviewsCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Share your experience with this delivery...'**
  String get reviewsCommentHint;

  /// No description provided for @reviewsSubmitAction.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get reviewsSubmitAction;

  /// No description provided for @reviewsNoReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet. Complete your first delivery to earn ratings!'**
  String get reviewsNoReviews;

  /// No description provided for @adminDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboardTitle;

  /// No description provided for @adminOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Platform Metrics & Health'**
  String get adminOverviewTitle;

  /// No description provided for @adminTotalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get adminTotalUsers;

  /// No description provided for @adminTotalTrips.
  ///
  /// In en, this message translates to:
  /// **'Active Trips'**
  String get adminTotalTrips;

  /// No description provided for @adminActiveDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Active In-Transit'**
  String get adminActiveDeliveries;

  /// No description provided for @adminTotalVolume.
  ///
  /// In en, this message translates to:
  /// **'Total Handover Volume'**
  String get adminTotalVolume;

  /// No description provided for @adminDisputeQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Dispute Escalations'**
  String get adminDisputeQueueTitle;

  /// No description provided for @adminNoOpenDisputes.
  ///
  /// In en, this message translates to:
  /// **'All disputes resolved. No escalations pending.'**
  String get adminNoOpenDisputes;

  /// No description provided for @adminDisputeReason.
  ///
  /// In en, this message translates to:
  /// **'Dispute Reason'**
  String get adminDisputeReason;

  /// No description provided for @adminRefundSenderAction.
  ///
  /// In en, this message translates to:
  /// **'Refund Sender'**
  String get adminRefundSenderAction;

  /// No description provided for @adminPayoutTravellerAction.
  ///
  /// In en, this message translates to:
  /// **'Payout Traveller'**
  String get adminPayoutTravellerAction;

  /// No description provided for @quickActionTravelling.
  ///
  /// In en, this message translates to:
  /// **'I am travelling'**
  String get quickActionTravelling;

  /// No description provided for @quickActionSending.
  ///
  /// In en, this message translates to:
  /// **'I need to send'**
  String get quickActionSending;

  /// No description provided for @verifiedPeerBadge.
  ///
  /// In en, this message translates to:
  /// **'Verified Peer'**
  String get verifiedPeerBadge;

  /// No description provided for @adminDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Metrics & Dispute Oversight'**
  String get adminDashboardSubtitle;

  /// No description provided for @enterPriceError.
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get enterPriceError;

  /// No description provided for @priceMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Must be > 0 BDT'**
  String get priceMustBePositive;

  /// No description provided for @chatEmptyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Start the negotiation or arrange handover details.'**
  String get chatEmptyPrompt;

  /// No description provided for @verifyConditionChecklistPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please verify parcel condition checklist before pickup'**
  String get verifyConditionChecklistPrompt;

  /// No description provided for @defaultPickupInspectedNote.
  ///
  /// In en, this message translates to:
  /// **'Inspected and collected in good condition.'**
  String get defaultPickupInspectedNote;

  /// No description provided for @disputeReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please describe the issue or dispute'**
  String get disputeReasonRequired;

  /// No description provided for @disputeReasonExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Package damaged or recipient unreachable'**
  String get disputeReasonExampleHint;

  /// No description provided for @authTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to CorridorShare'**
  String get authTitle;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Peer-to-peer intercity shipping across Bangladesh'**
  String get authSubtitle;

  /// No description provided for @tabPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get tabPhone;

  /// No description provided for @tabEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get tabEmail;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get emailInvalid;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter password (min 6 characters)'**
  String get passwordHint;

  /// No description provided for @passwordInvalid.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordInvalid;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Tanvir Ahmed'**
  String get nameHint;

  /// No description provided for @nameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name.'**
  String get nameInvalid;

  /// No description provided for @signInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInAction;

  /// No description provided for @signUpAction.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signUpAction;

  /// No description provided for @forgotPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordAction;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Check your inbox.'**
  String get passwordResetSent;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get signOutConfirmMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
