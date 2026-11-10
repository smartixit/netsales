import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:netsales/features/finance/presentation/controllers/repayment_history_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

class RepaymentReversalAction extends GetView<RepaymentHistoryController> {
  const RepaymentReversalAction({super.key, required this.repayment});

  final PosRepaymentEntity repayment;

  @override
  Widget build(BuildContext context) {
    return CustomButton.danger(
      text: 'عكس سند السداد',
      prefix: Icons.undo_rounded,
      width: double.infinity,
      onPressed: () => controller.requestReversal(repayment),
    );
  }
}
