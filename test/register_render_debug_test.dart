import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/theme_service.dart';
import 'package:netsales/features/auth/domain/usecases/get_directorates_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/get_governorates_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/register_network_use_case.dart';
import 'package:netsales/features/auth/presentation/controllers/register_network_controller.dart';
import 'package:netsales/features/auth/presentation/screens/register_network_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'register_network_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    Get.put<StorageService>(StorageService.instance, permanent: true);
    await ThemeService.instance.init();
    Get.put<ThemeService>(ThemeService.instance, permanent: true);

    final mockRepo = MockRegisterNetworkAuthRepository();
    final getGovs = GetGovernoratesUseCase(mockRepo);
    final getDirs = GetDirectoratesUseCase(mockRepo);
    final regNet = RegisterNetworkUseCase(mockRepo);

    Get.put<RegisterNetworkController>(
      RegisterNetworkController(getGovs, getDirs, regNet),
    );
  });

  testWidgets('pump RegisterNetworkScreen', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => const GetMaterialApp(
          themeMode: ThemeMode.light,
          home: RegisterNetworkScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
  });
}
