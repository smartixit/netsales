# ميثاق الهندسة البرمجية والكود النظيف الموحد لتطبيق فلاتر (NetSales Flutter Architecture & Clean Code Rules)

تعتبر هذه الوثيقة المرجع الأساسي والملزم لجميع عمليات التطوير والتعديل البرمجي داخل تطبيق Flutter الخاص بنظام NetSales. يجب الالتزام الصارم بها في كافة الملفات والمراحل دون الحاجة لأي تذكير:

---

## 1. سياسة منع الأرقام والألوان السحرية نهائياً (Zero Hardcoded Magic Values Policy)
- **الألوان:** يُحظر حظرًا قاطعاً كتابة أو استخدام `Color(0x...)` أو `Colors.any` داخل أي شاشة أو ودجت. المصدر الحصري والوحيد لجميع ألوان التطبيق هو `context.colors.*` المعرف في `AppColors` والذي يدعم الوضعين الفاتح والداكن تلقائياً.
- **التايبوغرافي والنصوص:** يُحظر حظرًا قاطعاً كتابة `TextStyle(fontSize: ..., fontWeight: ...)` أو تحديد أحجام خطوط عشوائية داخل الشاشات. يجب الاعتماد حصرياً على الرموز الموحدة في `AppTypography.*` (مثل `titleLarge`, `bodyMedium`, `buttonMedium`, `currencyHero`, `inputLabel`) مع استخدام `.copyWith(color: context.colors.*)` فقط عند الحاجة لتغيير اللون.
- **الأبعاد والمسافات والحواف:**
  - المسافات الأفقية: استخدام `AppSpacing.hXxs`, `AppSpacing.hXs`, `AppSpacing.hSm`, `AppSpacing.hMd`, `AppSpacing.hLg`, `AppSpacing.hXl` حصراً.
  - المسافات الرأسية: استخدام `AppSpacing.vXxs`, `AppSpacing.vXs`, `AppSpacing.vSm`, `AppSpacing.vMd`, `AppSpacing.vLg`, `AppSpacing.vXl` حصراً.
  - تدوير الحواف: استخدام `AppRadius.xs`, `AppRadius.sm`, `AppRadius.md`, `AppRadius.lg`, `AppRadius.full` حصراً.
  - جميع القياسات والمسافات والخطوط تدعم وتلتزم بـ `flutter_screenutil` (`.w`, `.h`, `.sp`, `.r`).
- **الظلال ومستويات الارتفاع:** يُحظر حظرًا قاطعاً كتابة `BoxShadow(...)` يدوياً داخل أي شاشة أو ودجت. الاعتماد الحصري على `AppElevation.level0` حتى `level5`، والظلال الملونة عبر `AppElevation.tinted(...)`، والتوهج عبر `AppElevation.glow(...)`.
- **التدرجات اللونية:** يُحظر حظرًا قاطعاً كتابة `LinearGradient(...)` عشوائية. الاعتماد الحصري على `AppGradients.*` (`surfaceMesh`, `financialHero`, `flowingBar`, `shimmer`, إلخ) مع التكيف التلقائي للمظهرين الفاتح والداكن.
- **الحركات والمدد الزمنية:** يُحظر حظرًا قاطعاً تحديد مدد زمنية `Duration(...)` أو منحنيات تسارع `Curves.*` عشوائية داخل الواجهات. الاعتماد الحصري على `AppMotion.*` ومراعاة إمكانية الوصول عبر `AppMotion.disabled(context)`.

---

## 2. المكونات الموحدة الإلزامية ومنع الأزرار الخام نهائياً (Mandatory Unified Components & Zero Raw Buttons Policy)
- **الأزرار وعناصر التحكم اللمسية (Buttons & Touch Handlers):**
  - **يُحظر حظرًا قاطعاً وباتاً** استخدام أزرار Flutter الخام (`ElevatedButton`, `OutlinedButton`, `TextButton`, `IconButton`, `FloatingActionButton`, `InkWell`, `GestureDetector`) مباشرة داخل أي شاشة أو ودجت.
  - **المصدر الحصري والوحيد للأزرار:** المكون القياسي الموحد `CustomButton` وفئاته المصنعية السبع:
    - `CustomButton.primary`: للإجراءات الرئيسية وتأكيد النماذج والعمليات الأساسية.
    - `CustomButton.secondary`: للإجراءات الثانوية والخيارات البديلة.
    - `CustomButton.outline`: للإجراءات المفرغة بحدود والإلغاء الأنيق.
    - `CustomButton.text`: للإجراءات النصية الخفيفة والروابط التفاعلية (مثل "نسيت كلمة المرور؟", "إنشاء حساب جديد").
    - `CustomButton.danger`: للحذف والإجراءات الحساسة والتدميرية.
    - `CustomButton.icon`: للأزرار الأيقونية الدائرية والمربعة، وأزرار الرجوع القياسية في `AppBar.leading` مع الأبعاد الموحدة (`dimension: 40.r`, `iconSize: 18.r`, `backgroundColor: Colors.transparent`).
    - `CustomButton.floating`: للأزرار العائمة.
- **التفاعل الحركي الناعم (Micro-interactions):**
  - يجب تغليف كافة العناصر التفاعلية والبطاقات القابلة للنقر بمكون `CustomInteractiveBounce` لتوفير ارتداد فيزيائي ناعم وتغذية لمسية فورية `HapticFeedback.lightImpact()`.
- **التنبيهات والرسائل (System Snackbars & Notifications):**
  - الاعتماد الحصري على `CustomSnackbar.show(...)` لكافة رسائل النظام وحالات الإشعار (`success`, `error`, `warning`, `info`)، مع تعقيم وتصفية رسائل الأخطاء عبر `AppException.sanitizeMessage`.
- **حقول النصوص وكلمات المرور (Unified Text Inputs & Password Toggle):**
  - الاعتماد التام على `CustomTextField`.
  - لحقول كلمات المرور: تفعيل خاصية `enablePasswordToggle: true` المدمجة بالودجت. **يُحظر تماماً** تمرير `suffixIcon: IconButton(...)` يدوي مكرر لإظهار وإخفاء كلمة المرور.
- **حقول رموز الأمان والتحقق الرقمي (PIN / OTP Fields):**
  - الاعتماد الحصري على المكون الموحد `CustomPinField`، ويُحظر كتابة أو تضمين حزم Pin الخام (مثل `PinCodeTextField` أو `Pinput`) مباشرة داخل الشاشات.
