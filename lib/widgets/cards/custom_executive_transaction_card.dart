import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/cards/models/executive_card_item_data.dart';
import 'package:netsales/widgets/cards/models/executive_card_metric_data.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

export 'package:netsales/widgets/cards/models/executive_card_item_data.dart';
export 'package:netsales/widgets/cards/models/executive_card_metric_data.dart';

/// بطاقة المعاملة والسجلات التنفيذية الموحدة لنظام NetSales (Executive Transaction Card)
///
/// المرجع التصميمي والمعماري الموحد لبطاقات المعاملات في النظام (الطلبات، الفواتير، المصروفات):
/// - إطار فاخر بحواف 24.r وظلال مزدوجة متناسقة ومقاومة كاملة للتجاوز.
/// - ترويسة بهوية المعاملة (UUID / Reference)، الأيقونة الديناميكية المتدرجة، بيانات الطرف الآخر، شارة الحالة المعتمدة، وشارة النوع.
/// - أكورديون تفاعلي يعرض مؤشرات البنود الملونة، تفاصيل الأوراق والكميات، والقيم والخصومات.
/// - سكة قياسات ثلاثية محمية بـ FittedBox ومقسمة بفواصل دقيقة.
/// - شريط أزرار إجراءات يتكيف تلقائياً مع السياق التشغيلي.
class CustomExecutiveTransactionCard extends StatelessWidget {
  const CustomExecutiveTransactionCard({
    super.key,
    required this.reference,
    required this.dateLabel,
    required this.partyName,
    this.partyLogoUrl,
    this.partyPhone,
    this.isPartyVerified = false,
    this.actorLabel,
    required this.statusPresentation,
    this.typePresentation,
    this.secondaryReference,
    this.onSecondaryReferenceTap,
    required this.items,
    this.itemsHeaderTitle,
    this.visibleItemNames = const [],
    required this.metrics,
    this.actions,
    required this.onTap,
    this.isExpanded = false,
    this.onToggleExpand,
  });

