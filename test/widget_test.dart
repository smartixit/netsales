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
    final themeService = Get.put<ThemeService>(ThemeService(), permanent: true);
    await themeService.init();
    Get.put<PermissionService>(PermissionService(), permanent: true);
    final sessionService = Get.put<SessionService>(
      SessionService(),
      permanent: true,
    );
    await sessionService.init();
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
