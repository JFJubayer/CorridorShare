import 'package:flutter/material.dart';

/// Six-step slate palette shared by both themes. Nothing outside this file
/// should reference a raw hex value; screens read `Theme.of(context)`.
abstract final class AppPalette {
  static const ink = Color(0xFF06141B);
  static const deep = Color(0xFF11212D);
  static const slate = Color(0xFF253745);
  static const steel = Color(0xFF4A5C6A);
  static const mist = Color(0xFF9BA8AB);
  static const fog = Color(0xFFCCD0CF);

  // Light-mode surfaces derived from `fog`; the palette has no lighter step.
  static const paper = Color(0xFFF2F4F3);
  static const paperRaised = Color(0xFFE3E7E6);

  // Functional colours, desaturated to sit inside the slate family.
  // Used only for status text and icons, never for primary actions.
  static const okDark = Color(0xFF7FB69A);
  static const okLight = Color(0xFF2E6B4F);
  static const dangerDark = Color(0xFFD08A7F);
  static const dangerLight = Color(0xFF9A3F33);
}

/// Semantic colours that `ColorScheme` does not model.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.ok,
    required this.danger,
    required this.textMuted,
    required this.skeleton,
  });

  final Color ok;
  final Color danger;
  final Color textMuted;
  final Color skeleton;

  static const dark = AppColors(
    ok: AppPalette.okDark,
    danger: AppPalette.dangerDark,
    textMuted: AppPalette.mist,
    skeleton: AppPalette.slate,
  );

  static const light = AppColors(
    ok: AppPalette.okLight,
    danger: AppPalette.dangerLight,
    textMuted: AppPalette.steel,
    skeleton: AppPalette.paperRaised,
  );

  @override
  AppColors copyWith({
    Color? ok,
    Color? danger,
    Color? textMuted,
    Color? skeleton,
  }) =>
      AppColors(
        ok: ok ?? this.ok,
        danger: danger ?? this.danger,
        textMuted: textMuted ?? this.textMuted,
        skeleton: skeleton ?? this.skeleton,
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      ok: Color.lerp(ok, other.ok, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      skeleton: Color.lerp(skeleton, other.skeleton, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;
  TextTheme get tt => Theme.of(this).textTheme;
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? AppColors.dark
          : AppColors.light);
}
