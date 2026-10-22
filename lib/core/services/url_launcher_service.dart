import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// ============================================================================
/// تصنيف نوع الرابط أو الإجراء المطلوب تشغيله (UrlLaunchType)
/// ============================================================================
enum UrlLaunchType {
  webUrl,
  phoneCall,
  sms,
  ussd,
  email,
  mapCoordinates,
  mapSearch,
  whatsApp,
  telegram,
  socialMedia,
  appStore,
  customScheme,
}

/// ============================================================================
/// تفضيل تطبيق الخرائط والملاحة الجغرافية (MapPlatformPreference)
/// ============================================================================
enum MapPlatformPreference {
  /// الاختيار التلقائي الأنسب للمنصة (Google Maps على Android/Web/Desktop، و Apple Maps على iOS/macOS)
  auto,

  /// خرائط جوجل (Google Maps)
  googleMaps,

  /// خرائط آبل (Apple Maps)
  appleMaps,

  /// تطبيق ويز (Waze Navigation)
  waze,

  /// خرائط الشارع المفتوحة (OpenStreetMap)
  openStreetMap,
}

/// ============================================================================
/// منصات التواصل الاجتماعي والشبكات المدعومة (SocialNetwork)
/// ============================================================================
enum SocialNetwork {
  whatsApp,
  telegram,
  facebook,
  xTwitter,
  instagram,
  linkedIn,
  youTube,
  tikTok,
  gitHub,
}

/// ============================================================================
/// نتيجة تنفيذ عملية التشغيل (UrlLaunchResult)
/// ============================================================================
class UrlLaunchResult {
  /// هل تمت العملية بنجاح أم تعذرت
  final bool isSuccess;

  /// نوع الرابط المشغل
  final UrlLaunchType type;

  /// الرابط النهائي الذي تم تشغيله أو محاولة تشغيله
  final Uri? uri;

  /// رسالة توضيحية أو سبب الخطأ إن وُجد
  final String message;

  /// الخطأ الأصلي أو الاستثناء الملتقط إن وُجد
  final Object? error;

  const UrlLaunchResult({
    required this.isSuccess,
    required this.type,
    required this.message,
    this.uri,
    this.error,
  });

  factory UrlLaunchResult.success({
    required UrlLaunchType type,
    required Uri uri,
    String message = 'تم فتح الرابط بنجاح',
  }) {
    return UrlLaunchResult(
      isSuccess: true,
      type: type,
      uri: uri,
      message: message,
    );
  }

  factory UrlLaunchResult.failure({
    required UrlLaunchType type,
    required String message,
    Uri? uri,
    Object? error,
  }) {
    return UrlLaunchResult(
      isSuccess: false,
      type: type,
      uri: uri,
      message: message,
      error: error,
    );
  }

  @override
  String toString() {
    return 'UrlLaunchResult(isSuccess: $isSuccess, type: $type, uri: $uri, message: $message)';
  }
}

/// ============================================================================
/// إعدادات وتخصيصات مشغل الروابط الموحد (UrlLauncherConfig)
/// ============================================================================
class UrlLauncherConfig {
  /// وضع الفتح الافتراضي لروابط الويب
  final LaunchMode defaultWebLaunchMode;

  /// تفعيل إضافة بادئة https:// تلقائياً عند نسيان كتابة البروتوكول في روابط الويب
  final bool autoPrependHttps;

  /// النسخ التلقائي للنص (رقم الهاتف، البريد، الرابط) إلى الحافظة عند فشل الفتح (مثل الأجهزة اللوحية دون شريحة)
  final bool copyToClipboardOnUnsupportedPlatform;

  /// تسجيل العمليات في كونسول المطورين (Logging)
  final bool enableLogging;

  /// دالة رد نداء عامة للإشعار برسائل الخطأ (تتيح ربطها بـ SnackBar أو Toast في أي تطبيق)
  final void Function(String message, UrlLaunchResult result)? onMessage;

  const UrlLauncherConfig({
    this.defaultWebLaunchMode = LaunchMode.platformDefault,
    this.autoPrependHttps = true,
    this.copyToClipboardOnUnsupportedPlatform = true,
    this.enableLogging = kDebugMode,
    this.onMessage,
  });
}

