import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:netsales/features/finance/presentation/controllers/repayment_history_controller.dart';
import 'package:netsales/features/finance/presentation/widgets/repayment_allocation_timeline.dart';
import 'package:netsales/features/finance/presentation/widgets/repayment_details_summary.dart';
import 'package:netsales/features/finance/presentation/widgets/repayment_reversal_action.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

class RepaymentDetailsScreen extends GetView<RepaymentHistoryController> {
  final PosRepaymentEntity? repayment;
  final bool isNetworkView;

  const RepaymentDetailsScreen({
    super.key,
    this.repayment,
    this.isNetworkView = true,
  });

  @override
  Widget build(BuildContext context) {
    final item =
        repayment ??
        (Get.arguments is PosRepaymentEntity
            ? Get.arguments as PosRepaymentEntity
            : null);

    if (item == null) {
      return const CustomAppScaffold(
        body: Center(
          child: CustomEmptyState(
            title: 'لم يتم العثور على السند',
            subtitle: 'تعذر تحديد بيانات سند التحصيل المطلوب',
          ),
        ),
      );
    }

    final canReverse = controller.canReverseRepayment(
      item,
      isNetworkView: isNetworkView,
    );

    return CustomAppScaffold(
      appBar: AppBar(title: Text('سند سداد #${item.repaymentId}')),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppBreakpoints.maxContentWidth,
            ),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RepaymentDetailsSummary(
                    repayment: item,
                    isNetworkView: isNetworkView,
                  ),
                  if (canReverse) ...[
                    AppSpacing.vMd,
                    RepaymentReversalAction(repayment: item),
                  ],
                  AppSpacing.vXl,
                  RepaymentAllocationTimeline(allocations: item.allocations),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
