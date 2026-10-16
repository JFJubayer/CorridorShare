import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Builds both themes from [AppPalette]. One radius, one accent (the
/// highest-contrast neutral), no seeded tinting.
abstract final class AppTheme {
  static const radius = 12.0;
  static final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radius),
  );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        scheme: const ColorScheme.dark(
          primary: AppPalette.fog,
          onPrimary: AppPalette.ink,
          secondary: AppPalette.mist,
          onSecondary: AppPalette.ink,
          surface: AppPalette.ink,
          onSurface: AppPalette.fog,
          surfaceContainerLow: AppPalette.deep,
          surfaceContainer: AppPalette.deep,
          surfaceContainerHigh: AppPalette.slate,
          surfaceContainerHighest: AppPalette.slate,
          onSurfaceVariant: AppPalette.mist,
          outline: AppPalette.slate,
          outlineVariant: AppPalette.slate,
          error: AppPalette.dangerDark,
          onError: AppPalette.ink,
          inverseSurface: AppPalette.fog,
          onInverseSurface: AppPalette.ink,
        ),
        ext: AppColors.dark,
      );

  static ThemeData light() => _build(
        brightness: Brightness.light,
        scheme: const ColorScheme.light(
          primary: AppPalette.ink,
          onPrimary: AppPalette.fog,
          secondary: AppPalette.steel,
          onSecondary: AppPalette.paper,
          surface: AppPalette.paper,
          onSurface: AppPalette.ink,
          surfaceContainerLow: AppPalette.paperRaised,
          surfaceContainer: AppPalette.paperRaised,
          surfaceContainerHigh: AppPalette.fog,
          surfaceContainerHighest: AppPalette.fog,
          onSurfaceVariant: AppPalette.steel,
          outline: AppPalette.mist,
          outlineVariant: AppPalette.fog,
          error: AppPalette.dangerLight,
          onError: AppPalette.paper,
          inverseSurface: AppPalette.ink,
          onInverseSurface: AppPalette.fog,
        ),
        ext: AppColors.light,
      );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required AppColors ext,
  }) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final text = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    final textTheme = text.copyWith(
      headlineMedium: text.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.15,
      ),
      headlineSmall: text.headlineSmall?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.2,
      ),
      titleLarge: text.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleMedium: text.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: text.titleSmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: text.bodyLarge?.copyWith(fontSize: 15, height: 1.45),
      bodyMedium: text.bodyMedium?.copyWith(
        fontSize: 13,
        height: 1.45,
        color: scheme.onSurfaceVariant,
      ),
      bodySmall: text.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.4,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: text.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: text.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: scheme.onSurfaceVariant,
      ),
      labelSmall: text.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: scheme.onSurfaceVariant,
      ),
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide.none,
    );

    return base.copyWith(
      colorScheme: scheme,
      extensions: [ext],
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      dividerColor: scheme.outlineVariant,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.surfaceContainerHigh,
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: shape,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: textTheme.bodyMedium,
        floatingLabelStyle:
            textTheme.labelMedium?.copyWith(color: scheme.onSurface),
        hintStyle:
            textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        helperStyle: textTheme.bodySmall,
        errorStyle: textTheme.bodySmall?.copyWith(color: scheme.error),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.surfaceContainerHigh,
          disabledForegroundColor: scheme.onSurfaceVariant,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: shape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: shape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: shape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: scheme.onSurface),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: scheme.surfaceContainerLow,
          foregroundColor: scheme.onSurfaceVariant,
          selectedBackgroundColor: scheme.primary,
          selectedForegroundColor: scheme.onPrimary,
          side: BorderSide.none,
          shape: shape,
          textStyle: textTheme.labelMedium,
          visualDensity: VisualDensity.compact,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: shape,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: scheme.outline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: shape,
        elevation: 0,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.surfaceContainerHigh,
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.08),
        trackHeight: 3,
        showValueIndicator: ShowValueIndicator.never,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.onSurface,
        linearTrackColor: scheme.surfaceContainerHigh,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyLarge,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerLow),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(shape),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: shape,
        textStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
