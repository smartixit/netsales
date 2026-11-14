import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_card.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// قسم آخر حركات الحساب والمشتريات الحية لنقطة البيع من الـ API (PosRecentTransactionsSection)
class PosRecentTransactionsSection extends StatelessWidget {
  final PosWorkspaceController controller;

  const PosRecentTransactionsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      if (controller.isLoadingRecentData.value &&
          controller.recentInvoices.isEmpty &&
          controller.recentRequests.isEmpty) {
        return const CustomSkeletonCard(height: 160);
      }

      final invoices = controller.recentInvoices;
      final requests = controller.recentRequests;

      if (invoices.isEmpty && requests.isEmpty) {
        return Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              AppSpacing.vMd,
              const CustomEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'لا توجد حركات سابقة',
                subtitle: 'لم يتم تسجيل أي فواتير أو طلبات توريد لهذه الشبكة حتى الآن.',
              ),
            ],
          ),
        );
      }

      return Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            AppSpacing.vMd,
            // عرض الفواتير الحقيقية من الـ API
            for (int i = 0; i < invoices.length; i++) ...[
              if (i > 0)
                Divider(color: colors.outlineVariant.withValues(alpha: 0.3)),
              PosInvoiceTransactionTile(invoice: invoices[i]),
            ],
            // عرض طلبات التوريد الحقيقية من الـ API
            for (int j = 0; j < requests.length; j++) ...[
              Divider(color: colors.outlineVariant.withValues(alpha: 0.3)),
              PosRequestTransactionTile(request: requests[j]),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  AppSpacing.hSm,
                  Text(
                    'آخر حركات الحساب والمشتريات',
                    style: AppTypography.titleMedium.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Text(
                'سجل فواتير التوريد من الشبكة وسندات المشتريات المعتمدة من الخادم',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        CustomButton.text(
          text: 'عرض الكل',
          suffix: Icons.chevron_left_rounded,
          onPressed: () => Get.toNamed<void>(AppRoutes.purchaseInvoices),
        ),
      ],
    );
  }
}

/// سطر فاتورة مشتريات حقيقية من الـ API (PosInvoiceTransactionTile)
class PosInvoiceTransactionTile extends StatelessWidget {
  final InvoiceEntity invoice;

  const PosInvoiceTransactionTile({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reference = invoice.invoiceUuid ?? '#INV-${invoice.invoiceId}';
    final date = invoice.invoiceDate ?? invoice.createdAt ?? '';

    return CustomInteractiveBounce(
      onTap: () {
        Get.toNamed<void>(AppRoutes.purchaseInvoiceDetails, arguments: invoice);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                color: colors.primary,
                size: 20.r,
              ),
            ),
            AppSpacing.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'فاتورة توريد #${invoice.invoiceId}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      AppSpacing.hSm,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          reference,
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 9.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${invoice.saleTypeLabel ?? 'شراء'} ${date.isNotEmpty ? '• $date' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.hSm,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AmountFormatter.formatValue(invoice.invoiceTotalAmount),
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  invoice.paymentStatusLabel ?? 'معتمدة',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// سطر طلب توريد حقيقي من الـ API (PosRequestTransactionTile)
class PosRequestTransactionTile extends StatelessWidget {
  final RequestEntity request;

  const PosRequestTransactionTile({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reference = request.requestUuid ?? '#REQ-${request.requestId}';
    final date = request.requestDate ?? request.createdAt ?? '';

    return CustomInteractiveBounce(
      onTap: () {
        Get.toNamed<void>(AppRoutes.procurementOrders, arguments: request);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.send_rounded,
                color: colors.primary,
                size: 20.r,
              ),
            ),
            AppSpacing.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'طلب توريد #${request.requestId}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      AppSpacing.hSm,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          reference,
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 9.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${request.saleTypeLabel ?? 'طلب شراء'} ${date.isNotEmpty ? '• $date' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.hSm,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AmountFormatter.formatValue(request.requestTotalAmount),
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  request.statusLabel ?? 'قيد المعالجة',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
