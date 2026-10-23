import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/sale_invoice_card.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// ============================================================================
/// قائمة تدفق فواتير المبيعات (SaleInvoicesFeed)
/// ============================================================================
/// تدير حالات التحميل، الفراغ، الخطأ، وعرض قائمة الفواتير التفاعلية.
class SaleInvoicesFeed extends StatelessWidget {
  final OperationsController controller;

  const SaleInvoicesFeed({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      // 1. حالة التحميل
      if (controller.isLoadingInvoices.value && controller.invoices.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.giant),
            child: CircularProgressIndicator(
              color: colors.primary,
            ),
          ),
        );
      }

      // 2. حالة الخطأ مع إمكانية إعادة المحاولة
      if (controller.invoicesErrorMessage.isNotEmpty && controller.invoices.isEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.lgRadius,
            border: Border.all(
              color: colors.error.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 48.r,
                color: colors.error,
              ),
              AppSpacing.vMd,
              Text(
                controller.invoicesErrorMessage.value,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vLg,
              CustomButton.primary(
                text: 'إعادة المحاولة',
                icon: Icons.refresh_rounded,
                onPressed: () => controller.loadInvoices(),
              ),
            ],
          ),
        );
      }

      // 3. حالة الفراغ
      if (controller.invoices.isEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.giant,
            horizontal: AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.lgRadius,
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48.r,
                color: colors.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              AppSpacing.vSm,
              Text(
                'لا توجد فواتير مبيعات مسجلة',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.vXxs,
              Text(
                'لم يتم العثور على أي فواتير تطابق معايير التصفية والبحث المحددة',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      // 4. حالة النجاح وعرض قائمة الفواتير
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.invoices.length,
        separatorBuilder: (_, __) => AppSpacing.vSm,
        itemBuilder: (context, index) {
          final invoice = controller.invoices[index];
          return SaleInvoiceCard(
            invoice: invoice,
            onTap: () {
              // مسار تفاصيل الفاتورة عند النقر
            },
          );
        },
      );
    });
  }
}