- **القوائم المنسدلة والبحث التفاعلي (Dropdowns & Selectors):**
  - الاعتماد الحصري على المكون الموحد `CustomDropdown` المدعوم بالبحث والتحقق اللحظي، وحظر استخدام `DropdownButton` الخام.
- **مربعات الحوار القياسية (Unified Dialogs & Approval States):**
  - الاعتماد الحصري على المكون القياسي `CustomDialog` المصمم كـ `StatelessWidget` أصيل ومطابق لهندسة `CustomButton`.
  - يُحظر استخدام `showDialog` أو `AlertDialog` الخام من Flutter في الشاشات.
- **المرفقات والملفات والصور (Unified Media & File Pickers):**
  - الاعتماد الحصري على `CustomImagePicker` لاختيار الشعارات والصور الشخصية، و `CustomFilePicker` لكافة الملفات والمستندات وجداول البيانات، مع إدارة كاملة عبر `FilePickerService`.

---

## 3. المعمارية الطبقية النظيفة الصارمة (Strict Layered Clean Architecture)
يجب أن تتبع كافة ميزات التطبيق التقسيم الهيكلي الإلزامي التالي المستمد من معيار Clean Architecture القياسي للمشاريع المؤسسية:
```
lib/
├── core/                                # البنية التحتية المشتركة (config, constants, services, themes, utils, models)
├── widgets/                             # الودجات العامة المشتركة لكافة شاشات التطبيق
└── features/
    └── [feature_name]/
        ├── data/
        │   ├── datasources/            # *_data_source.dart (عقد) & *_data_source_impl.dart (تطبيق)
        │   ├── models/                  # *_model.dart (يرث إجبارياً من Entity المقابلة)
        │   └── repositories/           # *_repository_impl.dart (تطبيق مستودع الدومين)
        ├── domain/
        │   ├── entities/                # *_entity.dart (كائنات نقية، خالية تماماً من منطق الـ JSON)
        │   ├── repositories/            # *_repository.dart (عقود المستودعات الدومينية المجردة)
        │   └── usecases/               # *_use_case.dart (حالات الاستخدام الذرية لمنطق الأعمال)
        └── presentation/                # طبقة العرض والواجهات (presentation)
            ├── bindings/                # *_binding.dart (حقن التبعيات وفق سريان الاعتمادية)
            ├── controllers/             # *_controller.dart (إدارة الحالة والتنسيق مع UseCases حصراً)
            ├── screens/                 # *_screen.dart (الشاشات الرئيسية)
            └── widgets/                 # الودجات المخصصة للميزة حصراً
```

### القواعد المعمارية الحاكمة ومصفوفة الحدود الصارمة:
1. **قاعدة سريان الاعتمادية للداخل (Inward Dependency Rule):**
   $$\text{Presentation} \longrightarrow \text{Domain UseCases} \longrightarrow \text{Domain Repository Contract} \longleftarrow \text{Data Repository Implementation} \longrightarrow \text{Data Sources}$$
   - طبقة الـ `Domain` هي مركز النظام النقي: **يُحظر حظرًا باتاً** أن تستورد أي ملف من `data/` أو `presentation/` أو أي حزمة خارجية (Dio, Storage, GetX, etc.).
   - طبقة الـ `Presentation` تستدعي **حصراً** حالات الاستخدام (`UseCases`). **يُحظر حظرًا باتاً** استدعاء `ApiService` أو `StorageService` أو `DataSource` أو `Repository` مباشرة داخل أي `Controller` أو `Widget`.
   - كلاسات الـ `Bindings` هي المكان الحصري المسموح له بتركيب سلسلة التبعيات: `DataSource` $\rightarrow$ `Repository` $\rightarrow$ `UseCase` $\rightarrow$ `Controller`.

2. **قاعدة وراثة الموديل من الكيان (`Model extends Entity`):**
   - كافة الموديلات في `data/models/` يجب أن ترث بالضرورة من الكيان المقابل في `domain/entities/` (`class UserModel extends UserEntity`).
   - الكيان (`Entity`) يحمل الحقول ومنطق الأعمال النقي فقط (دون دوال `fromJson`/`toJson`).
   - الموديل (`Model`) هو المسؤول الحصري عن تسلسل البيانات (`fromJson` / `toJson`).
   - مستودع البيانات (`RepositoryImpl`) يعيد كائن الموديل مباشرة بصفته Polymorphic Entity دون تكرار نسخ الحقول يدوياً.

3. **قواعد مصادر البيانات (`DataSources`):**
   - تُقسّم داخل `data/datasources/` إلى عقد مجرد `*_data_source.dart` وتطبيق فعلي `*_data_source_impl.dart`.
   - لا تتعامل مع الكيانات مباشرة، بل تستقبل وترجع كائنات الموديلات (`Models`) أو البيانات الأولية.

---

## 4. فصل المسؤوليات وإدارة الحالة والمعمارية التركيبية للشاشات (State Management & Modular Composite Screens)
- **الواجهات النحيفة والمعمارية التركيبية (Lean Views & Composite Architecture):**
  - الشاشات والودجات وظيفتها فقط رسم واجهة المستخدم والاستماع للحالة عبر `Obx` أو `GetBuilder`. يُحظر كتابة أي منطق أعمال أو طلبات شبكة أو عمليات حسابية معقدة داخل كلاسات الـ Widget.
