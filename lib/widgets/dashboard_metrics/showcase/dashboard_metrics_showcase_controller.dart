import 'package:get/get.dart';

/// Local presentation controls for the developer-only KPI showcase.
class DashboardMetricsShowcaseController extends GetxController {
  final isDarkMode = false.obs;
  final isRtl = false.obs;

  void setDarkMode(bool value) => isDarkMode.value = value;

  void setRtl(bool value) => isRtl.value = value;

  void reset() {
    isDarkMode.value = false;
    isRtl.value = false;
  }
}
