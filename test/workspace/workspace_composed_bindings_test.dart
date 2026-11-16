import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/features/workspace/presentation/bindings/network_workspace_binding.dart';
import 'package:netsales/features/workspace/presentation/bindings/pos_workspace_binding.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';

void main() {
  setUp(() async {
    Get.testMode = true;
    await Get.reset();
  });

  tearDown(() async {
    await Get.reset();
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
  });
}
