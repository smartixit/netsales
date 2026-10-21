import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/widgets/dialogs/widgets/dialog_action_bar.dart';
import 'package:netsales/widgets/dialogs/widgets/dialog_body_content.dart';
import 'package:netsales/widgets/dialogs/widgets/dialog_icon_header.dart';

export 'package:netsales/widgets/dialogs/widgets/dialog_icon_header.dart'
    show DialogType;

/// حوار مركزي تفاعلي موحد مبني وفق معمارية الودجات المستقلة (CustomDialog)
///
/// مطابق تماماً لهندسة [CustomButton]؛ حيث يعتبر كلاس StatelessWidget أصيل
/// يمكن استدعاؤه كودجت مباشر في أي شجرة، أو عرضه كنافذة منبثقة عبر دوال العرض الاستاتيكية.
class CustomDialog extends StatelessWidget {
  final DialogType type;
  final String title;
  final String message;
  final Widget? content;
  final String? confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool canPop;
  final double? maxWidth;
  final Widget? customHeader;
  final String? customAnimationPath;

  const CustomDialog({
    super.key,
    this.type = DialogType.info,
    required this.title,
    this.message = '',
    this.content,
    this.confirmLabel,
    this.cancelLabel,
    this.onConfirm,
    this.onCancel,
    this.canPop = true,
    this.maxWidth,
    this.customHeader,
    this.customAnimationPath,
  });

  /// 1. حوار تأكيد العمليات الحساسة (Confirmation)
  factory CustomDialog.confirmation({
    Key? key,
    required String title,
    required String message,
    String confirmLabel = 'تأكيد',
    String cancelLabel = 'إلغاء',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool canPop = true,
  }) =>
      CustomDialog(
        key: key,
        type: DialogType.confirmation,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
        canPop: canPop,
      );

  /// 2. حوار نجاح العمليات (Success)
  factory CustomDialog.success({
    Key? key,
    required String title,
    required String message,
    String? confirmLabel,
    VoidCallback? onConfirm,
    bool canPop = true,
  }) =>
      CustomDialog(
        key: key,
        type: DialogType.success,
        title: title,
        message: message,
        confirmLabel: confirmLabel ?? 'حسناً',
        onConfirm: onConfirm,
        canPop: canPop,
      );

  /// 3. حوار تنبيهات الأخطاء (Error)
  factory CustomDialog.error({
    Key? key,
    required String title,
    required String message,
    String? confirmLabel,
    VoidCallback? onConfirm,
    bool canPop = true,
  }) =>
      CustomDialog(
        key: key,
        type: DialogType.error,
        title: title,
        message: message,
        confirmLabel: confirmLabel ?? 'إغلاق',
        onConfirm: onConfirm,
        canPop: canPop,
      );

  /// 4. حوار التحذيرات التشغيلية (Warning)
  factory CustomDialog.warning({
    Key? key,
    required String title,
    required String message,
    String confirmLabel = 'متابعة',
    String cancelLabel = 'إلغاء',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool canPop = true,
  }) =>
      CustomDialog(
        key: key,
        type: DialogType.warning,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
        canPop: canPop,
      );

  /// 5. حوار إرشادي ومعلوماتي (Info)
  factory CustomDialog.info({
    Key? key,
    required String title,
    required String message,
    String confirmLabel = 'فهمت ذلك',
    VoidCallback? onConfirm,
    bool canPop = true,
  }) =>
      CustomDialog(
        key: key,
        type: DialogType.info,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
        canPop: canPop,
      );

  /// 6. حوار مراجعة واعتماد الحساب بعد التسجيل (Pending Approval)
  factory CustomDialog.pending({
    Key? key,
    required String title,
    required String message,
    String confirmLabel = 'الانتقال لتسجيل الدخول',
    VoidCallback? onConfirm,
    bool canPop = false,
  }) =>
      CustomDialog(
        key: key,
        type: DialogType.pending,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
        canPop: canPop,
      );

  /// 7. حوار الحذف والإجراءات التدميرية (Danger)
  factory CustomDialog.danger({
    Key? key,
    required String title,
    required String message,
    String confirmLabel = 'حذف نهائي',
    String cancelLabel = 'إلغاء',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool canPop = true,
  }) =>
      CustomDialog(
        key: key,
        type: DialogType.danger,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
        canPop: canPop,
      );

