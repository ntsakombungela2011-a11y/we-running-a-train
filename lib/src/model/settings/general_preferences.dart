import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/l10n/l10n.dart';
import 'package:lichess_mobile/src/model/settings/board_preferences.dart'
    show BoardPrefs, BoardTheme, boardPreferencesProvider;
import 'package:lichess_mobile/src/model/settings/preferences_storage.dart';
import 'package:lichess_mobile/src/theme.dart';
import 'package:lichess_mobile/src/utils/json.dart';

final generalPreferencesProvider = NotifierProvider<GeneralPreferencesNotifier, GeneralPrefs>(
  GeneralPreferencesNotifier.new,
  name: 'GeneralPreferencesProvider',
);

class GeneralPreferencesNotifier extends Notifier<GeneralPrefs>
    with PreferencesStorage<GeneralPrefs> {
  @override
  @protected
  final prefCategory = PrefCategory.general;

  @override
  @protected
  GeneralPrefs get defaults => GeneralPrefs.defaults;

  @override
  GeneralPrefs fromJson(Map<String, dynamic> json) => GeneralPrefs.fromJson(json);

  @override
  GeneralPrefs build() {
    return fetch();
  }

  Future<void> setBackgroundThemeMode(BackgroundThemeMode themeMode) {
    return save(state.copyWith(themeMode: themeMode));
  }

  Future<void> toggleSoundEnabled() {
    return save(state.copyWith(isSoundEnabled: !state.isSoundEnabled));
  }

  Future<void> setLocale(Locale? locale) {
    return save(state.copyWith(locale: locale));
  }

  Future<void> setSoundTheme(SoundTheme soundTheme) {
    return save(state.copyWith(soundTheme: soundTheme));
  }

  Future<void> setMasterVolume(double volume) {
    return save(state.copyWith(masterVolume: volume));
  }

  Future<void> setPalette(String paletteId) {
    return save(state.copyWith(selectedPaletteId: paletteId));
  }

  Future<void> toggleSystemColors() {
    final newState = state.copyWith(systemColors: !state.systemColors);
    return Future.wait([
      save(newState),
      ref
          .read(boardPreferencesProvider.notifier)
          .setBoardTheme(
            newState.systemColors ? BoardTheme.system : BoardPrefs.defaults.boardTheme,
          ),
    ]).then((_) => {});
  }

  Future<void> setBackground({
    (BackgroundColor, bool)? backgroundColor,
    BackgroundImage? backgroundImage,
  }) {
    assert(
      !(backgroundColor != null && backgroundImage != null),
      'Only one of backgroundColor or backgroundImage should be set',
    );
    return save(state.copyWith(backgroundColor: backgroundColor, backgroundImage: backgroundImage));
  }
}

class GeneralPrefs implements Serializable {
  const GeneralPrefs({
    required this.themeMode,
    required this.isSoundEnabled,
    required this.soundTheme,
    required this.masterVolume,
    required this.systemColors,
    required this.appThemeSeed,
    this.locale,
    this.backgroundColor,
    this.backgroundImage,
    required this.selectedPaletteId,
  });

  final BackgroundThemeMode themeMode;
  final bool isSoundEnabled;
  final SoundTheme soundTheme;
  final double masterVolume;
  final bool systemColors;
  final AppThemeSeed appThemeSeed;
  final Locale? locale;
  final (BackgroundColor, bool)? backgroundColor;
  final BackgroundImage? backgroundImage;
  final String selectedPaletteId;

  static const defaults = GeneralPrefs(
    themeMode: BackgroundThemeMode.system,
    isSoundEnabled: true,
    soundTheme: SoundTheme.standard,
    masterVolume: 0.8,
    systemColors: true,
    appThemeSeed: AppThemeSeed.board,
    selectedPaletteId: 'bullet_express',
  );

  GeneralPrefs copyWith({
    BackgroundThemeMode? themeMode,
    bool? isSoundEnabled,
    SoundTheme? soundTheme,
    double? masterVolume,
    bool? systemColors,
    AppThemeSeed? appThemeSeed,
    Locale? locale,
    (BackgroundColor, bool)? backgroundColor,
    BackgroundImage? backgroundImage,
    String? selectedPaletteId,
  }) {
    return GeneralPrefs(
      themeMode: themeMode ?? this.themeMode,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      soundTheme: soundTheme ?? this.soundTheme,
      masterVolume: masterVolume ?? this.masterVolume,
      systemColors: systemColors ?? this.systemColors,
      appThemeSeed: appThemeSeed ?? this.appThemeSeed,
      locale: locale ?? this.locale,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      selectedPaletteId: selectedPaletteId ?? this.selectedPaletteId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'isSoundEnabled': isSoundEnabled,
      'soundTheme': soundTheme.name,
      'masterVolume': masterVolume,
      'systemColors': systemColors,
      'appThemeSeed': appThemeSeed.name,
      'locale': locale?.toLanguageTag(),
      'selectedPaletteId': selectedPaletteId,
      if (backgroundColor != null) 'backgroundColor': [backgroundColor!.$1.name, backgroundColor!.$2],
      if (backgroundImage != null) 'backgroundImage': const BackgroundImageConverter().toJson(backgroundImage),
    };
  }

