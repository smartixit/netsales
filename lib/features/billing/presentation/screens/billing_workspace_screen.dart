import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_workspace_content.dart';

/// Composition-only route screen for the billing workspace.
class BillingWorkspaceScreen extends GetView<BillingController> {
  const BillingWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) => BillingWorkspaceContent(controller: controller);
}