- **قاعدة الواجهات التركيبية وحظر دوال البناء المساعدة نهائياً (`Zero Screen Helper Methods Policy`):**
  - **يُحظر حظرًا قاطعاً وباتاً** كتابة دوال مساعدة محلية مثل `Widget _buildHeader(...)`, `Widget _buildForm(...)`, `Widget _buildButtons(...)`, `Widget _buildSection(...)`, إلخ، داخل أي ملف شاشة (`*Screen`).
  - **الأساس الهندسي والأدائي الصارم:**
    - دوال البناء العادية لا تمتلك هوية (`Key`) أو دورة حياة خاصة في شجرة العناصر (`Element Tree`).
    - تفقد محرك Flutter القدرة على التخزين المؤقت للثوابت (`const constructor optimizations`).
    - تتسبب في إجبار Flutter على إعادة بناء كامل شجرة الشاشة بالكامل عند أي تحديث بسيط للحالة في GetX أو مع كل نبضة في حقول الإدخال، مما يسبب هدر الذاكرة، والـ Garbage Collection المتكرر، وسقوط الإطارات (Frame Drops / Jank).
  - **المعيار الإلزامي البديل (Modular Decomposition):**
    - يجب تفكيك كل شاشة إلى شريحة من الودجات المستقلة والمعزولة داخل مجلد `features/[feature_name]/presentation/widgets/`:
      1. ودجات الترويسة والشعارات (مثل `RegisterHeaderSection`, `LoginHeaderSection`, `TwoFactorHeaderSection`, `VerifyOtpHeaderSection`).
      2. ودجات البطاقات واستمارات الإدخال (مثل `NetworkInfoCard`, `OwnerInfoCard`, `LoginFormCard`, `TwoFactorFormCard`).
      3. ودجات التذييل والروابط والإجراءات (مثل `RegisterSubmitSection`, `LoginFooterLinks`, `TwoFactorDeviceCard`).
    - دور ملف الشاشة (`*Screen`) يقتصر فقط وحصراً على كونه "مجمّع تركيبي رشيق" (Lean Composite Assembler) يرتكز على `Scaffold`، ويحدد الحاوية التكيفية `ResponsiveContentWrapper`، ويرتب الودجات الفرعية المستقلة ذات الـ `const constructors`.
- **المتحكمات (Controllers):** ترث حصراً من `GetxController`. هي المسؤولة عن إدارة حالة العرض، استقبال مدخلات المستخدم، استدعاء الـ Use Cases، ومعالجة أخطاء الواجهة والتحميل.
- **إدارة دورة الحياة (Lifecycle):** تسجيل التبعيات عبر `Bindings` في المسارات، مع تنظيف الموارد في `onClose()`.

---

## 5. المطابقة التامة مع الواجهة الخلفية (Backend-Frontend Strict Contract)
- **المرجع الحصري للمسارات:** مسارات الـ API تستدعى حصراً من الثوابت المعرفة في `ApiConstants`.
- **المطابقة العقدية:** كافة نماذج البيانات (`Models`) وحقول الـ JSON يجب أن تتطابق بنسبة 100% مع واجهة `netsales_api` المعتمدة في `routes/api.php` ونماذج `app/Models`.
- **حظر متبقيات المشاريع السابقة نهائياً:** يُحظر حظراً باتاً كتابة أي متغيرات أو كلاسات أو دوال تتبع أنظمة سابقة لا صلة لها بنظام NetSales (مثل `stores`, `suppliers`, `purchases`, `purchaseReturns`). الكيانات المعتمدة حصراً هي:
  - الشبكات: `networks`
  - نقاط البيع: `pos`
  - ربط الشبكات بنقاط البيع: `network-pos`
  - باقات كروت الشبكة: `voucher-packages`
  - خصومات الباقات لنقاط البيع: `voucher-package-discounts`
  - فواتير بيع الكروت: `sale-invoices`
  - طلبات كروت الإنترنت: `voucher-requests` (أو `requests`)
  - محافظ الشبكات ونقاط البيع: `network-wallets`, `pos-wallets`
  - باقات واشتراكات مزودي الشبكات: `provider-subscriptions`, `subscription-plans`
  - تذاكر ورسائل الدعم الفني: `support-tickets`
  - المصروفات والحسابات البنكية: `expenses`, `bank-accounts`
  - المحافظات والمديريات: `governorates`, `directorates`
  - إعدادات الرسائل النصية للشبكات: `sms-settings`

---

## 6. معايير هندسة واجهات المستخدم وتجربة الاستخدام (UI/UX & RTL Standards)
- **الحالات الشاملة للواجهة:** يجب أن تغطي كل شاشة كافة حالاتها بوضوح:
  - حالة التحميل (`Loading State`) مع مؤشرات ملائمة وغير مزعجة.
  - حالة الفراغ (`Empty State`) مع رسائل توجيهية وإمكانية إعادة الإجراء.
  - حالة الخطأ (`Error State`) مع أزرار إعادة المحاولة (`Retry`).
  - حالة النجاح واستعراض البيانات الكاملة.
- **الدعم الكامل للغة العربية والاتجاه (RTL):** الواجهات مصممة أصلاً لدعم الـ RTL واللغة العربية بسلاسة تامة، مع محاذاة الأيقونات والمسارات بما يتناسب مع اتجاه القراءة العربي.
- **التصميم المتجاوب:** التوافق الكامل مع كافة أحجام الشاشات وأجهزة الهواتف والأجهزة اللوحية بالاعتماد الدائم على `flutter_screenutil`.

---

## 7. بروتوكول التحكم البرمجي الصارم وبوابات المصادقة (Absolute Execution Control & Gates)
- **العمل وفق أطوار هندسية متتالية:**
  1. طور التحليل والمعاينة البرمجية (Analysis Only) دون مساس بملفات المشروع.
  2. طور التخطيط وتقديم مقترح الميزة (Feature Plan).
  3. بوابة المصادقة الصريحة (Explicit Approval Gate) من المستخدم قبل أي تعديل.
  4. طور التنفيذ البرمجي لشريحة واحدة محددة (One Vertical Slice).
  5. طور التحقق المادي الشامل ومراجعة التغييرات (Diff Review).
- **تنفيذ ميزة واحدة في كل خطوة (One Feature at a Time):**
  - بناء ميزة متكاملة طرفياً من الـ Data Source وحتى الشاشة.
  - منع ترك أي كود وهمي أو TODOs أو استجابات تجريبية في المسار التنفيذي للإنتاج.
  - عدم الانتقال لأي ميزة تالية دون مصادقة صريحة.

---

## 8. سلامة التعديل والترميز وتجنب الأخطاء (Code Integrity & Verification)
- **حظر التعديل عبر أوامر الشل المؤذية:** يُحظر تماماً استخدام PowerShell `Set-Content` أو إعادة التوجيه النصي للكتابة داخل ملفات الكود لتجنب تشويه الترميز العربي (Mojibake). يتم التعديل دائماً بترميز `UTF-8` المعتمد لضمان دقة اللغة العربية وسلامة ملفات المشروع.
- **فحص الجودة الدائم:** تشغيل `flutter analyze` بعد أي تعديل جوهري للتأكد من خلو الكود من أي أخطاء أو تحذيرات برمجية قبل تسليمه.
- **تعريف الإنجاز التام (Definition of Done):** لا يُعلن عن إنجاز أي ميزة إلا بعد اجتياز فحص التحليل الساكن، والتأكد من مطابقة العقود، وتوفر أدلة التحقق المادية الصريحة.