  final String reference;
  final String dateLabel;
  final String partyName;
  final String? partyLogoUrl;
  final String? partyPhone;
  final bool isPartyVerified;
  final String? actorLabel;
  final EnumPresentation statusPresentation;
  final EnumPresentation? typePresentation;
  final String? secondaryReference;
  final VoidCallback? onSecondaryReferenceTap;
  final List<ExecutiveCardItemData> items;
  final String? itemsHeaderTitle;
  final List<String> visibleItemNames;
  final List<ExecutiveCardMetricData> metrics;
  final Widget? actions;
  final VoidCallback onTap;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: colors.primary.withValues(alpha: .15),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.emeraldDeep.withValues(alpha: .065),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: .025),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 1. ترويسة هوية المعاملة والطرف المقابل ──
            _ExecutiveCardHeader(
              reference: reference,
              dateLabel: dateLabel,
              partyName: partyName,
              partyLogoUrl: partyLogoUrl,
              partyPhone: partyPhone,
              isPartyVerified: isPartyVerified,
              actorLabel: actorLabel,
              statusPresentation: statusPresentation,
              typePresentation: typePresentation,
              secondaryReference: secondaryReference,
              onSecondaryReferenceTap: onSecondaryReferenceTap,
            ),

            // ── 2. المحتوى الداخلي للبطاقة ──
            Padding(
              padding: EdgeInsets.fromLTRB(14.r, 12.r, 14.r, 14.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // لوحة البنود بنظام الأكورديون
                  if (items.isNotEmpty) ...[
                    _ExecutiveCardAccordion(
                      items: items,
                      headerTitle: itemsHeaderTitle,
                      visibleNames: visibleItemNames,
                      isExpanded: isExpanded,
                      onToggle: onToggleExpand,
                    ),
                    AppSpacing.vSm,
                  ],

                  // سكة القياسات المالية والتشغيلية
                  if (metrics.isNotEmpty) ...[
                    _ExecutiveCardMetricsBar(metrics: metrics),
                    AppSpacing.vSm,
                  ],

                  // شريط أزرار الإجراءات السريعة
                  ?actions,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ترويسة البطاقة التنفيذية
class _ExecutiveCardHeader extends StatelessWidget {
  const _ExecutiveCardHeader({
    required this.reference,
    required this.dateLabel,
    required this.partyName,
    this.partyLogoUrl,
    this.partyPhone,
    this.isPartyVerified = false,
    this.actorLabel,
    required this.statusPresentation,
    this.typePresentation,
    this.secondaryReference,
    this.onSecondaryReferenceTap,
  });

  final String reference;
  final String dateLabel;
  final String partyName;
  final String? partyLogoUrl;
  final String? partyPhone;
  final bool isPartyVerified;
  final String? actorLabel;
  final EnumPresentation statusPresentation;
  final EnumPresentation? typePresentation;
  final String? secondaryReference;
  final VoidCallback? onSecondaryReferenceTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final toneColor = statusPresentation.tone.color(context);
    final iconGradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [toneColor, toneColor.withValues(alpha: 0.85)],
    );
    final iconBorderColor = toneColor.withValues(alpha: 0.40);
    final iconShadowColor = toneColor.withValues(alpha: 0.25);
    final statusIcon = statusPresentation.icon;
    final partyInitial = TextFormatter.avatarInitial(partyName);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 12.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            iconShadowColor.withValues(alpha: .06),
            iconShadowColor.withValues(alpha: .015),
            Colors.transparent,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: iconShadowColor.withValues(alpha: .08),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة الحالة الديناميكية المتدرجة
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              gradient: iconGradient,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: iconBorderColor, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: iconShadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(statusIcon, color: Colors.white, size: 22.r),
          ),
          AppSpacing.hSm,

          // البيانات القيادية للترويسة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // السطر 1: المعرف + زر النسخ + المرجع الثانوي
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                reference,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.titleSmall.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          AppSpacing.hXxs,
                          CustomInteractiveBounce(
                            onTap: () =>
                                UrlLauncherService.copyToClipboard(reference),
                            child: Padding(
                              padding: EdgeInsets.all(3.r),
                              child: Icon(
                                Icons.copy_rounded,
                                size: 13.r,
                                color: colors.onSurfaceVariant.withValues(
                                  alpha: .65,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (secondaryReference != null) ...[
                      AppSpacing.hXs,
                      CustomInteractiveBounce(
                        onTap: onSecondaryReferenceTap,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: .10),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: .30),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.receipt_rounded,
                                size: 11.r,
                                color: colors.primary,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                secondaryReference!,
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 5.h),

                // السطر 2: الطرف الآخر (الشعار، الاسم، والتحقق)
                Row(
                  children: [
                    CustomAvatarBadge(
                      imageUrl: partyLogoUrl,
                      initials: partyInitial,
                      size: AvatarBadgeSize.sm,
                      customDimension: 20.r,
                      hasPulse: false,
                    ),
                    AppSpacing.hXs,
                    Flexible(
                      child: Text(
                        partyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isPartyVerified) ...[
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.verified_rounded,
                        size: 13.r,
                        color: colors.emeraldDeep,
                      ),
                    ],
                    if (partyPhone != null) ...[
                      AppSpacing.hXs,
                      Flexible(
                        child: Text(
                          '• ${partyPhone!}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),

                // السطر 3: التاريخ وفاعل المعاملة
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 12.r,
                      color: colors.onSurfaceVariant,
                    ),
                    AppSpacing.hXxs,
                    Flexible(
                      child: Text(
                        dateLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (actorLabel != null && actorLabel!.isNotEmpty) ...[
                      AppSpacing.hXs,
                      Flexible(
                        child: Text(
                          '• $actorLabel',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 6.h),

                // السطر 4: شريط الشارات الدلالية المعتمدة
                Row(
                  children: [
                    CustomStatusBadge.fromPresentation(statusPresentation),
                    if (typePresentation != null) ...[
                      AppSpacing.hXs,
                      CustomStatusBadge.fromPresentation(typePresentation!),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// أكورديون بنود المعاملة
class _ExecutiveCardAccordion extends StatelessWidget {
  const _ExecutiveCardAccordion({
    required this.items,
    this.headerTitle,
    this.visibleNames = const [],
    required this.isExpanded,
    this.onToggle,
  });

  final List<ExecutiveCardItemData> items;
  final String? headerTitle;
  final List<String> visibleNames;
  final bool isExpanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final title = headerTitle ?? 'الباقات والكميات (${items.length})';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.fastOutSlowIn,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isExpanded
              ? colors.primary.withValues(alpha: .35)
              : colors.outlineVariant.withValues(alpha: .5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // شريط رأس الأكورديون
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: onToggle,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 10.r),
                child: Row(
                  children: [
                    // مؤشرات الألوان الأربعة الأولى للباقات
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < items.take(4).length; i++) ...[
                          if (i > 0) AppSpacing.hXxs,
                          Container(
                            width: 5.r,
                            height: 30.r,
                            decoration: BoxDecoration(
                              color: CustomColorPicker.parseHex(
                                items[i].colorHex,
                                fallback: colors.primary,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: AppTypography.labelLarge.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (visibleNames.isNotEmpty && !isExpanded) ...[
                            AppSpacing.vXxs,
                            Text(
                              visibleNames.join(' • '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isExpanded ? 'إخفاء البنود' : 'عرض البنود',
                          style: AppTypography.caption.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppSpacing.hXxs,
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.fastOutSlowIn,
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: colors.primary,
                            size: 20.r,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // محتوى البنود المتمدد
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(10.r, 0, 10.r, 10.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(
                    color: colors.outlineVariant.withValues(alpha: .25),
                    height: 1,
                  ),
                  for (final item in items) ...[
                    AppSpacing.vSm,
                    _ExecutiveCardItemRow(item: item),
                  ],
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 280),
            sizeCurve: Curves.easeInOutCubic,
          ),
        ],
      ),
    );
  }
}

/// سطر البند الفردي داخل الأكورديون
class _ExecutiveCardItemRow extends StatelessWidget {
  const _ExecutiveCardItemRow({required this.item});

  final ExecutiveCardItemData item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4.r,
          height: 28.r,
          decoration: BoxDecoration(
            color: CustomColorPicker.parseHex(
              item.colorHex,
              fallback: colors.primary,
            ),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
        AppSpacing.hSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (item.subtitle != null) ...[
                AppSpacing.vXxs,
                Text(
                  item.subtitle!,
                  style: AppTypography.caption.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        AppSpacing.hSm,
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                AmountFormatter.formatValue(item.totalAmount),
                style: AppTypography.labelLarge.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (item.discountAmount > 0)
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  'خصم: ${AmountFormatter.formatValue(item.discountAmount)}',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// سكة القياسات الثلاثية الموحدة
class _ExecutiveCardMetricsBar extends StatelessWidget {
  const _ExecutiveCardMetricsBar({required this.metrics});

  final List<ExecutiveCardMetricData> metrics;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 10.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .4)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < metrics.length; i++) ...[
            if (i > 0)
              Container(
                width: 1.0,
                height: 28.r,
                margin: EdgeInsets.symmetric(horizontal: 6.r),
                color: colors.outlineVariant.withValues(alpha: .5),
              ),
            Expanded(
              flex: metrics[i].flex,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    metrics[i].label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      metrics[i].value,
                      maxLines: 1,
                      style: metrics[i].isEmphasized
                          ? AppTypography.titleMedium.copyWith(
                              color: metrics[i].textColor ?? colors.primary,
                              fontWeight: FontWeight.w900,
                            )
                          : AppTypography.labelLarge.copyWith(
                              color: metrics[i].textColor ?? colors.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
