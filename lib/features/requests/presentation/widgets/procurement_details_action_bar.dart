import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/presentation/controllers/procurement_request_details_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_details_action_row.dart';

/// شريط الإجراءات التفاعلي المخصص في أسفل صفحة تفاصيل الطلب
class ProcurementDetailsActionBar extends StatelessWidget {
  const ProcurementDetailsActionBar({
    super.key,
    required this.request,
    required this.controller,
  });

  final RequestEntity request;
  final ProcurementRequestDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isNetwork = controller.isNetworkWorkspace;

    // لا نعرض شريط الأزرار إذا لم يكن هناك إجراء متاح
    final hasPendingActions = request.isPending;
    final hasInvoiceAction =
        request.isApproved &&
        request.invoiceId != null &&
        request.invoiceId! > 0;

    if (!hasPendingActions && !hasInvoiceAction) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadding,
          vertical: 10.h,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Align(
          alignment: Alignment.center,
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ProcurementDetailsActionRow(
              request: request,
              controller: controller,
              isNetwork: isNetwork,
            ),
          ),
        ),
      ),
    );
  }
}
