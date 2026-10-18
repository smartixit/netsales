# ميثاق الهندسة البرمجية والكود النظيف الموحد لتطبيق فلاتر (NetSales Flutter Architecture & Clean Code Rules)

تعتبر هذه الوثيقة المرجع الأساسي والملزم لجميع عمليات التطوير والتعديل البرمجي داخل تطبيق Flutter الخاص بنظام NetSales. يجب الالتزام الصارم بها في كافة الملفات والمراحل دون أي استثناء:

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

## 3. المعمارية وفصل المسؤوليات الصارم (Clean Architecture & GetX State Management)
- **الواجهات النحيفة (Lean Views):** الشاشات والودجات وظيفتها فقط رسم واجهة المستخدم والاستماع للحالة. يُحظر كتابة أي منطق أعمال، طلبات شبكة مباشرة، أو حسابات رياضية داخل كلاسات الـ Widget.
- **المتحكمات (Controllers):** ترث حصراً من `GetxController`. هي المسؤولة الوحيدة عن إدارة حالة الشاشة، التفاعل مع مدخلات المستخدم، ومعالجة أخطاء الواجهة.
- **طبقة الخدمات والمستودعات (Service & Repository Layer):** المسؤولة الحصرية عن استدعاءات الشبكة (`HttpService`) وتخزين واسترجاع البيانات ونمذجتها إلى كائنات Dart Models.

---

## 4. المطابقة التامة مع الواجهة الخلفية (Backend-Frontend Strict Contract)
- **المرجع الحصري:** مسارات `ApiConstants` وكافة نماذج البيانات وحقول الـ JSON يجب أن تتطابق بنسبة 100% مع واجهة `netsales_api` المعتمدة في `routes/api.php` ونماذج `app/Models`.
- **حظر متبقيات المشاريع السابقة:** يُحظر حظراً باتاً كتابة أي متغيرات أو كلاسات أو دوال تتبع أنظمة سابقة لا صلة لها بنظام NetSales (مثل `stores`, `suppliers`, `purchases`, `purchaseReturns`). الكيانات المعتمدة حصراً هي:
  - الشبكات: `networks`
  - نقاط البيع: `pos`
  - ربط الشبكات بنقاط البيع: `network-pos`
  - باقات كروت الشبكة: `voucher-packages`
  - خصومات الباقات لنقاط البيع: `voucher-package-discounts`
  - فواتير بيع الكروت: `sale-invoices`
  - محافظ الشبكات ونقاط البيع: `network-wallets`, `pos-wallets`
  - باقات واشتراكات مزودي الشبكات: `provider-subscriptions`, `subscription-plans`
  - تذاكر ورسائل الدعم الفني: `support-tickets`
  - المصروفات والحسابات البنكية: `expenses`, `bank-accounts`
  - المحافظات والمديريات: `governorates`, `directorates`
  - إعدادات الرسائل النصية للشبكات: `sms-settings`

---

## 5. سلامة التعديل والترميز وتجنب الأخطاء (Code Integrity & Encoding Policy)
- **حظر التعديل عبر أوامر الشل المؤذية:** يُحظر تماماً استخدام PowerShell `Set-Content` أو إعادة التوجيه النصي للكتابة داخل ملفات الكود لتجنب تشويه الترميز العربي (Mojibake). يتم التعديل دائماً بترميز `UTF-8` المعتمد لضمان دقة اللغة العربية وسلامة ملفات المشروع.
- **فحص الجودة الدائم:** يجب تشغيل `flutter analyze` بعد أي تعديل جوهري للتأكد من خلو الكود من التحذيرات أو المشاكل البرمجية قبل تسليمه.

---

## 6. عقلية المهندس الشريك المكتمل الخبرات (Senior Software Engineer Mindset)
- التفكير والتخطيط المعماري أولاً (Think First) قبل كتابة أو تعديل أي كود.
- التحقق من جودة الكود، التناسق، وسهولة الصيانة (Clean, Maintainable, Scalable).
- السؤال والتنبيه الصريح في حال وجود أي غموض أو تعارض في المتطلبات مع المعايير البرمجية النظيفة.
