// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Filipino Pilipino (`fil`).
class AppLocalizationsFil extends AppLocalizations {
  AppLocalizationsFil([String locale = 'fil']) : super(locale);

  @override
  String get languageSettingTitle => 'Wika';

  @override
  String get commonCancel => 'Kanselahin';

  @override
  String get commonBack => 'Bumalik';

  @override
  String get commonSettings => 'Mga Setting';

  @override
  String get commonResident => 'Residente';

  @override
  String get navHome => 'Home';

  @override
  String get navReports => 'Mga Ulat';

  @override
  String get navReport => 'IULAT';

  @override
  String get navMap => 'Mapa';

  @override
  String get navMore => 'Iba pa';

  @override
  String get menuCitizenPortal => 'Portal ng Mamamayan';

  @override
  String get menuDashboard => 'Dashboard';

  @override
  String get menuReportIncident => 'Mag-ulat ng Insidente';

  @override
  String get menuMyReports => 'Aking mga Ulat';

  @override
  String get menuMaps => 'Mapa';

  @override
  String get menuSettings => 'Mga Setting';

  @override
  String get menuLogout => 'Mag-logout';

  @override
  String get categoryFire => 'Sunog';

  @override
  String get categoryTheft => 'Pagnanakaw / Holdap';

  @override
  String get categoryMedical => 'Medikal na Emergency';

  @override
  String get categoryViolence => 'Karahasan / Away';

  @override
  String get categoryRoadAccident => 'Aksidente sa Daan';

  @override
  String get categorySuspicious => 'Kahina-hinalang Gawain';

  @override
  String get categoryFlood => 'Baha / Kalamidad';

  @override
  String get categoryLostOrMissing => 'Nawawalang Gamit / Tao';

  @override
  String get categoryNoise => 'Reklamo sa Ingay';

  @override
  String get categoryOther => 'Ibang Emergency';

  @override
  String get statusPending => 'Nakabinbin';

  @override
  String get statusInProgress => 'Inaaksyunan';

  @override
  String get statusResolved => 'Naresolba na';

  @override
  String get statusSpam => 'Spam';

  @override
  String get statusArchived => 'Naka-archive';

  @override
  String get urgencyLow => 'Mababa';

  @override
  String get urgencyMedium => 'Katamtaman';

  @override
  String get urgencyHigh => 'Mataas';

  @override
  String get urgencyCritical => 'Kritikal';

  @override
  String get timeJustNow => 'ngayon lang';

  @override
  String timeMinutesAgo(int count) {
    return '$count minuto ang nakalipas';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count oras ang nakalipas';
  }

  @override
  String timeDaysAgo(int count) {
    return '$count araw ang nakalipas';
  }

  @override
  String get reportTitle => 'Mag-ulat ng Insidente';

  @override
  String get reportDiscardTitle => 'Itapon ang Ulat?';

  @override
  String get reportDiscardMessage =>
      'May mga detalye ng ulat na hindi pa naisusumite. Sigurado ka bang aalis ka? Mabubura ang draft ng iyong emergency report.';

  @override
  String get reportKeepEditing => 'Ituloy ang Pag-edit';

  @override
  String get reportDiscard => 'Itapon';

  @override
  String reportGpsPinned(String address) {
    return 'Naka-pin sa GPS: $address';
  }

  @override
  String get reportEvidencePhotoSynced =>
      'Na-upload na sa ResQ Cloud ang larawang ebidensya!';

  @override
  String get reportPhotoSynced => 'Na-upload na sa ResQ Cloud ang larawan!';

  @override
  String get reportPhotoSavedLocally =>
      'Hindi na-upload sa cloud. Naka-save muna ang larawan sa device.';

  @override
  String reportImageSavedOffline(String error) {
    return 'Naka-save sa device ang larawan (offline): $error';
  }

  @override
  String reportPhotoSavedOffline(String error) {
    return 'Naka-save sa device ang larawan (offline): $error';
  }

  @override
  String reportChooseFileFailed(String error) {
    return 'Hindi makapili ng file: $error';
  }

  @override
  String reportOpenCameraFailed(String error) {
    return 'Hindi mabuksan ang camera: $error';
  }

  @override
  String get reportVideoLimitTitle => 'Lampas sa Limitasyon ang Video';

  @override
  String reportVideoLimitMessage(String sizeMb) {
    return 'Ang napiling video ay $sizeMb MB, lampas sa 20 MB na limitasyon para sa emergency.\n\nPara hindi bumagal ang network sa oras ng emergency, paikliin ang video o mag-record ng mas maikli (hindi lalampas sa 30 segundo).';
  }

  @override
  String get reportUnderstood => 'Naiintindihan ko';

  @override
  String get reportVideoSynced =>
      'Na-upload na sa ResQ Cloud ang video na ebidensya!';

  @override
  String get reportVideoSavedLocally =>
      'Hindi na-upload sa cloud. Naka-save muna ang video sa device.';

  @override
  String reportVideoSavedOffline(String error) {
    return 'Naka-save sa device ang video (offline): $error';
  }

  @override
  String reportChooseVideoFailed(String error) {
    return 'Hindi makapili ng video: $error';
  }

  @override
  String reportRecordVideoFailed(String error) {
    return 'Hindi makapag-record ng video: $error';
  }

  @override
  String get reportBiometricReason =>
      'I-verify ang iyong biometric na pagkakakilanlan para maisumite ang opisyal na emergency report sa mga responder ng Barangay Moonwalk.';

  @override
  String get reportBiometricCancelled =>
      'Hindi naisumite: Kailangan ang pag-verify ng pagkakakilanlan.';

  @override
  String get reportSubmittingTitle => 'Isinusumite ang Emergency Report';

  @override
  String get reportSubmittingMessage =>
      'Ipinapadala ang ticket sa mga responder ng Barangay Moonwalk...';

  @override
  String get reportVictimNameRequired =>
      'Ilagay ang pangalan ng taong iniuulat mo.';

  @override
  String get reportCategoryRequired =>
      'Pumili muna ng kategorya ng insidente bago magsumite.';

  @override
  String get reportOtherTypeRequired =>
      'Ilagay kung anong uri ng emergency (hal. Bumagsak na Kawad ng Kuryente, Tagas ng Gas, Sinkhole).';

  @override
  String get reportDescriptionRequired => 'Ilarawan ang nangyaring insidente';

  @override
  String get reportMediaStillUploading =>
      'Sandali lang, ina-upload pa sa cloud ang ebidensya...';

  @override
  String get reportDuplicateMineTitle => 'Naiulat Mo na Ito!';

  @override
  String get reportDuplicateNearbyTitle =>
      'May Katulad na Insidente sa Malapit!';

  @override
  String reportDuplicateFiled(String time) {
    return 'Naisumite ang iyong ticket $time';
  }

  @override
  String get reportDuplicateWithin =>
      'Posibleng doble: may katulad na ulat sa loob ng 250m';

  @override
  String reportDistanceFromYou(int meters) {
    return '$meters metro mula sa iyong lokasyon';
  }

  @override
  String get reportYourReport => 'Ulat Mo';

