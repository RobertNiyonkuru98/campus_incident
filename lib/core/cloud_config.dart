/// Cloudinary settings. Firebase Storage requires the paid Blaze plan, so
/// photographs are hosted here instead; the preset is unsigned by design, so no
/// API secret ships with the app.
class CloudConfig {
  const CloudConfig._();

  static const String cloudName = 'ieyem7xd';

  static const String uploadPreset = 'campuscare_unsigned';

  static bool get isConfigured =>
      !cloudName.startsWith('_REPLACE') && !uploadPreset.startsWith('_REPLACE');
}
