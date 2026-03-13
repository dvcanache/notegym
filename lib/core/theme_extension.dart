import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color accent;
  final Color accentLight;
  final Color accentDark;
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color glassWhite;
  final Color glassBorder;
  final Color glassWhiteStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color success;
  final Color warning;
  final Color error;
  
  final LinearGradient primaryGradient;
  final LinearGradient accentGradient;
  final LinearGradient purpleOrangeGradient;
  final LinearGradient backgroundGradient;

  final Map<String, Color> muscleColors;

  const AppColorsExtension({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.accent,
    required this.accentLight,
    required this.accentDark,
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.glassWhite,
    required this.glassBorder,
    required this.glassWhiteStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.error,
    required this.primaryGradient,
    required this.accentGradient,
    required this.purpleOrangeGradient,
    required this.backgroundGradient,
    required this.muscleColors,
  });

  @override
  AppColorsExtension copyWith({
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? accent,
    Color? accentLight,
    Color? accentDark,
    Color? background,
    Color? surface,
    Color? surfaceLight,
    Color? glassWhite,
    Color? glassBorder,
    Color? glassWhiteStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? success,
    Color? warning,
    Color? error,
    LinearGradient? primaryGradient,
    LinearGradient? accentGradient,
    LinearGradient? purpleOrangeGradient,
    LinearGradient? backgroundGradient,
    Map<String, Color>? muscleColors,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      accent: accent ?? this.accent,
      accentLight: accentLight ?? this.accentLight,
      accentDark: accentDark ?? this.accentDark,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      glassWhite: glassWhite ?? this.glassWhite,
      glassBorder: glassBorder ?? this.glassBorder,
      glassWhiteStrong: glassWhiteStrong ?? this.glassWhiteStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      accentGradient: accentGradient ?? this.accentGradient,
      purpleOrangeGradient: purpleOrangeGradient ?? this.purpleOrangeGradient,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      muscleColors: muscleColors ?? this.muscleColors,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentLight: Color.lerp(accentLight, other.accentLight, t)!,
      accentDark: Color.lerp(accentDark, other.accentDark, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      glassWhite: Color.lerp(glassWhite, other.glassWhite, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassWhiteStrong: Color.lerp(glassWhiteStrong, other.glassWhiteStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      primaryGradient: primaryGradient,
      accentGradient: accentGradient,
      purpleOrangeGradient: purpleOrangeGradient,
      backgroundGradient: backgroundGradient,
      muscleColors: muscleColors,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColorsExtension get colors => Theme.of(this).extension<AppColorsExtension>()!;
}