---

## 9. الحزام الأمني المؤسسي للصلاحيات والأدوار (Enterprise RBAC & Security Belt)
- **المطابقة الصارمة للصلاحيات:** يجب أن تتطابق مفاتيح الصلاحيات والأدوار بنسبة 100% مع البذور وقواعد الواجهة الخلفية في `PermissionSeeder.php` و `RoleKey.php` والمعرفة داخل `AppPermissions` (70 صلاحية و 7 أدوار مؤسسية).
- **إدارة الحالة المركزية (Single Source of Truth):** الاعتماد الحصري على `PermissionService` لفحص الصلاحيات اللحظية ببحث ذري $O(1)$ مع تجاوز تلقائي لدور `SUPER_ADMIN`.
- **حماية واجهات المستخدم (UI Defense-in-Depth):**
  - يُحظر عرض أي زر أو بطاقة أو قائمة إجراءات حساسة (حذف، تعديل، اعتماد، شحن) دون التحقق الصريح عبر `PermissionService.to.hasPermission(...)` أو `canAny(...)`.
  - العناصر المحمية تُخفى تماماً أو تُعطل بصرياً مع منع أي طلب شبكي غير مصرح.
- **حماية المسارات برمجياً (Route Guards & Middlewares):**
  - حماية المسارات الخاصة بالمستخدمين المسجلين عبر `AuthGuard`.
  - حماية مسارات الضيوف (تسجيل الدخول والتفعيل) عبر `GuestGuard`.
  - حماية المسارات الحساسة بالصلاحيات النوعية عبر `PermissionGuardMiddleware` لرفض الوصول المباشر عبر الروابط العميقة (Deep Links) وإرجاع رسالة خطأ معقمة عبر `PermissionDeniedException`.

---

## 10. منظومة التشفير اللامتناظر والتوثيق السيادي (Asymmetric Cryptography & Sovereign Digital Signatures)
- **انعدام الأسرار بالعميل (Zero Client Secrets):** يُحظر حظراً باتاً تخزين أي `APP_KEY` أو مفاتيح سرية أو مفاتيح خاصة على القرص أو داخل ملفات الكود أو `.env`. التطبيق يتعامل فقط مع المفتاح العام السيادي للخادم.
- **المفاتيح المؤقتة لكل طلب (Ephemeral In-Memory Keypairs):**
  - لكل طلب مشفر، يولد التطبيق زوج مفاتيح لامتناظر مؤقت في الذاكرة العشوائية (RAM) حصراً عبر `AppCryptoService.instance.generateEphemeralKeyPair()`.
  - يُحقن المفتاح العام المؤقت للعميل في الترويسة `X-Client-Public-Key` وداخل الحمولة المشفرة `_client_public_key`.
  - يُمسح المفتاح الخاص المؤقت وتُحرر الذاكرة فور فك تشفير الرد في كتلة `finally` الصارمة عبر `keyPair.dispose()`.
- **التشفير المصمت للطلبات (Sealed Box Request Encryption):**
  - تعمية حمولة الطلبات (POST, PUT, PATCH) بمفتاح الخادم العام السيادي (X25519) عبر `crypto_box_seal` وترميز `Base64URL` غير المبطن في حقل `{ "payload": "..." }`.
  - تتم العمليات بشفافية وتلقائية تامة عبر `_CryptoInterceptor` داخل `ApiService`.
- **فك تشفير الاستجابات الآمنة (Server Response Unsealing):**
  - التحقق من البادئة `NTS_ENC_` وفك تشفيرها بمفتاح الطلب المؤقت عبر `crypto_box_seal_open`.
- **مزامنة وتخزين المفاتيح العامة:** جلب المفاتيح من نقطة الوصول الآمنة `/api/v1/security/public-keys` وتخزين المفتاح العام محلياً للعمل دون اتصال.

---

## 11. منظومة منع تكرار العمليات وحالات السباق (Idempotency Key & Safe Retries)
- **إلزامية مفتاح عدم التكرار للعمليات الحساسة:** يجب تمرير `idempotencyKey` في كافة العمليات المالية والحساسة:
  - فواتير بيع الكروت (`sale-invoices`)
  - حركات وتعديلات أرصدة المحافظ (`network-wallets`, `pos-wallets`)
  - طلبات كروت الإنترنت وتأكيدها (`voucher-requests`, `requests`)
  - اشتراكات وتجديد باقات الشبكات (`provider-subscriptions`)
  - سندات المصروفات والحسابات البنكية (`expenses`, `bank-accounts`)
  - العمليات المجمعة (`batch-delete`, `batch-restore`, `batch-force-delete`)
- **المولد الموحد للمفاتيح (`IdempotencyHelper`):** استخدام المولد المعتمد `IdempotencyHelper.forSaleInvoice()`, `forWalletTransaction()`, `forVoucherRequest()`, إلخ، لضمان مفاتيح عشوائية سيبرانية ومحصنة ضد التصادم بصيغة `prefix-timestamp-randomHex`.
- **إعادة المحاولة الآمنة (Safe Retries):** تفعيل إعادة المحاولة التلقائية في `_RetryInterceptor` للطلبات المرفقة بمفتاح عدم التكرار عند انقطاع الاتصال أو أخطاء الخادم العابرة (502, 503, 504, Timeout)، مع ضمان عدم تكرار الأثر المالي بفضل `IdempotencyMiddleware` في الخادم.
- **تتبع استجابات التماثل:** قراءة `X-Idempotency-Hit` وتوثيقها في `ApiResponse.isIdempotentHit` لتمكين واجهات المستخدم من معرفة ما إذا كانت النتيجة مسترجعة من ذاكرة التماثل المؤقتة.

---

