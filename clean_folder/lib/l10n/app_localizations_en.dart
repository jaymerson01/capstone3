// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageSettingTitle => 'Language';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonBack => 'Back';

  @override
  String get commonSettings => 'Settings';

  @override
  String get commonResident => 'Resident';

  @override
  String get navHome => 'Home';

  @override
  String get navReports => 'Reports';

  @override
  String get navReport => 'REPORT';

  @override
  String get navMap => 'Map';

  @override
  String get navMore => 'More';

  @override
  String get menuCitizenPortal => 'Citizen Portal';

  @override
  String get menuDashboard => 'User Dashboard';

  @override
  String get menuReportIncident => 'Report Incident';

  @override
  String get menuMyReports => 'My Reports';

  @override
  String get menuMaps => 'Maps';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuLogout => 'Logout';

  @override
  String get categoryFire => 'Fire Incident';

  @override
  String get categoryTheft => 'Theft / Robbery';

  @override
  String get categoryMedical => 'Medical Emergency';

  @override
  String get categoryViolence => 'Violence / Physical Fight';

  @override
  String get categoryRoadAccident => 'Road Accident';

  @override
  String get categorySuspicious => 'Suspicious Activity';

  @override
  String get categoryFlood => 'Flood / Calamity';

  @override
  String get categoryLostOrMissing => 'Lost Item / Missing Person';

  @override
  String get categoryNoise => 'Noise Complaint';

  @override
  String get categoryOther => 'Other Emergency';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get statusSpam => 'Spam';

  @override
  String get statusArchived => 'Archived';

  @override
  String get urgencyLow => 'Low';

  @override
  String get urgencyMedium => 'Medium';

  @override
  String get urgencyHigh => 'High';

  @override
  String get urgencyCritical => 'Critical';

  @override
  String get timeJustNow => 'just now';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mins ago',
      one: '1 min ago',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hrs ago',
      one: '1 hr ago',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get reportTitle => 'Report Incident';

  @override
  String get reportDiscardTitle => 'Discard Report?';

  @override
  String get reportDiscardMessage =>
      'You have unsaved report details. Are you sure you want to leave? Your emergency report draft will be discarded.';

  @override
  String get reportKeepEditing => 'Keep Editing';

  @override
  String get reportDiscard => 'Discard';

  @override
  String reportGpsPinned(String address) {
    return 'GPS pinned: $address';
  }

  @override
  String get reportEvidencePhotoSynced =>
      'Evidence photo synced to ResQ Cloud!';

  @override
  String get reportPhotoSynced => 'Photo synced to ResQ Cloud!';

  @override
  String get reportPhotoSavedLocally =>
      'Cloud upload skipped or timed out. Photo saved locally on device.';

  @override
  String reportImageSavedOffline(String error) {
    return 'Image saved locally (offline): $error';
  }

  @override
  String reportPhotoSavedOffline(String error) {
    return 'Photo saved locally (offline): $error';
  }

  @override
  String reportChooseFileFailed(String error) {
    return 'Unable to choose file: $error';
  }

  @override
  String reportOpenCameraFailed(String error) {
    return 'Unable to open camera: $error';
  }

  @override
  String get reportVideoLimitTitle => 'Video Limit Exceeded';

  @override
  String reportVideoLimitMessage(String sizeMb) {
    return 'Selected video is $sizeMb MB, which exceeds the emergency limit of 20 MB.\n\nTo prevent network delays during critical emergencies, please trim or record a shorter video clip (under 30 seconds).';
  }

  @override
  String get reportUnderstood => 'Understood';

  @override
  String get reportVideoSynced => 'Video evidence synced to ResQ Cloud!';

  @override
  String get reportVideoSavedLocally =>
      'Cloud upload skipped or timed out. Video saved locally on device.';

  @override
  String reportVideoSavedOffline(String error) {
    return 'Video saved locally (offline): $error';
  }

  @override
  String reportChooseVideoFailed(String error) {
    return 'Unable to choose video: $error';
  }

  @override
  String reportRecordVideoFailed(String error) {
    return 'Unable to record video: $error';
  }

  @override
  String get reportBiometricReason =>
      'Verify your biometric identity to submit an official emergency report to Barangay Moonwalk responders.';

  @override
  String get reportBiometricCancelled =>
      'Submission cancelled: Identity verification is required.';

  @override
  String get reportSubmittingTitle => 'Submitting Emergency Report';

  @override
  String get reportSubmittingMessage =>
      'Dispatching ticket to Barangay Moonwalk responders...';

  @override
  String get reportVictimNameRequired =>
      'Please enter the name of the person you are reporting for.';

  @override
  String get reportCategoryRequired =>
      'Please select an incident category before submitting.';

  @override
  String get reportOtherTypeRequired =>
      'Please specify the emergency type (e.g. Fallen Electric Wire, Gas Leak, Sinkhole).';

  @override
  String get reportDescriptionRequired =>
      'Please enter a description of the incident';

  @override
  String get reportMediaStillUploading =>
      'Please wait a moment, evidence media is uploading to cloud...';

  @override
  String get reportDuplicateMineTitle => 'You Already Reported This!';

  @override
  String get reportDuplicateNearbyTitle => 'Similar Incident Nearby!';

  @override
  String reportDuplicateFiled(String time) {
    return 'Your ticket was filed $time';
  }

  @override
  String get reportDuplicateWithin =>
      'Potential duplicate detected within 250m';

  @override
  String reportDistanceFromYou(int meters) {
    return '$meters meters from your location';
  }

  @override
  String get reportYourReport => 'Your Report';

  @override
  String reportCitizensAffected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count citizens affected',
      one: '1 citizen affected',
    );
    return '$_temp0';
  }

  @override
  String reportDuplicateMineInfo(String status) {
    return 'Your earlier report is active (Status: $status). Emergency dispatch and Tanods have already been alerted.';
  }

  @override
  String get reportDuplicateCorroborateInfo =>
      'Corroborating (\'Me Too\') the existing report prevents overloading emergency dispatchers and elevates emergency urgency.';

  @override
  String get reportCorroborated =>
      'You corroborated this incident! Emergency priority escalated.';

  @override
  String get reportViewMyReport => 'View My Active Report & Notes';

  @override
  String get reportMeToo => 'Me Too / Corroborate Incident';

  @override
  String get reportSubmitAnyway => 'Submit New Separate Report Anyway';

  @override
  String get reportSubmitSeparate => 'Submit as Separate Incident';

  @override
  String get reportUploadingImage => 'Uploading image...';

  @override
  String get reportNoFileChosen => 'No file chosen';

  @override
  String get reportAiTriageEnabled => 'AI Triage Enabled';

  @override
  String reportCallAgencyTitle(String agency) {
    return 'Call $agency?';
  }

  @override
  String reportCallAgencyMessage(String agency, String phone) {
    return 'Dial the official hotline for $agency ($phone) now?';
  }

  @override
  String get reportCallNow => 'Call Now';

  @override
  String reportDialerFailed(String phone) {
    return 'Could not open dialer for $phone. Please dial manually.';
  }

  @override
  String reportSubmitFailed(String error) {
    return 'Failed to submit: $error';
  }

  @override
  String get reportAiAnalyzing =>
      'Gemini AI is analyzing incident threat levels...';

  @override
  String get reportAiFailed =>
      'AI Evaluation failed. Defaulting to MEDIUM priority.';

  @override
  String get reportAiAssessmentTitle => 'AI Urgency Assessment';

  @override
  String get reportProceedToSubmit => 'Proceed to Submit';

  @override
  String get reportGuidelinesTooltip => 'Filing Guidelines';

  @override
  String get reportGuidelinesMessage =>
      'Ensure accurate data for priority responder handling.';

  @override
  String get reportHotlinesTitle => 'Immediate Threat? Emergency Hotlines';

  @override
  String get reportEmergencyHotline => 'Emergency Hotline';

  @override
  String get reportCall911 => 'Call 911';

  @override
  String get reportBarangayDesk => 'Barangay Desk';

  @override
  String get reportDetailsTitle => 'Incident Details';

  @override
  String get reportModeLabel => 'Reporting Mode';

  @override
  String get reportModeMyself => 'Myself';

  @override
  String get reportModeForSomeone => 'For Someone';

  @override
  String get reportForSomeoneTitle => 'Reporting for Someone Else (Off-Site)';

  @override
  String get reportForSomeoneHelp =>
      'Enter the affected person\'s details and adjust the map pin below to their exact location in Barangay Moonwalk so responders can locate and assist them.';

  @override
  String get reportVictimNameLabel => 'Affected Person\'s Full Name *';

  @override
  String get reportVictimNameHint => 'E.g. Maria Santos / Lola Elena';

  @override
  String get reportVictimPhoneLabel =>
      'Affected Person\'s Contact Number (Optional)';

  @override
  String get reportVictimPhoneHint =>
      'E.g. 0917 123 4567 (for responder verification)';

  @override
  String get reportComplainantLabel => 'Complainant Identity';

  @override
  String reportComplainantSelf(String name) {
    return 'Self: $name';
  }

  @override
  String get reportComplainantAnonymous => 'Anonymous (Identity Shielded)';

  @override
  String get reportLocationVictimTitle => 'Victim / Incident Location';

  @override
  String get reportLocationTitle => 'Incident Location';

  @override
  String get reportLocationNotPinned => 'Location not pinned yet';

  @override
  String reportCoordinates(String coordinates) {
    return 'Coordinates: $coordinates';
  }

  @override
  String get reportPinHint =>
      'Drag pin or tap map below to pin exact house / compound';

  @override
  String get reportVictimLocation => 'Victim Location';

  @override
  String get reportDragToRefine => 'Drag to refine location';

  @override
  String get reportDraggingPin =>
      'Dragging pin: release to drop at exact location';

  @override
  String get reportResolvingSector => 'Resolving Moonwalk street & sector...';

  @override
  String get reportMapHint =>
      'Touch & drag pin freely, or tap anywhere to place';

  @override
  String get reportAcquiringGps => 'Acquiring GPS & Address...';

  @override
  String get reportUsePhoneGps => 'Use My Phone GPS Fix';

  @override
  String get reportPinWithGps => 'Pin Exact Location with GPS';

  @override
  String get reportLandmarkLabel =>
      'Nearby Landmark / Specific Details (Optional)';

  @override
  String get reportLandmarkHint =>
      'E.g. Near gate 2, corner store, 3rd floor unit';

  @override
  String get reportCategoryLabel => 'Incident Category';

  @override
  String get reportSelectCategory => 'Select Category';

  @override
  String get reportOtherTypeLabel => 'Specify Emergency Type';

  @override
  String get reportOtherTypeHint =>
      'e.g., Fallen Electric Wire, Gas Leak, Sinkhole, Oil Spill';

  @override
  String get reportDescriptionLabel => 'Incident Description';

  @override
  String get reportDescriptionHint =>
      'Provide details of what happened, people involved, etc.';

  @override
  String get reportUploadingVideo => 'Uploading video...';

  @override
  String get reportAddVideo => 'Add Video (≤ 20MB)';

  @override
  String get reportChangeVideo => 'Change Video';

  @override
  String reportVideoVerified(String sizeMb) {
    return '$sizeMb MB • Emergency low-latency verified';
  }

  @override
  String get reportSubmitButton => 'SUBMIT INCIDENT REPORT';

  @override
  String get reportTipFire1 =>
      'Leave the burning area immediately. Do not try to save belongings.';

  @override
  String get reportTipFire2 =>
      'Warn nearby people and help children, elderly, or persons with disability if safe.';

  @override
  String get reportTipFire3 =>
      'Stay low if there is smoke and cover your nose/mouth with cloth.';

  @override
  String get reportTipFire4 =>
      'Do not use elevators. Use stairs or the safest exit route.';

  @override
  String get reportTipFire5 =>
      'Call the fire station or emergency hotline immediately.';

  @override
  String get reportTipFire6 =>
      'Move to an open and safe area away from the fire.';

  @override
  String get reportTipTheft1 => 'Do not chase or confront the suspect.';

  @override
  String get reportTipTheft2 => 'Move to a safe and crowded area immediately.';

  @override
  String get reportTipTheft3 =>
      'Observe details only if safe: clothing, direction, vehicle plate, or appearance.';

  @override
  String get reportTipTheft4 =>
      'Call police or barangay responders right away.';

  @override
  String get reportTipMedical1 =>
      'Call an ambulance or emergency hotline immediately.';

  @override
  String get reportTipMedical2 =>
      'Keep the patient calm and do not move them unless the area is unsafe.';

  @override
  String get reportTipMedical3 =>
      'Check if the person is breathing and responsive.';

  @override
  String get reportTipRoad1 =>
      'Move to a safe side of the road if you are not injured.';

  @override
  String get reportTipRoad2 =>
      'Do not move injured persons unless there is immediate danger.';

  @override
  String get reportTipRoad3 =>
      'Call emergency responders or ambulance immediately.';

  @override
  String get reportTipGeneral1 => 'Move to a safe location first.';

  @override
  String get reportTipGeneral2 =>
      'Call the proper emergency hotline if there is immediate danger.';

  @override
  String get reportTipGeneral3 =>
      'Avoid touching evidence or confronting involved persons.';

  @override
  String get reportTipGeneral4 => 'Provide accurate details to responders.';

  @override
  String get reportPriorityCritical => 'CRITICAL PRIORITY';

  @override
  String get reportPriorityCriticalDetail =>
      'Immediate responder dispatch triggered.';

  @override
  String get reportPriorityHigh => 'HIGH PRIORITY';

  @override
  String get reportPriorityHighDetail =>
      'Active hazard • Priority response queue.';

  @override
  String get reportPriorityMedium => 'MEDIUM PRIORITY';

  @override
  String get reportPriorityMediumDetail =>
      'Patrol unit notified for investigation.';

  @override
  String get reportPriorityStandard => 'STANDARD PRIORITY';

  @override
  String get reportPriorityStandardDetail =>
      'Logged for municipal desk review.';

  @override
  String get reportDispatchedTitle => 'Report Dispatched';

  @override
  String get reportAssessedBadge => 'ASSESSED';

  @override
  String get reportAiSafetyAdvice => 'AI Safety Advice';

  @override
  String get reportAiGenerating =>
      'Generating tailored safety advice for your situation...';

  @override
  String get reportUnderstoodDone => 'I Understand & Done';
}