  @override
  String reportCitizensAffected(int count) {
    return '$count mamamayan ang apektado';
  }

  @override
  String reportDuplicateMineInfo(String status) {
    return 'Aktibo pa ang naunang ulat mo (Status: $status). Naabisuhan na ang emergency dispatch at mga Tanod.';
  }

  @override
  String get reportDuplicateCorroborateInfo =>
      'Ang pagkumpirma (\'Me Too\') sa kasalukuyang ulat ay nakakaiwas sa pagdagsa ng ulat sa mga dispatcher at nagpapataas ng priyoridad ng emergency.';

  @override
  String get reportCorroborated =>
      'Kinumpirma mo ang insidenteng ito! Itinaas ang priyoridad ng emergency.';

  @override
  String get reportViewMyReport => 'Tingnan ang Aking Aktibong Ulat at Tala';

  @override
  String get reportMeToo => 'Me Too / Kumpirmahin ang Insidente';

  @override
  String get reportSubmitAnyway => 'Magsumite Pa Rin ng Hiwalay na Ulat';

  @override
  String get reportSubmitSeparate => 'Isumite bilang Hiwalay na Insidente';

  @override
  String get reportUploadingImage => 'Ina-upload ang larawan...';

  @override
  String get reportNoFileChosen => 'Walang napiling file';

  @override
  String get reportAiTriageEnabled => 'Naka-on ang AI Triage';

  @override
  String reportCallAgencyTitle(String agency) {
    return 'Tawagan ang $agency?';
  }

  @override
  String reportCallAgencyMessage(String agency, String phone) {
    return 'Tawagan ngayon ang opisyal na hotline ng $agency ($phone)?';
  }

  @override
  String get reportCallNow => 'Tumawag Ngayon';

  @override
  String reportDialerFailed(String phone) {
    return 'Hindi mabuksan ang dialer para sa $phone. Paki-dial nang mano-mano.';
  }

  @override
  String reportSubmitFailed(String error) {
    return 'Hindi naisumite: $error';
  }

  @override
  String get reportAiAnalyzing =>
      'Sinusuri ng Gemini AI ang antas ng panganib ng insidente...';

  @override
  String get reportAiFailed =>
      'Hindi natapos ang pagsusuri ng AI. Gagamitin ang MEDIUM na priyoridad.';

  @override
  String get reportAiAssessmentTitle => 'Pagtatasa ng AI sa Pagkaapurahan';

  @override
  String get reportProceedToSubmit => 'Ituloy ang Pagsumite';

  @override
  String get reportGuidelinesTooltip => 'Gabay sa Pag-uulat';

  @override
  String get reportGuidelinesMessage =>
      'Siguraduhing tama ang detalye para mabilis na maaksyunan ng mga responder.';

  @override
  String get reportHotlinesTitle =>
      'May Agarang Panganib? Mga Emergency Hotline';

  @override
  String get reportEmergencyHotline => 'Emergency Hotline';

  @override
  String get reportCall911 => 'Tumawag sa 911';

  @override
  String get reportBarangayDesk => 'Barangay Desk';

  @override
  String get reportDetailsTitle => 'Detalye ng Insidente';

  @override
  String get reportModeLabel => 'Paraan ng Pag-uulat';

  @override
  String get reportModeMyself => 'Ako Mismo';

  @override
  String get reportModeForSomeone => 'Para sa Iba';

  @override
  String get reportForSomeoneTitle =>
      'Nag-uulat para sa Ibang Tao (Wala sa Lugar)';

  @override
  String get reportForSomeoneHelp =>
      'Ilagay ang detalye ng apektadong tao at iayos ang pin sa mapa sa ibaba sa eksaktong lokasyon nila sa Barangay Moonwalk para mahanap at matulungan sila ng mga responder.';

  @override
  String get reportVictimNameLabel => 'Buong Pangalan ng Apektadong Tao *';

  @override
  String get reportVictimNameHint => 'Hal. Maria Santos / Lola Elena';

  @override
  String get reportVictimPhoneLabel =>
      'Contact Number ng Apektadong Tao (Opsyonal)';

  @override
  String get reportVictimPhoneHint =>
      'Hal. 0917 123 4567 (para ma-verify ng responder)';

  @override
  String get reportComplainantLabel => 'Pagkakakilanlan ng Nagrereklamo';

  @override
  String reportComplainantSelf(String name) {
    return 'Ako: $name';
  }

  @override
  String get reportComplainantAnonymous =>
      'Anonymous (Nakatago ang Pagkakakilanlan)';

  @override
  String get reportLocationVictimTitle => 'Lokasyon ng Biktima / Insidente';

  @override
  String get reportLocationTitle => 'Lokasyon ng Insidente';

  @override
  String get reportLocationNotPinned => 'Hindi pa naka-pin ang lokasyon';

  @override
  String reportCoordinates(String coordinates) {
    return 'Coordinates: $coordinates';
  }

  @override
  String get reportPinHint =>
      'I-drag ang pin o i-tap ang mapa sa ibaba para i-pin ang eksaktong bahay / compound';

  @override
  String get reportVictimLocation => 'Lokasyon ng Biktima';

  @override
  String get reportDragToRefine => 'I-drag para ayusin ang lokasyon';

  @override
  String get reportDraggingPin =>
      'Dina-drag ang pin: bitawan sa eksaktong lokasyon';

  @override
  String get reportResolvingSector =>
      'Hinahanap ang kalye at sektor sa Moonwalk...';

  @override
  String get reportMapHint => 'I-drag ang pin, o i-tap kahit saan para ilagay';

  @override
  String get reportAcquiringGps => 'Kinukuha ang GPS at address...';

  @override
  String get reportUsePhoneGps => 'Gamitin ang GPS ng Phone Ko';

  @override
  String get reportPinWithGps => 'I-pin ang Eksaktong Lokasyon gamit ang GPS';

  @override
  String get reportLandmarkLabel =>
      'Malapit na Palatandaan / Detalye (Opsyonal)';

  @override
  String get reportLandmarkHint =>
      'Hal. Malapit sa gate 2, tindahan sa kanto, unit sa 3rd floor';

  @override
  String get reportCategoryLabel => 'Kategorya ng Insidente';

  @override
  String get reportSelectCategory => 'Pumili ng Kategorya';

  @override
  String get reportOtherTypeLabel => 'Tukuyin ang Uri ng Emergency';

  @override
  String get reportOtherTypeHint =>
      'hal. Bumagsak na Kawad ng Kuryente, Tagas ng Gas, Sinkhole, Tagas ng Langis';

  @override
  String get reportDescriptionLabel => 'Paglalarawan ng Insidente';

  @override
  String get reportDescriptionHint =>
      'Ilarawan ang nangyari, ang mga taong sangkot, at iba pa.';

  @override
  String get reportUploadingVideo => 'Ina-upload ang video...';

  @override
  String get reportAddVideo => 'Magdagdag ng Video (≤ 20MB)';

  @override
  String get reportChangeVideo => 'Palitan ang Video';

  @override
  String reportVideoVerified(String sizeMb) {
    return '$sizeMb MB • Pasado sa limitasyon para sa emergency';
  }

