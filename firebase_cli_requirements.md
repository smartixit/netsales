وفقاً لـ توثيق Firebase الرسمي لـ Flutter، هناك طريقتان معتمدتان لربط وتهيئة تطبيق Flutter بمشروع Firebase القائم (netsales-1e503):

الطريقة الأولى: عبر أداة FlutterFire CLI (الموصى بها رسمياً من Google)
تتميز هذه الطريقة بأنها تؤتمت بالكامل إنشاء وتنزيل ملفات الربط وتوليد إعدادات Dart:

المتطلبات الأساسية:
تثبيت أداة Firebase CLI على جهاز التطوير (عبر npm install -g firebase-tools أو الملف التنفيذي المباشر).
تسجيل الدخول بحساب Google المالك لمشروع Firebase:
bash
firebase login
تفعيل أداة FlutterFire CLI عالمياً:
bash
dart pub global activate flutterfire_cli


1. التأكد من تفعيل الأداة

تأكد أولاً من تثبيت وتفعيل حزمة flutterfire_cli عالمياً عبر تشغيل هذا الأمر:
bash
dart pub global activate flutterfire_cli
يُرجى استخدام الرمز البرمجي بحذر.

2. إضافة المسار إلى متغيرات البيئة (Environment Variables)

عند تفعيل الأداة، سيعطيك الـ Terminal تحذيراً يخبرك بالمصار الذي يجب إضافته. في نظام Windows، يكون المسار الافتراضي كالتالي:
text
%USERPROFILE%\AppData\Local\Pub\Cache\bin
يُرجى استخدام الرمز البرمجي بحذر.
(حيث تعبر %USERPROFILE% عن مجلد المستخدم الخاص بك مثل C:\Users\YourName).
خطوات إضافة المسار:
1. افتح قائمة ابدأ (Start) وابحث عن "Edit the system environment variables" واضغط عليها.
2. اضغط على زر Environment Variables في الأسفل.
3. في القسم العلوي (User variables)، ابحث عن المتغير المسمى Path وحدده، ثم اضغط على Edit.
4. اضغط على New، وقم بلصق المسار التالي:
%USERPROFILE%\AppData\Local\Pub\Cache\bin

تشغيل أمر الربط الآلي داخل مجلد مشروع فلاتر (netsales):
bash
flutterfire configure --project=netsales-1e503
ما يقوم به هذا الأمر تلقائياً:
يتعرف على معرف الحزمة في الأندرويد (com.smartix.netsales المعرف في 

android/app/build.gradle.kts
).
ينشئ التطبيق داخل وحدة تحكم Firebase لمشروع netsales-1e503.
يقوم بتنزيل ملف 

android/app/google-services.json
 الحقيقي المحتوي على المفاتيح السحابية الفعلية.
يولد ملف الإعدادات 

lib/core/config/firebase_options.dart
 بقيم المفاتيح الرسمية.