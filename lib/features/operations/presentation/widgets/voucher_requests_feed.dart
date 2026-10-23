import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/voucher_request_card.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_loading_state.dart';

class VoucherRequestsFeed extends GetView<OperationsController> {
  const VoucherRequestsFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      if (controller.isLoadingRequests.value) {
        return const CustomLoadingState(message: 'جاري تحميل الطلبات...');
      }

      if (controller.requestsErrorMessage.value.isNotEmpty) {
        return CustomErrorState(
          title: 'تعذر تحميل الطلبات',
          subtitle: controller.requestsErrorMessage.value,
          onRetry: () => controller.loadRequests(isRefresh: true),
        );
      }

      if (controller.requests.isEmpty) {
        return const CustomEmptyState(
          title: 'لا توجد طلبات',
          subtitle: 'لم يتم العثور على طلبات توريد.',
        );
      }

      return RefreshIndicator(
        color: colors.primary,
        onRefresh: () => controller.loadRequests(isRefresh: true),
        child: ListView.builder(
          padding: EdgeInsets.all(AppSpacing.md),
          itemCount: controller.requests.length,
          itemBuilder: (context, index) {
            final req = controller.requests[index];
            return VoucherRequestCard(
              request: req,
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
