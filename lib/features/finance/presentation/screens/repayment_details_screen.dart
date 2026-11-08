import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

class RepaymentDetailsScreen extends StatelessWidget {
  final PosRepaymentEntity? repayment;

  const RepaymentDetailsScreen({super.key, this.repayment});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final item = repayment ?? (Get.arguments is PosRepaymentEntity ? Get.arguments as PosRepaymentEntity : null);

    if (item == null) {
      return const CustomAppScaffold(
        body: Center(
          child: CustomEmptyState(
            title: 'لم يتم العثور على السند',
            subtitle: 'تعذر تحديد بيانات سند التحصيل المطلوب',
          ),
        ),
      );
    }

    return CustomAppScaffold(
      appBar: AppBar(title: Text('سند سداد #${item.repaymentId}')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'بيانات سند التحصيل المالي',
                        style: AppTypography.titleMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CustomStatusBadge(
                        label: item.isCompleted ? 'سداد مكتمل' : 'معكوس',
                        tone: item.isCompleted
                            ? SemanticTone.success
                            : SemanticTone.danger,
                      ),
                    ],
                  ),
                  AppSpacing.vSm,
                  Divider(color: colors.outlineVariant.withValues(alpha: 0.3)),
                  AppSpacing.vXs,
                  _buildRow('رقم السند:', '#${item.repaymentId}', context),
                  _buildRow(
                    'المزود (الشبكة):',
                    item.networkName ?? 'شبكة #${item.networkId}',
                    context,
                  ),
                  _buildRow(
                    'العميل (نقطة البيع):',
                    item.posName ?? 'نقطة بيع #${item.posId}',
                    context,
                  ),
                  _buildRow(
                    'طريقة السداد:',
                    item.paymentMethod ?? 'CASH',
                    context,
                  ),
                  if (item.referenceNumber != null)
                    _buildRow(
                      'رقم المرجع:',
                      item.referenceNumber!,
                      context,
                    ),
                  if (item.repaymentDate != null)
                    _buildRow(
                      'تاريخ السداد:',
                      item.repaymentDate!.substring(0, 10),
                      context,
                    ),
                  if (item.notes != null)
                    _buildRow('ملاحظات:', item.notes!, context),
                ],
              ),
            ),
            AppSpacing.vLg,
            Container(
              padding: EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'إجمالي المبلغ المسدد:',
                    style: AppTypography.titleMedium.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AmountFormatter.format(item.amount.toString()),
                    style: AppTypography.titleLarge.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.vLg,
            Text(
              'تسويات وتوزيعات الفواتير المعتمدة (FIFO Settled Invoices)',
              style: AppTypography.titleSmall.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vSm,
            if (item.allocations.isEmpty)
              Container(
                padding: EdgeInsets.all(AppSpacing.cardPadding),
                alignment: Alignment.center,
                child: Text(
                  'لم تسجل أي فواتير مسواة لهذا السند.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: item.allocations.length,
                separatorBuilder: (context, index) => AppSpacing.vXs,
                itemBuilder: (context, index) {
                  final alloc = item.allocations[index];
                  return Container(
                    padding: EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                Get.toNamed<void>(
                                  AppRoutes.saleInvoiceDetails,
                                  arguments: alloc.invoiceId,
                                );
                              },
                              child: Text(
                                'فاتورة #${alloc.invoiceId} (عرض التفاصيل)',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (alloc.allocatedAt != null)
                              Text(
                                alloc.allocatedAt!.substring(0, 10),
                                style: AppTypography.bodySmall.copyWith(
                                  fontSize: 11,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'المبلغ المسوى',
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              AmountFormatter.format(
                                alloc.allocatedAmount.toString(),
                              ),
                              style: AppTypography.titleSmall.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