  /// 8. حوار مخصص المحتوى (Custom)
  factory CustomDialog.custom({
    Key? key,
    required String title,
    required Widget content,
    String? confirmLabel,
    String? cancelLabel,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Widget? customHeader,
    bool canPop = true,
    double? maxWidth,
  }) =>
      CustomDialog(
        key: key,
        type: DialogType.custom,
        title: title,
        content: content,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
        customHeader: customHeader,
        canPop: canPop,
        maxWidth: maxWidth,
      );

  /// عرض الحوار كنافذة منبثقة تفاعلية عبر كائن الودجت
  Future<bool?> showDialog([BuildContext? context]) {
    return show(
      type: type,
      title: title,
      message: message,
      content: content,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      onConfirm: onConfirm,
      onCancel: onCancel,
      canPop: canPop,
      maxWidth: maxWidth,
      customHeader: customHeader,
      customAnimationPath: customAnimationPath,
    );
  }

  /// الدالة الاستاتيكية المركزية لعرض الحوار في النظام
  static Future<bool?> show({
    required DialogType type,
    required String title,
    String message = '',
    Widget? content,
    String? confirmLabel,
    String? cancelLabel,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool canPop = true,
    double? maxWidth,
    Widget? customHeader,
    String? customAnimationPath,
  }) async {
    return Get.generalDialog<bool>(
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: AppMotion.fast,
      pageBuilder: (context, animation, secondaryAnimation) {
        return PopScope(
          canPop: canPop,
          child: CustomDialog(
            type: type,
            title: title,
            message: message,
            content: content,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            onConfirm: onConfirm,
            onCancel: onCancel,
            canPop: canPop,
            maxWidth: maxWidth,
            customHeader: customHeader,
            customAnimationPath: customAnimationPath,
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  /// دوال الاستدعاء السريعة للتوافقية الكاملة عبر النظام:
  static Future<bool?> showConfirmation({
    required String title,
    required String message,
    String confirmLabel = 'تأكيد',
    String cancelLabel = 'إلغاء',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) =>
      show(
        type: DialogType.confirmation,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
      );

  static Future<bool?> showSuccess({
    required String title,
    required String message,
    String? confirmLabel,
    VoidCallback? onConfirm,
  }) =>
      show(
        type: DialogType.success,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
      );

  static Future<bool?> showPending({
    required String title,
    required String message,
    String? confirmLabel,
    VoidCallback? onConfirm,
    bool canPop = false,
  }) =>
      show(
        type: DialogType.pending,
        title: title,
        message: message,
        confirmLabel: confirmLabel ?? 'الانتقال لتسجيل الدخول',
        onConfirm: onConfirm,
        canPop: canPop,
      );

  static Future<bool?> showError({
    required String title,
    required String message,
    String? confirmLabel,
    VoidCallback? onConfirm,
  }) =>
      show(
        type: DialogType.error,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
      );

  static Future<bool?> showWarning({
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) =>
      show(
        type: DialogType.warning,
        title: title,
        message: message,
        confirmLabel: confirmLabel ?? 'تأكيد',
        cancelLabel: cancelLabel ?? 'إلغاء',
        onConfirm: onConfirm,
        onCancel: onCancel,
      );

  static Future<bool?> showDanger({
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) =>
      show(
        type: DialogType.danger,
        title: title,
        message: message,
        confirmLabel: confirmLabel ?? 'حذف',
        cancelLabel: cancelLabel ?? 'إلغاء',
        onConfirm: onConfirm,
        onCancel: onCancel,
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: RepaintBoundary(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            constraints: BoxConstraints(maxWidth: maxWidth ?? 380.w),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.dialog),
              boxShadow: AppElevation.level3(context),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.dialog),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. ترويسة الحوار والأيقونة أو الأنيميشن
                  DialogIconHeader(
                    type: type,
                    customHeader: customHeader,
                    customAnimationPath: customAnimationPath,
                  ),

                  // 2. جسم الحوار ونصوصه
                  DialogBodyContent(
                    title: title,
                    message: message,
                    content: content,
                  ),

                  // 3. أزرار الإجراءات الموحدة
                  DialogActionBar(
                    type: type,
                    confirmLabel: confirmLabel,
                    cancelLabel: cancelLabel,
                    onConfirm: onConfirm,
                    onCancel: onCancel,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
