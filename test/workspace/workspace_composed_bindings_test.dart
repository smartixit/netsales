import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/features/workspace/presentation/bindings/network_workspace_binding.dart';
import 'package:netsales/features/workspace/presentation/bindings/pos_workspace_binding.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_orders_controller.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_new_procurement_order_controller.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  test('network and POS workspace bindings can be composed repeatedly', () {
    expect(
      () {
        NetworkWorkspaceBinding().dependencies();
        PosWorkspaceBinding().dependencies();
        NetworkWorkspaceBinding().dependencies();
        PosWorkspaceBinding().dependencies();
      },
      returnsNormally,
    );

    expect(Get.isRegistered<NetworkWorkspaceController>(), isTrue);
    expect(Get.isRegistered<PosWorkspaceController>(), isTrue);
    expect(Get.isPrepared<PosProcurementOrdersController>(), isTrue);
    expect(Get.isPrepared<PosNewProcurementOrderController>(), isFalse);
  });
}