  @override
  String get reportSubmitButton => 'ISUMITE ANG ULAT';

  @override
  String get reportTipFire1 =>
      'Lumayo agad sa nasusunog na lugar. Huwag nang balikan ang mga gamit.';

  @override
  String get reportTipFire2 =>
      'Babalaan ang mga tao sa paligid at tulungan ang mga bata, matatanda, o may kapansanan kung ligtas.';

  @override
  String get reportTipFire3 =>
      'Yumuko kung may usok at takpan ng tela ang ilong at bibig.';

  @override
  String get reportTipFire4 =>
      'Huwag gumamit ng elevator. Gumamit ng hagdan o ng pinakaligtas na labasan.';

  @override
  String get reportTipFire5 =>
      'Tumawag agad sa bumbero o sa emergency hotline.';

  @override
  String get reportTipFire6 =>
      'Pumunta sa bukas at ligtas na lugar na malayo sa sunog.';

  @override
  String get reportTipTheft1 => 'Huwag habulin o harapin ang suspek.';

  @override
  String get reportTipTheft2 => 'Pumunta agad sa ligtas at mataong lugar.';

  @override
  String get reportTipTheft3 =>
      'Tandaan ang detalye kung ligtas lang: damit, direksyon, plaka ng sasakyan, o itsura.';

  @override
  String get reportTipTheft4 =>
      'Tumawag agad sa pulis o sa mga responder ng barangay.';

  @override
  String get reportTipMedical1 =>
      'Tumawag agad ng ambulansya o sa emergency hotline.';

  @override
  String get reportTipMedical2 =>
      'Panatilihing kalmado ang pasyente at huwag siyang galawin maliban kung delikado ang lugar.';

  @override
  String get reportTipMedical3 =>
      'Tingnan kung humihinga at sumasagot ang tao.';

  @override
  String get reportTipRoad1 =>
      'Pumunta sa ligtas na gilid ng daan kung hindi ka nasaktan.';

  @override
  String get reportTipRoad2 =>
      'Huwag galawin ang mga nasaktan maliban kung may agarang panganib.';

  @override
  String get reportTipRoad3 =>
      'Tumawag agad sa mga emergency responder o ng ambulansya.';

  @override
  String get reportTipGeneral1 => 'Pumunta muna sa ligtas na lugar.';

  @override
  String get reportTipGeneral2 =>
      'Tumawag sa tamang emergency hotline kung may agarang panganib.';

  @override
  String get reportTipGeneral3 =>
      'Iwasang hawakan ang ebidensya o harapin ang mga sangkot.';

  @override
  String get reportTipGeneral4 => 'Ibigay ang tamang detalye sa mga responder.';

  @override
  String get reportPriorityCritical => 'KRITIKAL NA PRIYORIDAD';

  @override
  String get reportPriorityCriticalDetail =>
      'Agad na ipinadala ang mga responder.';

  @override
  String get reportPriorityHigh => 'MATAAS NA PRIYORIDAD';

  @override
  String get reportPriorityHighDetail =>
      'Aktibong panganib • Uunahin sa pagresponde.';

  @override
  String get reportPriorityMedium => 'KATAMTAMANG PRIYORIDAD';

  @override
  String get reportPriorityMediumDetail =>
      'Naabisuhan ang patrol unit para mag-imbestiga.';

  @override
  String get reportPriorityStandard => 'KARANIWANG PRIYORIDAD';

  @override
  String get reportPriorityStandardDetail => 'Naitala para suriin ng desk.';

  @override
  String get reportDispatchedTitle => 'Naipadala na ang Ulat';

  @override
  String get reportAssessedBadge => 'NASURI';

  @override
  String get reportAiSafetyAdvice => 'Payo sa Kaligtasan mula sa AI';

  @override
  String get reportAiGenerating =>
      'Gumagawa ng payo sa kaligtasan para sa iyong sitwasyon...';

  @override
  String get reportUnderstoodDone => 'Naiintindihan Ko, Tapos Na';

  @override
  String get commonContinue => 'Magpatuloy';

  @override
  String get commonUnderstood => 'Naiintindihan ko';

  @override
  String get welcomeLoginRequiredTitle => 'Kailangang Mag-login';

  @override
  String get welcomeLoginRequiredMessage =>
      'Mag-login o gumawa muna ng account bago mag-ulat ng insidente.';

  @override
  String get authLogin => 'Mag-login';

  @override
  String get authSignUp => 'Mag-sign Up';

  @override
  String get welcomeTagline => 'Matalinong Command System ng Barangay';

  @override
  String get welcomeSubtitle =>
      'Ang inyong kaligtasan at tiwala ng komunidad ang aming prayoridad';

  @override
  String get welcomeReportIncident => 'Mag-ulat ng Insidente';

  @override
  String get welcomeHotlines => 'Mga Emergency Hotline';

  @override
  String get welcomeFooter =>
      '🛡️ Republika ng Pilipinas • Barangay Moonwalk, Lungsod ng Parañaque';

  @override
  String get authEmailLabel => 'Email Address';

  @override
  String get authEmailHint => 'hal. juan@gmail.com';

  @override
  String get authEmailRequired => 'Kailangan ang email.';

  @override
  String get authEmailInvalid => 'Maglagay ng tamang Gmail address.';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => 'hal. Moonwalk#01';

  @override
  String get authPasswordRequired => 'Kailangan ang password.';

  @override
  String get authOrContinueWith => 'o magpatuloy gamit ang';

  @override
  String get authContinueWithGoogle => 'Magpatuloy gamit ang Google';

  @override
  String get loginTitle => 'MAG-SIGN IN';

  @override
  String get loginSubtitle =>
      'Portal ng Barangay para sa Insidente at Kaligtasan';

  @override
  String get loginForgotPassword => 'Nakalimutan ang Password?';

  @override
  String get loginSigningIn => 'NAGSA-SIGN IN...';

  @override
  String get loginContinue => 'MAGPATULOY';

  @override
  String get loginNoAccount => 'Wala ka pang account? ';

  @override
  String get loginWelcomeBack => 'Maligayang Pagbabalik!';

  @override
  String get loginSuccess => 'Matagumpay kang naka-sign in.';

  @override
  String get resetTitle => 'I-reset ang Password';

  @override
  String get resetMessage =>
      'Ilagay ang iyong rehistradong email at magpapadala kami ng opisyal na link para i-reset ang iyong password.';

  @override
  String get resetEmailLabel => 'Rehistradong Email';

  @override
  String get resetEmailInvalid =>
      'Maglagay ng tamang rehistradong email address.';

  @override
  String resetSent(String email) {
    return 'Naipadala na ang email para i-reset ang password sa $email! Tingnan ang iyong inbox.';
  }

  @override
  String resetFailed(String error) {
    return 'Hindi naipadala ang reset link: $error';
  }

  @override
  String get resetSendLink => 'Ipadala ang Link';

  @override
  String get signUpTitle => 'GUMAWA NG ACCOUNT';

  @override
  String get signUpSubtitle => 'Sumali sa RESQ Barangay Safety Network';

  @override
  String get signUpNameLabel => 'Buong Pangalan';

