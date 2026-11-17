import 'package:flutter/material.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';

/// أنماط عرض الحالة الفارغة (Empty State Variants).
enum EmptyStateVariant { fullscreen, boxed, compact }

/// Canonical empty-state component using the shared visual state presenter.
class CustomEmptyState extends StatelessWidget {
  const CustomEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.badgeText,
    this.badgeIcon,
    this.animationPath = 'assets/animations/no_data.json',
    this.icon,
    this.iconColor,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.secondaryActionIcon,
    this.customAction,
    this.variant = EmptyStateVariant.fullscreen,
    this.graphicSize,
    this.padding,
  }) : compact = (variant == EmptyStateVariant.compact);

  const CustomEmptyState.boxed({
    super.key,
    required this.title,
    this.subtitle,
    this.badgeText,
    this.badgeIcon,
    this.animationPath = 'assets/animations/no_data.json',
    this.icon,
    this.iconColor,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.secondaryActionIcon,
    this.customAction,
    this.graphicSize,
    this.padding,
  }) : variant = EmptyStateVariant.boxed,
       compact = false;

  const CustomEmptyState.compact({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.actionLabel,
    this.onAction,
    this.padding,
  }) : badgeText = null,
       badgeIcon = null,
       animationPath = null,
       actionIcon = null,
       secondaryActionLabel = null,
       onSecondaryAction = null,
       secondaryActionIcon = null,
       customAction = null,
       graphicSize = null,
       variant = EmptyStateVariant.compact,
       compact = true;

  factory CustomEmptyState.search({
    Key? key,
    required String query,
    VoidCallback? onClearSearch,
    String? subtitle,
  }) {
    return CustomEmptyState(
      key: key,
      badgeText: 'نتائج البحث',
      badgeIcon: Icons.search_rounded,
      icon: Icons.search_off_rounded,
      animationPath: null,
      title: 'لم يتم العثور على أي نتائج',
      subtitle: subtitle ??
          (query.isNotEmpty
              ? 'لم تتطابق نتائج البحث مع "$query". يرجى التحقق من صحة الكلمات أو إعادة التصفية.'
              : 'لم نتمكن من العثور على أي سجلات متطابقة مع معايير البحث الحالية.'),
      actionLabel: onClearSearch != null ? 'مسح البحث' : null,
      actionIcon: Icons.clear_rounded,
      onAction: onClearSearch,
    );
  }

  final String title;
  final String? subtitle;
  final String? badgeText;
  final IconData? badgeIcon;

  /// محفوظ للتوافق العكسي؛ الرسم الموحد يعتمد الآن على أيقونات الحالة.
  final String? animationPath;

  final IconData? icon;
  final Color? iconColor;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final IconData? secondaryActionIcon;
  final Widget? customAction;
  final EmptyStateVariant variant;
  final double? graphicSize;
  final EdgeInsetsGeometry? padding;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final presentation = compact || variant == EmptyStateVariant.compact
        ? CustomStatePresentation.compact
        : variant == EmptyStateVariant.boxed
            ? CustomStatePresentation.boxed
            : CustomStatePresentation.fullscreen;

    return CustomStateView(
      kind: CustomStateKind.empty,
      title: title,
      subtitle: subtitle,
      presentation: presentation,
      badgeLabel: badgeText,
      icon: icon ?? badgeIcon,
      accentColor: iconColor,
      actionLabel: actionLabel,
      actionIcon: actionIcon,
      onAction: onAction,
      secondaryActionLabel: secondaryActionLabel,
      secondaryActionIcon: secondaryActionIcon,
      onSecondaryAction: onSecondaryAction,
      customAction: customAction,
      graphicSize: graphicSize,
      padding: padding,
    );
  }
}
