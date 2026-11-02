import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/domain/entities/request_pricing_preview_entity.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// ============================================================================
/// نافذة مراجعة وتعديل واعتماد طلب التوريد سيادياً (ReviewAndApproveRequestSheet)
/// ============================================================================
/// تتيح لمزود الشبكة مراجعة طلب التوريد وتعديل الباقات والكميات مع حساب الأسعار
/// والخصومات سيادياً من السيرفر دون إمكانية التعديل اليدوي، ثم اعتماد الطلب وتوليد الفاتورة.
class ReviewAndApproveRequestSheet extends StatelessWidget {
  final VoucherRequestEntity request;
  final OperationsController controller;

  const ReviewAndApproveRequestSheet({
    super.key,
    required this.request,
    required this.controller,
  });

  /// فتح نافذة المراجعة والاعتماد السفلية
  static Future<void> show(
    BuildContext context, {
    required VoucherRequestEntity request,
    required OperationsController controller,
  }) {
    controller.initReviewFlow(request);

    return CustomBottomSheet.show(
      title: 'مراجعة واعتماد طلب التوريد',
      subtitle: 'مراجعة وتعديل باقات وكميات الطلب قبل توليد فاتورة البيع',
      leadingIcon: Icons.fact_check_outlined,
      scrollable: true,
      child: ReviewAndApproveRequestSheet(
        request: request,
        controller: controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final preview = controller.pricingPreview.value;
      final isLoading = controller.isLoadingPreview.value;
      final error = controller.previewError.value;
      final draftItems = controller.reviewDraftItems;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. بطاقة معلومات الطلب الأصلية والطرف الطالب
          _buildOriginalOrderInfo(context),

          AppSpacing.vMd,

          // 2. نوع البيع المعتمد بالطلب الأصلي (سيادي غير قابل للتغيير من الشبكة)
          _buildSaleTypeReadonlyBadge(context, request.saleType),

          AppSpacing.vMd,

          // 3. بطاقة المقارنة المالية الحية المحسوبة سيادياً
          if (isLoading && preview == null)
            const CustomSkeletonFeed(
              itemCount: 1,
              cardHeight: 90,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
            )
          else if (error.isNotEmpty)
            _buildErrorMessage(context, error)
          else if (preview != null)
            _buildFinancialComparisonCard(context, preview),

          AppSpacing.vLg,

          // 4. رأس قسم الباقات الخاضعة للمراجعة وزر إضافة باقة جديدة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الباقات والكميات المعتمدة (${draftItems.length})',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              CustomButton.text(
                onPressed: () => _showAddPackageDialog(context),
                icon: Icon(Icons.add_circle_outline_rounded, size: 18.r),
                text: 'إضافة باقة',
              ),
            ],
          ),

          AppSpacing.vSm,

          // 5. قائمة الباقات المعتمدة مع محدد الكميات وأزرار الحذف
          if (isLoading && preview == null)
            const CustomSkeletonFeed(
              itemCount: 2,
              cardHeight: 110,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
            )
          else if (preview != null && preview.items.isNotEmpty)
            ...preview.items.map((item) => _buildReviewItemTile(context, item))
          else if (draftItems.isEmpty)
            _buildEmptyItemsWarning(context),

          // 6. قسم الباقات المستبعدة إن وجدت
          if (preview != null && preview.removedItems.isNotEmpty) ...[
            AppSpacing.vMd,
            _buildRemovedItemsSection(context, preview.removedItems),
          ],

          AppSpacing.vLg,

          // 7. حقل ملاحظات وتعليمات الاعتماد
          CustomTextField(
            controller: controller.reviewNotesController,
            label: 'ملاحظات الاعتماد والفوترة (اختياري)',
            hint: 'أدخل أي ملاحظات للتسجيل في فاتورة المبيعات...',
            prefixIcon: const Icon(Icons.notes_rounded),
            maxLines: 2,
          ),