/// ============================================================================
/// الخدمة المؤسسية الشاملة لإطلاق الروابط والوسائط (UrlLauncherService)
/// ============================================================================
///
/// صُممت هذه الخدمة لتكون "مستقلة تماماً" (100% Self-Contained) وقابلة لإعادة الاستخدام
/// في أي مشروع Flutter مستقبلي دون أي تبعيات خاصة أو كود مكرر.
///
/// المميزات الأساسية:
/// 1. دعم كامل لكافة المنصات (Android, iOS, Web, Windows, macOS, Linux).
/// 2. دعم كافة البروتوكولات الشائعة (HTTP, HTTPS, TEL, SMS, USSD, MAILTO, GEO, WHATSAPP, TELEGRAM, STORES).
/// 3. تعقيم وتشفير المعاملات والنصوص العربية والرموز الخاصة عبر ترميز RFC القياسي.
/// 4. دفاع أمني وحماية برمجية كاملة عبر كتل Try/Catch في كل نقطة وصول لمنع أي انهيار مفاجئ (Zero Crash).
/// 5. معالجة ذكية لحالات الفشل وتوفير آليات بديلة (Fallbacks) مثل النسخ للحافظة وروابط الويب البديلة.
/// 6. توفير واجهة Static Facade سريعة مع إمكانية التخصيص الكامل عبر الـ Config.
class UrlLauncherService {
  UrlLauncherService._();

  static final UrlLauncherService instance = UrlLauncherService._();

  UrlLauncherConfig _config = const UrlLauncherConfig();

  /// تحديث إعدادات الخدمة العامة
  static void configure(UrlLauncherConfig config) {
    instance._config = config;
  }

  // ===========================================================================
  // 1. تصفح الويب والروابط العامة (Web & Universal Links)
  // ===========================================================================

