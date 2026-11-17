import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/request_status.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// Request card built from the package card's layered visual language:
/// a focused identity hero, a distinct contents panel, and a precise metric rail.
class PosProcurementOrderCard extends StatelessWidget {
  const PosProcurementOrderCard({
    super.key,
    required this.request,
    required this.onDetails,
    this.onEdit,
    this.onCancel,
    this.onDelete,
  });

  final RequestEntity request;
  final VoidCallback onDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  String _dateLabel() {
    final raw = request.requestDate ?? request.createdAt;
    if (raw == null || raw.isEmpty) return 'التاريخ غير متاح';
    final parsed = DateTime.tryParse(raw);
    return parsed == null ? raw : DateFormatter.longDate(parsed);
  }

  String _timeLabel() {
    final raw = request.requestDate ?? request.createdAt;
    if (raw == null || raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    return parsed == null ? '' : DateFormatter.time(parsed);
  }

  Future<void> _showActions() async {
    final actions = <CustomBottomSheetActionItem>[
      if (onEdit != null)
        CustomBottomSheetActionItem(
          title: 'تعديل الطلب',
          icon: Icons.edit_note_rounded,
          onTap: onEdit!,
        ),
      if (onCancel != null)
        CustomBottomSheetActionItem(
          title: 'إلغاء الطلب',
          icon: Icons.cancel_outlined,
          isDestructive: true,
          onTap: onCancel!,
        ),
      if (onDelete != null)
        CustomBottomSheetActionItem(
          title: 'حذف من السجل',
          icon: Icons.delete_outline_rounded,
          isDestructive: true,
          onTap: onDelete!,
        ),
    ];
    if (actions.isEmpty) return;
    await CustomBottomSheet.showActions<void>(
      title: 'إجراءات الطلب #${request.requestId}',
      leadingIcon: Icons.more_horiz_rounded,
      items: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final status = EnumPresentationRegistry.resolveRequestStatus(
      request.status,
      serverLabel: request.statusLabel,
    );
    final saleType = EnumPresentationRegistry.resolveSaleType(
      request.saleType,
      serverLabel: request.saleTypeLabel,
    );
    final packages = request.items
        .map((item) => item.voucherPackage)
        .whereType<PackageEntity>()
        .toList(growable: false);
    final visiblePackages = packages.take(4).toList(growable: false);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.xxlRadius,
        border: Border.all(
          color: colors.primary.withValues(alpha: .17),
          width: 1,
        ),
        boxShadow: AppElevation.level3(context),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            width: 4.w,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.accentBadge(
                  context,
                  _statusColor(context, request.status),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _OrderIdentityHero(
                request: request,
                status: status,
                saleType: saleType,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  13.r,
                  12.r,
                  13.r,
                  12.r,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PackageSummaryPanel(
                      request: request,
                      packages: visiblePackages,
                    ),
                    AppSpacing.vSm,
                    _OrderMetricRail(
                      itemCount: request.items.length,
                      totalQuantity: request.totalVouchers,
                      saleType: saleType,
                    ),
                    AppSpacing.vSm,
                    Row(
                      children: [
                        if (onEdit != null ||
                            onCancel != null ||
                            onDelete != null) ...[
                          CustomButton.icon(
                            icon: Icons.more_vert_rounded,
                            tooltip: 'إجراءات أخرى',
                            dimension: 38.r,
                            backgroundColor: colors.surfaceContainerHigh,
                            foregroundColor: colors.onSurfaceVariant,
                            borderColor: colors.outlineVariant.withValues(alpha: .75),
                            onPressed: _showActions,
                          ),
                          AppSpacing.hXs,
                        ],
                        CustomButton.outline(
                          text: 'عرض التفاصيل',
                          icon: Icons.chevron_left_rounded,
                          iconPosition: AppButtonIconPosition.end,
                          width: 142.w,
                          height: 40.h,
                          size: AppButtonSize.small,
                          foregroundColor: colors.primary,
                          borderColor: colors.primary.withValues(alpha: .72),
                          onPressed: onDetails,
                        ),
                        const Spacer(),
                        Text(
                          request.requestUuid?.isNotEmpty == true
                              ? request.requestUuid!
                              : 'طلب #${request.requestId}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(BuildContext context, RequestStatus status) {
    final colors = context.colors;
    final presentation = EnumPresentationRegistry.resolveRequestStatus(status);
    return switch (presentation.tone.name) {
      'success' => colors.success,
      'warning' => colors.warning,
      'danger' => colors.error,
      _ => colors.onSurfaceVariant,
    };
  }
}

class _OrderIdentityHero extends StatelessWidget {
  const _OrderIdentityHero({
    required this.request,
    required this.status,
    required this.saleType,
  });

  final RequestEntity request;
  final dynamic status;
  final dynamic saleType;

  String _dateLabel() {
    final raw = request.requestDate ?? request.createdAt;
    if (raw == null || raw.isEmpty) return 'التاريخ غير متاح';
    final parsed = DateTime.tryParse(raw);
    return parsed == null ? raw : DateFormatter.longDate(parsed);
  }

  String _timeLabel() {
    final raw = request.requestDate ?? request.createdAt;
    if (raw == null || raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    return parsed == null ? '' : DateFormatter.time(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(13.r),
      decoration: BoxDecoration(
        gradient: AppGradients.accentHero3(context, colors.primary),
        border: Border(
          bottom: BorderSide(
            color: colors.primary.withValues(alpha: .10),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 54.r,
            height: 58.r,
            decoration: BoxDecoration(
              gradient: AppGradients.financialHero(context),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: colors.onPrimary.withValues(alpha: .22),
              ),
              boxShadow: AppElevation.tinted(
                context,
                colors.primary,
                alpha: .16,
                blur: 12,
                dy: 4,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  color: colors.onPrimary,
                  size: 27.r,
                ),
                PositionedDirectional(
                  end: 7.r,
                  top: 7.r,
                  child: Container(
                    width: 7.r,
                    height: 7.r,
                    decoration: BoxDecoration(
                      color: colors.tertiary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.onPrimary, width: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'طلب توريد #${request.requestId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    AppSpacing.hXxs,
                    CustomStatusBadge.fromPresentation(
                      status,
                      isCompact: true,
                    ),
                  ],
                ),
                AppSpacing.vXs,
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xxs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _OrderMetaItem(
                      icon: Icons.calendar_today_rounded,
                      label: _dateLabel(),
                    ),
                    if (_timeLabel().isNotEmpty)
                      _OrderMetaItem(
                        icon: Icons.schedule_rounded,
                        label: _timeLabel(),
                      ),
                  ],
                ),
                AppSpacing.vXs,
                CustomStatusBadge.fromPresentation(
                  saleType,
                  isCompact: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderMetaItem extends StatelessWidget {
  const _OrderMetaItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.r, color: colors.onSurfaceVariant),
        AppSpacing.hXxs,
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.caption.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PackageSummaryPanel extends StatelessWidget {
  const _PackageSummaryPanel({
    required this.request,
    required this.packages,
  });

  final RequestEntity request;
  final List<PackageEntity> packages;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final packageCount = request.items.length;
    final visibleNames = packages.take(2).map((package) => package.packageName).toList();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 11.r),
      decoration: BoxDecoration(
        gradient: AppGradients.accentHero3(context, colors.primary),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: colors.primary.withValues(alpha: .13),
        ),
      ),
      child: Row(
        children: [
          _PackageAccentStack(packages: packages),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  packageCount == 0
                      ? 'لا توجد باقات'
                      : '$packageCount ${packageCount == 1 ? 'باقة' : 'باقات'}',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  '${request.totalVouchers} وحدة',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (visibleNames.isNotEmpty) ...[
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
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: .76),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: colors.primary.withValues(alpha: .12),
              ),
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              color: colors.primary,
              size: 21.r,
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageAccentStack extends StatelessWidget {
  const _PackageAccentStack({required this.packages});

  final List<PackageEntity> packages;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (packages.isEmpty) {
      return Container(
        width: 7.r,
        height: 34.r,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: .25),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < packages.length; index++) ...[
          if (index > 0) AppSpacing.hXxs,
          Container(
            key: packages.length == 1
                ? const ValueKey('pos-order-package-color-accent')
                : ValueKey('pos-order-package-color-accent-${packages[index].packageId}'),
            width: 6.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: CustomColorPicker.parseHex(
                packages[index].packageColor,
                fallback: colors.primary,
              ),
              borderRadius: BorderRadius.circular(AppRadius.full),
              boxShadow: AppElevation.level1(context),
            ),
          ),
        ],
      ],
    );
  }
}

class _OrderMetricRail extends StatelessWidget {
  const _OrderMetricRail({
    required this.itemCount,
    required this.totalQuantity,
    required this.saleType,
  });

  final int itemCount;
  final int totalQuantity;
  final dynamic saleType;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.r, vertical: 10.r),
      decoration: BoxDecoration(
        gradient: AppGradients.accentBadge(context, colors.primary),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colors.primary.withValues(alpha: .10),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _OrderMetric(
              label: 'عدد البنود',
              value: itemCount.toString(),
              icon: Icons.list_alt_rounded,
            ),
          ),
          _MetricDivider(),
          Expanded(
            child: _OrderMetric(
              label: 'إجمالي الكمية',
              value: totalQuantity.toString(),
              icon: Icons.confirmation_number_outlined,
            ),
          ),
          _MetricDivider(),
          Expanded(
            child: _OrderMetric(
              label: 'نوع البيع',
              value: saleType.label,
              icon: saleType.icon ?? Icons.sell_outlined,
              emphasize: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderMetric extends StatelessWidget {
  const _OrderMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15.r,
            color: emphasize ? colors.primary : colors.onSurfaceVariant,
          ),
          AppSpacing.vXxs,
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          AppSpacing.vXxs,
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.titleSmall.copyWith(
              color: emphasize ? colors.primary : colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 44.h,
        color: context.colors.outlineVariant.withValues(alpha: .55),
      );
}
