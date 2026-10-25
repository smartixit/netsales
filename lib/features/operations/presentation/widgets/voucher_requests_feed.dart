import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/create_voucher_request_sheet.dart';
import 'package:netsales/features/operations/presentation/widgets/voucher_request_card.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';

class VoucherRequestsFeed extends GetView<OperationsController> {
  const VoucherRequestsFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      // 1. حالة التحميل الأولي عبر الهيكل التشكيلي الموحد (Skeleton Shimmer)
      if (controller.isLoadingRequests.value && controller.requests.isEmpty) {
        return const CustomSkeletonFeed(itemCount: 4, cardHeight: 120);
      }

      // 2. حالة الخطأ مع إمكانية إعادة المحاولة
      if (controller.requestsErrorMessage.value.isNotEmpty &&
          controller.requests.isEmpty) {
        return CustomErrorState(
          title: 'تعذر تحميل الطلبات',
          subtitle: controller.requestsErrorMessage.value,
          onRetry: () => controller.loadRequests(isRefresh: true),
        );
      }

      // 3. حالة الفراغ الموحدة مع زر طلب توريد
      if (controller.requests.isEmpty) {
        return CustomEmptyState(
          title: 'لا توجد طلبات توريد',
          subtitle: 'لم يتم العثور على أي طلبات توريد تطابق معايير التصفية والبحث المحددة',
          actionLabel: 'طلب توريد باقات كروت',
          onAction: () => CreateVoucherRequestSheet.show(context),
        );
      }

      // 4. حالة النجاح وعرض قائمة الطلبات مع السحب للتحديث
      return RefreshIndicator(
        color: colors.primary,
        onRefresh: () => controller.loadRequests(isRefresh: true),
        child: ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.xs,
          ),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          itemCount: controller.requests.length,
          separatorBuilder: (_, __) => AppSpacing.vSm,
          itemBuilder: (context, index) {
            final req = controller.requests[index];
            return VoucherRequestCard(
              request: req,
              onTap: () => Get.toNamed(
                AppRoutes.voucherRequestDetails,
                arguments: req.requestId,
              ),
              onApprove: req.isPending
                  ? () => controller.approveRequest(req.requestId)
                  : null,
              onReject: req.isPending
                  ? () => controller.rejectRequest(req.requestId, reason: 'مرفوض')
                  : null,
            );
          },
        ),
      );
    });
  }
}