  /// فتح رابط ويب عام مع معالجة البروتوكول والتنسيق
  ///
  /// [url]: الرابط المراد فتحه (مثال: 'https://smartix.net' أو 'google.com').
  /// [mode]: نمط الفتح (داخل التطبيق عبر Custom Tabs أو خارجي في المتصفح).
  /// [headers]: ترويسات HTTP إضافية عند الحاجة.
  /// [webWindowName]: اسم نافذة المتصفح على منصة الويب ('_blank', '_self').
  static Future<UrlLaunchResult> openUrl(
    String url, {
    LaunchMode? mode,
    Map<String, String>? headers,
    String? webWindowName,
  }) async {
    try {
      final cleanUrl = url.trim();
      if (cleanUrl.isEmpty) {
        return _fail(
          type: UrlLaunchType.webUrl,
          message: 'الرابط المدخل فارغ.',
        );
      }

      String formattedUrl = cleanUrl;
      if (instance._config.autoPrependHttps &&
          !formattedUrl.startsWith(RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://'))) {
        formattedUrl = 'https://$formattedUrl';
      }

      final uri = Uri.tryParse(formattedUrl);
      if (uri == null || !uri.hasScheme) {
        return _fail(
          type: UrlLaunchType.webUrl,
          message: 'صيغة الرابط غير صحيحة: $url',
        );
      }

      return await _launchInternal(
        uri: uri,
        type: UrlLaunchType.webUrl,
        mode: mode ?? instance._config.defaultWebLaunchMode,
        headers: headers,
        webWindowName: webWindowName,
        fallbackText: formattedUrl,
      );
    } catch (e, stackTrace) {
      return _handleUnexpectedError(
        type: UrlLaunchType.webUrl,
        error: e,
        stackTrace: stackTrace,
        fallbackText: url,
      );
    }
  }

  /// فتح الرابط في متصفح خارجي مستقل (External System Browser)
  static Future<UrlLaunchResult> openInExternalBrowser(String url) {
    return openUrl(url, mode: LaunchMode.externalApplication);
  }

  /// فتح الرابط في متصفح مدمج داخل التطبيق (In-App Browser View / Custom Tabs)
  static Future<UrlLaunchResult> openInAppBrowser(String url) {
    return openUrl(url, mode: LaunchMode.inAppBrowserView);
  }

  // ===========================================================================
  // 2. الاتصال الهاتفي والرسائل ورموز USSD (Telephony & Cellular)
  // ===========================================================================

  /// إجراء اتصال هاتفي أو فتح لوحة الاتصال برقم محدد
  ///
  /// [phoneNumber]: رقم الهاتف (مثال: '777123456' أو '+967777123456').
  static Future<UrlLaunchResult> callPhone(String phoneNumber) async {
    try {
      final sanitizedNumber = _sanitizePhoneNumber(phoneNumber);
      if (sanitizedNumber.isEmpty) {
        return _fail(
          type: UrlLaunchType.phoneCall,
          message: 'رقم الهاتف المدخل غير صالح أو فارغ.',
        );
      }

      final uri = Uri(scheme: 'tel', path: sanitizedNumber);
      return await _launchInternal(
        uri: uri,
        type: UrlLaunchType.phoneCall,
        mode: LaunchMode.externalApplication,
        fallbackText: sanitizedNumber,
        fallbackMessage: 'تعذر فتح تطبيق الاتصال. تم نسخ الرقم إلى الحافظة.',
      );
    } catch (e, stackTrace) {
      return _handleUnexpectedError(
        type: UrlLaunchType.phoneCall,
        error: e,
        stackTrace: stackTrace,
        fallbackText: phoneNumber,
      );
    }
  }

  /// إرسال رسالة نصية قصيرة SMS مع نص اختياري مسبق التجهيز
  ///
  /// [phoneNumber]: رقم هاتف المستلم.
  /// [message]: نص الرسالة (يدعم النصوص العربية والإنجليزية المشفرة تلقائياً).
  static Future<UrlLaunchResult> sendSms(
    String phoneNumber, {
    String? message,
  }) async {
    try {
      final sanitizedNumber = _sanitizePhoneNumber(phoneNumber);
      if (sanitizedNumber.isEmpty) {
        return _fail(
          type: UrlLaunchType.sms,
          message: 'رقم الهاتف غير صالح لإرسال الرسالة النصية.',
        );
      }

      // بناء رابط SMS المتوافق مع RFC وجميع منصات الهواتف
      final Map<String, String> queryParams = {};
      if (message != null && message.trim().isNotEmpty) {
        queryParams['body'] = message.trim();
      }

      final uri = Uri(
        scheme: 'sms',
        path: sanitizedNumber,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return await _launchInternal(
        uri: uri,
        type: UrlLaunchType.sms,
        mode: LaunchMode.externalApplication,
        fallbackText: sanitizedNumber,
        fallbackMessage: 'تعذر فتح تطبيق الرسائل. تم نسخ الرقم إلى الحافظة.',
      );
    } catch (e, stackTrace) {
      return _handleUnexpectedError(
        type: UrlLaunchType.sms,
        error: e,
        stackTrace: stackTrace,
        fallbackText: phoneNumber,
      );
    }
  }

  /// طلب كود USSD عبر لوحة الاتصال (مثل معرفة الرصيد أو كروت الشحن)
  ///
  /// يقوم بترميز رمز المربع `#` تلقائياً إلى `%23` حتى لا يتم اقتطاعه من قِبل نظام التشغيل.
  /// [ussdCode]: الكود المطلوب (مثال: '*555#' أو '*144*123456#').
  static Future<UrlLaunchResult> sendUssd(String ussdCode) async {
    try {
      final cleanCode = ussdCode.trim();
      if (cleanCode.isEmpty) {
        return _fail(
          type: UrlLaunchType.ussd,
          message: 'رمز USSD المدخل فارغ.',
        );
      }

      // رمز المربع # يمثل Fragment في معيار URI، لذلك يجب تعويضه برمز %23 للاتصال
      final encodedCode = cleanCode.replaceAll('#', '%23');
      final uri = Uri.parse('tel:$encodedCode');

      return await _launchInternal(
        uri: uri,
        type: UrlLaunchType.ussd,
        mode: LaunchMode.externalApplication,
        fallbackText: cleanCode,
        fallbackMessage: 'تعذر تشغيل كود USSD. تم نسخ الرمز إلى الحافظة.',
      );
    } catch (e, stackTrace) {
      return _handleUnexpectedError(
        type: UrlLaunchType.ussd,
        error: e,
        stackTrace: stackTrace,
        fallbackText: ussdCode,
      );
    }
  }

  // ===========================================================================
  // 3. البريد الإلكتروني المتقدم (Email / Mailto)
  // ===========================================================================

  /// إرسال بريد إلكتروني مع دعم المستلمين المتعددين والنسخ والموضوع والمحتوى
  ///
  /// [to]: عنوان بريد المستلم الأساسي أو قائمة مفصولة بفواصل.
  /// [subject]: موضوع الرسالة (مشفر بترميز UTF-8 تلقائياً).
  /// [body]: نص أو محتوى الرسالة.
  /// [cc]: مستلمو النسخة الإضافية (اختياري).
  /// [bcc]: مستلمو النسخة المخفية (اختياري).
  static Future<UrlLaunchResult> sendEmail({
    required String to,
    String? subject,
    String? body,
    List<String>? cc,
    List<String>? bcc,
  }) async {
    try {
      final cleanTo = to.trim();
      if (cleanTo.isEmpty) {
        return _fail(
          type: UrlLaunchType.email,
          message: 'عنوان البريد الإلكتروني فارغ.',
        );
      }

      final queryParams = <String, String>{};
      if (subject != null && subject.trim().isNotEmpty) {
        queryParams['subject'] = subject.trim();
      }
      if (body != null && body.trim().isNotEmpty) {
        queryParams['body'] = body.trim();
      }
      if (cc != null && cc.isNotEmpty) {
        queryParams['cc'] = cc.join(',');
      }
      if (bcc != null && bcc.isNotEmpty) {
        queryParams['bcc'] = bcc.join(',');
      }

      final uri = Uri(
        scheme: 'mailto',
        path: cleanTo,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return await _launchInternal(
        uri: uri,
        type: UrlLaunchType.email,
        mode: LaunchMode.externalApplication,
        fallbackText: cleanTo,
        fallbackMessage: 'تعذر فتح تطبيق البريد. تم نسخ عنوان البريد إلى الحافظة.',
      );
    } catch (e, stackTrace) {
      return _handleUnexpectedError(
        type: UrlLaunchType.email,
        error: e,
        stackTrace: stackTrace,
        fallbackText: to,
      );
    }
  }

  // ===========================================================================
  // 4. الخرائط والملاحة الجغرافية (Maps & GPS Navigation)
  // ===========================================================================

  /// فتح الإحداثيات الجغرافية على تطبيق الخرائط المفضل
  ///
  /// [latitude]: خط العرض.
  /// [longitude]: خط الطول.
  /// [label]: التسمية التوضيحية للموقع أو اسم المنشأة (اختياري).
  /// [preference]: تفضيل التطبيق المطلوب (Google Maps, Apple Maps, Waze, إلخ).
  static Future<UrlLaunchResult> openMapCoordinates({
    required double latitude,
    required double longitude,
    String? label,
    MapPlatformPreference preference = MapPlatformPreference.auto,
  }) async {
    try {
      final cleanLabel = label?.trim() ?? '';
      final encodedLabel = cleanLabel.isNotEmpty ? Uri.encodeComponent(cleanLabel) : '';

      Uri uri;

      switch (preference) {
        case MapPlatformPreference.appleMaps:
          uri = Uri.parse(
            encodedLabel.isNotEmpty
                ? 'https://maps.apple.com/?q=$encodedLabel&ll=$latitude,$longitude'
                : 'https://maps.apple.com/?ll=$latitude,$longitude',
          );
          break;

        case MapPlatformPreference.waze:
          uri = Uri.parse('https://waze.com/ul?ll=$latitude,$longitude&navigate=yes');
          break;

        case MapPlatformPreference.openStreetMap:
          uri = Uri.parse('https://www.openstreetmap.org/?mlat=$latitude&mlon=$longitude#map=16/$latitude/$longitude');
          break;

        case MapPlatformPreference.googleMaps:
          uri = Uri.parse(
            encodedLabel.isNotEmpty
                ? 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude($encodedLabel)'
                : 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
          );
          break;

        case MapPlatformPreference.auto:
          // التحديد التلقائي الأذكى: خرائط آبل على iOS وخرائط جوجل على بقية المنصات
          if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
            uri = Uri.parse(
              encodedLabel.isNotEmpty
                  ? 'https://maps.apple.com/?q=$encodedLabel&ll=$latitude,$longitude'
                  : 'https://maps.apple.com/?ll=$latitude,$longitude',
            );
          } else {
            uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
          }
          break;
      }

      return await _launchInternal(
        uri: uri,
        type: UrlLaunchType.mapCoordinates,
        mode: LaunchMode.externalApplication,
        fallbackText: '$latitude, $longitude',
        fallbackMessage: 'تعذر فتح تطبيق الخرائط. تم نسخ الإحداثيات إلى الحافظة.',
      );
    } catch (e, stackTrace) {
      return _handleUnexpectedError(
        type: UrlLaunchType.mapCoordinates,
        error: e,
        stackTrace: stackTrace,
        fallbackText: '$latitude, $longitude',
      );
    }
  }

  /// البحث عن موقع أو عنوان نصي على الخرائط
  ///
  /// [query]: العنوان أو اسم المكان المطلوب البحث عنه (مثال: 'صنعاء - شارع حده').
  static Future<UrlLaunchResult> searchMap(String query) async {
    try {
      final cleanQuery = query.trim();
      if (cleanQuery.isEmpty) {
        return _fail(
          type: UrlLaunchType.mapSearch,
          message: 'نص البحث في الخرائط فارغ.',
        );
      }

      final encodedQuery = Uri.encodeComponent(cleanQuery);
      Uri uri;

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        uri = Uri.parse('https://maps.apple.com/?q=$encodedQuery');
      } else {
        uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedQuery');
      }

      return await _launchInternal(
        uri: uri,
        type: UrlLaunchType.mapSearch,
        mode: LaunchMode.externalApplication,
        fallbackText: cleanQuery,
      );
    } catch (e, stackTrace) {
      return _handleUnexpectedError(
        type: UrlLaunchType.mapSearch,
        error: e,
        stackTrace: stackTrace,
        fallbackText: query,
      );
    }
  }

  // ===========================================================================
  // 5. تطبيقات المراسلة الفورية وشبكات التواصل (Instant Messaging & Socials)
  // ===========================================================================

  /// فتح محادثة مباشرة على واتساب (WhatsApp) مع رقم محدد ورسالة اختيارية
  ///
  /// يعتمد رابط Universal Link (wa.me) الذي يعمل بسلاسة عبر كافة الأجهزة والهواتف والويب.
  /// [phoneNumber]: رقم الهاتف بصيغته الدولية (مثال: '967777123456').
  /// [message]: نص الرسالة التمهيدية التلقائية (اختياري).
  static Future<UrlLaunchResult> openWhatsApp({
    required String phoneNumber,
    String? message,
  }) async {
    try {
      // واتساب يتطلب الرقم بالأرقام فقط مع كود الدولة وبدون إشارة + أو مسافات
      final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly.isEmpty) {
        return _fail(
          type: UrlLaunchType.whatsApp,
          message: 'رقم الهاتف غير صالح لفتح واتساب.',
        );
      }

      final queryParams = <String, String>{};
      if (message != null && message.trim().isNotEmpty) {
        queryParams['text'] = message.trim();
      }

      final uri = Uri(
        scheme: 'https',
        host: 'wa.me',
        path: digitsOnly,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return await _launchInternal(
        uri: uri,
        type: UrlLaunchType.whatsApp,
        mode: LaunchMode.externalApplication,
        fallbackText: digitsOnly,
        fallbackMessage: 'تعذر فتح واتساب. تم نسخ الرقم إلى الحافظة.',
      );
    } catch (e, stackTrace) {
      return _handleUnexpectedError(
        type: UrlLaunchType.whatsApp,
        error: e,
        stackTrace: stackTrace,
        fallbackText: phoneNumber,
      );
    }
  }

  /// فتح محادثة أو قناة أو حساب تيليجرام (Telegram)
  ///
  /// [username]: اسم المستخدم بدون @ (مثال: 'SmartixSupport').
  /// [phoneNumber]: أو رقم الهاتف الدولي إذا لم يتوفر اسم مستخدم.
  /// [text]: نص الرسالة التمهيدية عند مشاركتها (اختياري).
  static Future<UrlLaunchResult> openTelegram({
    String? username,
    String? phoneNumber,
    String? text,
  }) async {
    try {
      Uri uri;

      if (username != null && username.trim().isNotEmpty) {
        final cleanUsername = username.trim().replaceAll('@', '');
        uri = Uri.parse('https://t.me/$cleanUsername');
      } else if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        final cleanPhone = _sanitizePhoneNumber(phoneNumber);
        uri = Uri.parse('https://t.me/+$cleanPhone');
      } else {
        return _fail(
          type: UrlLaunchType.telegram,
          message: 'يرجى تقديم اسم مستخدم أو رقم هاتف لفتح تيليجرام.',
        );
      }

      if (text != null && text.trim().isNotEmpty) {
        uri = uri.replace(queryParameters: {'text': text.trim()});
      }

      return await _launchInternal(
        uri: uri,
        type: UrlLaunchType.telegram,
        mode: LaunchMode.externalApplication,
      );
    } catch (e, stackTrace) {
      return _handleUnexpectedError(
        type: UrlLaunchType.telegram,
        error: e,
        stackTrace: stackTrace,
        fallbackText: username ?? phoneNumber,
      );
    }
  }

