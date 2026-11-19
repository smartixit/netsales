import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/invoices/presentation/controllers/invoice_details_controller.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_details/invoice_details_action_bar.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_details/invoice_details_hero.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_details/invoice_details_item_card.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_details/invoice_details_metrics_strip.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_details/invoice_details_parties_card.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_details/invoice_request_callout.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة استعراض تفاصيل الفاتورة المالية وبنودها والعمليات المستندية المعتمدة
class InvoiceDetailsScreen extends GetView<InvoiceDetailsController> {
  const InvoiceDetailsScreen({
    super.key,
    this.isNetworkPerspective = true,
  });

  final bool isNetworkPerspective;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      // 1. حالة التحميل الهيكلي (Skeleton Loading State)
      if (controller.isLoading.value && controller.invoice.value == null) {
        return CustomAppScaffold(
          appBarTitle: 'تفاصيل الفاتورة',
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

      final invoice = controller.invoice.value;

      // 2. حالة عدم العثور على الفاتورة
      if (invoice == null) {
        return CustomAppScaffold(
          appBarTitle: 'تفاصيل الفاتورة',
          body: Center(
            child: CustomEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'الفاتورة غير موجودة',
              subtitle: 'تعذر العثور على بيانات الفاتورة المحددة أو تم حذفها.',
              actionLabel: 'العودة',
              onAction: () => Get.back<void>(),
            ),
          ),
        );
      }

      final displayReference = 'فاتورة #${invoice.displayReference}';

      // 3. عرض صفحة التفاصيل المتكاملة بالمعايير العالمية
      return CustomAppScaffold(
        appBarTitle: displayReference,
        showBackButton: true,
        bottomNavigationBar: InvoiceDetailsActionBar(controller: controller),
        body: RefreshIndicator.adaptive(
          color: colors.primary,
          backgroundColor: colors.surface,
          strokeWidth: 2.5,
          onRefresh: controller.refreshDetails,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
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
                    InvoiceDetailsHero(invoice: invoice),
                    AppSpacing.vMd,

                    // 2. شريط المؤشرات المالية والتشغيلية والتفقيط
                    InvoiceDetailsMetricsStrip(invoice: invoice),

                    // 3. بطاقة التنبيه للربط بطلب التوريد المعتمد
                    if (invoice.hasRequest) ...[
                      AppSpacing.vMd,
                      InvoiceRequestCallout(
                        invoice: invoice,
                        onOpenRequest: controller.openLinkedRequest,
                      ),
                    ],
                    AppSpacing.vMd,

                    // 4. بطاقة أطراف المعاملة المالية (المزود ونقطة البيع)
                    InvoiceDetailsPartiesCard(invoice: invoice),
                    AppSpacing.vLg,

                    // 5. عنوان قسم الباقات المفصلة
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
                            'بنود الفاتورة (${invoice.items.length})',
                            style: AppTypography.titleMedium.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vSm,

                    // 6. قائمة بطاقات بنود الفاتورة
                    if (invoice.items.isEmpty)
                      Container(
                        padding: EdgeInsets.all(AppSpacing.cardPadding),
                        alignment: Alignment.center,
                        child: Text(
                          'لا توجد بنود تفصيلية معروضة لهذه الفاتورة.',
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      for (int i = 0; i < invoice.items.length; i++)
                        Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.sm),
                          child: InvoiceDetailsItemCard(
                            item: invoice.items[i],
                            index: i,
                          ),
                        ),

                    AppSpacing.vLg,
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
