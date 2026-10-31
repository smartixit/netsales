# اختبارات Flutter Integration Test

هذه الاختبارات تشغّل التطبيق فعليًا على محاكي أو جهاز، وتتحقق من رحلة مستخدم كاملة أو جزء كبير منها. وهي ليست بديلًا عن اختبارات Unit وWidget؛ تكلفة تشغيلها وصيانتها أعلى، لذلك نختار بها أهم الرحلات فقط.

## الإعداد

أضف حزمة الاختبار الرسمية من Flutter إلى `dev_dependencies`:

```powershell
flutter pub add --dev integration_test
```

يفترض وجود `flutter_test` ضمن `dev_dependencies` كما في مشاريع Flutter المعتادة. راجع `pubspec.yaml` بعد الإضافة ثم احتفظ بتحديث `pubspec.lock`.

## إنشاء اختبار

أنشئ مثلًا `integration_test/app_flow_test.dart`. ابدأ بتهيئة binding:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('critical user journey', (tester) async {
    // TODO: استورد وشغّل جذر التطبيق بالطريقة الفعلية في مشروعك.
    // TODO: جهّز GetX bindings والخدمات والبيانات التجريبية.
    // TODO: نفّذ رحلة حقيقية وتحقق من النتيجة النهائية، لا من مجرد وجود الزر.
  });
}
```

لا تترك المثال كما هو؛ استبدل TODO بتهيئة التطبيق الفعلية واختبارات ذات معايير قبول واضحة.

## التشغيل على Windows

اعرض الأجهزة المتاحة:

```powershell
flutter devices
```

ثم شغّل الاختبار على جهاز محدد:

```powershell
flutter test integration_test/app_flow_test.dart -d <device-id>
```

للاتصال بخادم Laravel محلي من Android Emulator، غالبًا يكون عنوان جهاز المضيف `http://10.0.2.2:8000` بدل `localhost`. شغّل Laravel على واجهة تسمح للمحاكي بالوصول، واسمح بالمنفذ في جدار الحماية عند الحاجة. في جهاز Android فعلي استخدم عنوان IP محليًا يمكن الوصول إليه من الجهاز.

مرّر عنوان API اختباريًا مثلًا:

```powershell
flutter test integration_test/app_flow_test.dart -d <device-id> --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

يجب أن يقرأ التطبيق `API_BASE_URL` من `String.fromEnvironment` أو من آلية إعداد موجودة بالمشروع. لا تضع أسرارًا أو عنوان الإنتاج في ملف الاختبار.

## حدود الاختبارات

حزمة `integration_test` الرسمية لا تتحكم في واجهات النظام الأصلية مثل بعض نوافذ الأذونات. استخدم اختبارًا خاصًا بالمنصة أو فحصًا يدويًا مضبوطًا لهذه الحالات. اختبر فقط على بيانات وخادم اختبار.
