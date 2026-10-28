import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// ============================================================================
/// كائن خيار الإجراء داخل النافذة السفلية (CustomBottomSheetActionItem)
/// ============================================================================
class CustomBottomSheetActionItem {
  final String title;
  final String? subtitle;
  final dynamic icon;
  final VoidCallback onTap;
  final bool isDestructive;
  final Widget? trailing;
  final Color? iconColor;

  const CustomBottomSheetActionItem({
    required this.title,
    this.subtitle,
    this.icon,
    required this.onTap,
    this.isDestructive = false,
    this.trailing,
    this.iconColor,
  });
}

/// ============================================================================
/// النافذة السفلية المركزية الموحدة (CustomBottomSheet)
/// ============================================================================
/// ودجت قياسي موحد لعرض النوافذ السفلية وقوائم الخيارات وحوارات التأكيد
/// مبني وفق أعلى معايير الـ Clean Architecture ونظام التصميم الموحد.
class CustomBottomSheet extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget child;
  final List<Widget>? actions;
  final Widget? stickyFooter;
  final bool showDragHandle;
  final bool showCloseButton;
  final bool scrollable;
  final EdgeInsetsGeometry? padding;
  final double? maxHeightFactor;

  const CustomBottomSheet({
    super.key,
    this.title,
    this.subtitle,
    this.leadingIcon,
    required this.child,
    this.actions,
    this.stickyFooter,
    this.showDragHandle = true,
    this.showCloseButton = true,
    this.scrollable = false,
    this.padding,
    this.maxHeightFactor,
  });

  /// 1. مصنع النوافذ السفلية لقائمة الإجراءات والخيارات (Actions List)
  factory CustomBottomSheet.actions({
    Key? key,
    required String title,
    String? subtitle,
    IconData? leadingIcon,
    required List<CustomBottomSheetActionItem> items,
    bool showDragHandle = true,
    bool showCloseButton = true,
    EdgeInsetsGeometry? padding,
  }) {
    return CustomBottomSheet(
      key: key,
      title: title,
      subtitle: subtitle,
      leadingIcon: leadingIcon,
      showDragHandle: showDragHandle,
      showCloseButton: showCloseButton,
      padding: padding,
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: items.map((item) {
              final isDestructive = item.isDestructive;
              final itemColor = isDestructive
                  ? colors.error
                  : (item.iconColor ?? colors.primary);

              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: CustomInteractiveBounce(
                  onTap: () {
                    Get.back();
                    item.onTap();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isDestructive
                          ? colors.error.withValues(alpha: 0.08)
                          : colors.surfaceContainerHighest.withValues(
                              alpha: 0.35,
                            ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isDestructive
                            ? colors.error.withValues(alpha: 0.2)
                            : colors.outlineVariant.withValues(alpha: 0.2),
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (item.icon != null) ...[
                          Container(
                            width: 38.r,
                            height: 38.r,
                            decoration: BoxDecoration(
                              color: itemColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Center(
                              child: item.icon is IconData
                                  ? Icon(
                                      item.icon as IconData,
                                      size: 20.r,
                                      color: itemColor,
                                    )
                                  : item.icon as Widget,
                            ),
                          ),
                          AppSpacing.hSm,
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.title,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: isDestructive
                                      ? colors.error
                                      : colors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (item.subtitle != null) ...[
                                AppSpacing.vXxs,
                                Text(
                                  item.subtitle!,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDestructive
                                        ? colors.error.withValues(alpha: 0.8)
                                        : colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (item.trailing != null)
                          item.trailing!
                        else
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 20.r,
                            color: colors.onSurfaceVariant,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  /// 2. مصنع حوار التأكيد السفلي (Confirmation)
  factory CustomBottomSheet.confirmation({
    Key? key,
    required String title,
    required String message,
    IconData? leadingIcon,
    String confirmLabel = 'تأكيد',
    String cancelLabel = 'إلغاء',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
  }) {
    return CustomBottomSheet(
      key: key,
      title: title,
      leadingIcon: leadingIcon,
      actions: [
        Expanded(
          child: CustomButton.outline(
            text: cancelLabel,
            onPressed: () {
              Get.back();
              onCancel?.call();
            },
          ),
        ),
        AppSpacing.hSm,
        Expanded(
          child: isDestructive
              ? CustomButton.danger(
                  text: confirmLabel,
                  onPressed: () {
                    Get.back();
                    onConfirm?.call();
                  },
                )
              : CustomButton.primary(
                  text: confirmLabel,
                  onPressed: () {
                    Get.back();
                    onConfirm?.call();
                  },
                ),
        ),
      ],
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          );
        },
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// دوال العرض الاستاتيكية المركزية عبر GetX (Static Show Methods)
  /// --------------------------------------------------------------------------

  /// عرض نافذة سفلية مخصصة
  static Future<T?> show<T>({
    required Widget child,
    String? title,
    String? subtitle,
    IconData? leadingIcon,
    List<Widget>? actions,
    Widget? stickyFooter,
    bool showDragHandle = true,
    bool showCloseButton = true,
    bool scrollable = false,
    EdgeInsetsGeometry? padding,
    double? maxHeightFactor,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? barrierColor,
  }) {
    return Get.bottomSheet<T>(
      CustomBottomSheet(
        title: title,
        subtitle: subtitle,
        leadingIcon: leadingIcon,
        actions: actions,
        stickyFooter: stickyFooter,
        showDragHandle: showDragHandle,
        showCloseButton: showCloseButton,
        scrollable: scrollable,
        padding: padding,
        maxHeightFactor: maxHeightFactor,
        child: child,
      ),
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      barrierColor: barrierColor ?? Colors.black54,
      backgroundColor: Colors.transparent,
    );
  }

  /// عرض نافذة سفلية لقائمة الإجراءات
  static Future<T?> showActions<T>({
    required String title,
    String? subtitle,
    IconData? leadingIcon,
    required List<CustomBottomSheetActionItem> items,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return Get.bottomSheet<T>(
      CustomBottomSheet.actions(
        title: title,
        subtitle: subtitle,
        leadingIcon: leadingIcon,
        items: items,
      ),
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
    );
  }

  /// عرض نافذة سفلية لتأكيد عملية
  static Future<T?> showConfirmation<T>({
    required String title,
    required String message,
    IconData? leadingIcon,
    String confirmLabel = 'تأكيد',
    String cancelLabel = 'إلغاء',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
    bool isDismissible = true,
  }) {
    return Get.bottomSheet<T>(
      CustomBottomSheet.confirmation(
        title: title,
        message: message,
        leadingIcon: leadingIcon,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isDestructive: isDestructive,
      ),
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mediaQuery = MediaQuery.of(context);
    final effectiveMaxHeight =
        mediaQuery.size.height * (maxHeightFactor ?? 0.88);

    return Container(
      constraints: BoxConstraints(maxHeight: effectiveMaxHeight),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.bottomSheet),
        ),
        boxShadow: AppElevation.level5(context),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. مقبض السحب الموحد (Unified Drag Handle)
            if (showDragHandle)
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  margin: EdgeInsets.only(
                    top: AppSpacing.sm,
                    bottom: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),

            // 2. ترويسة النافذة الثابتة (Fixed Header)
            if (title != null) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.cardPadding,
                  AppSpacing.xs,
                  AppSpacing.cardPadding,
                  AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    if (leadingIcon != null) ...[
                      Container(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          leadingIcon,
                          color: context.colors.primary,
                          size: 20.r,
                        ),
                      ),
                      AppSpacing.hSm,
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title!,
                            style: AppTypography.titleMedium.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (subtitle != null) ...[
                            AppSpacing.vXxs,
                            Text(
                              subtitle!,
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (showCloseButton)
                      CustomButton.icon(
                        icon: Icons.close_rounded,
                        dimension: 34.r,
                        iconSize: 18.r,
                        backgroundColor: Colors.transparent,
                        foregroundColor: colors.onSurfaceVariant,
                        shape: AppButtonShape.circle,
                        onPressed: () => Get.back(),
                      ),
                  ],
                ),
              ),
              Divider(
                height: 1.h,
                thickness: 1.h,
                color: colors.outlineVariant.withValues(alpha: 0.25),
              ),
            ],

            // 3. المحتوى الرئيسي (Auto-Wrapping Scrollable Body Content)
            // Flexible مع FlexFit.loose يضمن:
            // - إذا كان المحتوى قصيراً: يأخذ حجم محتوياته بدقة (Wrap Content).
            // - إذا كبر المحتوى أو فُتح الكيبورد: يتحول للتمرير بسلاسة ويمنع أي RenderFlex overflow نهائياً!
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                physics: scrollable
                    ? const BouncingScrollPhysics()
                    : const ClampingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding:
                    padding ??
                    EdgeInsets.symmetric(
                      horizontal: AppSpacing.cardPadding,
                      vertical: AppSpacing.sm,
                    ),
                child: child,
              ),
            ),

            // 4. الذيل المثبت الدائم (Sticky Footer)
            if (stickyFooter != null)
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(
                    top: BorderSide(
                      color: colors.outlineVariant.withValues(alpha: 0.3),
                      width: 1.w,
                    ),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.cardPadding,
                  vertical: AppSpacing.sm,
                ),
                child: stickyFooter!,
              ),

            // 5. أزرار الإجراءات السفلية البسيطة (Legacy Actions Row)
            if (actions != null && actions!.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(
                    top: BorderSide(
                      color: colors.outlineVariant.withValues(alpha: 0.25),
                      width: 1.w,
                    ),
                  ),
                ),
                padding: EdgeInsets.all(AppSpacing.cardPadding),
                child: Row(children: actions!),
              ),
          ],
        ),
      ),
    );
  }
}