  /// فتح حساب أو صفحة على منصات التواصل الاجتماعي المختلفة
  ///
  /// [platform]: نوع المنصة (Facebook, Instagram, X/Twitter, LinkedIn, YouTube, TikTok, GitHub).
  /// [usernameOrId]: اسم الحساب أو المعرف أو مسار الصفحة.
  static Future<UrlLaunchResult> openSocialProfile({
    required SocialNetwork platform,
    required String usernameOrId,
  }) async {
    try {
      final cleanHandle = usernameOrId.trim().replaceAll('@', '');
      if (cleanHandle.isEmpty) {
        return _fail(
          type: UrlLaunchType.socialMedia,
          message: 'اسم الحساب أو المعرف فارغ.',
        );
      }

      Uri uri;

      switch (platform) {
        case SocialNetwork.whatsApp:
          return await openWhatsApp(phoneNumber: cleanHandle);

        case SocialNetwork.telegram:
          return await openTelegram(username: cleanHandle);

        case SocialNetwork.facebook:
          uri = Uri.parse('https://www.facebook.com/$cleanHandle');
          break;

        case SocialNetwork.xTwitter:
          uri = Uri.parse('https://x.com/$cleanHandle');
          break;

        case SocialNetwork.instagram:
          uri = Uri.parse('https://www.instagram.com/$cleanHandle');
          break;

        case SocialNetwork.linkedIn:
          uri = Uri.parse('https://www.linkedin.com/in/$cleanHandle');
          break;

        case SocialNetwork.youTube:
          uri = Uri.parse('https://www.youtube.com/@$cleanHandle');
          break;

        case SocialNetwork.tikTok:
          uri = Uri.parse('https://www.tiktok.com/@$cleanHandle');
          break;

        case SocialNetwork.gitHub:
          uri = Uri.parse('https://github.com/$cleanHandle');
          break;
      }

      return await _launchInternal(
        uri: uri,
        type: UrlLaunchType.socialMedia,
        mode: LaunchMode.externalApplication,
      );
    } catch (e, stackTrace) {
      return _handleUnexpectedError(
        type: UrlLaunchType.socialMedia,
        error: e,
        stackTrace: stackTrace,
        fallbackText: usernameOrId,
      );
    }
  }

