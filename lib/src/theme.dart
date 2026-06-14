import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lichess_mobile/src/constants.dart';
import 'package:lichess_mobile/src/model/settings/board_preferences.dart';
import 'package:lichess_mobile/src/model/settings/general_preferences.dart';
import 'package:lichess_mobile/src/model/theme/theme_colors.dart';
import 'package:lichess_mobile/src/model/theme/theme_palette.dart';
import 'package:lichess_mobile/src/styles/styles.dart';
import 'package:lichess_mobile/src/utils/color_palette.dart';

const kSliderTheme = SliderThemeData(
  // ignore: deprecated_member_use
  year2023: false,
);

ThemeData makeAppTheme(BuildContext context, GeneralPrefs generalPrefs, BoardPrefs boardPrefs, {ThemePalette? palette}) {
  return makeAppThemeNoContext(generalPrefs, boardPrefs, palette: palette);
}

ThemeData makeAppThemeNoContext(GeneralPrefs generalPrefs, BoardPrefs boardPrefs, {ThemePalette? palette}) {
  final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
  final brightness = generalPrefs.isForcedDarkMode
      ? Brightness.dark
      : switch (generalPrefs.themeMode) {
          BackgroundThemeMode.light => Brightness.light,
          BackgroundThemeMode.dark => Brightness.dark,
          BackgroundThemeMode.system => PlatformDispatcher.instance.platformBrightness,
        };

  if (generalPrefs.backgroundColor == null && generalPrefs.backgroundImage == null) {
    return _makeDefaultTheme(brightness, generalPrefs, boardPrefs, isIOS, palette: palette);
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

ThemeData makeAppThemeFromPalette(
  ThemePalette palette,
  Brightness brightness,
) {
  final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
  final appColorScheme = AppColorGenerator.generateFromPalette(
    palette,
    isDark: brightness == Brightness.dark,
  );

  final colorScheme = appColorScheme.toColorScheme(brightness);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: appColorScheme.surface,
    cupertinoOverrideTheme: _makeCupertinoThemeData(colorScheme, brightness),
    appBarTheme: _appBarTheme.copyWith(
      backgroundColor: isIOS ? null : appColorScheme.surface,
      scrolledUnderElevation: isIOS ? 0 : null,
      titleTextStyle: isIOS
          ? const CupertinoTextThemeData().navTitleTextStyle.copyWith(
              color: appColorScheme.onSurface,
            )
          : null,
    ),
    navigationBarTheme: isIOS
        ? NavigationBarThemeData(
            backgroundColor: appColorScheme.surface.withValues(alpha: kCupertinoBarOpacity),
          )
        : null,
    bottomAppBarTheme: BottomAppBarThemeData(
      color: appColorScheme.surface,
      elevation: isIOS ? 0 : null,
    ),
    searchBarTheme: isIOS ? _kCupertinoSearchBarTheme : null,
    iconTheme: IconThemeData(color: appColorScheme.onSurface.withValues(alpha: 0.7)),
    listTileTheme: _makeListTileTheme(colorScheme, isIOS),
    cardTheme: isIOS
        ? _kCupertinoCardTheme.copyWith(color: appColorScheme.surfaceContainerHigh)
        : null,
    inputDecorationTheme: isIOS ? _makeCupertinoInputDecorationTheme(colorScheme) : null,
    floatingActionButtonTheme: isIOS
        ? FloatingActionButtonThemeData(
            backgroundColor: appColorScheme.secondary,
            foregroundColor: appColorScheme.onSecondary,
          )
        : null,
    dialogTheme: isIOS ? _kCupertinoDialogTheme : null,
    filledButtonTheme: isIOS ? _kCupertinoFilledButtonTheme : null,
    outlinedButtonTheme: isIOS ? _kCupertinoOutlinedButtonTheme : null,
    menuTheme: isIOS ? _kCupertinoMenuThemeData : null,
    bottomSheetTheme: isIOS ? _kCupertinoBottomSheetTheme : null,
    sliderTheme: kSliderTheme,
    extensions: [lichessCustomColors.harmonized(colorScheme)],
  );
}

ThemeData _makeDefaultTheme(
  Brightness brightness,
  GeneralPrefs generalPrefs,
  BoardPrefs boardPrefs,
  bool isIOS, {
  ThemePalette? palette,
}) {
  if (palette != null) {
    return makeAppThemeFromPalette(palette, brightness);
  }

  final seedColor = brightness == Brightness.dark ? const Color(0xFF121414) : const Color(0xFFFFFFFF);
  final appColorScheme = AppColorGenerator.generateFromSeed(seedColor, isDark: brightness == Brightness.dark);
  final colorScheme = appColorScheme.toColorScheme(brightness);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: appColorScheme.surface,
    cupertinoOverrideTheme: _makeCupertinoThemeData(colorScheme, brightness),
    appBarTheme: _appBarTheme.copyWith(
      backgroundColor: isIOS ? null : appColorScheme.surface,
      scrolledUnderElevation: isIOS ? 0 : null,
      titleTextStyle: isIOS
          ? const CupertinoTextThemeData().navTitleTextStyle.copyWith(
              color: appColorScheme.onSurface,
            )
          : null,
    ),
    navigationBarTheme: isIOS
        ? NavigationBarThemeData(
            backgroundColor: appColorScheme.surface.withValues(alpha: kCupertinoBarOpacity),
          )
        : null,
    bottomAppBarTheme: BottomAppBarThemeData(
      color: appColorScheme.surface,
      elevation: isIOS ? 0 : null,
    ),
    searchBarTheme: isIOS ? _kCupertinoSearchBarTheme : null,
    iconTheme: IconThemeData(color: appColorScheme.onSurface.withValues(alpha: 0.7)),
    listTileTheme: _makeListTileTheme(colorScheme, isIOS),
    cardTheme: isIOS
        ? _kCupertinoCardTheme.copyWith(color: appColorScheme.surfaceContainerHigh)
        : null,
    inputDecorationTheme: isIOS ? _makeCupertinoInputDecorationTheme(colorScheme) : null,
    floatingActionButtonTheme: isIOS
        ? FloatingActionButtonThemeData(
            backgroundColor: appColorScheme.secondary,
            foregroundColor: appColorScheme.onSecondary,
          )
        : null,
    dialogTheme: isIOS ? _kCupertinoDialogTheme : null,
    filledButtonTheme: isIOS ? _kCupertinoFilledButtonTheme : null,
    outlinedButtonTheme: isIOS ? _kCupertinoOutlinedButtonTheme : null,
    menuTheme: isIOS ? _kCupertinoMenuThemeData : null,
    bottomSheetTheme: isIOS ? _kCupertinoBottomSheetTheme : null,
    sliderTheme: kSliderTheme,
    extensions: [lichessCustomColors.harmonized(colorScheme)],
  );
}

