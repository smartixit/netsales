import 'package:get/get.dart';

import 'dashboard_metrics_showcase_controller.dart';

/// Registers the isolated state used by the KPI showcase.
class DashboardMetricsShowcaseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardMetricsShowcaseController>(
      DashboardMetricsShowcaseController.new,
    );
  }
}