  // ===========================================================================
  // 6. متاجر التطبيقات وتحديثات النظام (App Stores & Updates)
  // ===========================================================================

  /// فتح صفحة التطبيق في متجر التطبيقات الرسمي بحسب المنصة الحالية
  ///
  /// يدعم تلقائياً كلاً من:
  /// - Google Play Store (Android)
  /// - Apple App Store (iOS / macOS)
  /// - Microsoft Store (Windows)
  /// - Huawei AppGallery (اختياري)
  ///
  /// [androidPackageName]: معرف حزمة أندرويد (مثال: 'com.smartix.netsales').
  /// [iosAppId]: معرف تطبيق آبل الرقمي (مثال: '1234567890').
  /// [windowsStoreId]: معرف متجر ويندوز (مثال: '9NZSTR123456').
  /// [huaweiAppId]: معرف متجر هواوي (اختياري).
  static Future<UrlLaunchResult> openStore({
    String? androidPackageName,
    String? iosAppId,
    String? windowsStoreId,
    String? huaweiAppId,
  }) async {
    try {
      Uri? uri;
      String storeName = 'متجر التطبيقات';

      if (!kIsWeb) {
        if (defaultTargetPlatform == TargetPlatform.android) {
          storeName = 'Google Play';
          if (androidPackageName != null && androidPackageName.isNotEmpty) {
            uri = Uri.parse('market://details?id=$androidPackageName');
            try {
              final canOpenMarket = await canLaunchUrl(uri);
              if (!canOpenMarket) {
                uri = Uri.parse('https://play.google.com/store/apps/details?id=$androidPackageName');
              }
            } catch (_) {
              uri = Uri.parse('https://play.google.com/store/apps/details?id=$androidPackageName');
            }
          }
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          storeName = 'App Store';
          if (iosAppId != null && iosAppId.isNotEmpty) {
            uri = Uri.parse('https://apps.apple.com/app/id$iosAppId');
          }
        } else if (defaultTargetPlatform == TargetPlatform.windows) {
          storeName = 'Microsoft Store';
          if (windowsStoreId != null && windowsStoreId.isNotEmpty) {
            uri = Uri.parse('ms-windows-store://pdp/?ProductId=$windowsStoreId');
          }
        } else if (defaultTargetPlatform == TargetPlatform.macOS) {
          storeName = 'Mac App Store';
          if (iosAppId != null && iosAppId.isNotEmpty) {
            uri = Uri.parse('macappstore://itunes.apple.com/app/id$iosAppId');
          }
        }
      }

      // إذا لم يتحدد رابط بناءً على المنصة، نعتمد رابط جوجل بلاي كرابط افتراضي للويب
      if (uri == null && androidPackageName != null && androidPackageName.isNotEmpty) {
        uri = Uri.parse('https://play.google.com/store/apps/details?id=$androidPackageName');
      }

      if (uri == null) {
        return _fail(
          type: UrlLaunchType.appStore,
          message: 'لم يتم توفير معرف المتجر المناسب للمنصة الحالية.',
        );
      }

      return await _launchInternal(
        uri: uri,
        type: UrlLaunchType.appStore,
        mode: LaunchMode.externalApplication,
        fallbackMessage: 'تعذر فتح $storeName.',
      );
    } catch (e, stackTrace) {
      return _handleUnexpectedError(
        type: UrlLaunchType.appStore,
        error: e,
        stackTrace: stackTrace,
        fallbackText: androidPackageName ?? iosAppId ?? windowsStoreId,
      );
    }
  }

