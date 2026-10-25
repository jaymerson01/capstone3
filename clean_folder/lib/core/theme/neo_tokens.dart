/// RESQ Neo-Tactile shape and blur tokens. The colors live in `AppColors`.
class NeoRadii {
  static const double tile = 12;   // Icon tiles
  static const double field = 16;  // Text fields, small cards, snackbars
  static const double card = 24;   // Cards and list groups
  static const double panel = 30;  // Glass panels, dialogs, sheets, bottom bar
  static const double pill = 999;  // Buttons, chips, status pills
}

/// Blur strength (sigma) for glass. Blur only big surfaces (bars, dialogs,
/// the Home hero); list cards stay translucent without blur so scrolling
/// stays smooth on low-end phones.
class NeoBlur {
  static const double glass = 22;  // Frosted bars and panels over the aurora
  static const double smoke = 16;  // Smoked glass over a landscape
}