  factory GeneralPrefs.fromJson(Map<String, dynamic> json) {
    return GeneralPrefs(
      themeMode: BackgroundThemeMode.values.byName(json['themeMode'] as String? ?? 'system'),
      isSoundEnabled: json['isSoundEnabled'] as bool? ?? true,
      soundTheme: SoundTheme.values.byName(json['soundTheme'] as String? ?? 'standard'),
      masterVolume: (json['masterVolume'] as num?)?.toDouble() ?? 0.8,
      systemColors: json['systemColors'] as bool? ?? true,
      appThemeSeed: AppThemeSeed.values.byName(json['appThemeSeed'] as String? ?? 'board'),
      locale: json['locale'] != null ? Locale.fromSubtags(languageCode: json['locale'] as String) : null,
      selectedPaletteId: json['selectedPaletteId'] as String? ?? 'bullet_express',
      backgroundColor: json['backgroundColor'] != null
          ? (BackgroundColor.values.byName((json['backgroundColor'] as List)[0] as String), (json['backgroundColor'] as List)[1] as bool)
          : null,
      backgroundImage: const BackgroundImageConverter().fromJson(json['backgroundImage'] as Map<String, dynamic>?),
    );
  }

  bool get isForcedDarkMode => backgroundColor != null || backgroundImage != null;
}

enum AppThemeSeed { system, board }

enum BackgroundThemeMode {
  system, light, dark;
  String title(AppLocalizations l10n) {
    switch (this) {
      case BackgroundThemeMode.system: return l10n.deviceTheme;
      case BackgroundThemeMode.dark: return l10n.dark;
      case BackgroundThemeMode.light: return l10n.light;
    }
  }
}

enum SoundTheme {
  standard('Standard'), piano('Piano'), nes('NES'), sfx('SFX'), futuristic('Futuristic'), lisp('Lisp');
  final String label;
  const SoundTheme(this.label);
}

enum BackgroundColor {
  blue(Color(0xff435665), 'Blue'),
  indigo(Color(0xff42455c), 'Indigo'),
  green(Color(0xff344d3c), 'Green'),
  brown(Color(0xff4a3d3f), 'Brown'),
  gold(Color(0xff675139), 'Gold'),
  red(Color(0xff5f353b), 'Red'),
  purple(Color(0xff624865), 'Purple'),
  lime(Color(0xff4f5530), 'Lime'),
  sepia(Color(0xff5f5d57), 'Sepia');
  final Color color;
  final String label;
  const BackgroundColor(this.color, this.label);
  ThemeData get baseTheme => BackgroundImage.getTheme(color);
  Color get darker => Color.lerp(color, Colors.black, 0.3)!;
}

class BackgroundImage {
  const BackgroundImage({
    required this.path,
    required this.transform,
    required this.isBlurred,
    required this.seedColor,
    required this.meanLuminance,
    required this.width,
    required this.height,
    required this.viewportWidth,
    required this.viewportHeight,
  });
  final String path;
  final Matrix4 transform;
  final bool isBlurred;
  final Color seedColor;
  final double meanLuminance;
  final double width;
  final double height;
  final double viewportWidth;
  final double viewportHeight;

  static ThemeData getTheme(Color seedColor) => ThemeData.from(
    colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark),
  );
  ThemeData get baseTheme => getTheme(seedColor);
}

class BackgroundImageConverter {
  const BackgroundImageConverter();
  BackgroundImage? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return BackgroundImage(
      path: json['path'] as String,
      transform: Matrix4.fromList((json['transform'] as List).map((e) => (e as num).toDouble()).toList()),
      isBlurred: json['isBlurred'] as bool,
      seedColor: Color(json['seedColor'] as int),
      meanLuminance: json['meanLuminance'] as double,
      width: json['width'] as double,
      height: json['height'] as double,
      viewportWidth: json['viewportWidth'] as double,
      viewportHeight: json['viewportHeight'] as double,
    );
  }
  Map<String, dynamic>? toJson(BackgroundImage? object) {
    if (object == null) return null;
    return {
      'path': object.path,
      'transform': object.transform.storage,
      'isBlurred': object.isBlurred,
      'seedColor': object.seedColor.toARGB32(),
      'meanLuminance': object.meanLuminance,
      'width': object.width,
      'height': object.height,
      'viewportWidth': object.viewportWidth,
      'viewportHeight': object.viewportHeight,
    };
  }
}