## 12. محرك المظهر والانتقال الدائري الفيزيائي (Telegram-Style Ripple Theme Engine)
- **التبديل بنقرة واحدة دون وميض:** التحكم المركزي عبر `ThemeService` وتحديث ألوان النظام `context.colors` فورياً مع حفظ الخيار في `StorageService`.
- **الانتقال الدائري التفاعلي (`TelegramThemeSwitcher`):**
  - تطبيق تأثير التموج الدائري GPU-Accelerated المتوسع من إحداثيات الزر المضغوط باستخدام `RenderRepaintBoundary` و `PathFillType.evenOdd`.
  - الارتداد الحركي الفيزيائي المدعوم بنظام `AppMotion` والاهتزاز اللمسي الذكي `HapticFeedback.lightImpact()`.

---

## 13. ميثاق رموز التصميم الموحدة والتوسيع المنظم للبنية التحتية (Design Tokens & Core Extensibility Policy)
- **حظر التنسيقات العشوائية والمؤقتة (Zero Ad-Hoc Styling):**
  - يُمنع منعاً باتاً استحداث قيم تنسيق معزولة أو ألوان أو ظلال أو أبعاد خاصة داخل شاشات الميزات (`features/[feature_name]`).
  - النظام مبني على مبدأ لغة التصميم المركزية الشاملة (Unified Central Design Language).
- **مبدأ التوسيع الإلزامي للبنية التحتية (Core-First Expansion Principle):**
  - إذا تطلب أي تصميم جديد أو ميزة معينة رمزاً غير موجود مسبقاً (مثل قيمة مسافة إضافية، تأثير ظل أو توهج لوني محدد، تدرج لوني مبتكر، أو نمط حركة جديد):
    - **يُحظر تماماً** حسابه يدوياً أو كتابته كقيمة عشوائية خاصة داخل الميزة.
    - **الإجراء الإلزامي:** يجب توسيع الملف الأساسي المعني داخل `lib/core/` أولاً (`app_spacing.dart`, `app_elevation.dart`, `app_gradients.dart`, `app_motion.dart`, `app_typography.dart`) وتعريفه كرمز تصميم رسمي موثق ومتاح لكافة أجزاء التطبيق.
- **التوافق التلقائي للرموز مع الوضعين (Light & Dark Mode Invariance):**
  - كافة رموز التصميم الموسعة في `core/` يجب أن تبنى بدلالة `context.colors` لتتكيف لحظياً مع التبديل الديناميكي بين المظهرين الفاتح والداكن دون أي انكسار بصري.

---

## 14. معمارية المكونات المشتركة المركزية وحظر التكرار (Centralized Shared Widgets & DRY Architecture)
- **حظر تكرار المكونات نهائياً (Zero Component Duplication):**
  - يُحظر حظراً قاطعاً إعادة كتابة أي ودجت أو عنصر واجهة مستخدم في أكثر من ميزة، أو إنشاء ودجات محلية داخل `features/[feature_name]/presentation/widgets` إذا كانت تؤدي وظيفة بصرية أو تفاعلية عامة أو قابلة لإعادة الاستخدام.
- **الهيكلية المعيارية لمجلد الودجات المشتركة (`lib/widgets/`):**
  - كافة المكونات المشتركة أو القابلة لإعادة الاستخدام يجب نقلها وتطويرها حصرياً داخل `lib/widgets/` مقسمة ومصنفة بحسب النطاق والوظيفة:
    - `lib/widgets/brand/`: شعارات وهوية النظام والعلامة التجارية المصممة بأحجام قياسية وتأثيرات هالة متناسقة (`CustomBrandLogo`).
    - `lib/widgets/cards/`: بطاقات الإجراءات والتحديد والخيارات المشتركة المدعومة بالارتداد الفيزيائي والظلال القياسية (`CustomActionCard`).
    - `lib/widgets/dividers/`: الفواصل المزخرفة والموسومة بعناوين نصية (`CustomLabeledDivider`).
    - `lib/widgets/indicators/`: مؤشرات الصفحات والخطوات التفاعلية ذات التوسع الانسيابي (`CustomPageIndicator`).
    - `lib/widgets/feedback/`: أشرطة التقدم الانسيابية، مؤشرات التحميل والارتداد ومؤثرات Shimmer (`SplashFlowingProgressBar`, إلخ).
    - `lib/widgets/buttons/`: الأزرار الموحدة بكافة فئاتها المصنعية السبع (`CustomButton`).
    - `lib/widgets/inputs/`: حقول الإدخال الموحدة (`CustomTextField`, `CustomPinField`, `CustomDropdown`).
    - `lib/widgets/pickers/`: أدوات اختيار الصور والوسائط والمستندات وجهات الاتصال (`CustomFilePicker`, `CustomImagePicker`, `CustomContactPickerIconButton`).
    - `lib/widgets/dialogs/`: مربعات الحوار التفاعلية وحالات التأكيد والاعتماد المعلق (`CustomDialog`).
- **المعايير القياسية لبناء المكون المشترك:**
  - دعم التجاوب التام والنسبي مع الشاشات عبر `flutter_screenutil` (`.w`, `.h`, `.sp`, `.r`).
  - دعم التفاعل الحركي الفيزيائي الناعم عبر `CustomInteractiveBounce`.
  - دعم الاتجاه العربي (RTL) الصارم وتوافق دلالات الوصولية (Accessibility & Semantics).

---

## 15. الانضباط الهندسي والشراكة الاستراتيجية وسلامة دورة الحياة (Strategic Senior Engineering & Lifecycle Safety)
- **عقلية المهندس المعماري والشريك الاستراتيجي (Principal Partner Mindset):**
  - المطور ليس مجرد منفذ أو كاتب للأكواد، بل هو مهندس برمجيات أول وشريك استراتيجي في نجاح واستقرار النظام على المدى الطويل.
  - **التحليل الاستباقي الشامل:** قبل كتابة أي كود، يجب فحص وتحليل كافة سيناريوهات الاستخدام، واحتمالات الفشل، وحالات الحافة (Edge Cases)، وانقطاع الشبكة، وضعف التوصيل، والتنقل العكسي السريع، وتباين أحجام الشاشات.
  - **بوابة التخطيط المسبق الإلزامية:** تقديم خطة عمل هندسية محكمة وواضحة المعالم، توضح الهيكلية ومسار البيانات والملفات والودجات المستهدفة، واستعراض كافة الاحتمالات والاستثناءات على المدى البعيد، وانتظار المصادقة الصريحة قبل الشروع في التنفيذ.