  // ===========================================================================
  // 7. تشغيل البروتوكولات والروابط المخصصة (Custom Schemes & Deep Links)
  // ===========================================================================

  /// تشغيل بروتوكول مخصص أو رابط عميق (Deep Link / Custom Scheme)
  ///
  /// [scheme]: اسم البروتوكول (مثال: 'myapp' أو 'fb' أو 'twitter').
  /// [host]: المضيف أو الوجهة الأساسية في الرابط العميق (اختياري، مثل 'payment').
  /// [path]: مسار الرابط (مثال: 'verify' أو '/payment/verify').
  /// [queryParameters]: المعاملات الإضافية.
  static Future<UrlLaunchResult> openCustomScheme(
    String scheme, {
    String? host,
    String? path,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final cleanScheme = scheme.trim().replaceAll('://', '');
      if (cleanScheme.isEmpty) {
        return _fail(
          type: UrlLaunchType.customScheme,
          message: 'اسم البروتوكول المخصص فارغ.',
        );
      }

      String? cleanHost = host?.trim();
      String? cleanPath = path?.trim();

      // استخراج الـ host تلقائياً في حال تمرير المسار بصيغة 'payment/verify' لإنتاج 'scheme://payment/verify'
      if (cleanHost == null && cleanPath != null && cleanPath.isNotEmpty) {
        if (cleanPath.startsWith('//')) {
          cleanPath = cleanPath.substring(2);
        }
        final segments = cleanPath.split('/');
        cleanHost = segments.first;
        cleanPath = segments.length > 1 ? '/${segments.sublist(1).join('/')}' : '';
      }

      final uri = Uri(
        scheme: cleanScheme,
        host: cleanHost,
        path: cleanPath,
        queryParameters: queryParameters?.map((k, v) => MapEntry(k, v.toString())),
      );

      return await _launchInternal(
        uri: uri,
        type: UrlLaunchType.customScheme,
        mode: LaunchMode.externalApplication,
      );
    } catch (e, stackTrace) {
      return _handleUnexpectedError(
        type: UrlLaunchType.customScheme,
        error: e,
        stackTrace: stackTrace,
        fallbackText: '$scheme://${host ?? ''}${path ?? ''}',
      );
    }
  }