  @override
  String get signUpNameHint => 'Ilagay ang iyong buong pangalan';

  @override
  String get signUpNameRequired => 'Kailangan ang pangalan.';

  @override
  String get signUpNameInvalid =>
      'Letra, espasyo, at gitling lang (2-50 karakter).';

  @override
  String get signUpPasswordNoSpaces => 'Bawal ang espasyo.';

  @override
  String get signUpPasswordRules =>
      '8-20 karakter: 1 malaking titik, 1 maliit, 1 numero, 1 simbolo.';

  @override
  String get signUpConfirmLabel => 'Kumpirmahin ang Password';

  @override
  String get signUpConfirmHint => 'Ulitin ang iyong password';

  @override
  String get signUpConfirmRequired => 'Pakikumpirma ang password.';

  @override
  String get signUpPasswordMismatch => 'Hindi magkapareho ang mga password.';

  @override
  String get signUpAcceptTerms =>
      'Tinatanggap ko ang Mga Tuntunin at Kundisyon';

  @override
  String get signUpRegistering => 'NAGPAPAREHISTRO...';

  @override
  String get signUpButton => 'GUMAWA NG ACCOUNT';

  @override
  String get signUpHaveAccount => 'May account ka na? Mag-sign In';

  @override
  String get signUpCreatedTitle => 'Nagawa na ang Account!';

  @override
  String signUpVerificationSentTo(String email) {
    return 'May verification link na ipinadala sa $email. I-verify ang iyong email para ma-activate ang account.';
  }

  @override
  String get signUpVerificationSent =>
      'May verification link na ipinadala sa iyong email. I-verify ang iyong email para ma-activate ang account.';

  @override
  String get signUpProceedToVerification => 'Magpatuloy sa Pag-verify';

  @override
  String get verifyYourEmailFallback => 'iyong email address';

  @override
  String get verifyNoSession => 'Walang naka-sign in. Mag-sign in ulit.';

  @override
  String get verifySuccess =>
      'Na-verify na ang email! Maligayang pagdating sa ResQ.';

  @override
  String get verifyNotYet =>
      'Hindi pa na-verify ang email mo. Buksan ang link na ipinadala sa inbox mo, saka i-tap ulit dito.';

  @override
  String get verifyResendShort => 'Ipadala Ulit';

  @override
  String verifyCheckFailed(String error) {
    return 'Hindi natapos ang pag-check: $error';
  }

  @override
  String verifyLinkResent(String email) {
    return 'May bagong verification link na ipinadala sa $email!';
  }

  @override
  String get verifySessionExpired => 'Nag-expire ang session. Mag-login ulit.';

  @override
  String verifyResendFailed(String error) {
    return 'Hindi maipadala ulit ang email: $error';
  }

  @override
  String get verifyDemoTitle => 'Demo Bypass para sa Defense';

  @override
  String get verifyDemoMessage =>
      'I-activate ang instant na verification bypass para sa presentasyon at testing ng Capstone?';

  @override
  String get verifyDemoConfirm => 'I-bypass para sa Demo';

  @override
  String get verifyBadge => 'Republika ng Pilipinas • Brgy. Moonwalk';

  @override
  String get verifyTitle => 'I-verify ang Iyong Email';

  @override
  String get verifyInstruction =>
      'Nagpadala kami ng opisyal na verification link sa iyong rehistradong email address:';

  @override
  String get verifyPending => 'Hinihintay ang Pag-verify';

  @override
  String get verifyChecking => 'Tinitingnan...';

  @override
  String get verifyDone => 'Na-verify Ko na ang Email';

  @override
  String get verifyResend => 'Ipadala Ulit ang Verification Link';

  @override
  String verifyResendIn(int seconds) {
    return 'Maipapadala ulit sa loob ng ${seconds}s';
  }

  @override
  String get verifyWrongEmail => 'Maling email address? Mag-sign Out';

  @override
  String get verifyTip =>
      '💡 Tip: Kung hindi mo makita ang email, tingnan ang Spam o Junk folder.\n(Defense note: Pindutin nang matagal ang civic badge sa itaas para i-activate ang demo bypass)';

  @override
  String get authInvalidTitle => 'Maling Detalye sa Pag-login';

  @override
  String get authInvalidMessage =>
      'Mali ang username o password na inilagay mo. Subukan ulit.';

  @override
  String get authTryAgain => 'Subukan Ulit';

  @override
  String get authAdminTitle => 'Admin Account ang Ginamit';

  @override
  String get authAdminMessage =>
      'Ang account na ito ay may pribilehiyo ng Opisyal ng Barangay at Dispatcher.\n\nMag-login sa ResQ Admin Command Center web portal.';

  @override
  String get authLockedTitle => 'Pansamantalang Naka-lock ang Account';

  @override
  String get authLockedMessage =>
      'Masyadong maraming maling pagtatangkang mag-login. Naka-lock ang account mo para sa seguridad.';

  @override
  String get authLockedRemaining => 'natitira';

  @override
  String get authErrorInvalidCredentials =>
      'Mali ang email o password. Subukan ulit.';

  @override
  String get authErrorInvalidEmail => 'Hindi wasto ang email address na iyan.';

  @override
  String get authErrorAccountSuspended =>
      'Sinuspinde ng admin ng Barangay Moonwalk ang account na ito. Makipag-ugnayan sa help desk ng barangay.';

  @override
  String get authErrorEmailInUse => 'May account na para sa email na ito.';

  @override
  String get authErrorWeakPassword => 'Masyadong mahina ang password na iyan.';

  @override
  String get authErrorTooManyRequests =>
      'Masyadong maraming pagtatangka. Maghintay ng ilang minuto at subukan ulit.';

  @override
  String get authErrorNetwork =>
      'Walang internet. Tingnan ang koneksyon at subukan ulit.';

  @override
  String get authErrorTimeout =>
      'Natagalan ang pag-login. Tingnan ang iyong internet connection.';

  @override
  String get authErrorGoogleCancelled =>
      'Kinansela ang pag-sign in gamit ang Google.';

  @override
  String get authErrorEmptyCredentials =>
      'Hindi puwedeng walang laman ang email at password.';

  @override
  String commonError(String message) {
    return 'Error: $message';
  }

  @override
  String get commonRelative => 'Kamag-anak';

  @override
  String commonEta(String eta) {
    return 'ETA: $eta';
  }

  @override
  String reportForPerson(String name) {
    return 'Para kay: $name';
  }

  @override
  String get statusSolved => 'Nalutas na';

  @override
  String get dashboardBiometricTitle => 'I-on ang Mabilis na Biometric Access';

  @override
  String get dashboardBiometricMessage =>
      'Protektahan ang iyong ResQ account at agad na i-verify ang mga emergency report gamit ang Fingerprint o Face ID.';

  @override
  String get dashboardMaybeLater => 'Mamaya na Lang';

  @override
  String get dashboardBiometricReason =>
      'I-scan ang fingerprint o mukha para i-on ang Biometric Quick Access';

  @override
  String get dashboardBiometricEnabled =>
      'Naka-on na ang biometric verification para sa ResQ!';

  @override
  String get dashboardEnableNow => 'I-on Ngayon';

