import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/core/services/theme_service.dart';
import 'package:netsales/main.dart';
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
    Get.put<PermissionService>(PermissionService.instance, permanent: true);
    await SessionService.instance.init();
    Get.put<SessionService>(
      SessionService.instance,
      permanent: true,
    );
  });

  testWidgets('NetSales application smoke test boots MyApp', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(MyApp), findsOneWidget);
  });
}
