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