  @override
  String dashboardReportedOn(String date) {
    return 'Iniulat noong $date';
  }

  @override
  String get dashboardMyReportsStatus => 'STATUS NG AKING MGA ULAT';

  @override
  String get dashboardViewAll => 'Tingnan Lahat';

  @override
  String get dashboardMyReportsSubtitle =>
      'Mga personal na ulat • Real-time na pagsubaybay sa pagresponde';

  @override
  String get dashboardCommunityIncidents => 'Mga Insidente sa Komunidad';

  @override
  String dashboardActiveCount(int count) {
    return '$count Aktibo';
  }

  @override
  String get dashboardCommunitySubtitle =>
      'Mga bagong ulat mula sa kalapit na compound at kalye';

  @override
  String get dashboardNoActiveIncidents => 'Walang aktibong insidente';

  @override
  String get dashboardWelcomeBack => 'Maligayang pagbabalik,';

  @override
  String get dashboardStatPending => 'Nakabinbin';

  @override
  String get dashboardStatInQueue => 'Nakapila';

  @override
  String get dashboardStatActive => 'Aktibo';

  @override
  String get dashboardStatResponding => 'Nirerespondehan';

  @override
  String get dashboardStatSolved => 'Nalutas';

  @override
  String get dashboardStatResolved => 'Naresolba';

  @override
  String get dashboardVideoInstructions => 'Mga Video na Gabay';

  @override
  String get dashboardVideoSubtitle =>
      'Paano mag-ulat ng mga problema sa kaligtasan sa Moonwalk';

  @override
  String get dashboardAdvisoryFallback => 'EMERGENCY ADVISORY';

  @override
  String get dashboardSirenAlertFallback => 'Siren Alert';

  @override
  String get dashboardAllSectors => 'Lahat ng Sektor';

  @override
  String get dashboardActiveSiren => 'AKTIBONG SIREN';

  @override
  String dashboardBroadcastTarget(String sector) {
    return 'Para sa: $sector';
  }

  @override
  String get myReportsTitle => 'AKING MGA ULAT';

  @override
  String get myReportsDirectory => 'Listahan ng mga Ulat';

  @override
  String get myReportsSubtitle => 'Ang mga ulat na isinumite mo';

  @override
  String get myReportsSearchHint =>
      'Maghanap ayon sa pamagat, lokasyon, kategorya...';

  @override
  String get myReportsFilterAll => 'LAHAT';

  @override
  String myReportsLoadError(String error) {
    return 'Hindi makuha ang mga ulat: $error';
  }

  @override
  String myReportsNoMatch(String query) {
    return 'Walang ulat na tugma sa \'$query\'.';
  }

  @override
  String get myReportsNoneForFilter => 'Walang ulat sa filter na ito.';

  @override
  String get myReportsCloseSearch => 'Isara';

  @override
  String get myReportsSearch => 'Maghanap';

  @override
  String get myReportsLive => 'Live';

  @override
  String get myReportsLocal => 'Lokal';

  @override
  String get detailLiveTitle => 'Natanggap na ng Command Center';

  @override
  String get detailLocalTitle =>
      'Naka-save sa Phone (Hinihintay ang Cloud Sync)';

  @override
  String get detailLiveMessage =>
      'Na-upload na ang ulat na ito sa cloud at natanggap na ng mga dispatcher ng Barangay Moonwalk.';

  @override
  String get detailLocalMessage =>
      'Ligtas na naka-save ang ulat na ito sa offline storage ng phone mo. Kusa itong maa-upload sa dispatch kapag nakakonekta na sa cloud server.';

  @override
  String detailIncidentId(String id) {
    return 'Incident ID: #$id';
  }

  @override
  String get detailLocalId => 'LOKAL';

  @override
  String get detailProtectedResident => 'Protektadong Residente';

  @override
  String get detailAnonymousFiling => 'Anonymous na Ulat';

  @override
  String get detailRegisteredResident => 'Rehistradong Residente';

  @override
  String get detailOnBehalfBadge => 'INIULAT PARA SA IBA';

  @override
  String get detailYourFiling => 'Ulat Mo';

  @override
  String get detailPrivacyBadge => 'Protektado ng RA 10173';

  @override
  String get detailOnBehalfOwn =>
      'Isinumite mo ang emergency report na ito para sa iyong kakilala';

  @override
  String get detailOnBehalfOther =>
      'Ulat ng Mamamayan na Wala sa Lugar (Nakatago ang Detalye para sa Kaligtasan)';

  @override
  String get detailAffectedPerson => 'Apektadong Tao / Kamag-anak sa Lugar:';

  @override
  String get detailUnspecifiedName => 'Walang Pangalan';

  @override
  String get detailVictimContact => 'Contact Number ng Biktima:';

  @override
  String get detailCallVictim => 'Tawagan ang Biktima';

  @override
  String get detailDispatcherOnly => 'Para sa Dispatcher Lang';

  @override
  String get detailPrivacyNotice =>
      'Alinsunod sa RA 10173 (Data Privacy Act of 2012), nakatago sa publiko ang contact info at para lang sa mga awtorisadong emergency responder.';

  @override
  String get detailPinnedLocation => 'Naka-pin na Lokasyon ng Insidente';

  @override
  String detailGps(String coordinates) {
    return 'GPS: $coordinates';
  }

  @override
  String get detailNarrative => 'Salaysay ng Insidente';

  @override
  String get detailNoDescription => 'Walang inilagay na paglalarawan.';

  @override
  String get detailDispatcherNotes => 'Puna at Aksyon ng Dispatcher';

  @override
  String get detailCommandStatus => 'Status sa Command Center';

  @override
  String get detailRespondersDispatched =>
      'NAIPADALA NA ANG MGA RESPONDER • TINATAYANG PAGDATING';

  @override
  String get detailAwaitingDispatcher =>
      'Hinihintay ang pagsusuri ng dispatcher. Dito lalabas nang real time ang mga update, ipinadalang emergency unit, o puna mula sa field verification.';

  @override
  String get detailEvidence => 'Kalakip na Ebidensya';

  @override
  String get detailNoEvidence => 'Walang kalakip na ebidensya ang ulat na ito';

  @override
  String get detailVerifiedEvidence => 'Beripikadong Ebidensya';

  @override
  String get detailTapToZoom => 'I-tap ang larawan para i-zoom';

  @override
  String get detailVideoEvidence => 'Video na Ebidensya ng Emergency';

  @override
  String get detailVideoVerified => 'Clip na beripikado ng responder network';

  @override
  String detailEvidenceTitle(String category) {
    return 'Ebidensya: $category';
  }

  @override
  String get detailWatchVideo => 'Panoorin ang Video na Ebidensya';

  @override
  String get detailPhotoStoredLocally =>
      'Naka-save sa phone ang larawang ebidensya (hinihintay ma-upload)';

  @override
  String get timelineSafetyProtocol => 'Mga Hakbang para sa Kaligtasan';

  @override
  String get timelineResolutionStage => 'Yugto ng Paglutas ng Insidente';

  @override
  String timelineRespondersOnTheWay(String eta) {
    return 'Papunta na ang mga responder • Tinatayang Pagdating: $eta';
  }

