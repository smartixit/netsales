import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// وحدة تطبيع وتطهير أرقام الهواتف الملتقطة من جهات الاتصال (ContactPhoneNormalizer).
///
/// تحل بشكل دائم وجذري مشكلات اختلاف تنسيقات جهات الاتصال:
/// - الأرقام العربية المشرقية (٠-٩).
/// - المسافات والفواصل والرموز الخاصة والشرطات والأقواس.
/// - مفاتيح الدول (+967, 00967, 967).
/// - الأصفار المسبوقة (07... -> 7...).
class ContactPhoneNormalizer {
  ContactPhoneNormalizer._();

  static const Map<String, String> _arabicDigits = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
  };

  /// تطبيع رقم الهاتف إلى أرقام إنجليزية نظيفة ومجردة من الرموز ومفاتيح الدول
  static String normalize(String? rawPhone) {
    if (rawPhone == null || rawPhone.trim().isEmpty) return '';

    // 1. استبدال الأرقام العربية بالأرقام اللاتينية القياسية
    String cleaned = rawPhone.trim();
    _arabicDigits.forEach((ar, en) {
      cleaned = cleaned.replaceAll(ar, en);
    });

    // 2. إزالة كافة الرموز والمسافات والأحرف غير الرقمية
    cleaned = cleaned.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.isEmpty) return '';

    // 3. تجريد مفتاح دولة اليمن الدولي إذا وجد (+967 أو 00967 أو 967)
    if (cleaned.startsWith('00967')) {
      cleaned = cleaned.substring(5);
    } else if (cleaned.startsWith('967') && cleaned.length > 9) {
      cleaned = cleaned.substring(3);
    }

    // 4. تجريد الصفر المسبوق لأرقام الجوال اليمنية (مثلاً: 0771... تصبح 771...)
    if (cleaned.startsWith('0') && cleaned.length >= 10 && cleaned[1] == '7') {
      cleaned = cleaned.substring(1);
    }

    // 5. إذا كان الرقم بطول 9 أرقام ويبدأ بـ 7 فهو رقم جوال يمني مطابق للمدقق
    return cleaned;
  }
}

/// خدمة مركزية لاختيار جهات الاتصال من النظام الأصلي (Native Contact Picker).
///
/// صُممت لتعمل باستقرار كامل ومنع أي استثناءات أو انهيارات:
/// - تعمل فقط على أجهزة الموبايل (Android / iOS).
/// - تستخدم منتقي النظام الأصلي فلا تتطلب أذونات خطرة أو تسبب مشاكل سياسات المتاجر.
/// - تعود بأمان عند الإلغاء أو غياب الأرقام.
class ContactPickerService {
  ContactPickerService._();

  static final FlutterNativeContactPicker _picker =
      FlutterNativeContactPicker();

  /// يتحقق مما إذا كانت منصة التشغيل تدعم منتقي جهات الاتصال الأصلي
  static bool get isSupported => Platform.isAndroid || Platform.isIOS;

  /// يفتح منتقي جهات الاتصال الأصلي ويعيد النتيجة المطهّرة
  static Future<({String phone, String? fullName})?> pickPhone() async {
    if (!isSupported) return null;

    try {
      final Contact? contact = await _picker.selectPhoneNumber();

      if (contact == null) {
        // ألغى المستخدم عملية الاختيار
        return null;
      }

      final rawPhone = contact.selectedPhoneNumber ??
          (contact.phoneNumbers != null && contact.phoneNumbers!.isNotEmpty
              ? contact.phoneNumbers!.first
              : null);

      if (rawPhone == null || rawPhone.trim().isEmpty) {
        CustomSnackbar.show(
          type: SnackType.warning,
          title: 'لا يوجد رقم هاتف',
          message: 'جهة الاتصال المحددة لا تحتوي على أي رقم هاتف.',
        );
        return null;
      }

      final normalized = ContactPhoneNormalizer.normalize(rawPhone);

      return (
        phone: normalized.isNotEmpty ? normalized : rawPhone.trim(),
        fullName: contact.fullName?.trim(),
      );
    } on PlatformException catch (e) {
      CustomSnackbar.show(
        type: SnackType.error,
        title: 'تعذر الوصول لجهات الاتصال',
        message: e.message ?? 'حدث خطأ أثناء محاولة فتح جهات الاتصال.',
      );
      return null;
    } catch (e) {
      CustomSnackbar.show(
        type: SnackType.error,
        title: 'خطأ غير متوقع',
        message: 'تعذر اختيار جهة الاتصال: ${e.toString()}',
      );
      return null;
    }
  }

  /// يختار رقم الجوال ويملأ الحقل المخصص مع خيار ملء حقل الاسم إن كان فارغاً
  static Future<void> pickAndFill({
    required TextEditingController phoneController,
    TextEditingController? nameController,
    VoidCallback? onSelected,
  }) async {
    final result = await pickPhone();
    if (result == null) return;

    phoneController.text = result.phone;

    if (nameController != null &&
        nameController.text.trim().isEmpty &&
        result.fullName != null &&
        result.fullName!.isNotEmpty) {
      nameController.text = result.fullName!;
    }

    onSelected?.call();

    CustomSnackbar.show(
      type: SnackType.success,
      title: 'تم اختيار الرقم بنجاح',
      message: result.fullName != null && result.fullName!.isNotEmpty
          ? 'تم اختيار رقم ${result.fullName}: ${result.phone}'
          : 'تم ملء رقم الجوال: ${result.phone}',
    );
  }
}