- **السلامة الصارمة لدورة الحياة والذاكرة واختبارات فلاتر (Lifecycle & Testing Guard):**
  - **حظر الرسوم المتحركة غير المنضبطة:** يُحظر استخدام الأنيميشن اللانهائي أو المتكرر عبر مكتبات الطرف الثالث (مثل `flutter_animate` مع `c.repeat()`) داخل الواجهات الرئيسية، نظراً لتسببها في تسريب الذاكرة وتعطيل اختبارات الوحدة وانهيار `pumpAndSettle()`.
  - **التحكم الصارم بالـ AnimationController:** أي حركة دورية أو تنفسية مستمرة يجب أن تُدار حصرياً عبر `AnimationController` مسجل داخل `StatefulWidget` مع استخدام `SingleTickerProviderStateMixin`، مع التدمير الصارم للمتحكم `controller.dispose()` داخل دالة `dispose()` لضمان تصفير كافة الـ Tickers وتحرير الموارد.
  - **احترام تفضيلات تقليل الحركة (Reduced Motion):** فحص `MediaQuery.disableAnimationsOf(context)` واستخدام `AppMotion.disabled(context)` لتعطيل أو تسريع الحركات للمستخدمين ذوي الاحتياجات الخاصة.
- **معيار الجودة والإتقان الصارم (Definition of Done):**
  - التحقق الدائم عبر فحص التحليل الساكن `flutter analyze` والتأكد من نتيجة `No issues found!`.
  - تشغيل واجتياز كافة اختبارات المشروع المؤتمتة `flutter test` دون أي إخفاق.
  - خلو الكود تماماً من أي ملفات مهجورة، أو استيرادات غير مستخدمة، أو تعليقات TODOs، أو نصوص تجريبية في بيئة الإنتاج.

---

## 16. منظومة التصميم التكيفي ونقاط الانقطاع المعيارية (Enterprise Adaptive Design System & Breakpoints)
- **المرجع الحصري للتصميم التكيفي:** الاعتماد الحصري والمطلق على `AppBreakpoints` وملحقات `ResponsiveContext` (`context.isMobile`, `context.isTablet`, `context.isDesktop`, `context.responsive(...)`) لاتخاذ قرارات التكيف البصري والهيكلي عبر كافة المنصات (Android, iOS, Windows, macOS, Linux, Web).
- **الفئات الست المعيارية للأجهزة (`AppDeviceSize`):**
  - `mobileSmall` (< 360dp)
  - `mobile` (360 - 599dp)
  - `tablet` (600 - 899dp)
  - `desktop` (900 - 1239dp)
  - `desktopLarge` (1240 - 1599dp)
  - `ultraWide` (>= 1600dp)
- **سياسة منع تمدد المحتوى العشوائي (Content Constraint Policy):**
  - يُحظر ترك نماذج واستمارات الإدخال وبطاقات الترحيب تتمدد بلا قيود على الشاشات الكبيرة؛ يجب استخدام `ResponsiveContentWrapper` أو التقييد بـ `AppBreakpoints.maxFormWidth` (540dp) مع التوسيط.
  - تحديد أقصى اتساع للمحتوى الرئيسي واللوحات بـ `AppBreakpoints.maxContentWidth` (1200dp).
- **التكيف الرأسي وتدوير الشاشة (Orientation & Height Guard):**
  - فحص `context.isCompactHeight` و `context.isLandscape` لتجنب انهيارات التمرير (`RenderFlex overflow`) عند تدوير الأجهزة أفقياً.
- **التنقل الهيكلي التكيفي (Adaptive Shell Navigation):**
  - استخدام `NavigationBar` السفلي حصرياً للهواتف الرأسية (`context.usesBottomBar`).
  - استخدام `NavigationRail` الجانبي المصغر للأجهزة اللوحية والهواتف الأفقية (`context.usesNavigationRail`).
  - استخدام `NavigationDrawer` الكامل للشاشات المكتبية والويب (`context.usesNavigationDrawer`).
- **ودجات التكيف الجاهزة:**
  - استخدام `AdaptiveLayout` للفصل المعماري النظيف بين واجهات الموبايل والتابلت والديسكتوب.
  - استخدام `AdaptiveSplitView` لتقسيم الشاشة لعمودين (Side Pane + Main Pane) على الشاشات الكبيرة والتراجع لعمود واحد تلقائياً على الهواتف.

---

## 17. منظومة التقاط واختيار الوسائط وحماية الذاكرة من الانهيار (Enterprise CustomImagePicker & Zero-OOM Image Architecture)
- **المكون القياسي الحصري لاختيار الصور:**
  - الاعتماد الحصري على ودجت `CustomImagePicker` بفئتيه المصنعيتين:
    - `CustomImagePicker.logo`: لاختيار شعار الشبكة، المتاجر، الفواتير، ونقاط البيع (بأبعاد دائرية أو مربعة أنيقة مع أيقونة متخصصة وحاوية متناسقة).
    - `CustomImagePicker.avatar`: لاختيار الصورة الشخصية للمستخدم أو مالك الشبكة أو العميل.
- **الحماية القصوى من انهيار الذاكرة العشوائية (Zero-OOM Protection Architecture):**
  - فك تشفير صور الكاميرا الحديثة بدقتها الكاملة (12MP - 108MP) مباشرة في الذاكرة عبر `Image.file(file)` يستهلك ما بين 80 إلى 200 ميجابايت من الـ RAM لكل صورة غير مضغوطة، مما يسبب انهيار فوري للتطبيق على أجهزة الهواتف المتوسطة والضعيفة نتيجة الـ Out Of Memory (OOM Crash).
  - **القاعدة الصارمة:** يُحظر عرض أي صورة محلية ملتقطة أو مختارة دون تقييد محرك التسييل عبر كاش الذاكرة بأبعاد تتطابق مع حاوية العرض:
    ```dart
    cacheWidth: (boxSize * 2.5).toInt(),
    cacheHeight: (boxSize * 2.5).toInt(),
    ```
    مما يضغط استهلاك الذاكرة اللحظي بنسبة تزيد عن 95% (إلى أقل من 2 ميجابايت).
- **التحقق الصارم من حجم الملف وحمايته:**
  - فحص حجم الملف فور اختياره؛ وفي حال تجاوز 2MB يتم إلغاء العملية فوراً مع عرض رسالة تنبيهية للمستخدم عبر `CustomSnackbar.show(...)`.