  @override
  String get trackingTitle => 'Live na Pagsubaybay sa Insidente';

  @override
  String get trackingClose => 'Isara ang tracking panel';

  @override
  String get kitFire1 =>
      '**Lumikas agad** gamit ang pinakaligtas at pinakamalapit na labasan.';

  @override
  String get kitFire2 =>
      '**Yumuko** malapit sa sahig para hindi makalanghap ng nakalalasong usok.';

  @override
  String get kitFire3 =>
      '**Huwag gumamit ng elevator**; laging gumamit ng hagdan kapag may sunog.';

  @override
  String get kitFire4 =>
      'Paglabas, dumiretso sa **Moonwalk Multipurpose Hall** o sa itinalagang evacuation area.';

  @override
  String get kitFlood1 =>
      '**Bantayan ang taas ng tubig** at ang mga opisyal na anunsyo ng Barangay Moonwalk.';

  @override
  String get kitFlood2 =>
      '**Patayin ang main switch ng kuryente** para maiwasan ang pagkakuryente at sunog.';

  @override
  String get kitFlood3 =>
      '**Ilipat agad ang mahahalagang gamit at ang pamilya** sa itaas na palapag.';

  @override
  String get kitFlood4 =>
      'Ihanda ang emergency Go-Bag at **lumikas** kapag iniutos ng awtoridad.';

  @override
  String get kitMedical1 =>
      '**Tingnan kung tumutugon** ang biktima at kung humihinga siya.';

  @override
  String get kitMedical2 =>
      '**Paluwagin ang paligid** para may sapat na espasyo at hangin ang biktima.';

  @override
  String get kitMedical3 =>
      '**Huwag galawin ang biktima** maliban kung nasa agarang panganib ang buhay niya.';

  @override
  String get kitMedical4 =>
      '**Maghintay nang kalmado** sa rescue ambulance ng Barangay at sa mga medical personnel.';

  @override
  String get kitEarthquake1 =>
      'Gawin agad ang **Duck, Cover, and Hold** hanggang tumigil ang pagyanig.';

  @override
  String get kitEarthquake2 =>
      '**Lumayo sa mga bintanang salamin**, nahuhulog na debris, at mabibigat na muwebles.';

  @override
  String get kitEarthquake3 =>
      '**Huwag gumamit ng elevator** habang o pagkatapos agad ng lindol.';

  @override
  String get kitEarthquake4 =>
      'Pumunta nang ligtas sa **bukas na lugar** o sa itinalagang safe zone kapag tuluyan nang tumigil ang pagyanig.';

  @override
  String get kitGeneral1 =>
      '**Manatiling kalmado** at agad na suriin ang iyong paligid.';

  @override
  String get kitGeneral2 =>
      '**Lumayo** sa anumang agarang panganib o sa mga istrukturang hindi matibay.';

  @override
  String get kitGeneral3 =>
      '**Hintayin ang opisyal na abiso** mula sa security personnel o mga opisyal ng Barangay Moonwalk.';

  @override
  String get commonClose => 'Isara';

  @override
  String get commonConfirm => 'Kumpirmahin';

  @override
  String get commonDelete => 'Burahin';

  @override
  String get commonSubmit => 'Ipasa';

  @override
  String get commonCallNow => 'Tumawag Ngayon';

  @override
  String get timeShortJustNow => 'Ngayon lang';

  @override
  String timeShortMinutes(int count) {
    return '${count}m ang nakalipas';
  }

  @override
  String timeShortHours(int count) {
    return '${count}h ang nakalipas';
  }

  @override
  String timeShortDays(int count) {
    return '${count}d ang nakalipas';
  }

  @override
  String get locationErrorGpsOff =>
      'Naka-off ang GPS. Mag-swipe pababa mula sa itaas ng screen at i-on ang Location.';

  @override
  String get locationErrorDenied =>
      'Hindi pinayagan ang access sa lokasyon. Payagan ang location access.';

  @override
  String get locationErrorDeniedForever =>
      'Permanenteng hindi pinayagan ang location. I-enable ito sa App Settings ng phone mo.';

  @override
  String get locationErrorNoFix =>
      'Hindi makuha ang GPS. Siguraduhing naka-on ang GPS at malinaw ang signal.';

  @override
  String get mapsTitle => 'MAPA NG KOMUNIDAD';

  @override
  String get mapsLive => 'LIVE NA MAPA';

  @override
  String get mapsFilterAll => 'Lahat';

  @override
  String get mapsFilterFire => 'Sunog';

  @override
  String get mapsFilterMedical => 'Medikal';

  @override
  String get mapsFilterFlood => 'Baha';

  @override
  String get mapsFilterTheft => 'Pagnanakaw';

  @override
  String get mapsFilterAccident => 'Aksidente';

  @override
  String get mapsFilterViolence => 'Karahasan';

  @override
  String get mapsAffectedOriginal =>
      '1 mamamayan ang apektado (ang nag-ulat). Hinihintay ang kumpirmasyon ng mga kapitbahay.';

  @override
  String mapsAffectedWithNeighbors(int total, int neighbors) {
    return '$total mamamayan ang apektado (nag-ulat + $neighbors kapitbahay)';
  }

  @override
  String get mapsYouAreAuthor =>
      'Ikaw ang nag-ulat nito. I-tap ang \'Tingnan ang Detalye\' para masubaybayan.';

  @override
  String get mapsConfirmationRecorded =>
      'Naitala ang iyong kumpirmasyon! Naabisuhan na ang dispatch.';

  @override
  String get mapsConfirmed => 'Nakumpirma';

  @override
  String get mapsIWitnessed => 'Nakita ko ito';

  @override
  String get mapsViewDetails => 'Tingnan ang Detalye';

  @override
  String get mapsOffline =>
      'Offline ka ngayon. Hindi ma-load ang mga live na insidente.';

  @override
  String mapsActiveIncidents(int count) {
    return '$count Aktibong Insidente';
  }

  @override
  String get hotlinesConfirmTitle => 'Tawagan ang Dispatch?';

  @override
  String hotlinesConfirmMessage(String title, String number) {
    return 'Sigurado ka bang tatawagan mo ngayon ang opisyal na hotline ng $title ($number)?';
  }

  @override
  String get hotlinesPortal => 'PORTAL NG EMERGENCY CALL';

  @override
  String get hotlinesGuestNote =>
      'Puwede kahit hindi naka-login. Tawagan nang direkta ang mga emergency responder sa ibaba.';

  @override
  String get hotlinesPolice => 'Dispatch ng Pulisya';

  @override
  String get hotlinesPoliceDesc =>
      'Agarang pag-uulat ng krimen, pagpapatrolya sa komunidad, pagpigil sa banta, at pagpapanatili ng kaayusan.';

  @override
  String get hotlinesFire => 'Istasyon ng Bumbero';

  @override
  String get hotlinesFireDesc =>
      'Mga sunog sa gusali, pagkontrol sa tagas ng mapanganib na kemikal, at agarang search and rescue.';

  @override
  String get hotlinesAmbulance => 'Medical Team ng Ambulansya';

