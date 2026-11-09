import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

class RepaymentAllocationTimeline extends StatelessWidget {
  const RepaymentAllocationTimeline({super.key, required this.allocations});

  final List<RepaymentAllocationEntity> allocations;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'توزيع السداد على الفواتير',
                style: AppTypography.titleMedium.copyWith(
                  color: colors.onSurface,
                ),
              ),
            ),
            CustomChip(
              label: '${allocations.length} فاتورة',
              icon: Icons.account_balance_outlined,
              isCompact: true,
            ),
          ],
        ),
        AppSpacing.vXxs,
        Text(
          'تفاصيل التوزيع المسجلة من الخادم لكل فاتورة.',
          style: AppTypography.bodySmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        AppSpacing.vMd,
        if (allocations.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: AppRadius.lgRadius,
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              'لا توجد تفاصيل توزيع مرتبطة بهذا السند.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allocations.length,
            separatorBuilder: (context, index) => AppSpacing.vSm,
            itemBuilder: (context, index) {
              final allocation = allocations[index];
              return _AllocationCard(
                allocation: allocation,
                onTap: allocation.invoiceId > 0
                    ? () => Get.toNamed<void>(
                        AppRoutes.saleInvoiceDetails,
                        arguments: allocation.invoiceId,
                      )
                    : null,
              );
            },
          ),
      ],
    );
  }
}

class _AllocationCard extends StatelessWidget {
  const _AllocationCard({required this.allocation, required this.onTap});

  final RepaymentAllocationEntity allocation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final invoice = allocation.invoice;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.lgRadius,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: AppSpacing.xxxl,
                  height: AppSpacing.xxxl,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: AppRadius.mdRadius,
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    color: colors.primary,
                    size: AppSpacing.xl,
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'فاتورة #${allocation.invoiceId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleSmall.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                      Text(
                        _dateLabel(invoice.invoiceDate),
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.open_in_new_rounded,
                    color: colors.primary,
                    size: AppSpacing.lg,
                  ),
              ],
            ),
            AppSpacing.vSm,
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                CustomChip(label: invoice.paymentStatusLabel, isCompact: true),
                CustomChip(
                  label: invoice.saleTypeLabel,
                  icon: Icons.sell_outlined,
                  isCompact: true,
                ),
              ],
            ),
            AppSpacing.vMd,
            Wrap(
              spacing: AppSpacing.xl,
              runSpacing: AppSpacing.sm,
              children: [
                _InvoiceValue(
                  label: 'قيمة الفاتورة',
                  value: invoice.totalAmount,
                ),
                _InvoiceValue(label: 'المسدد', value: invoice.paidAmount),
                _InvoiceValue(label: 'المتبقي', value: invoice.remainingAmount),
              ],
            ),
            AppSpacing.vMd,
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.28),
                borderRadius: AppRadius.mdRadius,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'المبلغ المخصص من هذا السند',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Text(
                    AmountFormatter.format(
                      allocation.allocatedAmount.toString(),
                    ),
                    style: AppTypography.titleMedium.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dateLabel(String value) {
    if (value.length <= 10) return value;
    return value.substring(0, 10);
  }
}

class _InvoiceValue extends StatelessWidget {
  const _InvoiceValue({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        AppSpacing.vXxs,
        Text(
          AmountFormatter.format(value.toString()),
          style: AppTypography.titleSmall.copyWith(color: colors.onSurface),
        ),
      ],
    );
  }
}
