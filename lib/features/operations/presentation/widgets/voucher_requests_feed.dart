import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/create_voucher_request_sheet.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/reject_voucher_request_sheet.dart';
import 'package:netsales/features/operations/presentation/widgets/voucher_request_ledger_tile.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// ============================================================================
/// قائمة تدفق طلبات توريد الكروت بالسجل السيادي المصنف (VoucherRequestsFeed)
/// ============================================================================
/// تعرض طلبات التوريد مجمعة زمنياً داخل أسطح مالية متصلة ومريحة للعين،
/// مع تأكيدات هادئة للاعتماد والرفض المباشر.
class VoucherRequestsFeed extends StatelessWidget {
  final OperationsController? controller;

  const VoucherRequestsFeed({super.key, this.controller});

  OperationsController get _activeController =>
      controller ?? Get.find<OperationsController>();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ctrl = _activeController;

    return Obx(() {
      // 1. حالة التحميل (الهيكل التشكيلي الموحد المتوافق تماماً في الحجم والهوامش)
      if (ctrl.isLoadingRequests.value) {
        return const CustomSkeletonFeed(
          itemCount: 4,
          cardHeight: 115,
          padding: EdgeInsets.zero,
        );
      }

      // 2. حالة الخطأ مع إمكانية إعادة المحاولة
      if (ctrl.requestsErrorMessage.value.isNotEmpty &&
          ctrl.requests.isEmpty) {
        return CustomErrorState(
          title: 'تعذر تحميل الطلبات',
          subtitle: ctrl.requestsErrorMessage.value,
          onRetry: () => ctrl.loadRequests(isRefresh: true),
        );
      }

      // 3. حالة الفراغ الموحدة
      if (ctrl.requests.isEmpty) {
        return CustomEmptyState(
          title: 'لا توجد طلبات توريد',
          subtitle:
              'لم يتم العثور على أي طلبات توريد تطابق معايير التصفية والبحث المحددة',
          actionLabel: 'طلب توريد باقات كروت',
          onAction: () => CreateVoucherRequestSheet.show(context),
        );
      }

      // تجميع الطلبات زمنياً عبر المتحكم المعتمد
      final groups = ctrl.groupedRequests;
      final groupKeys = groups.keys.toList();

      // 4. السجل المالي المصنف زمنياً مع السحب للتحديث
      return RefreshIndicator(
        color: colors.primary,
        onRefresh: () => ctrl.loadRequests(isRefresh: true),
        child: ListView.separated(
          padding: EdgeInsets.only(
            top: AppSpacing.xs,
            bottom: 130.h,
          ),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          itemCount: groupKeys.length,
          separatorBuilder: (_, __) => AppSpacing.vSm,
          itemBuilder: (context, groupIndex) {
            final key = groupKeys[groupIndex];
            final groupItems = groups[key]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ترويسة المجموعة الزمنية
                Padding(
                  padding: EdgeInsets.only(
                    bottom: AppSpacing.xs,
                    right: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Text(
                        key,
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                          fontSize: 11.sp,
                        ),
                      ),
                      AppSpacing.hXs,
                      Text(
                        '(${groupItems.length})',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                // بطاقات طلبات التوريد المستقلة الفاخرة بنمط الأكورديون الحصري
                ...groupItems.map(
                  (request) => Obx(
                    () => VoucherRequestLedgerTile(
                      key: ValueKey(request.requestId),
                      request: request,
                      isExpanded: ctrl.expandedRequestId.value ==
                          request.requestId,
                      onToggleExpand: () => ctrl
                          .toggleRequestExpansion(request.requestId),
                      onTap: () => ctrl.openRequestDetails(request.requestId),
                      onApprove: request.isPending
                          ? () {
                              CustomBottomSheet.showConfirmation(
                                title: 'تأكيد اعتماد طلب التوريد',
                                message:
                                    'سيتم اعتماد طلب التوريد ${request.requestUuid} وتوليد فاتورة مبيعات جديدة بقيمة ${AmountFormatter.formatValue(request.requestTotalAmount)} ر.ي.',
                                confirmLabel: 'اعتماد وتوليد الفاتورة',
                                cancelLabel: 'تراجع',
                                leadingIcon: Icons.verified_rounded,
                                onConfirm: () => ctrl.approveRequest(
                                  request.requestId,
                                ),
                              );
                            }
                          : null,
                      onReject: request.isPending
                          ? () => RejectVoucherRequestSheet.show(
                              context,
                              requestId: request.requestId,
                              requestUuid: request.requestUuid,
                              controller: ctrl,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }
}

