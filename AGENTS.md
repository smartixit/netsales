# ميثاق الهندسة البرمجية والكود النظيف الموحد لتطبيق فلاتر (NetSales Flutter Architecture & Clean Code Rules)

تعتبر هذه الوثيقة المرجع الأساسي والملزم لجميع عمليات التطوير والتعديل البرمجي داخل تطبيق Flutter الخاص بنظام NetSales. يجب الالتزام الصارم بها في كافة الملفات والمراحل دون الحاجة لأي تذكير:

---

## 1. سياسة منع الأرقام والألوان السحرية نهائياً (Zero Hardcoded Magic Values Policy)
- **الألوان:** يُحظر حظرًا قاطعاً كتابة أو استخدام `Color(0x...)` أو `Colors.any` داخل أي شاشة أو ودجت. المصدر الحصري والوحيد لجميع ألوان التطبيق هو `context.colors.*` المعرف في `AppColors` والذي يدعم الوضعين الفاتح والداكن تلقائياً.
- **التايبوغرافي والنصوص:** يُحظر حظرًا قاطعاً كتابة `TextStyle(fontSize: ..., fontWeight: ...)` أو تحديد أحجام خطوط عشوائية داخل الشاشات. يجب الاعتماد حصرياً على الرموز الموحدة في `AppTypography.*` (مثل `titleLarge`, `bodyMedium`, `buttonMedium`, `currencyHero`, `inputLabel`) مع استخدام `.copyWith(color: context.colors.*)` فقط عند الحاجة لتغيير اللون.
- **الأبعاد والمسافات والحواف:**
  - المسافات الأفقية: استخدام `AppSpacing.hXs`, `AppSpacing.hSm`, `AppSpacing.hMd`, `AppSpacing.hLg`, `AppSpacing.hXl` حصراً.
  - المسافات الرأسية: استخدام `AppSpacing.vXs`, `AppSpacing.vSm`, `AppSpacing.vMd`, `AppSpacing.vLg`, `AppSpacing.vXl` حصراً.
  - تدوير الحواف: استخدام `AppRadius.xs`, `AppRadius.sm`, `AppRadius.md`, `AppRadius.lg`, `AppRadius.full` حصراً.
  - جميع القياسات والمسافات والخطوط تدعم وتلتزم بـ `flutter_screenutil` (`.w`, `.h`, `.sp`, `.r`).

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
        │   ├── data_sources/            # الاتصال بالشبكة (HttpService) أو التخزين المحلي
        │   ├── interfaces/              # عقود ومنافذ مصادر البيانات
        │   └── models/                  # نماذج البيانات المتطابقة مع الـ JSON وتسلسل الحقول
        ├── domain/
        │   ├── entities/                # الكيانات الدومينية المجردة
        │   ├── repositories/            # عقود المستودعات الدومينية (Repository Contracts)
        │   └── use_cases/               # حالات الاستخدام ومنطق الأعمال المجرد
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
