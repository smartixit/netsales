import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_loading_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

class VoucherRequestDetailsScreen extends StatefulWidget {
  const VoucherRequestDetailsScreen({super.key, this.requestId});

  final int? requestId;

  @override
  State<VoucherRequestDetailsScreen> createState() => _VoucherRequestDetailsScreenState();
}

class _VoucherRequestDetailsScreenState extends State<VoucherRequestDetailsScreen> {
  late final OperationsController _controller;
  int? _id;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OperationsController>();
    _id = widget.requestId ?? (Get.arguments is int ? Get.arguments as int : null);
    if (_id != null) {
      _controller.loadRequestDetails(_id!);
    }
  }

  @override
  Widget build(BuildContext context) {

    return CustomAppScaffold(
      appBarTitle: 'تفاصيل طلب التوريد',
      body: Obx(() {
        if (_controller.isLoadingRequestDetails.value) {
          return const CustomLoadingState(message: 'جاري تحميل التفاصيل...');
        }
        if (_controller.requestDetailsError.value.isNotEmpty) {
          return CustomErrorState(
            title: 'تعذر تحميل التفاصيل',
            subtitle: _controller.requestDetailsError.value,
            onRetry: _id == null ? null : () => _controller.loadRequestDetails(_id!),
          );
        }
        final req = _controller.selectedRequest.value;
        if (req == null) {
          return const CustomEmptyState(title: 'لا توجد بيانات');
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('UUID: ${req.requestUuid}', style: AppTypography.bodySmall),
              AppSpacing.vSm,
              Text('الشبكة: ${req.networkName ?? req.networkId}', style: AppTypography.bodyMedium),
              AppSpacing.vSm,
              Text('نقطة البيع: ${req.posName ?? req.posId}', style: AppTypography.bodyMedium),
              AppSpacing.vSm,
              Text('النوع: ${req.saleTypeLabel}', style: AppTypography.bodyMedium),
              AppSpacing.vSm,
              Text('الإجمالي: ${AmountFormatter.formatValue(req.requestTotalAmount)}', style: AppTypography.bodyMedium),
              AppSpacing.vSm,
              Text('الحالة: ${req.statusLabel}', style: AppTypography.bodyMedium),
              if (req.requestNote != null) ...[
                AppSpacing.vSm,
                Text('ملاحظة: ${req.requestNote}', style: AppTypography.bodyMedium),
              ],
              if (req.isPending) ...[
                AppSpacing.vLg,
                Row(
                  children: [
                    Expanded(
                      child: CustomButton.primary(
                        text: 'اعتماد',
                        icon: Icons.check_rounded,
                        onPressed: () => _controller.approveRequest(req.requestId),
                      ),
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: CustomButton.outline(
                        text: 'رفض',
                        icon: Icons.close_rounded,
                        onPressed: () => _controller.rejectRequest(req.requestId, reason: 'مرفوض'),
                      ),
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: CustomButton.outline(
                        text: 'إلغاء',
                        icon: Icons.cancel_rounded,
                        onPressed: () => _controller.cancelRequest(req.requestId),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}
