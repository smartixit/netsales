import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/presentation/controllers/procurement_request_details_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_request_item_row.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة استعراض تفاصيل طلب التوريد والبنود والتسلسل الزمني (Procurement Request Details Screen)
class ProcurementRequestDetailsScreen
    extends GetView<ProcurementRequestDetailsController> {
  const ProcurementRequestDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      if (controller.isLoading.value && controller.request.value == null) {
        return CustomAppScaffold(
          appBar: AppBar(title: const Text('تفاصيل طلب التوريد')),
          body: Padding(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            child: const CustomSkeletonFeed(itemCount: 3),
          ),
        );
      }

      final request = controller.request.value;
      if (request == null) {
        return CustomAppScaffold(
          appBar: AppBar(title: const Text('تفاصيل طلب التوريد')),
          body: Center(
            child: CustomEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'الطلب غير موجود',
              subtitle: 'تعذر العثور على بيانات طلب التوريد المحدد.',
              actionLabel: 'العودة',
              onAction: () => Get.back<void>(),
            ),
          ),
        );
      }

      final statusPresentation = EnumPresentationRegistry.resolveRequestStatus(
        request.status,
        serverLabel: request.statusLabel,
      );

      return CustomAppScaffold(
        appBar: AppBar(
          title: Text(
            'طلب توريد #${request.requestId}',
            style: AppTypography.titleMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            CustomButton.icon(
              icon: Icons.refresh_rounded,
              tooltip: 'تحديث التفاصيل',
              backgroundColor: Colors.transparent,
              foregroundColor: colors.onSurfaceVariant,
              onPressed: () => controller.loadRequestDetails(request.requestId),
            ),
            AppSpacing.hXs,
          ],
        ),
        body: RefreshIndicator.adaptive(
          onRefresh: () => controller.loadRequestDetails(request.requestId),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. بطاقة ملخص حالة الطلب والهوية
                Container(
                  padding: EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'حالة الطلب الحالية:',
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          CustomStatusBadge(
                            label: statusPresentation.label,
                            tone: statusPresentation.tone,
                            icon: statusPresentation.icon,
                          ),
                        ],
                      ),
                      AppSpacing.vSm,
                      Divider(
                        height: 1,
                        color: colors.outlineVariant.withValues(alpha: 0.3),
                      ),
                      AppSpacing.vSm,
                      _buildInfoRow(
                        'الشبكة الموردة:',
                        request.networkName ?? 'شبكة #${request.networkId}',
                        context,
                      ),
                      _buildInfoRow(
                        'نقطة البيع (الوكيل):',
                        request.posName ?? 'نقطة بيع #${request.posId}',
                        context,
                      ),
                      _buildInfoRow(
                        'طريقة الدفع:',
                        EnumPresentationRegistry.resolveSaleType(
                          request.saleType,
                          serverLabel: request.saleTypeLabel,
                        ).label,
                        context,
                      ),
                      if (request.requestDate != null)
                        _buildInfoRow(
                          'تاريخ تقديم الطلب:',
                          request.requestDate!,
                          context,
                        ),
                      if (request.reviewDate != null)
                        _buildInfoRow(
                          'تاريخ المراجعة:',
                          request.reviewDate!,
                          context,
                        ),
                      if (request.invoiceId != null)
                        _buildInfoRow(
                          'رقم فاتورة المبيعات:',
                          'فاتورة #${request.invoiceId}',
                          context,
                          isHighlight: true,
                        ),
                      if (request.requestNote != null &&
                          request.requestNote!.isNotEmpty) ...[
                        AppSpacing.vXs,
                        Text(
                          'ملاحظات: ${request.requestNote}',
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                AppSpacing.vLg,

                // 2. جدول بنود طلب الكروت
                Text(
                  'بنود الكروت المطلوبة (${request.items.length})',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.vSm,

                if (request.items.isEmpty)
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      'لا توجد بنود مرفقة مع هذا الطلب.',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: request.items.length,
                    separatorBuilder: (context, index) => AppSpacing.vXs,
                    itemBuilder: (context, index) {
                      return ProcurementRequestItemRow(
                        item: request.items[index],
                        index: index,
                      );
                    },
                  ),

                AppSpacing.vLg,

                // 3. إجمالي الفاتورة والطلب السيادي
                Container(
                  padding: EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'إجمالي المبلغ المستحق (خادم النظام):',
                        style: AppTypography.bodyMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AmountFormatter.format(
                          request.requestTotalAmount.toString(),
                        ),
                        style: AppTypography.titleLarge.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpacing.vXl,
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildInfoRow(
    String label,
    String value,
    BuildContext context, {
    bool isHighlight = false,
  }) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.0),
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
              color: isHighlight ? colors.primary : colors.onSurface,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
