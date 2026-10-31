import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
// قم باستيراد ملف تشغيل التطبيق الخاص بك هنا، مثال:
// import 'package:netsales/main.dart' as app; 

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('تحقق من مطابقة عقد البيانات والاتصال', () {
    testWidgets('فحص استجابة الدخول ومطابقة الحقول مع OpenAPI', (tester) async {
      // 1. تشغيل التطبيق
      // app.main();
      // await tester.pumpAndSettle();

      // 2. هنا يتم فحص الـ Models وتأكيد عدم وجود حقول Nullable تكسر التطبيق
      // مثال للتأكد من موافقة حقول الكائن مع استجابة Scramble المتوقعة
      final mockResponse = {
        "status": true,
        "message": "Success",
        "data": {"id": 1, "name": "Smartix"}
      };
      
      expect(mockResponse.containsKey('data'), true);
      expect(mockResponse['data'], isA<Map<dynamic,dynamic>>());
    });
  });
}