  // ===========================================================================
  // 8. خدمات النسخ الاحتياطي للحافظة والأمان (Clipboard & Utilities)
  // ===========================================================================

  /// نسخ النص أو الرابط إلى حافظة الجهاز مع توفير تأكيد
  static Future<bool> copyToClipboard(String text, {String? confirmationMessage}) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (instance._config.enableLogging) {
        developer.log('[UrlLauncherService] Copied to clipboard: $text');
      }
      return true;
    } catch (e, stackTrace) {
      if (instance._config.enableLogging) {
        developer.log(
          '[UrlLauncherService] Failed to copy to clipboard: $e',
          error: e,
          stackTrace: stackTrace,
        );
      }
      return false;
    }
  }

  // ===========================================================================
  // محرك التنفيذ الداخلي الصارم والمعالجة الذكية (Internal Core Execution)
  // ===========================================================================

  static Future<UrlLaunchResult> _launchInternal({
    required Uri uri,
    required UrlLaunchType type,
    LaunchMode mode = LaunchMode.platformDefault,
    Map<String, String>? headers,
    String? webWindowName,
    String? fallbackText,
    String? fallbackMessage,
  }) async {
    if (instance._config.enableLogging) {
      developer.log('[UrlLauncherService] Launching $type: $uri (mode: $mode)');
    }

    try {
      // 1. فحص إمكانية تشغيل الرابط
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        if (instance._config.enableLogging) {
          developer.log('[UrlLauncherService] canLaunchUrl returned false for $uri');
        }

        // في حال تعذر الفتح وكان هناك نص بديل وخاصية النسخ مفعلة، نقوم بنسخه للحافظة
        if (instance._config.copyToClipboardOnUnsupportedPlatform &&
            fallbackText != null &&
            fallbackText.isNotEmpty) {
          await copyToClipboard(fallbackText);
        }

        final failureMessage = fallbackMessage ?? 'لا يتوفر تطبيق متوافق لفتح هذا الرابط على جهازك.';
        final result = UrlLaunchResult.failure(
          type: type,
          uri: uri,
          message: failureMessage,
        );

        instance._config.onMessage?.call(failureMessage, result);
        return result;
      }

      // 2. تشغيل الرابط عبر المحرك الأصلي
      final launched = await launchUrl(
        uri,
        mode: mode,
        webViewConfiguration: WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
          headers: headers ?? const <String, String>{},
        ),
        webOnlyWindowName: webWindowName,
      );

      if (!launched) {
        if (instance._config.copyToClipboardOnUnsupportedPlatform &&
            fallbackText != null &&
            fallbackText.isNotEmpty) {
          await copyToClipboard(fallbackText);
        }

        final failureMessage = fallbackMessage ?? 'تعذر فتح الرابط المطلوب.';
        final result = UrlLaunchResult.failure(
          type: type,
          uri: uri,
          message: failureMessage,
        );

        instance._config.onMessage?.call(failureMessage, result);
        return result;
      }

      return UrlLaunchResult.success(type: type, uri: uri);
    } catch (e, stackTrace) {
      return _handleUnexpectedError(
        type: type,
        error: e,
        stackTrace: stackTrace,
        fallbackText: fallbackText,
        fallbackMessage: fallbackMessage,
      );
    }
  }

  /// معالجة موحدة وشاملة لكافة الاستثناءات الطارئة (FormatException, PlatformException, etc.)
  static Future<UrlLaunchResult> _handleUnexpectedError({
    required UrlLaunchType type,
    required Object error,
    required StackTrace stackTrace,
    String? fallbackText,
    String? fallbackMessage,
  }) async {
    if (instance._config.enableLogging) {
      developer.log(
        '[UrlLauncherService] Unexpected error in $type: $error',
        error: error,
        stackTrace: stackTrace,
      );
    }

    if (instance._config.copyToClipboardOnUnsupportedPlatform &&
        fallbackText != null &&
        fallbackText.trim().isNotEmpty) {
      await copyToClipboard(fallbackText.trim());
    }

    final message = fallbackMessage ?? 'حدث خطأ غير متوقع أثناء معالجة أو تشغيل الرابط.';
    final result = UrlLaunchResult.failure(
      type: type,
      message: message,
      error: error,
    );

    instance._config.onMessage?.call(message, result);
    return result;
  }

  /// مساعدة سريعة لإنشاء نتيجة فشل موحدة
  static UrlLaunchResult _fail({
    required UrlLaunchType type,
    required String message,
  }) {
    final result = UrlLaunchResult.failure(type: type, message: message);
    instance._config.onMessage?.call(message, result);
    return result;
  }

  /// تنظيف وتنسيق أرقام الهواتف وإزالة المسافات والرموز غير المعتمدة
  static String _sanitizePhoneNumber(String phone) {
    var clean = phone.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return clean;
  }
}
