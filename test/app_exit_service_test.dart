import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/services/app_exit_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/theme_service.dart';
import 'package:netsales/core/themes/app_themes.dart';
import 'package:netsales/widgets/navigations/double_back_exit_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    Get.put<StorageService>(StorageService.instance, permanent: true);
    await ThemeService.instance.init();
    Get.put<ThemeService>(ThemeService.instance, permanent: true);
    Get.put<AppExitService>(AppExitService.instance, permanent: true);
  });

  Widget buildTestableWidget(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => GetMaterialApp(
        theme: AppThemes.light,
        home: child,
      ),
    );
  }

  group('AppExitService Unit Tests', () {
    test('first tap returns false and triggers notification', () async {
      final service = AppExitService.instance;
      service.reset();

      bool firstTapCallbackInvoked = false;
      final canExitFirst = await service.handleExitRequest(
        showToast: false,
        triggerHaptic: false,
        onFirstTap: () {
          firstTapCallbackInvoked = true;
        },
      );

      expect(canExitFirst, isFalse);
      expect(firstTapCallbackInvoked, isTrue);
    });

    test('second tap within time window returns true', () async {
      final service = AppExitService.instance;
      service.reset();

      final firstResult = await service.handleExitRequest(
        showToast: false,
        triggerHaptic: false,
      );
      expect(firstResult, isFalse);

      final secondResult = await service.handleExitRequest(
        showToast: false,
        triggerHaptic: false,
      );
      expect(secondResult, isTrue);
    });

    test('reset clears back press state', () async {
      final service = AppExitService.instance;
      service.reset();

      await service.handleExitRequest(
        showToast: false,
        triggerHaptic: false,
      );

      service.reset();

      // بعد الـ reset، يجب أن تُعامل النقرة التالية كنقرة أولى
      final resultAfterReset = await service.handleExitRequest(
        showToast: false,
        triggerHaptic: false,
      );
      expect(resultAfterReset, isFalse);
    });
  });

  group('DoubleBackExitScope Widget Tests', () {
    testWidgets('renders child widget cleanly', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const DoubleBackExitScope(
            child: Scaffold(
              body: Text('Protected Content'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Protected Content'), findsOneWidget);
      expect(find.byType(DoubleBackExitScope), findsOneWidget);
      expect(find.byWidgetPredicate((widget) => widget is PopScope), findsOneWidget);
    });
  });
}
