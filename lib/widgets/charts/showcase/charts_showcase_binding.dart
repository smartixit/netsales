import 'package:get/get.dart';
import 'charts_showcase_controller.dart';

/// Registers the isolated state for the developer-only chart showcase.
class ChartsShowcaseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChartsShowcaseController>(ChartsShowcaseController.new);
  }
}
