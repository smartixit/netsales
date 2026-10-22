import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// ============================================================================
/// التنبيه العائم الأنيق الموحد (CustomToast)
/// ============================================================================
/// مكون واجهة عصري وخفيف (Floating Pill Toast) مخصص للتنبيهات اللحظية السريعة
/// كإشعارات النقر المزدوج للخروج، النسخ إلى الحافظة، أو الإجراءات غير المعيقة.
class CustomToast {
  CustomToast._();

  static OverlayEntry? _activeEntry;
  static Timer? _dismissTimer;

  /// إظهار تنبيه عائم أنيق
  static void show({
    required String message,
    IconData? icon,
    Color? iconColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 2),
    double? bottomOffset,
  }) {
    final context = Get.context ?? Get.overlayContext;
    if (context == null) return;

    final overlay = Overlay.maybeOf(context) ??
        Get.key.currentState?.overlay ??
        Navigator.maybeOf(context)?.overlay;

    if (overlay == null) return;

    // إغلاق أي Toast نشط سابقاً
    dismiss();

    final entry = OverlayEntry(
      builder: (toastContext) {
        final colors = toastContext.colors;
        final effectiveBottom = bottomOffset ?? 96.h;

        return Positioned(
          bottom: effectiveBottom,
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(maxWidth: 340.w),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colors.inverseSurface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: AppElevation.level3(toastContext),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.2),
                    width: 1.r,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 18.r,
                        color: iconColor ?? colors.onInverseSurface,
                      ),
                      AppSpacing.hSm,
                    ],
                    Flexible(
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: AppTypography.labelLarge.copyWith(
                          color: textColor ?? colors.onInverseSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(
                  duration: AppMotion.normal,
                  curve: AppMotion.decelerate,
                )
                .slideY(
                  begin: 0.3,
                  end: 0,
                  duration: AppMotion.normal,
                  curve: AppMotion.decelerate,
                ),
          ),
        );
      },
    );

    _activeEntry = entry;
    overlay.insert(entry);

    _dismissTimer = Timer(duration, () {
      dismiss();
    });
  }

  /// إخفاء الـ Toast فوراً وتنظيف الموارد
  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _activeEntry?.remove();
    _activeEntry = null;
  }
}
