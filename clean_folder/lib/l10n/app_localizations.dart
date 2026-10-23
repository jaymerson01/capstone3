import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fil.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('en'),
    Locale('fil'),
  ];

  /// Title of the Settings row where the resident picks the app's interface language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSettingTitle;

  /// Generic cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Tooltip of a back button.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// Action that opens phone settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get commonSettings;

  /// Fallback name when the resident's name is unknown.
  ///
  /// In en, this message translates to:
  /// **'Resident'**
  String get commonResident;

  /// Bottom navigation tab: home dashboard.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation tab: the resident's reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// Center bottom navigation button that starts a new report (short, uppercase).
  ///
  /// In en, this message translates to:
  /// **'REPORT'**
  String get navReport;

  /// Bottom navigation tab: incident map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// Bottom navigation tab: settings and more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// Subtitle under the RESQ name in the side menu.
  ///
  /// In en, this message translates to:
  /// **'Citizen Portal'**
  String get menuCitizenPortal;

  /// Side menu item: home dashboard.
  ///
  /// In en, this message translates to:
  /// **'User Dashboard'**
  String get menuDashboard;

  /// Side menu item: start a new report.
  ///
  /// In en, this message translates to:
  /// **'Report Incident'**
  String get menuReportIncident;

  /// Side menu item: the resident's reports.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get menuMyReports;

  /// Side menu item: incident map.
  ///
  /// In en, this message translates to:
  /// **'Maps'**
  String get menuMaps;

  /// Side menu item: settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// Side menu item: sign out.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get menuLogout;

  /// Incident category.
  ///
  /// In en, this message translates to:
  /// **'Fire Incident'**
  String get categoryFire;

  /// Incident category.
  ///
  /// In en, this message translates to:
  /// **'Theft / Robbery'**
  String get categoryTheft;

  /// Incident category.
  ///
  /// In en, this message translates to:
  /// **'Medical Emergency'**
  String get categoryMedical;

  /// Incident category.
  ///
  /// In en, this message translates to:
  /// **'Violence / Physical Fight'**
  String get categoryViolence;

  /// Incident category.
  ///
  /// In en, this message translates to:
  /// **'Road Accident'**
  String get categoryRoadAccident;

  /// Incident category.
  ///
  /// In en, this message translates to:
  /// **'Suspicious Activity'**
  String get categorySuspicious;

  /// Incident category.
  ///
  /// In en, this message translates to:
  /// **'Flood / Calamity'**
  String get categoryFlood;

  /// Incident category.
  ///
  /// In en, this message translates to:
  /// **'Lost Item / Missing Person'**
  String get categoryLostOrMissing;

  /// Incident category.
  ///
  /// In en, this message translates to:
  /// **'Noise Complaint'**
  String get categoryNoise;

  /// Incident category for anything not listed.
  ///
  /// In en, this message translates to:
  /// **'Other Emergency'**
  String get categoryOther;

  /// Incident status.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// Incident status.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// Incident status.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// Incident status for fake reports.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get statusSpam;

  /// Incident status.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get statusArchived;

  /// Urgency level.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get urgencyLow;

  /// Urgency level.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get urgencyMedium;

  /// Urgency level.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get urgencyHigh;

  /// Urgency level.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get urgencyCritical;

  /// Something happened less than a minute ago.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeJustNow;

  /// Time since something happened, in minutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 min ago} other{{count} mins ago}}'**
  String timeMinutesAgo(int count);

  /// Time since something happened, in hours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hr ago} other{{count} hrs ago}}'**
  String timeHoursAgo(int count);

  /// Time since something happened, in days.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String timeDaysAgo(int count);

  /// Title of the Report Incident screen.
  ///
  /// In en, this message translates to:
  /// **'Report Incident'**
  String get reportTitle;

  /// Dialog title when leaving an unfinished report.
  ///
  /// In en, this message translates to:
  /// **'Discard Report?'**
  String get reportDiscardTitle;

  /// Dialog text when leaving an unfinished report.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved report details. Are you sure you want to leave? Your emergency report draft will be discarded.'**
  String get reportDiscardMessage;

  /// Button that stays on the report form.
  ///
  /// In en, this message translates to:
  /// **'Keep Editing'**
  String get reportKeepEditing;

  /// Button that throws away the report draft.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get reportDiscard;

  /// Shown after the phone's GPS location was pinned. The address is not translated.
  ///
  /// In en, this message translates to:
  /// **'GPS pinned: {address}'**
  String reportGpsPinned(String address);

  /// Photo from the gallery was uploaded.
  ///
  /// In en, this message translates to:
  /// **'Evidence photo synced to ResQ Cloud!'**
  String get reportEvidencePhotoSynced;

  /// Photo from the camera was uploaded.
  ///
  /// In en, this message translates to:
  /// **'Photo synced to ResQ Cloud!'**
  String get reportPhotoSynced;

  /// Photo upload failed but the photo is kept.
  ///
  /// In en, this message translates to:
  /// **'Cloud upload skipped or timed out. Photo saved locally on device.'**
  String get reportPhotoSavedLocally;

  /// Gallery photo kept on the phone after an upload error.
  ///
  /// In en, this message translates to:
  /// **'Image saved locally (offline): {error}'**
  String reportImageSavedOffline(String error);

  /// Camera photo kept on the phone after an upload error.
  ///
  /// In en, this message translates to:
  /// **'Photo saved locally (offline): {error}'**
  String reportPhotoSavedOffline(String error);

  /// Gallery could not be opened.
  ///
  /// In en, this message translates to:
  /// **'Unable to choose file: {error}'**
  String reportChooseFileFailed(String error);

  /// Camera could not be opened.
  ///
  /// In en, this message translates to:
  /// **'Unable to open camera: {error}'**
  String reportOpenCameraFailed(String error);

  /// Dialog title for a video over 20 MB.
  ///
  /// In en, this message translates to:
  /// **'Video Limit Exceeded'**
  String get reportVideoLimitTitle;

  /// Dialog text for a video over 20 MB.
  ///
  /// In en, this message translates to:
  /// **'Selected video is {sizeMb} MB, which exceeds the emergency limit of 20 MB.\n\nTo prevent network delays during critical emergencies, please trim or record a shorter video clip (under 30 seconds).'**
  String reportVideoLimitMessage(String sizeMb);

  /// Button that closes the video limit dialog.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get reportUnderstood;

  /// Video was uploaded.
  ///
  /// In en, this message translates to:
  /// **'Video evidence synced to ResQ Cloud!'**
  String get reportVideoSynced;

  /// Video upload failed but the video is kept.
  ///
  /// In en, this message translates to:
  /// **'Cloud upload skipped or timed out. Video saved locally on device.'**
  String get reportVideoSavedLocally;

  /// Video kept on the phone after an upload error.
  ///
  /// In en, this message translates to:
  /// **'Video saved locally (offline): {error}'**
  String reportVideoSavedOffline(String error);

  /// Video gallery could not be opened.
  ///
  /// In en, this message translates to:
  /// **'Unable to choose video: {error}'**
  String reportChooseVideoFailed(String error);

  /// Video recording failed.
  ///
  /// In en, this message translates to:
  /// **'Unable to record video: {error}'**
  String reportRecordVideoFailed(String error);

  /// Shown by the phone's fingerprint/face prompt before submitting.
  ///
  /// In en, this message translates to:
  /// **'Verify your biometric identity to submit an official emergency report to Barangay Moonwalk responders.'**
  String get reportBiometricReason;

  /// Biometric check was cancelled.
  ///
  /// In en, this message translates to:
  /// **'Submission cancelled: Identity verification is required.'**
  String get reportBiometricCancelled;

  /// Loading dialog title while submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting Emergency Report'**
  String get reportSubmittingTitle;

  /// Loading dialog text while submitting.
  ///
  /// In en, this message translates to:
  /// **'Dispatching ticket to Barangay Moonwalk responders...'**
  String get reportSubmittingMessage;

  /// Validation: name missing when reporting for someone.
  ///
  /// In en, this message translates to:
  /// **'Please enter the name of the person you are reporting for.'**
  String get reportVictimNameRequired;

  /// Validation: no category.
  ///
  /// In en, this message translates to:
  /// **'Please select an incident category before submitting.'**
  String get reportCategoryRequired;

  /// Validation: 'Other Emergency' chosen without a type.
  ///
  /// In en, this message translates to:
  /// **'Please specify the emergency type (e.g. Fallen Electric Wire, Gas Leak, Sinkhole).'**
  String get reportOtherTypeRequired;

  /// Validation: description missing.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description of the incident'**
  String get reportDescriptionRequired;

  /// Validation: photo/video still uploading.
  ///
  /// In en, this message translates to:
  /// **'Please wait a moment, evidence media is uploading to cloud...'**
  String get reportMediaStillUploading;

  /// Duplicate dialog title: the resident's own report.
  ///
  /// In en, this message translates to:
  /// **'You Already Reported This!'**
  String get reportDuplicateMineTitle;

  /// Duplicate dialog title: someone else's report.
  ///
  /// In en, this message translates to:
  /// **'Similar Incident Nearby!'**
  String get reportDuplicateNearbyTitle;

  /// When the resident's earlier report was filed; time is e.g. 'just now' or '5 mins ago'.
  ///
  /// In en, this message translates to:
  /// **'Your ticket was filed {time}'**
  String reportDuplicateFiled(String time);

  /// Duplicate dialog subtitle.
  ///
  /// In en, this message translates to:
  /// **'Potential duplicate detected within 250m'**
  String get reportDuplicateWithin;

  /// Distance to the similar report.
  ///
  /// In en, this message translates to:
  /// **'{meters} meters from your location'**
  String reportDistanceFromYou(int meters);

  /// Badge on the resident's own report.
  ///
  /// In en, this message translates to:
  /// **'Your Report'**
  String get reportYourReport;

  /// How many residents reported or confirmed the incident.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 citizen affected} other{{count} citizens affected}}'**
  String reportCitizensAffected(int count);

  /// Explains that the resident's own report is still active.
  ///
  /// In en, this message translates to:
  /// **'Your earlier report is active (Status: {status}). Emergency dispatch and Tanods have already been alerted.'**
  String reportDuplicateMineInfo(String status);

  /// Explains why confirming an existing report helps.
  ///
  /// In en, this message translates to:
  /// **'Corroborating (\'Me Too\') the existing report prevents overloading emergency dispatchers and elevates emergency urgency.'**
  String get reportDuplicateCorroborateInfo;

  /// After tapping 'Me Too'.
  ///
  /// In en, this message translates to:
  /// **'You corroborated this incident! Emergency priority escalated.'**
  String get reportCorroborated;

  /// Button to open the resident's own report.
  ///
  /// In en, this message translates to:
  /// **'View My Active Report & Notes'**
  String get reportViewMyReport;

  /// Button to confirm someone else's report.
  ///
  /// In en, this message translates to:
  /// **'Me Too / Corroborate Incident'**
  String get reportMeToo;

  /// Button to file a new report anyway.
  ///
  /// In en, this message translates to:
  /// **'Submit New Separate Report Anyway'**
  String get reportSubmitAnyway;

  /// Button to file a separate report.
  ///
  /// In en, this message translates to:
  /// **'Submit as Separate Incident'**
  String get reportSubmitSeparate;

  /// Photo button while uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading image...'**
  String get reportUploadingImage;

  /// Photo button before a photo is picked.
  ///
  /// In en, this message translates to:
  /// **'No file chosen'**
  String get reportNoFileChosen;

  /// Hidden AI triage feature was switched on.
  ///
  /// In en, this message translates to:
  /// **'AI Triage Enabled'**
  String get reportAiTriageEnabled;

  /// Call confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Call {agency}?'**
  String reportCallAgencyTitle(String agency);

  /// Call confirmation text.
  ///
  /// In en, this message translates to:
  /// **'Dial the official hotline for {agency} ({phone}) now?'**
  String reportCallAgencyMessage(String agency, String phone);

  /// Button that starts the phone call.
  ///
  /// In en, this message translates to:
  /// **'Call Now'**
  String get reportCallNow;

  /// Phone app could not be opened.
  ///
  /// In en, this message translates to:
  /// **'Could not open dialer for {phone}. Please dial manually.'**
  String reportDialerFailed(String phone);

  /// Report submission failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit: {error}'**
  String reportSubmitFailed(String error);

  /// Loading text while AI triage runs.
  ///
  /// In en, this message translates to:
  /// **'Gemini AI is analyzing incident threat levels...'**
  String get reportAiAnalyzing;

  /// AI triage failed.
  ///
  /// In en, this message translates to:
  /// **'AI Evaluation failed. Defaulting to MEDIUM priority.'**
  String get reportAiFailed;

  /// AI triage result dialog title.
  ///
  /// In en, this message translates to:
  /// **'AI Urgency Assessment'**
  String get reportAiAssessmentTitle;

  /// Button after the AI triage result.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Submit'**
  String get reportProceedToSubmit;

  /// Tooltip of the help button.
  ///
  /// In en, this message translates to:
  /// **'Filing Guidelines'**
  String get reportGuidelinesTooltip;

  /// Help button message.
  ///
  /// In en, this message translates to:
  /// **'Ensure accurate data for priority responder handling.'**
  String get reportGuidelinesMessage;

  /// Hotline card title.
  ///
  /// In en, this message translates to:
  /// **'Immediate Threat? Emergency Hotlines'**
  String get reportHotlinesTitle;

  /// Name of the 911 hotline in the call dialog.
  ///
  /// In en, this message translates to:
  /// **'Emergency Hotline'**
  String get reportEmergencyHotline;

  /// Button that calls 911.
  ///
  /// In en, this message translates to:
  /// **'Call 911'**
  String get reportCall911;

  /// Button and name for the barangay desk hotline.
  ///
  /// In en, this message translates to:
  /// **'Barangay Desk'**
  String get reportBarangayDesk;

  /// Form section title.
  ///
  /// In en, this message translates to:
  /// **'Incident Details'**
  String get reportDetailsTitle;

  /// Label above Myself / For Someone.
  ///
  /// In en, this message translates to:
  /// **'Reporting Mode'**
  String get reportModeLabel;

  /// Reporting for yourself, at the scene.
  ///
  /// In en, this message translates to:
  /// **'Myself'**
  String get reportModeMyself;

  /// Reporting on behalf of someone else.
  ///
  /// In en, this message translates to:
  /// **'For Someone'**
  String get reportModeForSomeone;

  /// Title of the on-behalf section.
  ///
  /// In en, this message translates to:
  /// **'Reporting for Someone Else (Off-Site)'**
  String get reportForSomeoneTitle;

  /// Help text of the on-behalf section.
  ///
  /// In en, this message translates to:
  /// **'Enter the affected person\'s details and adjust the map pin below to their exact location in Barangay Moonwalk so responders can locate and assist them.'**
  String get reportForSomeoneHelp;

  /// Field label (required).
  ///
  /// In en, this message translates to:
  /// **'Affected Person\'s Full Name *'**
  String get reportVictimNameLabel;

  /// Field hint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Maria Santos / Lola Elena'**
  String get reportVictimNameHint;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Affected Person\'s Contact Number (Optional)'**
  String get reportVictimPhoneLabel;

  /// Field hint.
  ///
  /// In en, this message translates to:
  /// **'E.g. 0917 123 4567 (for responder verification)'**
  String get reportVictimPhoneHint;

  /// Label above the identity dropdown.
  ///
  /// In en, this message translates to:
  /// **'Complainant Identity'**
  String get reportComplainantLabel;

  /// Report under your own name.
  ///
  /// In en, this message translates to:
  /// **'Self: {name}'**
  String reportComplainantSelf(String name);

  /// Report anonymously.
  ///
  /// In en, this message translates to:
  /// **'Anonymous (Identity Shielded)'**
  String get reportComplainantAnonymous;

  /// Location section title when reporting for someone.
  ///
  /// In en, this message translates to:
  /// **'Victim / Incident Location'**
  String get reportLocationVictimTitle;

  /// Location section title and map pin title.
  ///
  /// In en, this message translates to:
  /// **'Incident Location'**
  String get reportLocationTitle;

  /// Before a location is pinned.
  ///
  /// In en, this message translates to:
  /// **'Location not pinned yet'**
  String get reportLocationNotPinned;

  /// Pinned coordinates (and area name, not translated).
  ///
  /// In en, this message translates to:
  /// **'Coordinates: {coordinates}'**
  String reportCoordinates(String coordinates);

  /// Before a location is pinned.
  ///
  /// In en, this message translates to:
  /// **'Drag pin or tap map below to pin exact house / compound'**
  String get reportPinHint;

  /// Map pin title when reporting for someone.
  ///
  /// In en, this message translates to:
  /// **'Victim Location'**
  String get reportVictimLocation;

  /// Map pin hint.
  ///
  /// In en, this message translates to:
  /// **'Drag to refine location'**
  String get reportDragToRefine;

  /// Map hint while dragging.
  ///
  /// In en, this message translates to:
  /// **'Dragging pin: release to drop at exact location'**
  String get reportDraggingPin;

  /// Map hint while looking up the address.
  ///
  /// In en, this message translates to:
  /// **'Resolving Moonwalk street & sector...'**
  String get reportResolvingSector;

  /// Map hint.
  ///
  /// In en, this message translates to:
  /// **'Touch & drag pin freely, or tap anywhere to place'**
  String get reportMapHint;

  /// GPS button while locating.
  ///
  /// In en, this message translates to:
  /// **'Acquiring GPS & Address...'**
  String get reportAcquiringGps;

  /// GPS button after a location is pinned.
  ///
  /// In en, this message translates to:
  /// **'Use My Phone GPS Fix'**
  String get reportUsePhoneGps;

  /// GPS button before a location is pinned.
  ///
  /// In en, this message translates to:
  /// **'Pin Exact Location with GPS'**
  String get reportPinWithGps;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Nearby Landmark / Specific Details (Optional)'**
  String get reportLandmarkLabel;

  /// Field hint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Near gate 2, corner store, 3rd floor unit'**
  String get reportLandmarkHint;

  /// Label above the category dropdown.
  ///
  /// In en, this message translates to:
  /// **'Incident Category'**
  String get reportCategoryLabel;

  /// Category dropdown placeholder.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get reportSelectCategory;

  /// Field label for 'Other Emergency'.
  ///
  /// In en, this message translates to:
  /// **'Specify Emergency Type'**
  String get reportOtherTypeLabel;

  /// Field hint for 'Other Emergency'.
  ///
  /// In en, this message translates to:
  /// **'e.g., Fallen Electric Wire, Gas Leak, Sinkhole, Oil Spill'**
  String get reportOtherTypeHint;

  /// Field label.
  ///
  /// In en, this message translates to:
  /// **'Incident Description'**
  String get reportDescriptionLabel;

  /// Field hint.
  ///
  /// In en, this message translates to:
  /// **'Provide details of what happened, people involved, etc.'**
  String get reportDescriptionHint;

  /// Video button while uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading video...'**
  String get reportUploadingVideo;

  /// Video button before a video is picked.
  ///
  /// In en, this message translates to:
  /// **'Add Video (≤ 20MB)'**
  String get reportAddVideo;

  /// Video button after a video is picked.
  ///
  /// In en, this message translates to:
  /// **'Change Video'**
  String get reportChangeVideo;

  /// Picked video size is within the limit.
  ///
  /// In en, this message translates to:
  /// **'{sizeMb} MB • Emergency low-latency verified'**
  String reportVideoVerified(String sizeMb);

  /// Main submit button (uppercase).
  ///
  /// In en, this message translates to:
  /// **'SUBMIT INCIDENT REPORT'**
  String get reportSubmitButton;

  /// Fire safety tip.
  ///
  /// In en, this message translates to:
  /// **'Leave the burning area immediately. Do not try to save belongings.'**
  String get reportTipFire1;

  /// Fire safety tip.
  ///
  /// In en, this message translates to:
  /// **'Warn nearby people and help children, elderly, or persons with disability if safe.'**
  String get reportTipFire2;

  /// Fire safety tip.
  ///
  /// In en, this message translates to:
  /// **'Stay low if there is smoke and cover your nose/mouth with cloth.'**
  String get reportTipFire3;

  /// Fire safety tip.
  ///
  /// In en, this message translates to:
  /// **'Do not use elevators. Use stairs or the safest exit route.'**
  String get reportTipFire4;

  /// Fire safety tip.
  ///
  /// In en, this message translates to:
  /// **'Call the fire station or emergency hotline immediately.'**
  String get reportTipFire5;

  /// Fire safety tip.
  ///
  /// In en, this message translates to:
  /// **'Move to an open and safe area away from the fire.'**
  String get reportTipFire6;

  /// Theft safety tip.
  ///
  /// In en, this message translates to:
  /// **'Do not chase or confront the suspect.'**
  String get reportTipTheft1;

  /// Theft safety tip.
  ///
  /// In en, this message translates to:
  /// **'Move to a safe and crowded area immediately.'**
  String get reportTipTheft2;

  /// Theft safety tip.
  ///
  /// In en, this message translates to:
  /// **'Observe details only if safe: clothing, direction, vehicle plate, or appearance.'**
  String get reportTipTheft3;

  /// Theft safety tip.
  ///
  /// In en, this message translates to:
  /// **'Call police or barangay responders right away.'**
  String get reportTipTheft4;

  /// Medical safety tip.
  ///
  /// In en, this message translates to:
  /// **'Call an ambulance or emergency hotline immediately.'**
  String get reportTipMedical1;

  /// Medical safety tip.
  ///
  /// In en, this message translates to:
  /// **'Keep the patient calm and do not move them unless the area is unsafe.'**
  String get reportTipMedical2;

  /// Medical safety tip.
  ///
  /// In en, this message translates to:
  /// **'Check if the person is breathing and responsive.'**
  String get reportTipMedical3;

  /// Road accident safety tip.
  ///
  /// In en, this message translates to:
  /// **'Move to a safe side of the road if you are not injured.'**
  String get reportTipRoad1;

  /// Road accident safety tip.
  ///
  /// In en, this message translates to:
  /// **'Do not move injured persons unless there is immediate danger.'**
  String get reportTipRoad2;

  /// Road accident safety tip.
  ///
  /// In en, this message translates to:
  /// **'Call emergency responders or ambulance immediately.'**
  String get reportTipRoad3;

  /// General safety tip.
  ///
  /// In en, this message translates to:
  /// **'Move to a safe location first.'**
  String get reportTipGeneral1;

  /// General safety tip.
  ///
  /// In en, this message translates to:
  /// **'Call the proper emergency hotline if there is immediate danger.'**
  String get reportTipGeneral2;

  /// General safety tip.
  ///
  /// In en, this message translates to:
  /// **'Avoid touching evidence or confronting involved persons.'**
  String get reportTipGeneral3;

  /// General safety tip.
  ///
  /// In en, this message translates to:
  /// **'Provide accurate details to responders.'**
  String get reportTipGeneral4;

  /// Assessed priority (uppercase).
  ///
  /// In en, this message translates to:
  /// **'CRITICAL PRIORITY'**
  String get reportPriorityCritical;

  /// Priority explanation.
  ///
  /// In en, this message translates to:
  /// **'Immediate responder dispatch triggered.'**
  String get reportPriorityCriticalDetail;

  /// Assessed priority (uppercase).
  ///
  /// In en, this message translates to:
  /// **'HIGH PRIORITY'**
  String get reportPriorityHigh;

  /// Priority explanation.
  ///
  /// In en, this message translates to:
  /// **'Active hazard • Priority response queue.'**
  String get reportPriorityHighDetail;

  /// Assessed priority (uppercase).
  ///
  /// In en, this message translates to:
  /// **'MEDIUM PRIORITY'**
  String get reportPriorityMedium;

  /// Priority explanation.
  ///
  /// In en, this message translates to:
  /// **'Patrol unit notified for investigation.'**
  String get reportPriorityMediumDetail;

  /// Assessed priority (uppercase).
  ///
  /// In en, this message translates to:
  /// **'STANDARD PRIORITY'**
  String get reportPriorityStandard;

  /// Priority explanation.
  ///
  /// In en, this message translates to:
  /// **'Logged for municipal desk review.'**
  String get reportPriorityStandardDetail;

  /// After-submit dialog title.
  ///
  /// In en, this message translates to:
  /// **'Report Dispatched'**
  String get reportDispatchedTitle;

  /// Small badge next to the priority (uppercase).
  ///
  /// In en, this message translates to:
  /// **'ASSESSED'**
  String get reportAssessedBadge;

  /// Title of the safety advice card.
  ///
  /// In en, this message translates to:
  /// **'AI Safety Advice'**
  String get reportAiSafetyAdvice;

  /// While the AI advice loads.
  ///
  /// In en, this message translates to:
  /// **'Generating tailored safety advice for your situation...'**
  String get reportAiGenerating;

  /// Button that closes the after-submit dialog.
  ///
  /// In en, this message translates to:
  /// **'I Understand & Done'**
  String get reportUnderstoodDone;

  /// Generic continue button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// Button that closes an information dialog.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get commonUnderstood;

  /// Dialog title when a guest tries to report.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get welcomeLoginRequiredTitle;

  /// Dialog text when a guest tries to report.
  ///
  /// In en, this message translates to:
  /// **'Please login or create an account first before reporting an incident.'**
  String get welcomeLoginRequiredMessage;

  /// Login button.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// Sign-up button or link.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignUp;

  /// Subtitle under the RESQ logo.
  ///
  /// In en, this message translates to:
  /// **'Smart Barangay Command System'**
  String get welcomeTagline;

  /// Welcome screen tagline.
  ///
  /// In en, this message translates to:
  /// **'Your safety and community trust are our priority'**
  String get welcomeSubtitle;

  /// Welcome screen button.
  ///
  /// In en, this message translates to:
  /// **'Report an Incident'**
  String get welcomeReportIncident;

  /// Welcome screen button.
  ///
  /// In en, this message translates to:
  /// **'Emergency Hotlines'**
  String get welcomeHotlines;

  /// Official footer of the welcome screen.
  ///
  /// In en, this message translates to:
  /// **'🛡️ Republic of the Philippines • Barangay Moonwalk, Parañaque City'**
  String get welcomeFooter;

  /// Email field label.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authEmailLabel;

  /// Email field hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. juan@gmail.com'**
  String get authEmailHint;

  /// Validation: email empty.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get authEmailRequired;

  /// Validation: not a Gmail address.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Gmail address.'**
  String get authEmailInvalid;

  /// Password field label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// Password field hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Moonwalk#01'**
  String get authPasswordHint;

  /// Validation: password empty.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get authPasswordRequired;

  /// Divider above the Google button.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get authOrContinueWith;

  /// Google sign-in button.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// Login screen title (uppercase).
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get loginTitle;

  /// Login screen subtitle.
  ///
  /// In en, this message translates to:
  /// **'Barangay Incident & Public Safety Portal'**
  String get loginSubtitle;

  /// Link that opens password reset.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get loginForgotPassword;

  /// Login button while signing in (uppercase).
  ///
  /// In en, this message translates to:
  /// **'SIGNING IN...'**
  String get loginSigningIn;

  /// Login button (uppercase).
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get loginContinue;

  /// Text before the Sign Up link (keep the trailing space).
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginNoAccount;

  /// Dialog title after signing in.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get loginWelcomeBack;

  /// Dialog text after signing in.
  ///
  /// In en, this message translates to:
  /// **'You have successfully signed in.'**
  String get loginSuccess;

  /// Password reset dialog title.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetTitle;

  /// Password reset dialog text.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email and we\'ll send you an official link to reset your password.'**
  String get resetMessage;

  /// Password reset email field.
  ///
  /// In en, this message translates to:
  /// **'Registered Email'**
  String get resetEmailLabel;

  /// Password reset validation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid registered email address.'**
  String get resetEmailInvalid;

  /// Password reset email sent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent to {email}! Please check your inbox.'**
  String resetSent(String email);

  /// Password reset failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset link: {error}'**
  String resetFailed(String error);

  /// Password reset button.
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get resetSendLink;

  /// Sign-up screen title (uppercase).
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get signUpTitle;

  /// Sign-up screen subtitle.
  ///
  /// In en, this message translates to:
  /// **'Join the RESQ Barangay Safety Network'**
  String get signUpSubtitle;

  /// Name field label.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get signUpNameLabel;

  /// Name field hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get signUpNameHint;

  /// Validation: name empty.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get signUpNameRequired;

  /// Validation: name has invalid characters.
  ///
  /// In en, this message translates to:
  /// **'Letters, spaces, hyphens only (2-50 chars).'**
  String get signUpNameInvalid;

  /// Validation: password has spaces.
  ///
  /// In en, this message translates to:
  /// **'No spaces allowed.'**
  String get signUpPasswordNoSpaces;

  /// Validation: password too weak.
  ///
  /// In en, this message translates to:
  /// **'8-20 chars, 1 upper, 1 lower, 1 num, 1 special.'**
  String get signUpPasswordRules;

  /// Confirm password field label.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get signUpConfirmLabel;

  /// Confirm password field hint.
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get signUpConfirmHint;

  /// Validation: confirm password empty.
  ///
  /// In en, this message translates to:
  /// **'Please confirm password.'**
  String get signUpConfirmRequired;

  /// Validation: passwords differ.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get signUpPasswordMismatch;

  /// Terms checkbox.
  ///
  /// In en, this message translates to:
  /// **'I accept the Terms and Conditions'**
  String get signUpAcceptTerms;

  /// Sign-up button while registering (uppercase).
  ///
  /// In en, this message translates to:
  /// **'REGISTERING...'**
  String get signUpRegistering;

  /// Sign-up button (uppercase).
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get signUpButton;

  /// Link back to login.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get signUpHaveAccount;

  /// Dialog title after sign-up.
  ///
  /// In en, this message translates to:
  /// **'Account Created!'**
  String get signUpCreatedTitle;

  /// Dialog text after sign-up.
  ///
  /// In en, this message translates to:
  /// **'A verification link was sent to {email}. Please verify your email to activate your account.'**
  String signUpVerificationSentTo(String email);

  /// Dialog text after sign-up (email unknown).
  ///
  /// In en, this message translates to:
  /// **'A verification link was sent to your email. Please verify your email to activate your account.'**
  String get signUpVerificationSent;

  /// Button after sign-up.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Verification'**
  String get signUpProceedToVerification;

  /// Used when the email address is unknown.
  ///
  /// In en, this message translates to:
  /// **'your email address'**
  String get verifyYourEmailFallback;

  /// No signed-in user.
  ///
  /// In en, this message translates to:
  /// **'No authenticated session. Please sign in again.'**
  String get verifyNoSession;

  /// Email verified.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully! Welcome to ResQ.'**
  String get verifySuccess;

  /// Email not verified yet.
  ///
  /// In en, this message translates to:
  /// **'Your email is not verified yet. Please open the link sent to your inbox, then tap here again.'**
  String get verifyNotYet;

  /// Short action to resend the email.
  ///
  /// In en, this message translates to:
  /// **'Resend Link'**
  String get verifyResendShort;

  /// Check failed.
  ///
  /// In en, this message translates to:
  /// **'Verification check failed: {error}'**
  String verifyCheckFailed(String error);

  /// Verification email resent.
  ///
  /// In en, this message translates to:
  /// **'A new verification link was sent to {email}!'**
  String verifyLinkResent(String email);

  /// Session expired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get verifySessionExpired;

  /// Resend failed.
  ///
  /// In en, this message translates to:
  /// **'Could not resend email: {error}'**
  String verifyResendFailed(String error);

  /// Hidden capstone demo dialog title.
  ///
  /// In en, this message translates to:
  /// **'Defense Demo Bypass'**
  String get verifyDemoTitle;

  /// Hidden capstone demo dialog text.
  ///
  /// In en, this message translates to:
  /// **'Activate instant verification bypass for Capstone presentation and testing purposes?'**
  String get verifyDemoMessage;

  /// Hidden capstone demo button.
  ///
  /// In en, this message translates to:
  /// **'Bypass for Demo'**
  String get verifyDemoConfirm;

  /// Official badge text.
  ///
  /// In en, this message translates to:
  /// **'Republic of the Philippines • Brgy. Moonwalk'**
  String get verifyBadge;

  /// Verification screen title.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyTitle;

  /// Text above the email address.
  ///
  /// In en, this message translates to:
  /// **'We have sent an official verification link to your registered email address:'**
  String get verifyInstruction;

  /// Status chip.
  ///
  /// In en, this message translates to:
  /// **'Verification Pending'**
  String get verifyPending;

  /// Button while checking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get verifyChecking;

  /// Button to check verification.
  ///
  /// In en, this message translates to:
  /// **'I\'ve Verified My Email'**
  String get verifyDone;

  /// Button to resend the email.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Link'**
  String get verifyResend;

  /// Resend countdown.
  ///
  /// In en, this message translates to:
  /// **'Resend Link in {seconds}s'**
  String verifyResendIn(int seconds);

  /// Sign out link.
  ///
  /// In en, this message translates to:
  /// **'Wrong email address? Sign Out'**
  String get verifyWrongEmail;

  /// Help text at the bottom of the verification screen.
  ///
  /// In en, this message translates to:
  /// **'💡 Tip: If you don\'t see the email, please check your Spam or Junk folder.\n(Defense note: Long-press the civic badge above to activate demo bypass)'**
  String get verifyTip;

  /// Dialog title.
  ///
  /// In en, this message translates to:
  /// **'Invalid Credentials'**
  String get authInvalidTitle;

  /// Dialog text.
  ///
  /// In en, this message translates to:
  /// **'The username or password you entered is incorrect. Please try again.'**
  String get authInvalidMessage;

  /// Dialog button.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get authTryAgain;

  /// Dialog title when an admin uses the resident app.
  ///
  /// In en, this message translates to:
  /// **'Admin Account Detected'**
  String get authAdminTitle;

  /// Dialog text when an admin uses the resident app.
  ///
  /// In en, this message translates to:
  /// **'This account is registered with Barangay Official & Dispatcher privileges.\n\nPlease log in via the ResQ Admin Command Center web portal.'**
  String get authAdminMessage;

  /// Lockout dialog title.
  ///
  /// In en, this message translates to:
  /// **'Account Temporarily Locked'**
  String get authLockedTitle;

  /// Lockout dialog text.
  ///
  /// In en, this message translates to:
  /// **'Too many failed login attempts detected. Your account is locked for security.'**
  String get authLockedMessage;

  /// Under the lockout countdown.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get authLockedRemaining;

  /// Login error.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password. Please try again.'**
  String get authErrorInvalidCredentials;

  /// Login/sign-up error.
  ///
  /// In en, this message translates to:
  /// **'That email address is not valid.'**
  String get authErrorInvalidEmail;

  /// Login error.
  ///
  /// In en, this message translates to:
  /// **'This account has been suspended by the Barangay Moonwalk admin. Please contact the barangay help desk.'**
  String get authErrorAccountSuspended;

  /// Sign-up error.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for this email.'**
  String get authErrorEmailInUse;

  /// Sign-up error.
  ///
  /// In en, this message translates to:
  /// **'That password is too weak.'**
  String get authErrorWeakPassword;

  /// Login error.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a few minutes and try again.'**
  String get authErrorTooManyRequests;

  /// Login/sign-up error.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your connection and try again.'**
  String get authErrorNetwork;

  /// Login error.
  ///
  /// In en, this message translates to:
  /// **'Login request timed out. Please check your internet connection.'**
  String get authErrorTimeout;

  /// Google sign-in error.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In was cancelled.'**
  String get authErrorGoogleCancelled;

  /// Login error.
  ///
  /// In en, this message translates to:
  /// **'Email and password cannot be empty.'**
  String get authErrorEmptyCredentials;

  /// Generic error line.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String commonError(String message);

  /// Fallback when the person reported for has no name.
  ///
  /// In en, this message translates to:
  /// **'Relative'**
  String get commonRelative;

  /// Estimated arrival written by the dispatcher (not translated).
  ///
  /// In en, this message translates to:
  /// **'ETA: {eta}'**
  String commonEta(String eta);

  /// Person the report was filed for.
  ///
  /// In en, this message translates to:
  /// **'For: {name}'**
  String reportForPerson(String name);

  /// Incident status as shown on the home screen.
  ///
  /// In en, this message translates to:
  /// **'Solved'**
  String get statusSolved;

  /// Biometric prompt title.
  ///
  /// In en, this message translates to:
  /// **'Enable Quick Biometric Access'**
  String get dashboardBiometricTitle;

  /// Biometric prompt text.
  ///
  /// In en, this message translates to:
  /// **'Protect your ResQ account and instantly verify emergency incident reports using your Fingerprint or Face ID.'**
  String get dashboardBiometricMessage;

  /// Biometric prompt: skip.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get dashboardMaybeLater;

  /// Shown by the phone's biometric prompt.
  ///
  /// In en, this message translates to:
  /// **'Scan fingerprint or face to enable Biometric Quick Access'**
  String get dashboardBiometricReason;

  /// Biometric turned on.
  ///
  /// In en, this message translates to:
  /// **'Biometric verification enabled for ResQ!'**
  String get dashboardBiometricEnabled;

  /// Biometric prompt: enable.
  ///
  /// In en, this message translates to:
  /// **'Enable Now'**
  String get dashboardEnableNow;

  /// Report card date (month/day/year).
  ///
  /// In en, this message translates to:
  /// **'Reported {date}'**
  String dashboardReportedOn(String date);

  /// Section title (uppercase).
  ///
  /// In en, this message translates to:
  /// **'MY REPORTS STATUS'**
  String get dashboardMyReportsStatus;

  /// Link to all reports.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get dashboardViewAll;

  /// Section subtitle.
  ///
  /// In en, this message translates to:
  /// **'Personal incident filings • Real-time response tracking'**
  String get dashboardMyReportsSubtitle;

  /// Section title.
  ///
  /// In en, this message translates to:
  /// **'Community Incidents'**
  String get dashboardCommunityIncidents;

  /// Number of active community incidents.
  ///
  /// In en, this message translates to:
  /// **'{count} Active'**
  String dashboardActiveCount(int count);

  /// Section subtitle.
  ///
  /// In en, this message translates to:
  /// **'Recent reports from nearby compounds and streets'**
  String get dashboardCommunitySubtitle;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'No active incidents'**
  String get dashboardNoActiveIncidents;

  /// Greeting before the resident's name.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get dashboardWelcomeBack;

  /// Stat card label.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get dashboardStatPending;

  /// Stat card sublabel.
  ///
  /// In en, this message translates to:
  /// **'In Queue'**
  String get dashboardStatInQueue;

  /// Stat card label.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get dashboardStatActive;

  /// Stat card sublabel.
  ///
  /// In en, this message translates to:
  /// **'Responding'**
  String get dashboardStatResponding;

  /// Stat card label.
  ///
  /// In en, this message translates to:
  /// **'Solved'**
  String get dashboardStatSolved;

  /// Stat card sublabel.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get dashboardStatResolved;

  /// Banner title.
  ///
  /// In en, this message translates to:
  /// **'Video Instructions'**
  String get dashboardVideoInstructions;

  /// Banner subtitle.
  ///
  /// In en, this message translates to:
  /// **'How to report safety issues in Moonwalk'**
  String get dashboardVideoSubtitle;

  /// Broadcast title when the admin gave none (uppercase).
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY ADVISORY'**
  String get dashboardAdvisoryFallback;

  /// Broadcast type when the admin gave none.
  ///
  /// In en, this message translates to:
  /// **'Siren Alert'**
  String get dashboardSirenAlertFallback;

  /// Broadcast target when the admin gave none.
  ///
  /// In en, this message translates to:
  /// **'All Sectors'**
  String get dashboardAllSectors;

  /// Broadcast badge (uppercase).
  ///
  /// In en, this message translates to:
  /// **'ACTIVE SIREN'**
  String get dashboardActiveSiren;

  /// Who the broadcast is for (area name not translated).
  ///
  /// In en, this message translates to:
  /// **'Target: {sector}'**
  String dashboardBroadcastTarget(String sector);

  /// Screen title (uppercase).
  ///
  /// In en, this message translates to:
  /// **'MY REPORTS'**
  String get myReportsTitle;

  /// Header title.
  ///
  /// In en, this message translates to:
  /// **'Report Directory'**
  String get myReportsDirectory;

  /// Header subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your submitted incident reports'**
  String get myReportsSubtitle;

  /// Search field hint.
  ///
  /// In en, this message translates to:
  /// **'Search title, location, category...'**
  String get myReportsSearchHint;

  /// Filter chip showing every report (uppercase).
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get myReportsFilterAll;

  /// Reports failed to load.
  ///
  /// In en, this message translates to:
  /// **'Error fetching reports: {error}'**
  String myReportsLoadError(String error);

  /// Empty search result.
  ///
  /// In en, this message translates to:
  /// **'No reports matching \'{query}\' found.'**
  String myReportsNoMatch(String query);

  /// Empty filter result.
  ///
  /// In en, this message translates to:
  /// **'No reports found under this status filter.'**
  String get myReportsNoneForFilter;

  /// Closes the search field.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get myReportsCloseSearch;

  /// Opens the search field.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get myReportsSearch;

  /// Report is uploaded.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get myReportsLive;

  /// Report is only on the phone.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get myReportsLocal;

  /// Sync banner: uploaded.
  ///
  /// In en, this message translates to:
  /// **'Live at Command Center'**
  String get detailLiveTitle;

  /// Sync banner: offline.
  ///
  /// In en, this message translates to:
  /// **'Stored Locally (Pending Cloud Sync)'**
  String get detailLocalTitle;

  /// Sync banner text: uploaded.
  ///
  /// In en, this message translates to:
  /// **'This report has been uploaded to the live cloud database and received by Barangay Moonwalk dispatchers.'**
  String get detailLiveMessage;

  /// Sync banner text: offline.
  ///
  /// In en, this message translates to:
  /// **'This report is safely preserved in your phone\'s offline storage. It will automatically upload to dispatch once connected to the cloud server.'**
  String get detailLocalMessage;

  /// Short incident id.
  ///
  /// In en, this message translates to:
  /// **'Incident ID: #{id}'**
  String detailIncidentId(String id);

  /// Shown instead of an id for offline reports.
  ///
  /// In en, this message translates to:
  /// **'LOCAL'**
  String get detailLocalId;

  /// Hidden name of another resident.
  ///
  /// In en, this message translates to:
  /// **'Protected Resident'**
  String get detailProtectedResident;

  /// Reporter shown as anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous Filing'**
  String get detailAnonymousFiling;

  /// Reporter with no name.
  ///
  /// In en, this message translates to:
  /// **'Registered Resident'**
  String get detailRegisteredResident;

  /// Badge (uppercase).
  ///
  /// In en, this message translates to:
  /// **'REPORTED ON BEHALF'**
  String get detailOnBehalfBadge;

  /// Badge on the resident's own report.
  ///
  /// In en, this message translates to:
  /// **'Your Filing'**
  String get detailYourFiling;

  /// Data Privacy Act badge.
  ///
  /// In en, this message translates to:
  /// **'RA 10173 Protected'**
  String get detailPrivacyBadge;

  /// On-behalf card text: own report.
  ///
  /// In en, this message translates to:
  /// **'You filed this emergency report on behalf of your contact'**
  String get detailOnBehalfOwn;

  /// On-behalf card text: someone else's report.
  ///
  /// In en, this message translates to:
  /// **'Off-Site Citizen Dispatch Filing (Anonymized for Public Safety)'**
  String get detailOnBehalfOther;

  /// Label before the name.
  ///
  /// In en, this message translates to:
  /// **'On-Scene Affected Person / Relative:'**
  String get detailAffectedPerson;

  /// No name given.
  ///
  /// In en, this message translates to:
  /// **'Unspecified Name'**
  String get detailUnspecifiedName;

  /// Label before the phone number.
  ///
  /// In en, this message translates to:
  /// **'Victim Contact Number:'**
  String get detailVictimContact;

  /// Tooltip of the call button.
  ///
  /// In en, this message translates to:
  /// **'Call Victim On-Site'**
  String get detailCallVictim;

  /// Masked phone badge.
  ///
  /// In en, this message translates to:
  /// **'Dispatcher Only'**
  String get detailDispatcherOnly;

  /// Privacy notice.
  ///
  /// In en, this message translates to:
  /// **'In compliance with RA 10173 (Data Privacy Act of 2012), contact info is masked for public viewing and restricted to authorized emergency responders.'**
  String get detailPrivacyNotice;

  /// Location card title.
  ///
  /// In en, this message translates to:
  /// **'Incident Pinned Location'**
  String get detailPinnedLocation;

  /// Coordinates line.
  ///
  /// In en, this message translates to:
  /// **'GPS: {coordinates}'**
  String detailGps(String coordinates);

  /// Description card title.
  ///
  /// In en, this message translates to:
  /// **'Incident Narrative'**
  String get detailNarrative;

  /// Empty description.
  ///
  /// In en, this message translates to:
  /// **'No description provided.'**
  String get detailNoDescription;

  /// Notes card title with notes.
  ///
  /// In en, this message translates to:
  /// **'Dispatcher Remarks & Action Notes'**
  String get detailDispatcherNotes;

  /// Notes card title without notes.
  ///
  /// In en, this message translates to:
  /// **'Command Center Status'**
  String get detailCommandStatus;

  /// ETA box label (uppercase).
  ///
  /// In en, this message translates to:
  /// **'RESPONDERS DISPATCHED • ESTIMATED ARRIVAL'**
  String get detailRespondersDispatched;

  /// No dispatcher notes yet.
  ///
  /// In en, this message translates to:
  /// **'Awaiting dispatcher evaluation. Updates, dispatched emergency units, or field verification remarks will be displayed here in real time.'**
  String get detailAwaitingDispatcher;

  /// Evidence card title.
  ///
  /// In en, this message translates to:
  /// **'Evidence Attachment'**
  String get detailEvidence;

  /// No photo or video.
  ///
  /// In en, this message translates to:
  /// **'No media evidence attached to this report'**
  String get detailNoEvidence;

  /// Evidence card title with media.
  ///
  /// In en, this message translates to:
  /// **'Verified Evidence'**
  String get detailVerifiedEvidence;

  /// Hint on the photo.
  ///
  /// In en, this message translates to:
  /// **'Tap photo to zoom'**
  String get detailTapToZoom;

  /// Video box title.
  ///
  /// In en, this message translates to:
  /// **'Emergency Video Evidence'**
  String get detailVideoEvidence;

  /// Video box subtitle.
  ///
  /// In en, this message translates to:
  /// **'Low-latency clip verified by responder network'**
  String get detailVideoVerified;

  /// Video player title; category already translated.
  ///
  /// In en, this message translates to:
  /// **'{category} Evidence'**
  String detailEvidenceTitle(String category);

  /// Button that plays the video.
  ///
  /// In en, this message translates to:
  /// **'Watch Evidence Video Stream'**
  String get detailWatchVideo;

  /// Photo not uploaded yet.
  ///
  /// In en, this message translates to:
  /// **'Evidence photo stored locally (pending upload)'**
  String get detailPhotoStoredLocally;

  /// Safety tips title.
  ///
  /// In en, this message translates to:
  /// **'Safety Action Protocol'**
  String get timelineSafetyProtocol;

  /// Timeline title.
  ///
  /// In en, this message translates to:
  /// **'Incident Resolution Stage'**
  String get timelineResolutionStage;

  /// ETA from the dispatcher (not translated).
  ///
  /// In en, this message translates to:
  /// **'Responders on the way • Estimated Arrival: {eta}'**
  String timelineRespondersOnTheWay(String eta);

  /// Tracking sheet title.
  ///
  /// In en, this message translates to:
  /// **'Live Incident Tracking'**
  String get trackingTitle;

  /// Tooltip of the close button.
  ///
  /// In en, this message translates to:
  /// **'Close tracking panel'**
  String get trackingClose;

  /// Fire safety step.
  ///
  /// In en, this message translates to:
  /// **'**Evacuate immediately** using the safest and nearest exit.'**
  String get kitFire1;

  /// Fire safety step.
  ///
  /// In en, this message translates to:
  /// **'**Stay low** to the ground to avoid inhaling toxic smoke.'**
  String get kitFire2;

  /// Fire safety step.
  ///
  /// In en, this message translates to:
  /// **'**Do not use elevators**; always use the stairs during a fire.'**
  String get kitFire3;

  /// Fire safety step.
  ///
  /// In en, this message translates to:
  /// **'Once outside, proceed directly to the **Moonwalk Multipurpose Hall** or your designated evacuation area.'**
  String get kitFire4;

  /// Flood safety step.
  ///
  /// In en, this message translates to:
  /// **'**Monitor local water levels** and official Barangay Moonwalk announcements.'**
  String get kitFlood1;

  /// Flood safety step.
  ///
  /// In en, this message translates to:
  /// **'**Turn off main electrical switches** to prevent electrocution and electrical fires.'**
  String get kitFlood2;

  /// Flood safety step.
  ///
  /// In en, this message translates to:
  /// **'**Move critical belongings and your family** to upper floors immediately.'**
  String get kitFlood3;

  /// Flood safety step.
  ///
  /// In en, this message translates to:
  /// **'Prepare your emergency Go-Bag and **evacuate** if ordered by authorities.'**
  String get kitFlood4;

  /// Medical safety step.
  ///
  /// In en, this message translates to:
  /// **'**Check for responsiveness** and ensure the victim is breathing.'**
  String get kitMedical1;

  /// Medical safety step.
  ///
  /// In en, this message translates to:
  /// **'**Clear the immediate surroundings** to give the victim adequate space and air.'**
  String get kitMedical2;

  /// Medical safety step.
  ///
  /// In en, this message translates to:
  /// **'**Do not move the victim** unless they are in immediate, life-threatening danger.'**
  String get kitMedical3;

  /// Medical safety step.
  ///
  /// In en, this message translates to:
  /// **'**Wait calmly** for the Barangay rescue ambulance and professional medical personnel.'**
  String get kitMedical4;

  /// Earthquake safety step.
  ///
  /// In en, this message translates to:
  /// **'Execute **Duck, Cover, and Hold** immediately until the shaking stops.'**
  String get kitEarthquake1;

  /// Earthquake safety step.
  ///
  /// In en, this message translates to:
  /// **'**Stay clear of glass windows**, falling debris, and heavy furniture.'**
  String get kitEarthquake2;

  /// Earthquake safety step.
  ///
  /// In en, this message translates to:
  /// **'**Do not use elevators** during or immediately after the earthquake.'**
  String get kitEarthquake3;

  /// Earthquake safety step.
  ///
  /// In en, this message translates to:
  /// **'Head safely to **open fields** or designated safe zones after the shaking entirely stops.'**
  String get kitEarthquake4;

  /// General safety step.
  ///
  /// In en, this message translates to:
  /// **'**Stay calm** and quickly assess your immediate surroundings.'**
  String get kitGeneral1;

  /// General safety step.
  ///
  /// In en, this message translates to:
  /// **'**Move away** from any immediate danger, hazards, or unstable structures.'**
  String get kitGeneral2;

  /// General safety step.
  ///
  /// In en, this message translates to:
  /// **'**Wait for official instructions** from Barangay Moonwalk security personnel or officials.'**
  String get kitGeneral3;
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
      <String>['en', 'fil'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fil':
      return AppLocalizationsFil();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
