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
  String get reportBlotterTitle => 'Record in the Barangay Blotter';

  @override
  String get reportBlotterHelp =>
      'The barangay will log this report in its official blotter, for disputes or complaints you may need to settle or follow up on later.';

  @override
  String get commonBlotterEntry => 'Blotter Entry';

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

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonUnderstood => 'Understood';

  @override
  String get welcomeLoginRequiredTitle => 'Login Required';

  @override
  String get welcomeLoginRequiredMessage =>
      'Please login or create an account first before reporting an incident.';

  @override
  String get authLogin => 'Login';

  @override
  String get authSignUp => 'Sign Up';

  @override
  String get welcomeTagline => 'Smart Barangay Command System';

  @override
  String get welcomeSubtitle =>
      'Your safety and community trust are our priority';

  @override
  String get welcomeReportIncident => 'Report an Incident';

  @override
  String get welcomeHotlines => 'Emergency Hotlines';

  @override
  String get welcomeFooter =>
      '🛡️ Republic of the Philippines • Barangay Moonwalk, Parañaque City';

  @override
  String get authEmailLabel => 'Email Address';

  @override
  String get authEmailHint => 'e.g. juan@gmail.com';

  @override
  String get authEmailRequired => 'Email is required.';

  @override
  String get authEmailInvalid => 'Enter a valid Gmail address.';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => 'e.g. Moonwalk#01';

  @override
  String get authPasswordRequired => 'Password is required.';

  @override
  String get authOrContinueWith => 'or continue with';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get loginTitle => 'SIGN IN';

  @override
  String get loginSubtitle => 'Barangay Incident & Public Safety Portal';

  @override
  String get loginForgotPassword => 'Forgot Password?';

  @override
  String get loginSigningIn => 'SIGNING IN...';

  @override
  String get loginContinue => 'CONTINUE';

  @override
  String get loginNoAccount => 'Don\'t have an account? ';

  @override
  String get loginWelcomeBack => 'Welcome Back!';

  @override
  String get loginSuccess => 'You have successfully signed in.';

  @override
  String get resetTitle => 'Reset Password';

  @override
  String get resetMessage =>
      'Enter your registered email and we\'ll send you an official link to reset your password.';

  @override
  String get resetEmailLabel => 'Registered Email';

  @override
  String get resetEmailInvalid =>
      'Please enter a valid registered email address.';

  @override
  String resetSent(String email) {
    return 'Password reset email sent to $email! Please check your inbox.';
  }

  @override
  String resetFailed(String error) {
    return 'Failed to send reset link: $error';
  }

  @override
  String get resetSendLink => 'Send Link';

  @override
  String get signUpTitle => 'CREATE ACCOUNT';

  @override
  String get signUpSubtitle => 'Join the RESQ Barangay Safety Network';

  @override
  String get signUpNameLabel => 'Full Name';

  @override
  String get signUpNameHint => 'Enter your full name';

  @override
  String get signUpNameRequired => 'Name is required.';

  @override
  String get signUpNameInvalid => 'Letters, spaces, hyphens only (2-50 chars).';

  @override
  String get signUpPasswordNoSpaces => 'No spaces allowed.';

  @override
  String get signUpPasswordRules =>
      '8-20 chars, 1 upper, 1 lower, 1 num, 1 special.';

  @override
  String get signUpConfirmLabel => 'Confirm Password';

  @override
  String get signUpConfirmHint => 'Repeat your password';

  @override
  String get signUpConfirmRequired => 'Please confirm password.';

  @override
  String get signUpPasswordMismatch => 'Passwords do not match.';

  @override
  String get signUpAcceptTerms => 'I accept the Terms and Conditions';

  @override
  String get signUpRegistering => 'REGISTERING...';

  @override
  String get signUpButton => 'CREATE ACCOUNT';

  @override
  String get signUpHaveAccount => 'Already have an account? Sign In';

  @override
  String get signUpCreatedTitle => 'Account Created!';

  @override
  String signUpVerificationSentTo(String email) {
    return 'A verification link was sent to $email. Please verify your email to activate your account.';
  }

  @override
  String get signUpVerificationSent =>
      'A verification link was sent to your email. Please verify your email to activate your account.';

  @override
  String get signUpProceedToVerification => 'Proceed to Verification';

  @override
  String get verifyYourEmailFallback => 'your email address';

  @override
  String get verifyNoSession =>
      'No authenticated session. Please sign in again.';

  @override
  String get verifySuccess => 'Email verified successfully! Welcome to ResQ.';

  @override
  String get verifyNotYet =>
      'Your email is not verified yet. Please open the link sent to your inbox, then tap here again.';

  @override
  String get verifyResendShort => 'Resend Link';

  @override
  String verifyCheckFailed(String error) {
    return 'Verification check failed: $error';
  }

  @override
  String verifyLinkResent(String email) {
    return 'A new verification link was sent to $email!';
  }

  @override
  String get verifySessionExpired => 'Session expired. Please log in again.';

  @override
  String verifyResendFailed(String error) {
    return 'Could not resend email: $error';
  }

  @override
  String get verifyDemoTitle => 'Defense Demo Bypass';

  @override
  String get verifyDemoMessage =>
      'Activate instant verification bypass for Capstone presentation and testing purposes?';

  @override
  String get verifyDemoConfirm => 'Bypass for Demo';

  @override
  String get verifyBadge => 'Republic of the Philippines • Brgy. Moonwalk';

  @override
  String get verifyTitle => 'Verify Your Email';

  @override
  String get verifyInstruction =>
      'We have sent an official verification link to your registered email address:';

  @override
  String get verifyPending => 'Verification Pending';

  @override
  String get verifyChecking => 'Checking...';

  @override
  String get verifyDone => 'I\'ve Verified My Email';

  @override
  String get verifyResend => 'Resend Verification Link';

  @override
  String verifyResendIn(int seconds) {
    return 'Resend Link in ${seconds}s';
  }

  @override
  String get verifyWrongEmail => 'Wrong email address? Sign Out';

  @override
  String get verifyTip =>
      '💡 Tip: If you don\'t see the email, please check your Spam or Junk folder.\n(Defense note: Long-press the civic badge above to activate demo bypass)';

  @override
  String get authInvalidTitle => 'Invalid Credentials';

  @override
  String get authInvalidMessage =>
      'The username or password you entered is incorrect. Please try again.';

  @override
  String get authTryAgain => 'Try Again';

  @override
  String get authAdminTitle => 'Admin Account Detected';

  @override
  String get authAdminMessage =>
      'This account is registered with Barangay Official & Dispatcher privileges.\n\nPlease log in via the ResQ Admin Command Center web portal.';

  @override
  String get authLockedTitle => 'Account Temporarily Locked';

  @override
  String get authLockedMessage =>
      'Too many failed login attempts detected. Your account is locked for security.';

  @override
  String get authLockedRemaining => 'remaining';

  @override
  String get authErrorInvalidCredentials =>
      'Incorrect email or password. Please try again.';

  @override
  String get authErrorInvalidEmail => 'That email address is not valid.';

  @override
  String get authErrorAccountSuspended =>
      'This account has been suspended by the Barangay Moonwalk admin. Please contact the barangay help desk.';

  @override
  String get authErrorEmailInUse => 'An account already exists for this email.';

  @override
  String get authErrorWeakPassword => 'That password is too weak.';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Please wait a few minutes and try again.';

  @override
  String get authErrorNetwork =>
      'No internet connection. Please check your connection and try again.';

  @override
  String get authErrorTimeout =>
      'Login request timed out. Please check your internet connection.';

  @override
  String get authErrorGoogleCancelled => 'Google Sign-In was cancelled.';

  @override
  String get authErrorEmptyCredentials => 'Email and password cannot be empty.';

  @override
  String commonError(String message) {
    return 'Error: $message';
  }

  @override
  String get commonRelative => 'Relative';

  @override
  String commonEta(String eta) {
    return 'ETA: $eta';
  }

  @override
  String reportForPerson(String name) {
    return 'For: $name';
  }

  @override
  String get statusSolved => 'Solved';

  @override
  String get dashboardBiometricTitle => 'Enable Quick Biometric Access';

  @override
  String get dashboardBiometricMessage =>
      'Protect your ResQ account and instantly verify emergency incident reports using your Fingerprint or Face ID.';

  @override
  String get dashboardMaybeLater => 'Maybe Later';

  @override
  String get dashboardBiometricReason =>
      'Scan fingerprint or face to enable Biometric Quick Access';

  @override
  String get dashboardBiometricEnabled =>
      'Biometric verification enabled for ResQ!';

  @override
  String get dashboardEnableNow => 'Enable Now';

  @override
  String dashboardReportedOn(String date) {
    return 'Reported $date';
  }

  @override
  String get dashboardMyReportsStatus => 'MY REPORTS STATUS';

  @override
  String get dashboardViewAll => 'View All';

  @override
  String get dashboardMyReportsSubtitle =>
      'Personal incident filings • Real-time response tracking';

  @override
  String get dashboardCommunityIncidents => 'Community Incidents';

  @override
  String dashboardActiveCount(int count) {
    return '$count Active';
  }

  @override
  String get dashboardCommunitySubtitle =>
      'Recent reports from nearby compounds and streets';

  @override
  String get dashboardNoActiveIncidents => 'No active incidents';

  @override
  String get dashboardWelcomeBack => 'Welcome back,';

  @override
  String get dashboardStatPending => 'Pending';

  @override
  String get dashboardStatInQueue => 'In Queue';

  @override
  String get dashboardStatActive => 'Active';

  @override
  String get dashboardStatResponding => 'Responding';

  @override
  String get dashboardStatSolved => 'Solved';

  @override
  String get dashboardStatResolved => 'Resolved';

  @override
  String get dashboardVideoInstructions => 'Video Instructions';

  @override
  String get dashboardVideoSubtitle =>
      'How to report safety issues in Moonwalk';

  @override
  String get dashboardAdvisoryFallback => 'EMERGENCY ADVISORY';

  @override
  String get dashboardSirenAlertFallback => 'Siren Alert';

  @override
  String get dashboardAllSectors => 'All Sectors';

  @override
  String get dashboardActiveSiren => 'ACTIVE SIREN';

  @override
  String dashboardBroadcastTarget(String sector) {
    return 'Target: $sector';
  }

  @override
  String get myReportsTitle => 'MY REPORTS';

  @override
  String get myReportsDirectory => 'Report Directory';

  @override
  String get myReportsSubtitle => 'Your submitted incident reports';

  @override
  String get myReportsSearchHint => 'Search title, location, category...';

  @override
  String get myReportsFilterAll => 'ALL';

  @override
  String myReportsLoadError(String error) {
    return 'Error fetching reports: $error';
  }

  @override
  String myReportsNoMatch(String query) {
    return 'No reports matching \'$query\' found.';
  }

  @override
  String get myReportsNoneForFilter =>
      'No reports found under this status filter.';

  @override
  String get myReportsCloseSearch => 'Close';

  @override
  String get myReportsSearch => 'Search';

  @override
  String get myReportsLive => 'Live';

  @override
  String get myReportsLocal => 'Local';

  @override
  String get detailLiveTitle => 'Live at Command Center';

  @override
  String get detailLocalTitle => 'Stored Locally (Pending Cloud Sync)';

  @override
  String get detailLiveMessage =>
      'This report has been uploaded to the live cloud database and received by Barangay Moonwalk dispatchers.';

  @override
  String get detailLocalMessage =>
      'This report is safely preserved in your phone\'s offline storage. It will automatically upload to dispatch once connected to the cloud server.';

  @override
  String detailIncidentId(String id) {
    return 'Incident ID: #$id';
  }

  @override
  String get detailLocalId => 'LOCAL';

  @override
  String get detailProtectedResident => 'Protected Resident';

  @override
  String get detailAnonymousFiling => 'Anonymous Filing';

  @override
  String get detailRegisteredResident => 'Registered Resident';

  @override
  String get detailOnBehalfBadge => 'REPORTED ON BEHALF';

  @override
  String get detailYourFiling => 'Your Filing';

  @override
  String get detailPrivacyBadge => 'RA 10173 Protected';

  @override
  String get detailOnBehalfOwn =>
      'You filed this emergency report on behalf of your contact';

  @override
  String get detailOnBehalfOther =>
      'Off-Site Citizen Dispatch Filing (Anonymized for Public Safety)';

  @override
  String get detailAffectedPerson => 'On-Scene Affected Person / Relative:';

  @override
  String get detailUnspecifiedName => 'Unspecified Name';

  @override
  String get detailVictimContact => 'Victim Contact Number:';

  @override
  String get detailCallVictim => 'Call Victim On-Site';

  @override
  String get detailDispatcherOnly => 'Dispatcher Only';

  @override
  String get detailPrivacyNotice =>
      'In compliance with RA 10173 (Data Privacy Act of 2012), contact info is masked for public viewing and restricted to authorized emergency responders.';

  @override
  String get detailPinnedLocation => 'Incident Pinned Location';

  @override
  String detailGps(String coordinates) {
    return 'GPS: $coordinates';
  }

  @override
  String get detailNarrative => 'Incident Narrative';

  @override
  String get detailNoDescription => 'No description provided.';

  @override
  String get detailDispatcherNotes => 'Dispatcher Remarks & Action Notes';

  @override
  String get detailCommandStatus => 'Command Center Status';

  @override
  String get detailRespondersDispatched =>
      'RESPONDERS DISPATCHED • ESTIMATED ARRIVAL';

  @override
  String get detailAwaitingDispatcher =>
      'Awaiting dispatcher evaluation. Updates, dispatched emergency units, or field verification remarks will be displayed here in real time.';

  @override
  String get detailEvidence => 'Evidence Attachment';

  @override
  String get detailNoEvidence => 'No media evidence attached to this report';

  @override
  String get detailVerifiedEvidence => 'Verified Evidence';

  @override
  String get detailTapToZoom => 'Tap photo to zoom';

  @override
  String get detailVideoEvidence => 'Emergency Video Evidence';

  @override
  String get detailVideoVerified =>
      'Low-latency clip verified by responder network';

  @override
  String detailEvidenceTitle(String category) {
    return '$category Evidence';
  }

  @override
  String get detailWatchVideo => 'Watch Evidence Video Stream';

  @override
  String get detailPhotoStoredLocally =>
      'Evidence photo stored locally (pending upload)';

  @override
  String get timelineSafetyProtocol => 'Safety Action Protocol';

  @override
  String get timelineResolutionStage => 'Incident Resolution Stage';

  @override
  String timelineRespondersOnTheWay(String eta) {
    return 'Responders on the way • Estimated Arrival: $eta';
  }

  @override
  String get trackingTitle => 'Live Incident Tracking';

  @override
  String get trackingClose => 'Close tracking panel';

  @override
  String get kitFire1 =>
      '**Evacuate immediately** using the safest and nearest exit.';

  @override
  String get kitFire2 =>
      '**Stay low** to the ground to avoid inhaling toxic smoke.';

  @override
  String get kitFire3 =>
      '**Do not use elevators**; always use the stairs during a fire.';

  @override
  String get kitFire4 =>
      'Once outside, proceed directly to the **Moonwalk Multipurpose Hall** or your designated evacuation area.';

  @override
  String get kitFlood1 =>
      '**Monitor local water levels** and official Barangay Moonwalk announcements.';

  @override
  String get kitFlood2 =>
      '**Turn off main electrical switches** to prevent electrocution and electrical fires.';

  @override
  String get kitFlood3 =>
      '**Move critical belongings and your family** to upper floors immediately.';

  @override
  String get kitFlood4 =>
      'Prepare your emergency Go-Bag and **evacuate** if ordered by authorities.';

  @override
  String get kitMedical1 =>
      '**Check for responsiveness** and ensure the victim is breathing.';

  @override
  String get kitMedical2 =>
      '**Clear the immediate surroundings** to give the victim adequate space and air.';

  @override
  String get kitMedical3 =>
      '**Do not move the victim** unless they are in immediate, life-threatening danger.';

  @override
  String get kitMedical4 =>
      '**Wait calmly** for the Barangay rescue ambulance and professional medical personnel.';

  @override
  String get kitEarthquake1 =>
      'Execute **Duck, Cover, and Hold** immediately until the shaking stops.';

  @override
  String get kitEarthquake2 =>
      '**Stay clear of glass windows**, falling debris, and heavy furniture.';

  @override
  String get kitEarthquake3 =>
      '**Do not use elevators** during or immediately after the earthquake.';

  @override
  String get kitEarthquake4 =>
      'Head safely to **open fields** or designated safe zones after the shaking entirely stops.';

  @override
  String get kitGeneral1 =>
      '**Stay calm** and quickly assess your immediate surroundings.';

  @override
  String get kitGeneral2 =>
      '**Move away** from any immediate danger, hazards, or unstable structures.';

  @override
  String get kitGeneral3 =>
      '**Wait for official instructions** from Barangay Moonwalk security personnel or officials.';

  @override
  String get commonClose => 'Close';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get commonCallNow => 'Call Now';

  @override
  String get timeShortJustNow => 'Just now';

  @override
  String timeShortMinutes(int count) {
    return '${count}m ago';
  }

  @override
  String timeShortHours(int count) {
    return '${count}h ago';
  }

  @override
  String timeShortDays(int count) {
    return '${count}d ago';
  }

  @override
  String get locationErrorGpsOff =>
      'GPS is turned off. Please swipe down from the top of your screen and turn on Location.';

  @override
  String get locationErrorDenied =>
      'Location permission was denied. Please allow location access.';

  @override
  String get locationErrorDeniedForever =>
      'Location permission is permanently denied. Please enable it in your phone App Settings.';

  @override
  String get locationErrorNoFix =>
      'Could not acquire GPS fix. Please ensure you have GPS turned on and a clear signal.';

  @override
  String get mapsTitle => 'COMMUNITY MAP';

  @override
  String get mapsLive => 'LIVE MAP';

  @override
  String get mapsFilterAll => 'All';

  @override
  String get mapsFilterFire => 'Fire';

  @override
  String get mapsFilterMedical => 'Medical';

  @override
  String get mapsFilterFlood => 'Flood';

  @override
  String get mapsFilterTheft => 'Theft';

  @override
  String get mapsFilterAccident => 'Accident';

  @override
  String get mapsFilterViolence => 'Violence';

  @override
  String get mapsAffectedOriginal =>
      '1 citizen affected (original reporter). Awaiting neighborhood confirmation.';

  @override
  String mapsAffectedWithNeighbors(int total, int neighbors) {
    String _temp0 = intl.Intl.pluralLogic(
      neighbors,
      locale: localeName,
      other: '$neighbors neighbors',
      one: '1 neighbor',
    );
    return '$total citizens affected (original reporter + $_temp0)';
  }

  @override
  String get mapsYouAreAuthor =>
      'You are the author of this report. Tap \'View Details\' to track progress.';

  @override
  String get mapsConfirmationRecorded =>
      'Your confirmation has been recorded! Dispatch alerted.';

  @override
  String get mapsConfirmed => 'Confirmed';

  @override
  String get mapsIWitnessed => 'I witnessed this';

  @override
  String get mapsViewDetails => 'View Details';

  @override
  String get mapsOffline =>
      'You are currently offline. Live incidents cannot be loaded.';

  @override
  String mapsActiveIncidents(int count) {
    return '$count Active Incidents';
  }

  @override
  String get hotlinesConfirmTitle => 'Call Dispatch Line?';

  @override
  String hotlinesConfirmMessage(String title, String number) {
    return 'Are you sure you want to dial the official hotline for $title ($number) now?';
  }

  @override
  String get hotlinesPortal => 'EMERGENCY CALL PORTAL';

  @override
  String get hotlinesGuestNote =>
      'Unauthenticated guest access enabled. Dial emergency responders directly below.';

  @override
  String get hotlinesPolice => 'Police Department Dispatch';

  @override
  String get hotlinesPoliceDesc =>
      'Immediate criminal activity reporting, neighborhood patrols, threat neutralization, and public order enforcement.';

  @override
  String get hotlinesFire => 'Fire Command Station';

  @override
  String get hotlinesFireDesc =>
      'Structural active fire emergencies, hazardous chemical leak containment, and immediate search and rescue ops.';

  @override
  String get hotlinesAmbulance => 'Ambulance Medical Team';

  @override
  String get hotlinesAmbulanceDesc =>
      'Severe medical trauma support, critical emergency patient transport, and emergency responder dispatch.';

  @override
  String get hotlinesBarangay => 'Barangay Desk Center';

  @override
  String get hotlinesBarangayDesc =>
      'Barangay Moonwalk local safety reports, minor community disputes, security desk coordination, and assistance.';

  @override
  String get hotlinesTooltip =>
      'Tap to call directly • Long-press for confirmation';

  @override
  String get hotlinesCall => 'CALL';

  @override
  String get notificationsTitle => 'NOTIFICATIONS';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsEmptyTitle => 'No Notifications Yet';

  @override
  String get notificationsEmptyMessage =>
      'You will be alerted when dispatch updates your reports, neighbors corroborate incidents, or community sirens sound.';

  @override
  String get notificationsViewReport => 'View report →';

  @override
  String get notificationsRemove => 'Remove';

  @override
  String get broadcastDefaultTitle => 'MUNICIPAL EMERGENCY ADVISORY';

  @override
  String get broadcastDefaultType => 'Emergency Siren';

  @override
  String get broadcastDefaultMessage =>
      'Immediate safety precautions are advised by Barangay authorities.';

  @override
  String get broadcastDefaultSource => 'Barangay Command Center';

  @override
  String get broadcastBarrierLabel => 'Emergency Siren Alert';

  @override
  String get broadcastHeader => 'MUNICIPAL EMERGENCY SIREN';

  @override
  String broadcastTargetSector(String sector) {
    return 'Target Sector: $sector';
  }

  @override
  String broadcastOrigin(String source) {
    return 'Origin: $source';
  }

  @override
  String get broadcastAcknowledge => 'ACKNOWLEDGE ALERT';

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get settingsEmergencyServices => 'Emergency Services';

  @override
  String get settingsHotlinesTitle => 'Barangay Emergency Hotlines';

  @override
  String get settingsHotlinesSubtitle =>
      'Police (911), Fire (112), Medical (143) & BDRRMC';

  @override
  String get settingsAccount => 'Account Settings';

  @override
  String get settingsEditProfile => 'Edit Personal Details';

  @override
  String get settingsEditProfileSubtitle =>
      'Full name, mobile number, sector & home address';

  @override
  String get settingsPrivacy => 'Privacy & Account Security';

  @override
  String get settingsPrivacySubtitle =>
      'Update account credentials & view anti-spam security policy';

  @override
  String get settingsPreferences => 'App Preferences';

  @override
  String get settingsTheme => 'App Theme';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsLightMode => 'Light Mode';

  @override
  String get settingsSupport => 'Support & Information';

  @override
  String get settingsAbout => 'About ResQ Community Safety';

  @override
  String get settingsAboutSubtitle =>
      'Platform guidelines, emergency mandates & version';

  @override
  String get settingsAboutBody =>
      'ResQ Community Safety is a civic-tech emergency response platform connecting residents with the Barangay Command Operations Center for rapid incident dispatch, verification, and community resilience.';

  @override
  String get settingsHelpDesk => 'Barangay Help Desk';

  @override
  String get settingsHelpDeskSubtitle =>
      'Contact municipal administrative support team';

  @override
  String get settingsFeedback => 'Submit App Feedback & Bug Report';

  @override
  String get settingsFeedbackSubtitle =>
      'Report issues or suggest platform improvements';

  @override
  String get settingsResidentCitizen => 'Resident Citizen';

  @override
  String get settingsSectorNotSet => 'Sector not set';

  @override
  String get settingsVerifiedResident => 'Verified Resident';

  @override
  String get settingsLogOut => 'Log Out';

  @override
  String get settingsLogOutConfirm =>
      'Are you sure you want to log out of your ResQ resident account?';

  @override
  String get settingsDeleteAccount => 'Delete Account';

  @override
  String get settingsDeleteWarning =>
      'Warning: Deleting your resident account permanently clears all filed report logs and saved profile information. This action is irreversible.';

  @override
  String get settingsDeleteForever => 'Permanently Delete Account';

  @override
  String get settingsNoSession => 'No active resident session found.';

  @override
  String get settingsAccountErased =>
      'Your account and personal data have been permanently erased (RA 10173).';

  @override
  String get settingsRecentLoginRequired =>
      'Security Alert: Account deletion requires recent authentication. Please log out, sign in again, and retry.';

  @override
  String settingsDeleteFailed(String error) {
    return 'Account deletion failed: $error';
  }

  @override
  String settingsDeleteError(String error) {
    return 'Error deleting account: $error';
  }

  @override
  String get settingsHelpDeskTitle => 'Barangay Administrative Help Desk';

  @override
  String get settingsOfficeAddress => 'Office Address';

  @override
  String get settingsServiceHours => 'Public Service Hours';

  @override
  String get settingsServiceHoursValue => 'Monday – Friday: 8:00 AM – 5:00 PM';

  @override
  String get settingsCallOffice => 'Call Office';

  @override
  String get settingsSendEmail => 'Send Email';

  @override
  String get settingsHelpDeskNote =>
      'For immediate life-threatening emergencies (Fire, Police, Medical), please use the Emergency Hotlines or submit an incident report.';

  @override
  String get settingsFeedbackTitle => 'Submit App Feedback';

  @override
  String get settingsFeedbackIntro =>
      'Help us improve ResQ for Barangay Moonwalk. Your feedback is sent directly to the development team.';

  @override
  String get settingsFeedbackCategory => 'FEEDBACK CATEGORY';

  @override
  String get feedbackGeneral => 'General Feedback';

  @override
  String get feedbackBug => 'Bug Report';

  @override
  String get feedbackFeature => 'Feature Suggestion';

  @override
  String get settingsFeedbackHint =>
      'Describe your feedback, suggestion, or bug encounter...';

  @override
  String get settingsFeedbackEmpty =>
      'Please write a short description before submitting.';

  @override
  String get settingsFeedbackThanks =>
      'Thank you! Your feedback has been submitted to the technical team.';

  @override
  String settingsFeedbackFailed(String error) {
    return 'Failed to submit feedback: $error';
  }

  @override
  String get profileTitle => 'Edit Profile';

  @override
  String get profilePhotoTitle => 'Profile Photo';

  @override
  String get profileTakePhoto => 'Take Photo with Camera';

  @override
  String get profileChooseGallery => 'Choose from Gallery';

  @override
  String get profileUpdated => 'Profile details updated successfully!';

  @override
  String profileUpdateFailed(String error) {
    return 'Failed to update profile: $error';
  }

  @override
  String get profileCredentials => 'Personal Credentials';

  @override
  String get profileNameRequired => 'Please enter your full name';

  @override
  String get profileEmailLabel => 'Email Address (Account ID)';

  @override
  String get profileEmailHelper => 'Primary login credential cannot be changed';

  @override
  String get profilePhoneLabel => 'Mobile Phone Number';

  @override
  String get profilePhoneInvalid => 'Please enter a valid mobile number';

  @override
  String get profileJurisdiction => 'Barangay Jurisdiction & Address';

  @override
  String get profileAreaLabel => 'Barangay Area / Sector';

  @override
  String get profileAddressLabel => 'Residential Address / House Details';

  @override
  String get profileAddressRequired => 'Please enter your residential address';

  @override
  String get profileEmergencyContact => 'Emergency Contact Fallback';

  @override
  String get profileContactName => 'Emergency Contact Person';

  @override
  String get profileContactNameRequired =>
      'Please provide an emergency contact person';

  @override
  String get profileContactNumber => 'Emergency Contact Number';

  @override
  String get profileContactNumberInvalid =>
      'Please provide an emergency contact phone number';

  @override
  String get profileSave => 'SAVE PROFILE CHANGES';

  @override
  String get privacyTitle => 'Privacy & Security';

  @override
  String get privacyCredentials => 'Credentials & Access';

  @override
  String get privacyChangePassword => 'Change Account Password';

  @override
  String get privacyChangePasswordSubtitle =>
      'Update password for resident account credentials';

  @override
  String get privacyPolicyTitle => 'Civic Security & Anti-Spam Policy';

  @override
  String get privacyBiometric => 'Biometric Verification';

  @override
  String get privacyEnforced => 'ENFORCED';

  @override
  String get privacyBiometricOn =>
      'Biometric confirmation (fingerprint or face authentication) is enforced by Barangay Moonwalk municipal policy when submitting emergency reports to deter false alarms and prank filings.';

  @override
  String get privacyBiometricOff =>
      'Hardware biometrics not detected on this device. Device PIN or secure credential confirmation will serve as anti-spam verification.';

  @override
  String get passwordDialogTitle => 'Change Password';

  @override
  String get passwordDialogIntro =>
      'Please enter your current password followed by your new password.';

  @override
  String get passwordCurrentRequired => 'Please enter your current password';

  @override
  String get passwordCurrentLabel => 'Current Password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordNewLabel => 'New Password';

  @override
  String get passwordMismatchShort => 'Passwords do not match';

  @override
  String get passwordConfirmLabel => 'Confirm New Password';

  @override
  String get passwordNoEmail => 'No registered email found for this account.';

  @override
  String passwordResetSent(String email) {
    return 'Password reset link sent to $email. Please check your email inbox to reset your password.';
  }

  @override
  String passwordResetFailed(String error) {
    return 'Failed to send reset email: $error';
  }

  @override
  String get passwordForgot =>
      'Forgot current password? Send reset link to email';

  @override
  String passwordChangeFailed(String error) {
    return 'Password change failed: $error';
  }

  @override
  String get passwordUpdated => 'Password updated successfully!';

  @override
  String get passwordUpdateButton => 'UPDATE PASSWORD';

  @override
  String get viewerVideoTitle => 'Evidence Video Stream';

  @override
  String get viewerOpenExternalTab => 'Open in External Tab';

  @override
  String get viewerVideoError => 'Unable to stream video in-app';

  @override
  String get viewerOpenExternalPlayer => 'Open in External Player';

  @override
  String get viewerBuffering => 'Buffering live evidence stream...';

  @override
  String get viewerReplay => 'Replay Video';

  @override
  String get viewerPhotoTitle => 'Photo Evidence Viewer';

  @override
  String get viewerResetZoom => 'Reset Zoom';

  @override
  String get viewerOpenFullImage => 'Open Full Image in New Tab';

  @override
  String get viewerImageError => 'Unable to display image in-app';

  @override
  String get viewerZoomHint =>
      'Pinch, scroll, or drag to pan and zoom photo evidence';

  @override
  String get aiTriggerActivated =>
      'Intelligent Triage Engine Activated: Handshake Sequence Engaged.';

  @override
  String get chatResetTitle => 'Reset Conversation?';

  @override
  String get chatResetMessage =>
      'Are you sure you want to clear your chat history with ResQ Civil Defense Assistant? This will start a fresh session.';

  @override
  String get chatReset => 'Reset';

  @override
  String get chatTitle => 'Civil Defense Assistant';

  @override
  String get chatStatus => 'Barangay Moonwalk • Active';

  @override
  String get chatQuickGuides => 'Quick Civil Defense Guides';

  @override
  String get chatSenderAi => 'RESQ GEMINI AI';

  @override
  String get chatSenderOfficer => 'CIVIL DEFENSE OFFICER';

  @override
  String get chatHotlineDialers => 'Immediate Hotline Dialers:';

  @override
  String get chatAllHotlines => 'All Hotlines';

  @override
  String get chatHint => 'Ask safety or first-aid guide...';

  @override
  String get videoPlay => 'Play';

  @override
  String get videoPause => 'Pause';

  @override
  String get reportTakePhoto => 'Take a photo';

  @override
  String get reportRecordVideo => 'Record a video';
}