ThemeData _makeBackgroundImageTheme({
  required ThemeData baseTheme,
  required Color seedColor,
  required bool isIOS,
  required bool isBackgroundImage,
}) {
  final baseSurfaceAlpha = isBackgroundImage ? 0.5 : 0.3;

  return baseTheme.copyWith(
    colorScheme: baseTheme.colorScheme.copyWith(
      surface: baseTheme.colorScheme.surface.withValues(alpha: baseSurfaceAlpha),
      surfaceContainerLowest: baseTheme.colorScheme.surfaceContainerLowest.withValues(
        alpha: baseSurfaceAlpha,
      ),
      surfaceContainerLow: baseTheme.colorScheme.surfaceContainerLow.withValues(
        alpha: baseSurfaceAlpha,
      ),
      surfaceContainer: baseTheme.colorScheme.surfaceContainer.withValues(alpha: baseSurfaceAlpha),
      surfaceContainerHigh: baseTheme.colorScheme.surfaceContainerHigh.withValues(
        alpha: baseSurfaceAlpha,
      ),
      surfaceContainerHighest: baseTheme.colorScheme.surfaceContainerHighest.withValues(
        alpha: baseSurfaceAlpha,
      ),
      surfaceDim: baseTheme.colorScheme.surfaceDim.withValues(alpha: baseSurfaceAlpha + 1),
      surfaceBright: baseTheme.colorScheme.surfaceBright.withValues(alpha: baseSurfaceAlpha - 2),
    ),
    cupertinoOverrideTheme: _makeCupertinoThemeData(baseTheme.colorScheme, baseTheme.brightness),
    listTileTheme: _makeListTileTheme(baseTheme.colorScheme, isIOS),
    cardTheme: isIOS ? _kCupertinoCardTheme : null,
    inputDecorationTheme: isIOS ? _makeCupertinoInputDecorationTheme(baseTheme.colorScheme) : null,
    bottomSheetTheme: (isIOS ? _kCupertinoBottomSheetTheme : const BottomSheetThemeData()).copyWith(
      backgroundColor: isIOS
          ? Color.lerp(baseTheme.colorScheme.surface, Colors.white, 0.1)!.withValues(alpha: 0.9)
          : baseTheme.colorScheme.surface.withValues(alpha: 0.9),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: baseTheme.colorScheme.surfaceContainerLow.withValues(alpha: 0.9),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: baseTheme.colorScheme.secondaryFixedDim,
      foregroundColor: baseTheme.colorScheme.onSecondaryFixedVariant,
    ),
    dialogTheme: (isIOS ? _kCupertinoDialogTheme : const DialogThemeData()).copyWith(
      backgroundColor: baseTheme.colorScheme.surface.withValues(alpha: 0.9),
    ),
    filledButtonTheme: isIOS ? _kCupertinoFilledButtonTheme : null,
    outlinedButtonTheme: isIOS ? _kCupertinoOutlinedButtonTheme : null,
    menuTheme: isIOS
        ? MenuThemeData(
            style: MenuStyle(
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(
                baseTheme.colorScheme.surfaceContainer.withValues(alpha: 0.8),
              ),
            ),
          )
        : MenuThemeData(
            style: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(
                baseTheme.colorScheme.surfaceContainerLow.withValues(alpha: 0.8),
              ),
            ),
          ),
    scaffoldBackgroundColor: seedColor.withValues(alpha: 0),
    appBarTheme: _appBarTheme.copyWith(
      backgroundColor: isBackgroundImage ? null : seedColor.withValues(alpha: kCupertinoBarOpacity),
      scrolledUnderElevation: isIOS ? 0 : null,
      titleTextStyle: isIOS
          ? const CupertinoTextThemeData().navTitleTextStyle.copyWith(
              color: baseTheme.colorScheme.onSurface,
            )
          : null,
    ),
    navigationBarTheme: isIOS
        ? NavigationBarThemeData(
            backgroundColor: isBackgroundImage
                ? baseTheme.colorScheme.surface.withValues(alpha: baseSurfaceAlpha)
                : seedColor.withValues(alpha: kCupertinoBarOpacity),
          )
        : null,
    bottomAppBarTheme: BottomAppBarThemeData(
      color: isBackgroundImage
          ? baseTheme.colorScheme.surface.withValues(alpha: baseSurfaceAlpha)
          : seedColor,
      elevation: isIOS ? 0 : null,
    ),
    searchBarTheme: isIOS ? _kCupertinoSearchBarTheme : null,
    splashFactory: isIOS ? NoSplash.splashFactory : null,
    sliderTheme: kSliderTheme,
    extensions: [lichessCustomColors.harmonized(baseTheme.colorScheme)],
  );
}