          AppSpacing.vLg,

          // 8. شريط أزرار اتخاذ القرار النهائي
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomButton.outline(
                  text: 'إلغاء المراجعة',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                flex: 3,
                child: CustomButton.primary(
                  text: 'اعتماد وتوليد الفاتورة',
                  icon: Icons.check_circle_outline_rounded,
                  loading: controller.isSubmittingAction.value,
                  onPressed: draftItems.isEmpty || preview == null
                      ? null
                      : () => _confirmApproval(context, preview),
                ),
              ),
            ],
          ),
          AppSpacing.vMd,
        ],
      );
    });
  }

  /// بطاقة تعريفية بالطلب الأصلي والطرف الطالب
  Widget _buildOriginalOrderInfo(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: colors.primary.withValues(alpha: 0.12),
            child: Icon(
              Icons.storefront_rounded,
              color: colors.primary,
              size: 20.r,
            ),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.posName ?? 'نقطة البيع',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                AppSpacing.vXs,
                Text(
                  'طلب رقم: #${request.requestUuid}',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: AppRadius.xsRadius,
            ),
            child: Text(
              'الأصل: ${AmountFormatter.formatValue(request.requestTotalAmount)} ر.ي',
              style: AppTypography.labelSmall.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بطاقة مقارنة مالية حية سيادية
  /// شريط نوع البيع المعتمد أصلاً بالطلب (غير قابل للتعديل)
  Widget _buildSaleTypeReadonlyBadge(BuildContext context, String saleType) {
    final colors = context.colors;
    final isCash = saleType.toUpperCase() == 'CASH';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: (isCash ? colors.successContainer : colors.secondaryContainer).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: (isCash ? colors.success : colors.secondary).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCash ? Icons.payments_outlined : Icons.credit_score_outlined,
            size: 18.r,
            color: isCash ? colors.success : colors.secondary,
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نوع البيع المتفق عليه في الطلب الأصلي',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  isCash ? 'دفع نقدي (كاش)' : 'دفع آجل (حساب الوكيل)',
                  style: AppTypography.labelLarge.copyWith(
                    color: isCash ? colors.success : colors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Text(
              'غير قابل للتعديل',
              style: AppTypography.labelSmall.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialComparisonCard(
    BuildContext context,
    RequestPricingPreviewEntity preview,
  ) {
    final colors = context.colors;
    final diff = preview.previewTotalAmount - request.requestTotalAmount;
    final hasDiff = diff.abs() > 0.01;

    final Color badgeColor = !hasDiff
        ? colors.primary
        : (diff > 0 ? colors.warning : colors.tertiary);

    final String diffText = !hasDiff
        ? 'مطابق تماماً للقيمة الأصلية'
        : (diff > 0
              ? '+${AmountFormatter.formatValue(diff)} ر.ي (زيادة)'
              : '${AmountFormatter.formatValue(diff)} ر.ي (تخفيض)');

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.4),
          width: 1.2.w,
        ),
        boxShadow: AppElevation.level1(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.security_rounded,
                    size: 16.r,
                    color: colors.primary,
                  ),
                  AppSpacing.hXs,
                  Text(
                    'التسعير السيادي للمعاينة',
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Text(
                  diffText,
                  style: AppTypography.labelSmall.copyWith(
                    color: badgeColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          const Divider(height: 1),
          AppSpacing.vSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إجمالي القيمة الأصلية',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.vXs,
                  Text(
                    '${AmountFormatter.formatValue(request.requestTotalAmount)} ر.ي',
                    style: AppTypography.titleSmall.copyWith(
                      decoration: hasDiff ? TextDecoration.lineThrough : null,
                      color: hasDiff
                          ? colors.onSurfaceVariant
                          : colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'إجمالي الاعتماد النهائي',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.vXs,
                  Text(
                    '${AmountFormatter.formatValue(preview.previewTotalAmount)} ر.ي',
                    style: AppTypography.titleMedium.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (preview.totalDiscountAmount > 0) ...[
            AppSpacing.vXs,
            Text(
              'الخصم التجاري الممنوح: ${AmountFormatter.formatValue(preview.totalDiscountAmount)} ر.ي (الإجمالي قبل الخصم: ${AmountFormatter.formatValue(preview.grossTotalAmount)} ر.ي)',
              style: AppTypography.bodySmall.copyWith(
                fontSize: 11.sp,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// عنصر بند في قائمة الباقات الخاضعة للمراجعة
  Widget _buildReviewItemTile(
    BuildContext context,
    RequestPreviewItemEntity item,
  ) {
    final colors = context.colors;

    final bool isAdded = item.isAdded;
    final bool isQtyChanged = item.isQuantityChanged;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(
          color: isAdded
              ? colors.primary.withValues(alpha: 0.5)
              : (isQtyChanged
                    ? colors.warning.withValues(alpha: 0.5)
                    : colors.outlineVariant.withValues(alpha: 0.3)),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      item.packageName,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    AppSpacing.hSm,
                    _buildItemStatusBadge(context, item),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: colors.error,
                  size: 20.r,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => controller.removeReviewItem(
                  request.requestId,
                  item.packageId,
                ),
                tooltip: 'استبعاد الباقة',
              ),
            ],
          ),
          AppSpacing.vXs,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'سعر الكرت: ${AmountFormatter.formatValue(item.voucherPrice)} ر.ي (خصم ${item.itemDiscount}%)',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 11.5.sp,
                ),
              ),
              Text(
                '${AmountFormatter.formatValue(item.itemTotalAmount)} ر.ي',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          // وحدة التحكم في الكمية (الستبر)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.originalVoucherCount != null
                    ? 'الكمية الأصلية: ${item.originalVoucherCount}'
                    : 'باقة جديدة',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 11.sp,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: AppRadius.smRadius,
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, size: 16.r),
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      constraints: const BoxConstraints(),
                      onPressed: () => controller.updateReviewItemQuantity(
                        request.requestId,
                        item.packageId,
                        item.voucherCount - 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text(
                        '${item.voucherCount}',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, size: 16.r),
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      constraints: const BoxConstraints(),
                      onPressed: () => controller.updateReviewItemQuantity(
                        request.requestId,
                        item.packageId,
                        item.voucherCount + 1,
                      ),
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

  /// شارة حالة التعديل للبند
  Widget _buildItemStatusBadge(
    BuildContext context,
    RequestPreviewItemEntity item,
  ) {
    final colors = context.colors;

    if (item.isAdded) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.12),
          borderRadius: AppRadius.xsRadius,
        ),
        child: Text(
          'مضافة حديثاً',
          style: AppTypography.labelSmall.copyWith(
            color: colors.primary,
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (item.isQuantityChanged) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: colors.warning.withValues(alpha: 0.12),
          borderRadius: AppRadius.xsRadius,
        ),
        child: Text(
          'تعدلت الكمية',
          style: AppTypography.labelSmall.copyWith(
            color: colors.warning,
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colors.outlineVariant.withValues(alpha: 0.15),
        borderRadius: AppRadius.xsRadius,
      ),
      child: Text(
        'السعر الأصلي محفوظ',
        style: AppTypography.labelSmall.copyWith(
          color: colors.onSurfaceVariant,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  /// قسم الباقات المستبعدة مع إمكانية الاستعادة
  Widget _buildRemovedItemsSection(
    BuildContext context,
    List<RequestPreviewRemovedItemEntity> removedItems,
  ) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.04),
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: colors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.remove_circle_outline_rounded,
                size: 16.r,
                color: colors.error,
              ),
              AppSpacing.hXs,
              Text(
                'باقات تم استبعادها من الطلب الأصلي (${removedItems.length})',
                style: AppTypography.labelMedium.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.vXs,
          ...removedItems.map(
            (rem) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${rem.packageName} (${rem.originalVoucherCount} كرت)',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                  CustomButton.text(
                    onPressed: () {
                      final pkg = controller.networkAvailablePackages
                          .firstWhereOrNull(
                            (p) => p.packageId == rem.packageId,
                          );
                      if (pkg != null) {
                        controller.addReviewPackage(
                          request.requestId,
                          pkg,
                          quantity: rem.originalVoucherCount,
                        );
                      } else {
                        // إضافة مباشرة للمسودة
                        controller.reviewDraftItems.add({
                          'package_id': rem.packageId,
                          'voucher_count': rem.originalVoucherCount,
                        });
                        controller.refreshReviewPreview(request.requestId);
                      }
                    },

                    text: 'استعادة للطلب',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// رسالة تحذيرية عند خلو الطلب من الباقات
  Widget _buildEmptyItemsWarning(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        borderRadius: AppRadius.mdRadius,
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: colors.error),
          AppSpacing.hSm,
          Expanded(
            child: Text(
              'تم استبعاد جميع الباقات! يجب إبقاء باقة واحدة على الأقل لاعتماد الطلب.',
              style: AppTypography.bodySmall.copyWith(color: colors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// رسالة خطأ عند فشل استدعاء التسعير السيادي
  Widget _buildErrorMessage(BuildContext context, String message) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        borderRadius: AppRadius.mdRadius,
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colors.error),
          AppSpacing.hSm,
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(color: colors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// حوار اختيار باقة جديدة لإضافتها
  void _showAddPackageDialog(BuildContext context) {
    final colors = context.colors;
    final available = controller.networkAvailablePackages;

    if (available.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'لا توجد باقات مفعلة إضافية متاحة لهذه الشبكة حالياً.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'اختر باقة لإضافتها إلى الطلب',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              AppSpacing.vMd,
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 300.h),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: available.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final pkg = available[index];
                    return ListTile(
                      title: Text(pkg.packageName),
                      subtitle: Text(
                        'سعر الكرت: ${AmountFormatter.formatValue(pkg.packageVoucherPrice)} ر.ي',
                      ),
                      trailing: Icon(
                        Icons.add_circle_outline_rounded,
                        color: colors.primary,
                      ),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        controller.addReviewPackage(request.requestId, pkg);
                      },
                    );
                  },
                ),
              ),
              AppSpacing.vSm,
            ],
          ),
        );
      },
    );
  }

  /// تأكيد الاعتماد النهائي وتوليد الفاتورة
  void _confirmApproval(
    BuildContext context,
    RequestPricingPreviewEntity preview,
  ) {
    final diff = preview.previewTotalAmount - request.requestTotalAmount;
    final String diffMsg = diff.abs() > 0.01
        ? '\n\nملاحظة: طرأ تعديل على القيمة الإجمالية الأصلية (${AmountFormatter.formatValue(request.requestTotalAmount)} ر.ي) لتصبح (${AmountFormatter.formatValue(preview.previewTotalAmount)} ر.ي).'
        : '';

    CustomBottomSheet.showConfirmation(
      title: 'تأكيد اعتماد الطلب وتوليد الفاتورة',
      message:
          'سيتم اعتماد طلب التوريد رقم #${request.requestUuid} بنمط (${preview.saleTypeLabel}) وتوليد فاتورة مبيعات نظامية ملزمة وتسوية الأرصدة.$diffMsg\n\nهل تريد المتابعة؟',
      confirmLabel: 'تأكيد واعتماد الفاتورة',
      cancelLabel: 'تراجع',
      leadingIcon: Icons.verified_rounded,
      onConfirm: () async {
        final success = await controller.submitApprovalWithModifications(
          request.requestId,
        );
        if (success && context.mounted) {
          Navigator.of(context).pop(); // إغلاق نافذة المراجعة
        }
      },
    );
  }
}
