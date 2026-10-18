import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/themes/app_colors.dart';

enum SnackType { success, error, warning, info }

class CustomSnackbar {
  static void show({
    required String title,
    required String message,
    SnackType type = SnackType.success,
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    final cleanMessage = (type == SnackType.error || type == SnackType.warning)
        ? AppException.sanitizeMessage(message)
        : message;

    final context = Get.context ?? Get.overlayContext;
    if (context == null) return;
    final themeColors = context.colors;

    final backgroundGradient = type == SnackType.error
        ? themeColors.errorGradient
        : type == SnackType.success
        ? themeColors.successGradient
        : type == SnackType.info
        ? themeColors.infoGradient
        : type == SnackType.warning
        ? themeColors.warningGradient
        : null;

    final iconData = switch (type) {
      SnackType.success => Icons.check_circle,
      SnackType.error => Icons.error,
      SnackType.warning => Icons.warning,
      SnackType.info => Icons.info,
    };

    final titleColor = switch (type) {
      SnackType.warning => themeColors.onWarning,
      SnackType.success => themeColors.onSuccess,
      SnackType.info => themeColors.onInfo,
      SnackType.error => themeColors.onError,
    };

    final iconColor = titleColor;

    final subtitleColor = switch (type) {
      SnackType.warning => themeColors.onWarningVariant,
      SnackType.success => themeColors.onSuccessVariant,
      SnackType.info => themeColors.onInfoVariant,
      SnackType.error => themeColors.onErrorVariant,
    };

    if (Get.isSnackbarOpen) {
      try {
        Get.closeCurrentSnackbar();
      } catch (_) {}
    }

    Get.rawSnackbar(
      shouldIconPulse: true,
      titleText: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          color: titleColor,
          fontWeight: FontWeight.w700,
        ),
      ),
      messageText: Text(
        cleanMessage,
        style: AppTypography.bodyMedium.copyWith(color: subtitleColor),
      ),
      backgroundGradient: backgroundGradient,
      snackPosition: position,
      margin: EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.md,
      icon: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Icon(iconData, color: iconColor),
      ),
      duration: const Duration(seconds: 4),
    );
  }
}
