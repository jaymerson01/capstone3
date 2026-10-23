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
}
