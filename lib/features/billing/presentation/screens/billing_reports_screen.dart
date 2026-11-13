import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_reports_controller.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_reports_content.dart';

/// Composition-only route screen for subscription reports.
class BillingReportsScreen extends GetView<BillingReportsController> {
 const BillingReportsScreen({super.key});

 @override
 Widget build(BuildContext context) => Obx(
  () => BillingReportsContent(controller:controller),
 );
}
