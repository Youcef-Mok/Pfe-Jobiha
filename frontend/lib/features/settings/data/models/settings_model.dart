// TODO(API): Adapter les champs à la réponse JSON de l'endpoint GET /settings

class AppSettings {
  final bool notificationsEnabled;
  final bool darkMode;
  final String languageCode;

  const AppSettings({
    this.notificationsEnabled = true,
    this.darkMode = false,
    this.languageCode = 'fr',
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? darkMode,
    String? languageCode,
  }) =>
      AppSettings(
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        darkMode: darkMode ?? this.darkMode,
        languageCode: languageCode ?? this.languageCode,
      );

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
        darkMode: json['dark_mode'] as bool? ?? false,
        languageCode: json['language_code'] as String? ?? 'fr',
      );

  Map<String, dynamic> toJson() => {
        'notifications_enabled': notificationsEnabled,
        'dark_mode': darkMode,
        'language_code': languageCode,
      };
}