  @override
  String get hotlinesAmbulanceDesc =>
      'Tulong sa malubhang pinsala, paghatid sa kritikal na pasyente, at pagpapadala ng emergency responder.';

  @override
  String get hotlinesBarangay => 'Barangay Desk Center';

  @override
  String get hotlinesBarangayDesc =>
      'Mga lokal na ulat sa kaligtasan sa Barangay Moonwalk, maliliit na alitan sa komunidad, koordinasyon sa security desk, at tulong.';

  @override
  String get hotlinesTooltip =>
      'I-tap para direktang tumawag • Pindutin nang matagal para kumpirmahin';

  @override
  String get hotlinesCall => 'TUMAWAG';

  @override
  String get notificationsTitle => 'MGA NOTIPIKASYON';

  @override
  String get notificationsMarkAllRead => 'Markahang nabasa lahat';

  @override
  String get notificationsEmptyTitle => 'Wala Pang Notipikasyon';

  @override
  String get notificationsEmptyMessage =>
      'Aabisuhan ka kapag may update ang dispatch sa iyong mga ulat, may kumpirma ang mga kapitbahay sa insidente, o may tunog ng siren sa komunidad.';

  @override
  String get notificationsViewReport => 'Tingnan ang ulat →';

  @override
  String get notificationsRemove => 'Alisin';

  @override
  String get broadcastDefaultTitle => 'MUNICIPAL EMERGENCY ADVISORY';

  @override
  String get broadcastDefaultType => 'Emergency Siren';

  @override
  String get broadcastDefaultMessage =>
      'Pinapayuhan ng mga awtoridad ng Barangay ang agarang pag-iingat.';

  @override
  String get broadcastDefaultSource => 'Barangay Command Center';

  @override
  String get broadcastBarrierLabel => 'Alerto ng Emergency Siren';

  @override
  String get broadcastHeader => 'EMERGENCY SIREN NG MUNISIPYO';

  @override
  String broadcastTargetSector(String sector) {
    return 'Sektor: $sector';
  }

  @override
  String broadcastOrigin(String source) {
    return 'Mula sa: $source';
  }

  @override
  String get broadcastAcknowledge => 'KUMPIRMAHIN ANG ALERTO';

  @override
  String get settingsTitle => 'MGA SETTING';

  @override
  String get settingsEmergencyServices => 'Mga Serbisyong Pang-emergency';

  @override
  String get settingsHotlinesTitle => 'Mga Emergency Hotline ng Barangay';

  @override
  String get settingsHotlinesSubtitle =>
      'Pulis (911), Bumbero (112), Medikal (143) at BDRRMC';

  @override
  String get settingsAccount => 'Mga Setting ng Account';

  @override
  String get settingsEditProfile => 'I-edit ang Personal na Detalye';

  @override
  String get settingsEditProfileSubtitle =>
      'Buong pangalan, mobile number, sektor at address';

  @override
  String get settingsPrivacy => 'Privacy at Seguridad ng Account';

  @override
  String get settingsPrivacySubtitle =>
      'I-update ang login credentials at tingnan ang anti-spam security policy';

  @override
  String get settingsPreferences => 'Mga Kagustuhan sa App';

  @override
  String get settingsTheme => 'Tema ng App';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsLightMode => 'Light Mode';

  @override
  String get settingsSupport => 'Suporta at Impormasyon';

  @override
  String get settingsAbout => 'Tungkol sa ResQ Community Safety';

  @override
  String get settingsAboutSubtitle =>
      'Mga gabay, mandato sa emergency at bersyon';

  @override
  String get settingsAboutBody =>
      'Ang ResQ Community Safety ay isang civic-tech na platform para sa emergency response na nag-uugnay sa mga residente at sa Barangay Command Operations Center para sa mabilis na pagresponde, pag-verify, at katatagan ng komunidad.';

  @override
  String get settingsHelpDesk => 'Help Desk ng Barangay';

  @override
  String get settingsHelpDeskSubtitle =>
      'Makipag-ugnayan sa administrative support team';

  @override
  String get settingsFeedback => 'Magpadala ng Feedback at Ulat ng Bug';

  @override
  String get settingsFeedbackSubtitle =>
      'Mag-ulat ng problema o magmungkahi ng pagpapabuti';

  @override
  String get settingsResidentCitizen => 'Residenteng Mamamayan';

  @override
  String get settingsSectorNotSet => 'Wala pang sektor';

  @override
  String get settingsVerifiedResident => 'Beripikadong Residente';

  @override
  String get settingsLogOut => 'Mag-log Out';

  @override
  String get settingsLogOutConfirm =>
      'Sigurado ka bang magla-log out ka sa iyong ResQ resident account?';

  @override
  String get settingsDeleteAccount => 'Burahin ang Account';

  @override
  String get settingsDeleteWarning =>
      'Babala: Kapag binura mo ang iyong resident account, permanenteng mawawala ang lahat ng naisumiteng ulat at naka-save na profile. Hindi na ito maibabalik.';

  @override
  String get settingsDeleteForever => 'Permanenteng Burahin ang Account';

  @override
  String get settingsNoSession => 'Walang aktibong session ng residente.';

  @override
  String get settingsAccountErased =>
      'Permanenteng nabura ang iyong account at personal na datos (RA 10173).';

  @override
  String get settingsRecentLoginRequired =>
      'Paalala sa Seguridad: Kailangang bagong mag-sign in bago burahin ang account. Mag-log out, mag-sign in ulit, at subukan muli.';

  @override
  String settingsDeleteFailed(String error) {
    return 'Hindi nabura ang account: $error';
  }

  @override
  String settingsDeleteError(String error) {
    return 'Error sa pagbura ng account: $error';
  }

  @override
  String get settingsHelpDeskTitle => 'Administrative Help Desk ng Barangay';

  @override
  String get settingsOfficeAddress => 'Address ng Opisina';

  @override
  String get settingsServiceHours => 'Oras ng Serbisyo';

  @override
  String get settingsServiceHoursValue => 'Lunes – Biyernes: 8:00 AM – 5:00 PM';

  @override
  String get settingsCallOffice => 'Tawagan ang Opisina';

  @override
  String get settingsSendEmail => 'Mag-email';

  @override
  String get settingsHelpDeskNote =>
      'Para sa agarang emergency na may panganib sa buhay (Sunog, Pulis, Medikal), gamitin ang Mga Emergency Hotline o magsumite ng ulat ng insidente.';

  @override
  String get settingsFeedbackTitle => 'Magpadala ng Feedback';

  @override
  String get settingsFeedbackIntro =>
      'Tulungan kaming pagandahin ang ResQ para sa Barangay Moonwalk. Diretsong ipinapadala sa development team ang iyong feedback.';

  @override
  String get settingsFeedbackCategory => 'KATEGORYA NG FEEDBACK';

  @override
  String get feedbackGeneral => 'Pangkalahatang Feedback';

  @override
  String get feedbackBug => 'Ulat ng Bug';

  @override
  String get feedbackFeature => 'Mungkahing Feature';

  @override
  String get settingsFeedbackHint =>
      'Ilarawan ang iyong feedback, mungkahi, o bug na naranasan...';

