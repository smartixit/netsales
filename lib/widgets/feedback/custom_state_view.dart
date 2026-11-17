import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/toasts/custom_toast.dart';
import 'package:netsales/widgets/feedback/custom_state_skeleton.dart';
import 'package:netsales/core/services/url_launcher_service.dart';

part 'custom_state_view_renderer.dart';

/// الحالات الموحدة المعتمدة لكل واجهات NetSales.
enum CustomStateKind {
  loading,
  empty,
  error,
  offline,
  pricingExpired,
}

/// طرق تقديم الحالة دون تغيير هويتها البصرية.
enum CustomStatePresentation {
  fullscreen,
  boxed,
  compact,
  banner,
  skeletonOnly,
}

/// مكوّن مركزي موحّد لحالات التحميل والفراغ والأخطاء والاتصال وانتهاء التعرفة.
///
/// تعتمد جميع الشاشات على هذا المكوّن، بينما تبقى مكونات Skeleton المتخصصة
/// متاحة للتحميل التدريجي داخل القوائم والجداول دون استبدال المحتوى المحمّل.
class CustomStateView extends StatelessWidget {
  const CustomStateView({
    super.key,
    required this.kind,
    required this.title,
    this.subtitle,
    this.presentation = CustomStatePresentation.boxed,
    this.badgeLabel,
    this.icon,
    this.accentColor,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.secondaryActionLabel,
    this.secondaryActionIcon,
    this.onSecondaryAction,
    this.customAction,
    this.technicalDetails,
    this.graphicSize,
    this.padding,
    this.showLoadingSkeleton = true,
    this.skeleton,
    this.skeletonBuilder,
  });

  const CustomStateView.loading({
    super.key,
    this.title = 'جارٍ تحميل البيانات',
    this.subtitle = 'نجهّز المحتوى المطلوب، يرجى الانتظار.',
    this.presentation = CustomStatePresentation.boxed,
    this.badgeLabel = 'جارٍ التحميل',
    this.icon = Icons.hourglass_top_rounded,
    this.accentColor,
    this.graphicSize,
    this.padding,
    this.showLoadingSkeleton = true,
    this.skeleton,
    this.skeletonBuilder,
  }) : kind = CustomStateKind.loading,
       actionLabel = null,
       actionIcon = null,
       onAction = null,
       secondaryActionLabel = null,
       secondaryActionIcon = null,
       onSecondaryAction = null,
       customAction = null,
       technicalDetails = null;

  const CustomStateView.empty({
    super.key,
    required this.title,
    this.subtitle,
    this.presentation = CustomStatePresentation.boxed,
    this.badgeLabel = 'لا توجد بيانات',
    this.icon = Icons.inbox_rounded,
    this.accentColor,
    this.actionLabel,
    this.actionIcon = Icons.add_rounded,
    this.onAction,
    this.secondaryActionLabel,
    this.secondaryActionIcon,
    this.onSecondaryAction,
    this.customAction,
    this.graphicSize,
    this.padding,
  }) : kind = CustomStateKind.empty,
       technicalDetails = null,
       showLoadingSkeleton = false,
       skeleton = null,
       skeletonBuilder = null;

  const CustomStateView.error({
    super.key,
    this.title = 'تعذر إكمال العملية',
    this.subtitle,
    this.presentation = CustomStatePresentation.boxed,
    this.badgeLabel = 'حدث خطأ',
    this.icon = Icons.error_outline_rounded,
    this.accentColor,
    this.actionLabel = 'إعادة المحاولة',
    this.actionIcon = Icons.refresh_rounded,
    this.onAction,
    this.secondaryActionLabel,
    this.secondaryActionIcon,
    this.onSecondaryAction,
    this.customAction,
    this.technicalDetails,
    this.graphicSize,
    this.padding,
  }) : kind = CustomStateKind.error,
       showLoadingSkeleton = false,
       skeleton = null,
       skeletonBuilder = null;

  const CustomStateView.offline({
    super.key,
    this.title = 'الاتصال غير متاح',
    this.subtitle = 'تحقق من اتصال الإنترنت ثم أعد المحاولة.',
    this.presentation = CustomStatePresentation.boxed,
    this.badgeLabel = 'OFFLINE',
    this.icon = Icons.wifi_off_rounded,
    this.accentColor,
    this.actionLabel = 'إعادة فحص الاتصال',
    this.actionIcon = Icons.refresh_rounded,
    this.onAction,
    this.secondaryActionLabel,
    this.secondaryActionIcon = Icons.settings_outlined,
    this.onSecondaryAction,
    this.customAction,
    this.graphicSize,
    this.padding,
  }) : kind = CustomStateKind.offline,
       technicalDetails = null,
       showLoadingSkeleton = false,
       skeleton = null,
       skeletonBuilder = null;

  const CustomStateView.pricingExpired({
    super.key,
    this.title = 'انتهت صلاحية التعرفة',
    this.subtitle = 'لم يعد عرض الأسعار الحالي صالحاً. حدّث التعرفة قبل إرسال الطلب.',
    this.presentation = CustomStatePresentation.boxed,
    this.badgeLabel = 'PRICING EXPIRED',
    this.icon = Icons.timer_off_rounded,
    this.accentColor,
    this.actionLabel = 'تحديث التعرفة',
    this.actionIcon = Icons.refresh_rounded,
    this.onAction,
    this.secondaryActionLabel,
    this.secondaryActionIcon,
    this.onSecondaryAction,
    this.customAction,
    this.graphicSize,
    this.padding,
  }) : kind = CustomStateKind.pricingExpired,
       technicalDetails = null,
       showLoadingSkeleton = false,
       skeleton = null,
       skeletonBuilder = null;

  final CustomStateKind kind;
  final String title;
  final String? subtitle;
  final CustomStatePresentation presentation;
  final String? badgeLabel;
  final IconData? icon;
  final Color? accentColor;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final IconData? secondaryActionIcon;
  final VoidCallback? onSecondaryAction;
  final Widget? customAction;
  final String? technicalDetails;
  final double? graphicSize;
  final EdgeInsetsGeometry? padding;
  final bool showLoadingSkeleton;
  final CustomStateSkeleton? skeleton;
  final WidgetBuilder? skeletonBuilder;

  @override
    @override
  Widget build(BuildContext context) => _buildStateView(context);
}
