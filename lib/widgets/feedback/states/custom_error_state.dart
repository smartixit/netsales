import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';

/// تصنيفات الأخطاء التشغيلية.
enum ErrorStateType { general, connection, server, auth, notFound }

/// أنماط عرض حالة الخطأ.
enum ErrorStateVariant { fullscreen, boxed, compact }

/// Canonical error-state component. Visual rendering is delegated to the shared state presenter.
class CustomErrorState extends StatelessWidget {
  const CustomErrorState({
    super.key,
    required this.title,
    this.subtitle,
    this.retryLabel = 'إعادة المحاولة',
    this.onRetry,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.secondaryActionIcon,
    this.type = ErrorStateType.general,
    this.variant = ErrorStateVariant.fullscreen,
    this.errorCode,
    this.technicalDetails,
    this.animationPath,
    this.icon,
    this.customAction,
    this.padding,
  });

  factory CustomErrorState.connection({
    Key? key,
    String title = 'تعذر الاتصال بالشبكة',
    String subtitle = 'يرجى التحقق من اتصالك بالإنترنت أو بيانات الهاتف ثم المحاولة مجدداً.',
    String retryLabel = 'إعادة فحص الاتصال',
    VoidCallback? onRetry,
    VoidCallback? onOpenSettings,
  }) {
    return CustomErrorState(
      key: key,
      title: title,
      subtitle: subtitle,
      retryLabel: retryLabel,
      onRetry: onRetry,
      secondaryActionLabel: onOpenSettings != null ? 'إعدادات الشبكة' : null,
      onSecondaryAction: onOpenSettings,
      secondaryActionIcon: Icons.settings_outlined,
      type: ErrorStateType.connection,
      errorCode: 'OFFLINE',
      icon: Icons.wifi_off_rounded,
    );
  }

  factory CustomErrorState.server({
    Key? key,
    String title = 'الخدمة غير متاحة مؤقتاً',
    String subtitle = 'حدث خطأ غير متوقع أثناء معالجة الطلب في الخادم. يجري العمل على حل المشكلة.',
    String retryLabel = 'إعادة المحاولة',
    VoidCallback? onRetry,
    String? technicalDetails,
    String? errorCode = 'ERR_500',
  }) {
    return CustomErrorState(
      key: key,
      title: title,
      subtitle: subtitle,
      retryLabel: retryLabel,
      onRetry: onRetry,
      type: ErrorStateType.server,
      errorCode: errorCode,
      technicalDetails: technicalDetails,
      icon: Icons.cloud_off_rounded,
    );
  }

  const CustomErrorState.boxed({
    super.key,
    required this.title,
    this.subtitle,
    this.retryLabel = 'إعادة المحاولة',
    this.onRetry,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.secondaryActionIcon,
    this.type = ErrorStateType.general,
    this.errorCode,
    this.technicalDetails,
    this.animationPath,
    this.icon,
    this.customAction,
    this.padding,
  }) : variant = ErrorStateVariant.boxed;

  const CustomErrorState.compact({
    super.key,
    required this.title,
    this.subtitle,
    this.retryLabel = 'إعادة المحاولة',
    this.onRetry,
    this.icon,
    this.padding,
  }) : secondaryActionLabel = null,
       onSecondaryAction = null,
       secondaryActionIcon = null,
       type = ErrorStateType.general,
       errorCode = null,
       technicalDetails = null,
       animationPath = null,
       customAction = null,
       variant = ErrorStateVariant.compact;

  final String title;
  final String? subtitle;
  final String retryLabel;
  final VoidCallback? onRetry;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final IconData? secondaryActionIcon;
  final ErrorStateType type;
  final ErrorStateVariant variant;
  final String? errorCode;
  final String? technicalDetails;

  /// محفوظ للتوافق العكسي؛ يستخدم المكوّن الموحد الرسوم والرموز المشتركة.
  final String? animationPath;

  final IconData? icon;
  final Widget? customAction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final presentation = switch (variant) {
      ErrorStateVariant.fullscreen => CustomStatePresentation.fullscreen,
      ErrorStateVariant.boxed => CustomStatePresentation.boxed,
      ErrorStateVariant.compact => CustomStatePresentation.compact,
    };
    final isOffline = type == ErrorStateType.connection;
    final accent = switch (type) {
      ErrorStateType.connection || ErrorStateType.auth => colors.warning,
      ErrorStateType.notFound => colors.secondary,
      ErrorStateType.server || ErrorStateType.general => colors.error,
    };
    final defaultBadge = switch (type) {
      ErrorStateType.connection => 'انقطاع الاتصال',
      ErrorStateType.server => 'خطأ في الخادم',
      ErrorStateType.auth => 'التحقق من الوصول',
      ErrorStateType.notFound => 'غير موجود',
      ErrorStateType.general => 'خطأ في النظام',
    };

    return CustomStateView(
      kind: isOffline ? CustomStateKind.offline : CustomStateKind.error,
      title: title,
      subtitle: subtitle,
      presentation: presentation,
      badgeLabel: errorCode ?? defaultBadge,
      icon: icon ?? (isOffline ? Icons.wifi_off_rounded : _defaultIcon()),
      accentColor: accent,
      actionLabel: variant == ErrorStateVariant.compact && onRetry == null
          ? null
          : retryLabel,
      actionIcon: Icons.refresh_rounded,
      onAction: onRetry,
      secondaryActionLabel: secondaryActionLabel,
      secondaryActionIcon: secondaryActionIcon,
      onSecondaryAction: onSecondaryAction,
      customAction: customAction,
      technicalDetails: technicalDetails,
      padding: padding,
    );
  }

  IconData _defaultIcon() {
    return switch (type) {
      ErrorStateType.connection => Icons.wifi_off_rounded,
      ErrorStateType.server => Icons.cloud_off_rounded,
      ErrorStateType.auth => Icons.lock_clock_rounded,
      ErrorStateType.notFound => Icons.search_off_rounded,
      ErrorStateType.general => Icons.error_outline_rounded,
    };
  }
}