- **التوافقية العقدية التامة مع الواجهة الخلفية (Multipart vs JSON):**
  - عند وجود ملفات ملتقطة، يتم إرسال طلب الإنشاء أو التعديل تلقائياً بصيغة `FormData` (Multipart) عبر حقول المطابقة في الواجهة الخلفية (`network_profile_logo`, `user_profile_logo`). وعند انعدام الملفات يتم الإرسال بصيغة `application/json` الخفيفة لتوفير استهلاك البيانات وسرعة المعالجة.

---

## 18. منظومة اختيار جهات الاتصال والأرقام المعتمدة (`CustomContactPickerIconButton`)
- **منظومة اختيار جهات الاتصال (`CustomContactPickerIconButton`):**
  - يُحظر استخدام أي حزم خارجية لاختيار الأرقام مباشرة في الشاشات.
  - الاعتماد الحصري على `CustomContactPickerIconButton` كزر فرعي متكامل داخل حقول أرقام الهواتف (`suffixIcon` في `CustomTextField`).
  - التنسيق مع `ContactPickerService` المعقم لتنظيف أرقام الهواتف واستخراج المفاتيح الدولية تلقائياً، والتحقق الصارم من الشبكات اليمنية المعتمدة (يمن موبايل، يو، سبأفون، واي، الهاتف الثابت).

---

## 19. معايير القياسات والتجاوب الموحدة مع ScreenUtil (Strict ScreenUtil Scaling Policy)
- **أحجام الأيقونات وتدوير الحواف:** استخدام لاحقة `.r` حصراً (`iconSize: 20.r`, `borderRadius: AppRadius.md.r`).
- **العروض والمسافات الأفقية وسمك الحدود:** استخدام لاحقة `.w` حصراً (`width: 320.w`, `borderWidth: 1.5.w`).
- **الارتفاعات والمسافات الرأسية:** استخدام لاحقة `.h` حصراً (`height: 48.h`).
- **الأحجام النصية:** استخدام لاحقة `.sp` المدمجة أصلاً في رموز `AppTypography`.
- **المسافات الفاصلة بين العناصر:** الاعتماد الحصري على `AppSpacing.h*` للمسافات الأفقية و `AppSpacing.v*` للمسافات الرأسية، وحظر كتابة `SizedBox(width: 10)` أو `SizedBox(height: 15)` عشوائياً.

---

## 20. منظومة الملفات والمرفقات المركزية فائقة التخصيص وحظر التكرار (Enterprise File & Media System - FilePickerService & CustomFilePicker)
- **حظر استدعاء حزم الملفات الخام في الشاشات والودجات:**
  - **يُحظر حظرًا قاطعاً** استدعاء مكتبات `file_picker` أو `image_picker` بشكل مباشر داخل أي شاشة أو ودجت عرض.
  - المصدر الحصري والوحيد لكافة عمليات اختيار الوسائط والملفات هو الخدمة المركزية الموحدة `FilePickerService.instance`.
- **كائن الدومين النقي للملفات (`AppPickedFile`):**
  - كافة عمليات الاختيار تعيد حصراً كائنات من نوع `AppPickedFile` المستقل والمجرد من الحزم الخارجية، والذي يوفر خصائص ذكية مدمجة (`sizeFormatted`, `isPdf`, `isSpreadsheet`, `isImage`, `isWord`, `isArchive`, `isText`, `toFile()`).
- **الضوابط الصارمة للأحجام والسعة والعدد (Strict Enterprise Quotas):**
  - **التحكم بسقف الحجم الفردي (`maxFileSizeBytes`):** التحقق التلقائي مع إطلاق تنبيه معقم باللغة العربية عبر `CustomSnackbar.show` يوضح اسم الملف وحجمه الفعلي والحد الأقصى المسموح.
  - **التحكم بالسعة التراكمية المجمعة (`maxTotalSizeBytes`):** منع تجاوز إجمالي حجم المرفقات للحد المصرح به لتفادي استنزاف حزم البيانات وموارد الخادم.
  - **التحكم بالعدد الأقصى (`maxFiles`):** منع اختيار أو إرفاق ملفات إضافية عند بلوغ السقف مع إشعار المستخدم فوراً.
- **الحزام الأمني المؤسسي ضد الملفات الخبيثة (Malicious File Guard):**
  - حظر وتصفية فوري لأي ملف تنفيذي أو برمجي (`.exe`, `.bat`, `.cmd`, `.sh`, `.php`, `.apk`, `.bin`, `.msi`, `.vbs`, `.ps1`) حتى في حال السماح بكافة الملفات (`FileTypePreset.anySafe`).
- **المكون القياسي الموحد للمرفقات والملفات (`CustomFilePicker`):**
  - الاعتماد الحصري على `CustomFilePicker` لعرض وإدارة ورفع المرفقات في أي شاشة بالأنماط الثلاثة:
    - `FilePickerDisplayMode.dropzone`: مساحة سحب وإفلات تفاعلية تدعم `desktop_drop` على أنظمة سطح المكتب والويب.
    - `FilePickerDisplayMode.button`: زر مدمج أنيق عبر `CustomButton.outline` مع عداد شارات للملفات المرفقة.
    - `FilePickerDisplayMode.formCard`: بطاقة استمارة رسمية متكاملة مع التحقق الصارم `FormFieldValidator`.
  - كل ملف مرفق يُعرض عبر `FileCardItem` مع وسم ملون متكيف بحسب النوع، واسمه، وحجمه، ومعاينة مصغرة للصور بحماية كاملة للذاكرة، وزر حذف قياسي مع ارتداد فيزيائي `CustomInteractiveBounce`.

---

## 21. معمارية مربعات الحوار التفاعلية ومطابقتها مع معيار CustomButton (Enterprise CustomDialog Architecture)
- **المطابقة المعمارية الصارمة مع CustomButton:**
  - يُحظر بناء الحوارات كـ Utility Classes تعتمد على دوال مساعدة `_buildXxx()` خاصة.
  - `CustomDialog` هو **`StatelessWidget` أصيل ومستقل**، يمكن تضمينه في أي شجرة عناصر، أو معاينته في الاختبارات واللوحات، أو إطلاقه كنافذة منبثقة تفاعلية عبر محرك `Get.generalDialog`.
