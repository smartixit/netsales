import 'package:flutter/foundation.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_auth/smart_auth.dart';

/// ============================================================================
/// كلاس استخراج الرمز التلقائي التابع لـ Pinput (AppSmsRetriever)
/// ============================================================================
/// يطبق واجهة [SmsRetriever] من حزمة Pinput للاستماع المباشر لرسائل OTP
/// عبر Google Play Services SMS Retriever API (تلقائي بالكامل Zero-Click).
class AppSmsRetriever implements SmsRetriever {
  AppSmsRetriever({
    SmartAuth? smartAuth,
    this.matcher = r'\d{4,8}',
  }) : _smartAuth = smartAuth ?? SmartAuth.instance;

  final SmartAuth _smartAuth;

  /// نمط استخراج الرمز الرقمي من نص الرسالة (من 4 إلى 8 أرقام)
  final String matcher;

  @override
  Future<void> dispose() async {
    try {
      await _smartAuth.removeSmsRetrieverApiListener();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppSmsRetriever] dispose error: $e');
      }
    }
  }

  @override
  Future<String?> getSmsCode() async {
    try {
      final res = await _smartAuth.getSmsWithRetrieverApi(matcher: matcher);
      final code = res.data?.code;
      if (kDebugMode) {
        debugPrint('[AppSmsRetriever] SMS Code Received: $code');
      }
      return code;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppSmsRetriever] getSmsCode error: $e');
      }
      return null;
    }
  }

  @override
  bool get listenForMultipleSms => false;
}

/// ============================================================================
/// خدمة إدارة وتنسيق التعبئة التلقائية للرسائل (SmsRetrieverService)
/// ============================================================================
/// توفر أدوات مساعدة لجلب بصمة التطبيق (App Signature Hash) لتهيئة السيرفر
/// وتوليد كائنات [SmsRetriever] المتوافقة مع معايير الأمان المؤسسية.
class SmsRetrieverService {
  SmsRetrieverService._();

  static final SmsRetrieverService instance = SmsRetrieverService._();

  final SmartAuth _smartAuth = SmartAuth.instance;

  /// توليد كائن استماع جديد لـ Pinput
  SmsRetriever createRetriever({String matcher = r'\d{4,8}'}) {
    return AppSmsRetriever(smartAuth: _smartAuth, matcher: matcher);
  }

  /// جلب بصمة التطبيق (11 محرفاً) الخاصة بـ SMS Retriever API
  /// وتدوينها في سجل التصحيح في وضع kDebugMode لنسخها في بيئة الخادم.
  Future<String?> getAppSignature() async {
    try {
      final result = await _smartAuth.getAppSignature();
      final signature = result.data;
      if (kDebugMode) {
        debugPrint('====================================================');
        debugPrint('[NetSales SMS Retriever] App Signature Hash: $signature');
        debugPrint('Use this 11-char hash in backend SMS_RETRIEVER_APP_HASH');
        debugPrint('====================================================');
      }
      return signature;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NetSales SMS Retriever] Failed to get app signature: $e');
      }
      return null;
    }
  }
}
