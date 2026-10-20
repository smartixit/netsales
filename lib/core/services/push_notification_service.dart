import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:netsales/core/config/firebase_options.dart';
import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/core/services/device_service.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/storage_service.dart';

/// دالة المعالجة المعزولة في الخلفية عند وصول إشعار والتطبيق بالخلفية أو مغلق.
/// يجب أن تكون في المستوى الأعلى (Top-Level) ومحمية بـ @pragma('vm:entry-point').
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    log('🔔 [FCM Background Handler] Received message #${message.messageId}');
  } catch (e, stack) {
    log('⚠️ [FCM Background Handler Error]: $e\n$stack');
  }
}

/// ============================================================================
/// خدمة الإشعارات المركزية المؤسسية (Enterprise Push Notification Service)
/// ============================================================================
/// تدير دورة حياة إشعارات فايربيس (FCM) والإشعارات المحلية (Local Notifications)
/// والمزامنة اللحظية لرمز الجهاز مع الواجهة الخلفية وإدارة التوجيه الذكي (Deep Linking).
class PushNotificationService extends GetxService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  static PushNotificationService get to => Get.find<PushNotificationService>();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// القناة الافتراضية عالية الأهمية لنظام أندرويد
  static const AndroidNotificationChannel highImportanceChannel =
      AndroidNotificationChannel(
    'netsales_high_importance',
    'إشعارات نظام مبيعات الشبكة الفورية',
    description: 'تنبيهات فورية للعمليات المالية وكروت الشبكة والنشاطات الأمنية',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  String? _fcmToken;

  /// رمز الإشعارات الفورية الحالي للجهاز
  String? get fcmToken => _fcmToken;

  /// تهيئة محرك الإشعارات
  Future<PushNotificationService> init() async {
    try {
      // 1. تهيئة حزمة فايربيس
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // 2. تسجيل دالة استقبال إشعارات الخلفية
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 3. تهيئة قنوات وأدوات الإشعارات المحلية
      await _initLocalNotifications();

      // 4. طلب أذونات الإشعارات (Android 13+ و iOS)
      await requestPermissions();

      // 5. ضبط إعدادات عرض الإشعارات أثناء فتح التطبيق (Foreground)
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 6. الاستماع لرسائل المقدمة والتفاعل مع النقر
      _setupMessageListeners();

      // 7. جلب رمز FCM الحالي
      await _retrieveFcmToken();

      // 8. فحص الرسالة الأولية في حال فُتح التطبيق من إشعار وهو مغلق (Terminated State)
      await _checkInitialMessage();

      log('✅ [PushNotificationService] Initialized enterprise push engine successfully.');
    } catch (e, stack) {
      log('⚠️ [PushNotificationService] Initialization error: $e\n$stack');
    }

    return this;
  }

  /// تهيئة إعدادات الإشعارات المحلية لنظامي Android و iOS
  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          _handleNotificationPayloadString(response.payload!);
        }
      },
    );

    // تسجيل القناة عالية الأهمية لدى نظام أندرويد
    final androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation
          .createNotificationChannel(highImportanceChannel);
    }
  }

  /// طلب الصلاحيات التكيفية لنظامي أندرويد و iOS
  Future<bool> requestPermissions() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final isAuthorized =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      log('📱 [PushNotificationService] Authorization Status: ${settings.authorizationStatus}');
      return isAuthorized;
    } catch (e) {
      log('⚠️ [PushNotificationService] Error requesting notification permissions: $e');
      return false;
    }
  }

  /// جلب الرمز الفريد ومراقبة تحديثه (FCM Token Rotation)
  Future<void> _retrieveFcmToken() async {
    try {
      _fcmToken = await _fcm.getToken();
      if (_fcmToken != null && _fcmToken!.isNotEmpty) {
        log('🔑 [PushNotificationService] FCM Token acquired: ${_fcmToken!.substring(0, 16)}...');
        // مزامنة الرمز مع الخادم إذا كان المستخدم مسجلاً بالفعل
        if (SessionService.to.isAuthenticated) {
          await syncTokenWithBackend();
        }
      }

      // الاستماع لتحديث وتدوير الرمز بواسطة خدمات جوجل
      _fcm.onTokenRefresh.listen((newToken) async {
        log('🔄 [PushNotificationService] FCM Token rotated by Google Services.');
        _fcmToken = newToken;
        if (SessionService.to.isAuthenticated) {
          await syncTokenWithBackend(force: true);
        }
      });
    } catch (e) {
      log('⚠️ [PushNotificationService] Failed to retrieve FCM Token: $e');
    }
  }

  /// مزامنة الرمز الحالي مع الواجهة الخلفية عبر نقطة الوصول /api/v1/notifications/fcm-token
  Future<bool> syncTokenWithBackend({bool force = false}) async {
    final token = _fcmToken;
    if (token == null || token.isEmpty) {
      return false;
    }

    final storage = StorageService.instance;
    final cachedToken = storage.getString(StorageKeys.fcmTokenStorage);

    // إذا كان الرمز قد تمت مزامنته مسبقاً ولم يُطلب فرض التحديث، نتجنب تكرار الطلب
    if (!force && cachedToken == token) {
      return true;
    }

    try {
      final device = DeviceService.instance;
      final payload = {
        'device_uuid': device.deviceUuid,
        'fcm_token': token,
        'device_name': device.deviceName,
        'device_type': device.deviceType,
      };

      final response = await ApiService.instance.post(
        ApiConstants.notificationFcmToken,
        data: payload,
      );

      if (response.success) {
        await storage.setString(StorageKeys.fcmTokenStorage, token);
        log('📡 [PushNotificationService] FCM Token synced with server for device: ${device.deviceUuid}');
        return true;
      }
    } catch (e) {
      log('⚠️ [PushNotificationService] Failed to sync FCM token with server: $e');
    }

    return false;
  }

  /// مسح رمز الإشعارات من الذاكرة والخادم وحذف توكن Firebase عند تسجيل الخروج
  Future<void> clearFcmToken() async {
    try {
      await StorageService.instance.remove(StorageKeys.fcmTokenStorage);
      _fcmToken = null;
      await _fcm.deleteToken();
      log('🧹 [PushNotificationService] FCM Token deleted from device.');
    } catch (e) {
      log('⚠️ [PushNotificationService] Error clearing FCM token: $e');
    }
  }

  /// إعداد مستمعات استقبال الرسائل أثناء فتح التطبيق والتفاعل معها
  void _setupMessageListeners() {
    // 1. استقبال الرسائل أثناء استخدام التطبيق في المقدمة (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('📥 [PushNotificationService] Foreground Message received: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // 2. التفاعل مع النقر على الإشعار عند عودة التطبيق من الخلفية (Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('👆 [PushNotificationService] Notification clicked from background.');
      _handleMessageNavigation(message);
    });
  }

  /// فحص الإشعار الذي فتح التطبيق عندما كان مغلقاً كلياً (Terminated)
  Future<void> _checkInitialMessage() async {
    try {
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        log('🚀 [PushNotificationService] App launched from terminated state via notification.');
        // ننتظر قليلاً حتى تكتمل جاهزية شجرة التوجيه والواجهات
        Future.delayed(const Duration(milliseconds: 600), () {
          _handleMessageNavigation(initialMessage);
        });
      }
    } catch (e) {
      log('⚠️ [PushNotificationService] Error checking initial message: $e');
    }
  }

  /// عرض إشعار محلي فوري عند وصول رسالة FCM والتطبيق مفتوح في المقدمة
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      highImportanceChannel.id,
      highImportanceChannel.name,
      channelDescription: highImportanceChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@drawable/ic_notification',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final payloadString = jsonEncode(message.data);
    final notificationId = message.hashCode;

    await _localNotifications.show(
      id: notificationId,
      title: notification.title,
      body: notification.body,
      notificationDetails: notificationDetails,
      payload: payloadString,
    );
  }

  /// معالجة التوجيه الذكي (Deep Linking) استناداً إلى حمولة الرسالة
  void _handleMessageNavigation(RemoteMessage message) {
    _dispatchPayloadNavigation(message.data);
  }

  /// معالجة السلسلة النصية للحمولة القادمة من نقر الإشعار المحلي
  void _handleNotificationPayloadString(String payloadString) {
    try {
      final Map<String, dynamic> data = jsonDecode(payloadString);
      _dispatchPayloadNavigation(data);
    } catch (e) {
      log('⚠️ [PushNotificationService] Error decoding notification payload: $e');
    }
  }

  /// توجيه المستخدم للشاشة المناسبة بحسب نوع الكيان ومعرفه
  void _dispatchPayloadNavigation(Map<String, dynamic> data) {
    if (data.isEmpty) return;

    final actionType = data['action_type']?.toString().toUpperCase();
    final entityType = data['entity_type']?.toString().toUpperCase();
    final entityId = data['entity_id']?.toString();
    final route = data['route']?.toString();

    log('🎯 [PushNotificationService] Dispatching deep link: entityType=$entityType, entityId=$entityId, actionType=$actionType');

    // 1. التوجيه المباشر بالمسار الصريح إن وُجد
    if (route != null && route.isNotEmpty) {
      Get.toNamed(route);
      return;
    }

    // 2. التوجيه بحسب نوع الكيان المعياري لنظام NetSales
    switch (entityType) {
      // case 'SUPPORT_TICKET':
      //   Get.toNamed(AppRoutes.supportTickets);
      //   break;

      case 'SALE_INVOICE':
        Get.toNamed(AppRoutes.saleInvoices);
        break;

      // case 'VOUCHER_REQUEST':
      //   Get.toNamed(AppRoutes.voucherRequests);
      //   break;

      case 'WALLET':
      case 'WALLET_TRANSACTION':
        Get.toNamed(AppRoutes.dashboard);
        break;

      case 'NETWORK':
        Get.toNamed(AppRoutes.networks);
        break;

      case 'POS':
        Get.toNamed(AppRoutes.pos);
        break;

      default:
        // إذا كان هناك إشعار عام بدون كيان محدد، ننتقل للوحة التحكم أو شاشة الإشعارات
        if (Get.currentRoute != AppRoutes.dashboard) {
          Get.toNamed(AppRoutes.dashboard);
        }
        break;
    }
  }
}