const _kCupertinoFilledButtonTheme = FilledButtonThemeData(
  style: ButtonStyle(
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
    ),
  ),
);

const _kCupertinoOutlinedButtonTheme = OutlinedButtonThemeData(
  style: ButtonStyle(
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
    ),
  ),
);

const MenuThemeData _kCupertinoMenuThemeData = MenuThemeData(
  style: MenuStyle(elevation: WidgetStatePropertyAll(0)),
);

ListTileThemeData _makeListTileTheme(ColorScheme colorScheme, bool isIOS) {
  return ListTileThemeData(
    iconColor: colorScheme.onSurface.withValues(alpha: 0.7),
    titleTextStyle: isIOS
        ? TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 16)
        : null,
    subtitleTextStyle: TextStyle(
      color: colorScheme.onSurface.withValues(alpha: Styles.subtitleOpacity),
    ),
    contentPadding: isIOS ? const EdgeInsets.symmetric(horizontal: 16) : null,
    minTileHeight: isIOS ? 48.0 : null,
  );
}

const _appBarTheme = AppBarTheme(actionsPadding: EdgeInsets.only(right: 8.0));

const _kCupertinoBottomSheetTheme = BottomSheetThemeData(
  elevation: 0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
);

const _kCupertinoDialogTheme = DialogThemeData(
  elevation: 0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
);

const _kCupertinoCardTheme = CardThemeData(
  elevation: 0,
  margin: EdgeInsets.zero,
  shape: RoundedRectangleBorder(borderRadius: Styles.cardBorderRadius),
);

const _kCupertinoSearchBarTheme = SearchBarThemeData(
  elevation: WidgetStatePropertyAll(0),
  shape: WidgetStatePropertyAll(
    RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
  ),
  constraints: BoxConstraints(minHeight: 40, maxHeight: 40),
  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 7)),
);

InputDecorationTheme _makeCupertinoInputDecorationTheme(ColorScheme colorScheme) {
  return InputDecorationTheme(
    filled: true,
    fillColor: colorScheme.surfaceContainer.withValues(alpha: 0.7),
    border: const OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: colorScheme.outline),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    ),
    disabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: colorScheme.error),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    ),
  );
}

CupertinoThemeData _makeCupertinoThemeData(ColorScheme colorScheme, Brightness brightness) {
  return CupertinoThemeData(
    applyThemeToAll: true,
    primaryColor: colorScheme.primary,
    primaryContrastingColor: colorScheme.onPrimary,
    textTheme: const CupertinoThemeData().textTheme.copyWith(
      primaryColor: colorScheme.primary,
      textStyle: const CupertinoThemeData().textTheme.textStyle.copyWith(
        color: colorScheme.onSurface,
      ),
      navTitleTextStyle: const CupertinoThemeData().textTheme.navTitleTextStyle.copyWith(
        color: colorScheme.onSurface,
      ),
      navLargeTitleTextStyle: const CupertinoThemeData().textTheme.navLargeTitleTextStyle.copyWith(
        color: colorScheme.onSurface,
      ),
    ),
    brightness: brightness,
  );
}

const TextStyle _kCupertinoDefaultTextStyle = TextStyle(letterSpacing: -0.41);

const TextTheme kCupertinoDefaultTextTheme = TextTheme(
  titleMedium: _kCupertinoDefaultTextStyle,
  titleSmall: _kCupertinoDefaultTextStyle,
  bodyLarge: _kCupertinoDefaultTextStyle,
  bodyMedium: _kCupertinoDefaultTextStyle,
  bodySmall: _kCupertinoDefaultTextStyle,
  labelLarge: _kCupertinoDefaultTextStyle,
  labelMedium: _kCupertinoDefaultTextStyle,
  labelSmall: _kCupertinoDefaultTextStyle,
);