- **الفئات المصنعية المتخصصة (Unified Dialog Factories):**
  - `CustomDialog.confirmation(...)`: لحالات التحقق والتأكيد للعمليات التشغيلية والمالية.
  - `CustomDialog.success(...)`: لتأكيد النجاح مع تدرج لوني أخضر وأنيميشن Lottie معبر.
  - `CustomDialog.error(...)`: لتنبيهات الأخطاء والتعثرات.
  - `CustomDialog.warning(...)`: للتحذيرات التنبيهية بالأصفر الداكن.
  - `CustomDialog.info(...)`: للإرشادات التوجيهية والمعلومات العامة.
  - `CustomDialog.pending(...)`: المخصص حصرياً لحالات انتظار الاعتماد والمراجعة الإدارية (`PENDING`) بعد التسجيل، مع توجيه صريح لصفحة تسجيل الدخول.
  - `CustomDialog.danger(...)`: لإجراءات الحذف النهائي والتدمير بالأحمر الصريح مع زر `CustomButton.danger`.
  - `CustomDialog.custom(...)`: للحوارات ذات المحتوى المعقد أو الاستمارات الداخلية.
- **التفكيك الذري للمكونات (Zero Dialog Helper Methods):**
  - تفكيك هيكل الحوار الداخلي إلى ودجات مستقلة ومعزولة تدعم الـ `const` في `widgets/dialogs/widgets/`:
    - `DialogIconHeader`: الترويسة والتدرج اللوني والأنيميشن التفاعلي مع أيقونة طوارئ بديلة.
    - `DialogBodyContent`: العناوين والرسائل والمحتوى المتكيف مع التمرير الرأسي الآمن لمنع أي Overflow.
    - `DialogActionBar`: شريط الإجراءات المعتمد حصرياً على `CustomButton.primary` و `CustomButton.outline` و `CustomButton.danger`.
- **الدوال الاستاتيكية المريحة:**
  - توفير دوال الاستدعاء السريعة للتوافقية (`CustomDialog.show(...)`, `CustomDialog.showPending(...)`, `CustomDialog.showConfirmation(...)`) مع انتقال فيزيائي ناعم مقيد بـ `AppMotion.fast`.

---

## 22. منظومة الكاش المركزية الموحدة ومعرض الوسائط واستعراض مستندات PDF (Enterprise AppCacheService & MediaGallery System)
- **منع تشتت خدمات الكاش (Unified Cache Architecture):**
  - **يُحظر حظرًا قاطعاً** إنشاء خدمات كاش متعددة متناثرة في النظام. المصدر الحصري والوحيد لإدارة الكاش هو `AppCacheService.instance` بالتعاون مع `NetSalesCacheManager.instance`.
  - **قطاع كاش الوسائط والملفات:** تحميل وجلب وتخزين الملفات والصور ومستندات الـ PDF محلياً، مع حساب الحجم الفعلي للكاش، وحذف الكاش الفاسد فوراً (`Self-Healing`).
  - **قطاع كاش البيانات الحية مع مدة الصلاحية (Data Cache with TTL):** تخزين الكائنات المؤقتة مع فترات انتهاء دقيقة وإمكانية الإبطال الجماعي بالوسوم (`invalidateByTag`).
  - **التنظيف الشامل:** تفريغ آمن وشامل لكافة أنواع الكاش (`clearAllCache`) عند تسجيل الخروج لحماية الخصوصية.
- **التطبيع الذري لروابط الوسائط ومنع تلويث الكاش (Anti-Cache Poisoning & URL Normalization):**
  - التحويل التلقائي للمسارات النسبية (`networks/logos/...`, `users/avatars/...`) إلى روابط كاملة عبر `NetSalesDioFileService.normalizeMediaUrl`.
  - الحقن الإلزامي لترويسات الجلسة والأمان (`X-Session-Id`, `X-Device-Uuid`, `Authorization: Bearer`).
  - فحص صارم لكود الحالة ونوع المحتوى `Content-Type` لمنع حفظ استجابات الأخطاء JSON أو صفحات HTML في كاش الصور والملفات.
- **المكون القياسي الموحد للصور الشبكية (`CustomCachedImage`):**
  - الاعتماد الحصري على `CustomCachedImage` كبديل دائم لـ `Image.network` أو مكتبات الكاش الخام.
  - الحماية القصوى للذاكرة عبر الـ Downsampling التلقائي بالأبعاد وكثافة البكسل لمنع الـ OOM.
  - فئات مصنعية متخصصة: `CustomCachedImage.avatar(...)` و `CustomCachedImage.logo(...)`.
- **معرض الوسائط والمستندات التفاعلي الموحد (`MediaGalleryViewer`):**
  - الاعتماد الحصري على `MediaGalleryViewer` لاستعراض الصور ومستندات الـ PDF وجداول البيانات في نافذة تفاعلية واحدة دون مغادرة التطبيق إلى متصفحات الويب.
  - **استعراض الـ PDF التفاعلي المدمج:** عرض كافة صفحات ملفات الـ PDF تفاعلياً داخل التطبيق عبر `PdfPreview` مع دعم التكبير والصفحات والطباعة المباشرة وحفظ الملف.
  - **استعراض الصور:** دعم التكبير والتصغير المزدوج (`Double-tap Zoom`) باللمس المزدوج بنعومة `AppMotion.fast`.
  - **الإغلاق بالسحب الرأسي:** دعم السحب للإغلاق (`Swipe-to-Dismiss`) مع تخفيت تدريجي للشفافية.
  - **شريط المصغرات السفلي التفاعلي (`MediaGalleryFilmstrip`):** مستوحى من أحدث معايير WhatsApp لعرض مصغرات العناصر المتعددة مع التحديد والتوهج.
  - **الالتزام الكامل بـ CustomButton:** كافة أزرار الترويسة والإجراءات (إغلاق، حفظ، مشاركة، طباعة، فتح خارجي) تعتمد حصرياً على `CustomButton.icon` و `CustomButton.primary`.
  - **دوال الاستدعاء السريعة:**
    - `MediaGalleryViewer.show(context, items: [...], initialIndex: 0)`
    - `MediaGalleryViewer.showSingle(context, item)`
    - `MediaGalleryViewer.showPickedFiles(context, files: [...], initialIndex: 0)`
