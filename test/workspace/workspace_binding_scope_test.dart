import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/features/membership/presentation/bindings/membership_binding.dart';
import 'package:netsales/features/membership/presentation/controllers/network_members_controller.dart';
import 'package:netsales/features/membership/presentation/controllers/pos_members_controller.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  test('membership controllers are registered cleanly and independently per workspace', () {
    MembershipBinding().dependencies();

    expect(Get.isRegistered<NetworkMembersController>(), isTrue);
    expect(Get.isRegistered<PosMembersController>(), isTrue);
  });

  test('re-entering membership binding does not duplicate registrations', () {
    MembershipBinding().dependencies();

    expect(
      () {
        MembershipBinding().dependencies();
      },
      returnsNormally,
    );

    expect(Get.isRegistered<NetworkMembersController>(), isTrue);
    expect(Get.isRegistered<PosMembersController>(), isTrue);
  });
}