  @override
  String get settingsFeedbackEmpty =>
      'Magsulat muna ng maikling paglalarawan bago magsumite.';

  @override
  String get settingsFeedbackThanks =>
      'Salamat! Naipadala na sa technical team ang iyong feedback.';

  @override
  String settingsFeedbackFailed(String error) {
    return 'Hindi naipadala ang feedback: $error';
  }

  @override
  String get profileTitle => 'I-edit ang Profile';

  @override
  String get profilePhotoTitle => 'Larawan sa Profile';

  @override
  String get profileTakePhoto => 'Kumuha ng Larawan gamit ang Camera';

  @override
  String get profileChooseGallery => 'Pumili mula sa Gallery';

  @override
  String get profileUpdated => 'Na-update na ang mga detalye ng profile!';

  @override
  String profileUpdateFailed(String error) {
    return 'Hindi na-update ang profile: $error';
  }

  @override
  String get profileCredentials => 'Personal na Impormasyon';

  @override
  String get profileNameRequired => 'Ilagay ang iyong buong pangalan';

  @override
  String get profileEmailLabel => 'Email Address (Account ID)';

  @override
  String get profileEmailHelper =>
      'Hindi na mapapalitan ang pangunahing login credential';

  @override
  String get profilePhoneLabel => 'Mobile Number';

  @override
  String get profilePhoneInvalid => 'Maglagay ng tamang mobile number';

  @override
  String get profileJurisdiction => 'Sakop na Barangay at Address';

  @override
  String get profileAreaLabel => 'Lugar / Sektor sa Barangay';

  @override
  String get profileAddressLabel => 'Address ng Tirahan / Detalye ng Bahay';

  @override
  String get profileAddressRequired => 'Ilagay ang address ng iyong tirahan';

  @override
  String get profileEmergencyContact => 'Emergency Contact';

  @override
  String get profileContactName => 'Taong Kokontakin sa Emergency';

  @override
  String get profileContactNameRequired =>
      'Maglagay ng taong kokontakin sa emergency';

  @override
  String get profileContactNumber => 'Numero ng Emergency Contact';

  @override
  String get profileContactNumberInvalid =>
      'Maglagay ng numero ng emergency contact';

  @override
  String get profileSave => 'I-SAVE ANG MGA PAGBABAGO';

  @override
  String get privacyTitle => 'Privacy at Seguridad';

  @override
  String get privacyCredentials => 'Credentials at Access';

  @override
  String get privacyChangePassword => 'Palitan ang Password ng Account';

  @override
  String get privacyChangePasswordSubtitle =>
      'I-update ang password ng iyong resident account';

  @override
  String get privacyPolicyTitle => 'Patakaran sa Seguridad at Anti-Spam';

  @override
  String get privacyBiometric => 'Biometric na Pag-verify';

  @override
  String get privacyEnforced => 'IPINATUTUPAD';

  @override
  String get privacyBiometricOn =>
      'Ipinatutupad ng patakaran ng Barangay Moonwalk ang biometric na kumpirmasyon (fingerprint o face authentication) sa pagsusumite ng emergency report para maiwasan ang mga pekeng alarma at prank na ulat.';

  @override
  String get privacyBiometricOff =>
      'Walang biometric hardware sa device na ito. Ang PIN o secure credential ng device ang gagamitin bilang anti-spam na pag-verify.';

  @override
  String get passwordDialogTitle => 'Palitan ang Password';

  @override
  String get passwordDialogIntro =>
      'Ilagay ang kasalukuyang password at ang bagong password.';

  @override
  String get passwordCurrentRequired => 'Ilagay ang kasalukuyang password';

  @override
  String get passwordCurrentLabel => 'Kasalukuyang Password';

  @override
  String get passwordMinLength =>
      'Dapat hindi bababa sa 6 na karakter ang password';

  @override
  String get passwordNewLabel => 'Bagong Password';

  @override
  String get passwordMismatchShort => 'Hindi magkapareho ang mga password';

  @override
  String get passwordConfirmLabel => 'Kumpirmahin ang Bagong Password';

  @override
  String get passwordNoEmail => 'Walang rehistradong email ang account na ito.';

  @override
  String passwordResetSent(String email) {
    return 'Naipadala na ang link para i-reset ang password sa $email. Tingnan ang iyong email inbox.';
  }

  @override
  String passwordResetFailed(String error) {
    return 'Hindi naipadala ang reset email: $error';
  }

  @override
  String get passwordForgot =>
      'Nakalimutan ang password? Ipadala ang reset link sa email';

  @override
  String passwordChangeFailed(String error) {
    return 'Hindi napalitan ang password: $error';
  }

  @override
  String get passwordUpdated => 'Napalitan na ang password!';

  @override
  String get passwordUpdateButton => 'I-UPDATE ANG PASSWORD';

  @override
  String get viewerVideoTitle => 'Video na Ebidensya';

  @override
  String get viewerOpenExternalTab => 'Buksan sa Ibang Tab';

  @override
  String get viewerVideoError => 'Hindi ma-play ang video sa app';

  @override
  String get viewerOpenExternalPlayer => 'Buksan sa Ibang Player';

  @override
  String get viewerBuffering => 'Nilo-load ang video na ebidensya...';

  @override
  String get viewerReplay => 'Ulitin ang Video';

  @override
  String get viewerPhotoTitle => 'Larawang Ebidensya';

  @override
  String get viewerResetZoom => 'I-reset ang Zoom';

  @override
  String get viewerOpenFullImage => 'Buksan ang Buong Larawan sa Bagong Tab';

  @override
  String get viewerImageError => 'Hindi maipakita ang larawan sa app';

  @override
  String get viewerZoomHint =>
      'I-pinch, i-scroll, o i-drag para i-zoom at galawin ang larawan';

  @override
  String get aiTriggerActivated => 'Na-activate ang Intelligent Triage Engine.';

  @override
  String get chatResetTitle => 'I-reset ang Usapan?';

  @override
  String get chatResetMessage =>
      'Sigurado ka bang buburahin ang chat history mo sa ResQ Civil Defense Assistant? Magsisimula ito ng bagong session.';

  @override
  String get chatReset => 'I-reset';

  @override
  String get chatTitle => 'Civil Defense Assistant';

  @override
  String get chatStatus => 'Barangay Moonwalk • Aktibo';

  @override
  String get chatQuickGuides => 'Mabilisang Gabay sa Civil Defense';

  @override
  String get chatSenderAi => 'RESQ GEMINI AI';

  @override
  String get chatSenderOfficer => 'CIVIL DEFENSE OFFICER';

  @override
  String get chatHotlineDialers => 'Mga Hotline na Puwedeng Tawagan:';

  @override
  String get chatAllHotlines => 'Lahat ng Hotline';

  @override
  String get chatHint => 'Magtanong tungkol sa kaligtasan o first aid...';

  @override
  String get videoPlay => 'I-play';

  @override
  String get videoPause => 'I-pause';

  @override
  String get reportTakePhoto => 'Kumuha ng litrato';

  @override
  String get reportRecordVideo => 'Mag-record ng video';
}
