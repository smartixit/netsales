import 'package:get/get.dart';
import 'package:netsales/features/home/presentation/controllers/home_layout_controller.dart';

/// ============================================================================
/// رابط حقن تبعيات الشاشة الرئيسية (HomeLayoutBinding)
/// ============================================================================
/// يسجل كائن [HomeLayoutController] في شجرة حقن التبعيات وفق معايير Clean Architecture.
class HomeLayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeLayoutController>(() => HomeLayoutController());
  }
}
