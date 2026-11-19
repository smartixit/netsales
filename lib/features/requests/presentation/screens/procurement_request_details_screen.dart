import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/controllers/procurement_request_details_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_details_action_bar.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_details_hero.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_details_item_card.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_details_metrics_strip.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_details_notes_card.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_details_parties_card.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_details_timeline.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_request_invoice_callout.dart';
import 'package:netsales/features/requests/presentation/widgets/request_modification_summary_panel.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة تفاصيل طلب التوريد بالمعايير العالمية والعمق البصري الفاخر
class ProcurementRequestDetailsScreen
    extends GetView<ProcurementRequestDetailsController> {
  const ProcurementRequestDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      // 1. حالة التحميل الهيكلي (Skeleton State)
      if (controller.isLoading.value && controller.request.value == null) {
        return CustomAppScaffold(
          appBar: AppBar(
            title: const Text('تفاصيل طلب التوريد'),
            centerTitle: true,
          ),
          body: Padding(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            child: const CustomStateView.loading(
              presentation: CustomStatePresentation.skeletonOnly,
              skeleton: CustomStateSkeleton(
                layout: CustomStateSkeletonLayout.list,
                itemCount: 4,
                cardHeight: 140,
              ),
            ),
          ),
        );
      }

      final request = controller.request.value;

      // 2. حالة عدم العثور على الطلب
      if (request == null) {
        return CustomAppScaffold(
          appBar: AppBar(
            title: const Text('تفاصيل طلب التوريد'),
            centerTitle: true,
          ),
          body: Center(
            child: CustomEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'الطلب غير موجود',
              subtitle: 'تعذر العثور على بيانات طلب التوريد المحدد أو تم حذفه.',
              actionLabel: 'العودة',
              onAction: () => Get.back<void>(),
            ),
          ),
        );
      }

      final displayUuid = request.displayReference;

      // 3. عرض صفحة التفاصيل المتكاملة
      return CustomAppScaffold(
        appBarTitle: displayUuid,
        showBackButton: true,
        bottomNavigationBar: ProcurementDetailsActionBar(
          request: request,
          controller: controller,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.cardPadding,
            AppSpacing.cardPadding,
            AppSpacing.cardPadding,
            AppSpacing.xl,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. الترويسة القيادية بالعمق اللوني المتكيف
                  ProcurementDetailsHero(request: request),
                  AppSpacing.vMd,

                  // 2. شريط المؤشرات المالية والتشغيلية
                  ProcurementDetailsMetricsStrip(request: request),

                  // 3. ملخص المقارنة في حالة وجود تعديلات بعد المراجعة
                  if (request.hasModificationSummary) ...[
                    AppSpacing.vMd,
                    RequestModificationSummaryPanel(
                      summary: request.modificationSummary!,
                    ),
                  ],

                  // 4. بطاقة التنبيه للفاتورة المعتمدة
                  if (request.hasInvoice) ...[
                    AppSpacing.vMd,
                    ProcurementRequestInvoiceCallout(
                      onOpenInvoice: controller.openLinkedInvoice,
                    ),
                  ],
                  AppSpacing.vMd,

                  // 5. مسار التدقيق والتسلسل الزمني لمراحل الطلب
                  ProcurementDetailsTimeline(request: request),
                  AppSpacing.vMd,

                  // 6. بطاقة أطراف العملية التوريدية (الشبكة ونقطة البيع)
                  ProcurementDetailsPartiesCard(request: request),
                  AppSpacing.vLg,

                  // 7. عنوان قسم الباقات المفصلة
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 18.r,
                        color: colors.primary,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'تفاصيل الباقات المطلوبة (${request.items.length})',
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vSm,

                  // 8. قائمة بطاقات الباقات
                  for (int i = 0; i < request.items.length; i++) ...[
                    if (i > 0) AppSpacing.vSm,
                    ProcurementDetailsItemCard(
                      item: request.items[i],
                      index: i,
                      isExpanded: controller.isItemExpanded(i),
                      onToggleExpand: () => controller.toggleItemExpansion(i),
                    ),
                  ],

                  // 9. بطاقة الملاحظات إن وجدت
                  if (request.hasNote) ...[
                    AppSpacing.vMd,
                    ProcurementDetailsNotesCard(
                      notes: request.requestNote!.trim(),
                    ),
                  ],

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
