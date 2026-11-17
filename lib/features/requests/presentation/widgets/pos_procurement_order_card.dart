import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/request_status.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

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

  Color _statusAccent(BuildContext context) {
    final colors = context.colors;
    return switch (request.status) {
      RequestStatus.pending => colors.warning,
      RequestStatus.approved => colors.success,
      RequestStatus.rejected => colors.error,
      RequestStatus.cancelled => colors.onSurfaceVariant,
      RequestStatus.unknown => colors.outline,
    };
  }

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

  Future<void> _showActions() {
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
    if (actions.isEmpty) return Future<void>.value();
    return CustomBottomSheet.showActions<void>(
      title: 'إجراءات الطلب #${request.requestId}',
      leadingIcon: Icons.more_horiz_rounded,
      items: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = _statusAccent(context);
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
        .whereType<dynamic>()
        .toList(growable: false);
    final visibleColors = packages.take(4).toList(growable: false);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.38)),
        boxShadow: AppElevation.level2(context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 4.w, color: accent),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'طلب توريد #${request.requestUuid ?? request.requestId}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.titleMedium.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            AppSpacing.vXs,
                            Wrap(
                              spacing: AppSpacing.xs,
                              runSpacing: AppSpacing.xxs,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Icon(Icons.calendar_today_rounded, size: 13.r, color: colors.onSurfaceVariant),
                                Text(_dateLabel(), style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant)),
                                if (_timeLabel().isNotEmpty) ...[
                                  Icon(Icons.schedule_rounded, size: 13.r, color: colors.onSurfaceVariant),
                                  Text(_timeLabel(), style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant)),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.hXs,
                      CustomStatusBadge.fromPresentation(status, isCompact: true),
                    ],
                  ),
                  AppSpacing.vMd,
                  Row(
                    children: [
                      if (visibleColors.isNotEmpty)
                        Row(
                          children: visibleColors.map((package) {
                            final color = CustomColorPicker.parseHex(
                              package.packageColor,
                              fallback: colors.primary,
                            );
                            return Container(
                              width: 7.r,
                              height: 30.r,
                              margin: EdgeInsetsDirectional.only(end: 5.w),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(AppRadius.full),
                              ),
                            );
                          }).toList(growable: false),
                        )
                      else
                        Icon(Icons.inventory_2_outlined, color: colors.primary, size: 22.r),
                      AppSpacing.hSm,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${request.items.length} ${request.items.length == 1 ? 'باقة' : 'باقات'}',
                              style: AppTypography.titleSmall.copyWith(color: colors.onSurface, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${request.totalVouchers} وحدة',
                              style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vMd,
                  Divider(height: 1, color: colors.outlineVariant.withValues(alpha: 0.35)),
                  AppSpacing.sm,
                  Row(
                    children: [
                      Expanded(child: _Metric(label: 'عدد البنود', value: request.items.length.toString())),
                      _MetricDivider(),
                      Expanded(child: _Metric(label: 'إجمالي الكمية', value: request.totalVouchers.toString())),
                      _MetricDivider(),
                      Expanded(child: _Metric(label: 'نوع السعر', value: saleType.label)),
                    ],
                  ),
                  AppSpacing.sm,
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AmountFormatter.format(request.requestTotalAmount.toString()),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleMedium.copyWith(color: colors.primary, fontWeight: FontWeight.w800),
                        ),
                      ),
                      CustomButton.outline(
                        text: 'عرض التفاصيل',
                        icon: Icons.chevron_left_rounded,
                        iconPosition: AppButtonIconPosition.end,
                        size: AppButtonSize.small,
                        onPressed: onDetails,
                      ),
                      if (onEdit != null || onCancel != null || onDelete != null) ...[
                        AppSpacing.hXs,
                        CustomButton.icon(
                          icon: Icons.more_vert_rounded,
                          tooltip: 'إجراءات أخرى',
                          dimension: 36.r,
                          backgroundColor: colors.surfaceContainerHighest,
                          foregroundColor: colors.onSurfaceVariant,
                          onPressed: _showActions,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant)),
        AppSpacing.vXxs,
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.titleSmall.copyWith(color: colors.onSurface, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 34.h,
    color: context.colors.outlineVariant.withValues(alpha: 0.45),
  );
}
