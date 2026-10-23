import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_loading_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

class SaleInvoiceDetailsScreen extends StatefulWidget {
  const SaleInvoiceDetailsScreen({super.key, this.invoiceId});

  final int? invoiceId;

  @override
  State<SaleInvoiceDetailsScreen> createState() => _SaleInvoiceDetailsScreenState();
}

class _SaleInvoiceDetailsScreenState extends State<SaleInvoiceDetailsScreen> {
  late final OperationsController _controller;
  int? _id;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<OperationsController>();
    _id = widget.invoiceId ?? (Get.arguments is int ? Get.arguments as int : null);
    if (_id != null) {
      _controller.loadInvoiceDetails(_id!);
    }
  }

  @override
  Widget build(BuildContext context) {

    return CustomAppScaffold(
      appBarTitle: 'تفاصيل الفاتورة',
      body: Obx(() {
        if (_controller.isLoadingInvoiceDetails.value) {
          return const CustomLoadingState(message: 'جاري تحميل التفاصيل...');
        }
        if (_controller.invoiceDetailsError.value.isNotEmpty) {
          return CustomErrorState(
            title: 'تعذر تحميل التفاصيل',
            subtitle: _controller.invoiceDetailsError.value,
            onRetry: _id == null ? null : () => _controller.loadInvoiceDetails(_id!),
          );
        }
        final inv = _controller.selectedInvoice.value;
        if (inv == null) {
          return const CustomEmptyState(title: 'لا توجد بيانات');
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('UUID: ${inv.invoiceUuid}', style: AppTypography.bodySmall),
              AppSpacing.vSm,
              Text('نقطة البيع: ${inv.posName ?? inv.posId}', style: AppTypography.bodyMedium),
              AppSpacing.vSm,
              Text('الشبكة: ${inv.networkName ?? inv.networkId}', style: AppTypography.bodyMedium),
              AppSpacing.vSm,
              Text('النوع: ${inv.saleTypeLabel}', style: AppTypography.bodyMedium),
              AppSpacing.vSm,
              Text('الإجمالي: ${AmountFormatter.formatValue(inv.invoiceTotalAmount)}', style: AppTypography.bodyMedium),
              AppSpacing.vSm,
              Text('المدفوع: ${AmountFormatter.formatValue(inv.paidAmount)}', style: AppTypography.bodyMedium),
              AppSpacing.vSm,
              Text('المتبقي: ${AmountFormatter.formatValue(inv.remainingAmount)}', style: AppTypography.bodyMedium),
              AppSpacing.vSm,
              Text('الحالة: ${inv.paymentStatus}', style: AppTypography.bodyMedium),
            ],
          ),
        );
      }),
    );
  }
}
