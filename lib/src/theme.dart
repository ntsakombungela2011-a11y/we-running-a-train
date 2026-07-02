import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lichess_mobile/src/constants.dart';
import 'package:lichess_mobile/src/model/settings/board_preferences.dart';
import 'package:lichess_mobile/src/model/settings/general_preferences.dart';
import 'package:lichess_mobile/src/styles/styles.dart';
import 'package:lichess_mobile/src/styles/palettes.dart';
import 'package:lichess_mobile/src/utils/color_palette.dart';

const kSliderTheme = SliderThemeData(
  // ignore: deprecated_member_use
  year2023: false,
);

ThemeData makeAppTheme(BuildContext context, GeneralPrefs generalPrefs, BoardPrefs boardPrefs) {
  final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
  final brightness = generalPrefs.isForcedDarkMode
      ? Brightness.dark
      : switch (generalPrefs.themeMode) {
          BackgroundThemeMode.light => Brightness.light,
          BackgroundThemeMode.dark => Brightness.dark,
          BackgroundThemeMode.system => MediaQuery.platformBrightnessOf(context),
        };

  if (generalPrefs.backgroundColor == null && generalPrefs.backgroundImage == null) {
    return _makeDefaultTheme(brightness, generalPrefs, boardPrefs, isIOS);
  } else {
    return _makeBackgroundImageTheme(
      baseTheme:
          generalPrefs.backgroundImage?.baseTheme ?? generalPrefs.backgroundColor!.$1.baseTheme,
      seedColor:
          generalPrefs.backgroundImage?.seedColor ??
          (generalPrefs.backgroundColor!.$2
              ? generalPrefs.backgroundColor!.$1.darker
              : generalPrefs.backgroundColor!.$1.color),
      isIOS: isIOS,
      isBackgroundImage: generalPrefs.backgroundImage != null,
    );
  }
}

ThemeData _makeDefaultTheme(
  Brightness brightness,
  GeneralPrefs generalPrefs,
  BoardPrefs boardPrefs,
  bool isIOS,
) {
  final selectedPalette = allPalettes.firstWhere(
    (p) => p.id == generalPrefs.selectedPaletteId,
    orElse: () => allPalettes.first,
  );

  ColorScheme scheme;
  if (selectedPalette.id == 'boipelo_pick') {
    // strictly monochromatic blue
    scheme = ColorScheme.fromSeed(
      seedColor: selectedPalette.colors.first,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
    );
  } else {
    scheme = ColorScheme.fromSeed(
      seedColor: selectedPalette.colors.first,
      secondary: selectedPalette.colors.length > 1 ? selectedPalette.colors[1] : null,
      tertiary: selectedPalette.colors.length > 2 ? selectedPalette.colors[2] : null,
      brightness: brightness,
    );
  }

  final theme = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: brightness,
    typography: isIOS ? Typography.material2021() : null,
  );

  return theme.copyWith(
    appBarTheme: _appBarTheme.copyWith(
      backgroundColor: isIOS ? scheme.surface : null,
      elevation: 0,
    ),
    scaffoldBackgroundColor: scheme.surface,
    cupertinoOverrideTheme: _makeCupertinoThemeData(scheme, brightness),
    listTileTheme: _makeListTileTheme(scheme, isIOS),
    cardTheme: _kCupertinoCardTheme.copyWith(color: scheme.surfaceContainerHigh),
    sliderTheme: kSliderTheme,
  );
}

ThemeData _makeBackgroundImageTheme({
  required ThemeData baseTheme,
  required Color seedColor,
  required bool isIOS,
  required bool isBackgroundImage,
}) {
  final baseSurfaceAlpha = isBackgroundImage ? 0.5 : 0.3;
  final scheme = baseTheme.colorScheme;

  return baseTheme.copyWith(
    colorScheme: scheme.copyWith(
      surface: scheme.surface.withOpacity(baseSurfaceAlpha),
    ),
    appBarTheme: _appBarTheme.copyWith(
      backgroundColor: isBackgroundImage ? null : seedColor.withOpacity(kCupertinoBarOpacity),
    ),
    scaffoldBackgroundColor: seedColor.withOpacity(0),
    sliderTheme: kSliderTheme,
  );
}

ListTileThemeData _makeListTileTheme(ColorScheme colorScheme, bool isIOS) {
  return ListTileThemeData(
    iconColor: colorScheme.onSurface.withOpacity(0.7),
    titleTextStyle: isIOS
        ? TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 16)
        : null,
    subtitleTextStyle: TextStyle(
      color: colorScheme.onSurface.withOpacity(Styles.subtitleOpacity),
    ),
  );
}

const _appBarTheme = AppBarTheme(actionsPadding: EdgeInsets.only(right: 8.0));

const _kCupertinoCardTheme = CardThemeData(
  elevation: 0,
  margin: EdgeInsets.zero,
  shape: RoundedRectangleBorder(borderRadius: Styles.cardBorderRadius),
);

CupertinoThemeData _makeCupertinoThemeData(ColorScheme colorScheme, Brightness brightness) {
  return CupertinoThemeData(
    applyThemeToAll: true,
    primaryColor: colorScheme.primary,
    brightness: brightness,
  );
}

const TextTheme kCupertinoDefaultTextTheme = TextTheme(
  titleMedium: TextStyle(letterSpacing: -0.41),
  bodyMedium: TextStyle(letterSpacing: -0.41),
);
