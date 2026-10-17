import 'package:flutter/material.dart';

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color onSuccessVariant;

  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color onWarningVariant;

  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;
  final Color onInfoVariant;

  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color onErrorVariant;

  final Gradient? successGradient;
  final Gradient? errorGradient;
  final Gradient? infoGradient;
  final Gradient? warningGradient;

  const AppThemeColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.onSuccessVariant,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.onWarningVariant,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.onInfoVariant,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.onErrorVariant,
    this.successGradient,
    this.errorGradient,
    this.infoGradient,
    this.warningGradient,
  });

  @override
  AppThemeColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? onSuccessVariant,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? onWarningVariant,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? onInfoVariant,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? onErrorVariant,
    Gradient? successGradient,
    Gradient? errorGradient,
    Gradient? infoGradient,
    Gradient? warningGradient,
  }) {
    return AppThemeColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      successGradient: successGradient ?? this.successGradient,
      errorGradient: errorGradient ?? this.errorGradient,
      infoGradient: infoGradient ?? this.infoGradient,
      warningGradient: warningGradient ?? this.warningGradient,
      onSuccessVariant: onSuccessVariant ?? this.onSuccessVariant,
      onWarningVariant: onWarningVariant ?? this.onWarningVariant,
      onInfoVariant: onInfoVariant ?? this.onInfoVariant,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      onErrorVariant: onErrorVariant ?? this.onErrorVariant,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;

    return AppThemeColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
      successGradient: successGradient,
      errorGradient: errorGradient,
      infoGradient: infoGradient,
      warningGradient: warningGradient,
      onSuccessVariant: Color.lerp(
        onSuccessVariant,
        other.onSuccessVariant,
        t,
      )!,
      onWarningVariant: Color.lerp(
        onWarningVariant,
        other.onWarningVariant,
        t,
      )!,
      onInfoVariant: Color.lerp(onInfoVariant, other.onInfoVariant, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      onErrorContainer: Color.lerp(
        onErrorContainer,
        other.onErrorContainer,
        t,
      )!,
      onErrorVariant: Color.lerp(onErrorVariant, other.onErrorVariant, t)!,
    );
  }
}
