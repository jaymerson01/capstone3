/// Public, non-secret app configuration.
///
/// Nothing secret belongs here: everything in the app bundle can be read by
/// anyone who installs the APK or opens the admin website. Secrets (like the
/// Gemini API key) live in Cloud Functions secrets instead.
class AppConfig {
  AppConfig._();

  /// Cloudinary account for evidence photos/videos. The upload preset is an
  /// *unsigned* preset whose limits (file types, size caps, folders) are set
  /// in the Cloudinary console, so these values are safe to ship.
  static const String cloudinaryCloudName = 'g45cmboy';
  static const String cloudinaryUploadPreset = 'crkjnmhd';
}
