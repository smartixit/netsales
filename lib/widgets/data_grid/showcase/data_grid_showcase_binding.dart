
import 'package:get/get.dart';
import 'data_grid_showcase_controller.dart';

class DataGridShowcaseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DataGridShowcaseController>(DataGridShowcaseController.new);
  }
}
