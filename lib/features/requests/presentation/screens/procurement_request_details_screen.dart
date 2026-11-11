import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/presentation/controllers/procurement_request_details_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_request_info_row.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_request_item_row.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/indicators/custom_amount_to_words_banner.dart';

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
            'طلب توريد #${request.requestUuid}',
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
                      ProcurementRequestInfoRow(
                        label: 'الشبكة الموردة:',
                        value:
                            request.networkName ?? 'شبكة #${request.networkId}',
                      ),
                      ProcurementRequestInfoRow(
                        label: 'نقطة البيع (الوكيل):',
                        value: request.posName ?? 'نقطة بيع #${request.posId}',
                      ),
                      ProcurementRequestInfoRow(
                        label: 'طريقة الدفع:',
                        value: EnumPresentationRegistry.resolveSaleType(
                          request.saleType,
                          serverLabel: request.saleTypeLabel,
                        ).label,
                      ),
                      if (request.requestDate != null)
                        ProcurementRequestInfoRow(
                          label: 'تاريخ تقديم الطلب:',
                          value: request.requestDate!,
                        ),
                      if (request.reviewDate != null)
                        ProcurementRequestInfoRow(
                          label: 'تاريخ المراجعة:',
                          value: request.reviewDate!,
                        ),
                      if (request.invoiceId != null)
                        ProcurementRequestInfoRow(
                          label: 'رقم فاتورة المبيعات:',
                          value: 'فاتورة #${request.invoiceId}',
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'إجمالي المبلغ المستحق:',
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
                      CustomAmountToWordsBanner(
                        amount: request.requestTotalAmount,
                        currencyCode: 'YER',
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
}

