import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/features/membership/presentation/bindings/membership_binding.dart';
import 'package:netsales/features/membership/presentation/controllers/membership_controller.dart';
import 'package:netsales/features/membership/presentation/screens/membership_screen.dart';

void main() {
  setUp(() async {
    Get.testMode = true;
    await Get.reset();
  });

  tearDown(() async {
    await Get.reset();
  });

  test('membership controllers are registered independently per workspace', () {
    MembershipBinding(isNetwork: true).dependencies();
    MembershipBinding(isNetwork: false).dependencies();

    expect(
      Get.isRegistered<MembershipController>(
        tag: MembershipBinding.networkTag,
      ),
      isTrue,
    );
    expect(
      Get.isRegistered<MembershipController>(
        tag: MembershipBinding.posTag,
      ),
      isTrue,
    );
    expect(Get.isRegistered<MembershipController>(), isFalse);
  });

  test('membership screens resolve the matching workspace controller tag', () {
    expect(
      const MembershipScreen(isNetwork: true).tag,
      MembershipBinding.networkTag,
    );
    expect(
      const MembershipScreen(isNetwork: false).tag,
      MembershipBinding.posTag,
    );
  });

  test('re-entering workspace bindings does not duplicate registrations', () {
    MembershipBinding(isNetwork: true).dependencies();
    MembershipBinding(isNetwork: false).dependencies();

    expect(
      () {
        MembershipBinding(isNetwork: true).dependencies();
        MembershipBinding(isNetwork: false).dependencies();
      },
      returnsNormally,
    );

    expect(
      Get.isRegistered<MembershipController>(
        tag: MembershipBinding.networkTag,
      ),
      isTrue,
    );
    expect(
      Get.isRegistered<MembershipController>(
        tag: MembershipBinding.posTag,
      ),
      isTrue,
    );
  });
}
