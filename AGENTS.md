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

## 2. المكونات الموحدة الإلزامية (Mandatory Unified Components)
- **الأزرار:** يُحظر إنشاء أزرار مخصصة غير قياسية أو استخدام أزرار Flutter الخام (`ElevatedButton`, `OutlinedButton`, `TextButton`, `InkWell`) مباشرة في الشاشات. يجب استخدام المكون القياسي الموحد `CustomButton` وفئاته المصنعية السبع:
  - `CustomButton.primary` (الإجراءات الرئيسية)
  - `CustomButton.secondary` (الإجراءات الثانوية)
  - `CustomButton.outline` (الإجراءات المحددة)
  - `CustomButton.text` (الإجراءات النصية الخفيفة)
  - `CustomButton.danger` (الحذف والإجراءات الحساسة)
  - `CustomButton.icon` (أزرار الأيقونات القياسية)
  - `CustomButton.floating` (الأزرار العائمة)
- **التفاعل الحركي الناعم (Micro-interactions):** يجب تغليف العناصر التفاعلية والبطاقات القابلة للنقر بمكون `CustomInteractiveBounce` لتوفير ارتداد فيزيائي ناعم وتغذية لمسية فورية.
- **التنبيهات والرسائل:** استخدام `CustomSnackbar.show(...)` حصراً لجميع رسائل النظام وحالات الإشعار (`success`, `error`, `warning`, `info`)، مع تعقيم وتصفية رسائل الأخطاء عبر `AppException.sanitizeMessage`.

---

## 3. المعمارية الطبقية النظيفة الصارمة (Strict Layered Clean Architecture)
يجب أن تتبع كافة ميزات التطبيق التقسيم الهيكلي الإلزامي التالي دون خلط في المسؤوليات:
```
lib/
├── core/                                # البنية التحتية المشتركة (config, constants, services, themes, utils)
├── widgets/                             # الودجات العامة المشتركة لكافة شاشات التطبيق
└── features/
    └── [feature_name]/
        ├── data/
        │   ├── datasources/            # الاتصال بالشبكة (HttpService) أو التخزين المحلي
        │   ├── interfaces/              # عقود ومنافذ مصادر البيانات
        │   └── models/                  # نماذج البيانات المتطابقة مع الـ JSON وتسلسل الحقول
        ├── domain/
        │   ├── entities/                # الكيانات الدومينية المجردة
        │   ├── repositories/            # عقود المستودعات الدومينية (Repository Contracts)
        │   └── usecases/               # حالات الاستخدام ومنطق الأعمال المجرد
        └── presentation/
            ├── bindings/                # حقن الاعتماديات لـ GetX (Bindings)
            ├── controllers/             # متحكمات واجهة المستخدم (GetxController)
            ├── screens/                 # الشاشات الرئيسية
            └── widgets/                 # الودجات المخصصة للميزة حصراً
```
- **اتجاه سريان الاعتمادية (Inward Dependency Rule):**
  $$\text{Presentation} \longrightarrow \text{Domain Use Case} \longrightarrow \text{Domain Repository Contract} \longleftarrow \text{Data Repository Implementation} \longrightarrow \text{Data Source}$$
  - يُحظر استدعاء Dio أو عميل الشبكة أو قاعدة البيانات أو الـ DataSource مباشرة داخل كلاسات الـ `Controller` أو الـ `Widget`.
  - المتحكمات تنسق فقط مع الـ `Use Cases` أو عقود المستودعات المعتمدة.

---

## 4. فصل المسؤوليات وإدارة الحالة مع GetX
- **الواجهات النحيفة (Lean Views):** الشاشات والودجات وظيفتها فقط رسم واجهة المستخدم والاستماع للحالة عبر `Obx` أو `GetBuilder`. يُحظر كتابة أي منطق أعمال أو طلبات شبكة أو عمليات حسابية معقدة داخل كلاسات الـ Widget.
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
