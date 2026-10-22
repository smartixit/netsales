// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// منصة وهمية (Mock Platform) لاختبار url_launcher والتقاط الروابط والمعاملات
class MockUrlLauncherPlatform extends UrlLauncherPlatform {
  String? lastLaunchedUrl;
  PreferredLaunchMode? lastLaunchMode;
  bool canLaunchResult = true;
  bool launchResult = true;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async {
    return canLaunchResult;
  }

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    lastLaunchedUrl = url;
    lastLaunchMode = options.mode;
    return launchResult;
  }

  void reset() {
    lastLaunchedUrl = null;
    lastLaunchMode = null;
    canLaunchResult = true;
    launchResult = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockUrlLauncherPlatform mockPlatform;

  setUp(() {
    mockPlatform = MockUrlLauncherPlatform();
    UrlLauncherPlatform.instance = mockPlatform;
    UrlLauncherService.configure(const UrlLauncherConfig(
      enableLogging: false,
      copyToClipboardOnUnsupportedPlatform: false,
    ));
  });

  group('Web & Universal Links Tests', () {
    test('openUrl automatically prepends https to plain domains', () async {
      final result = await UrlLauncherService.openUrl('smartix.net');

      expect(result.isSuccess, isTrue);
      expect(result.type, UrlLaunchType.webUrl);
      expect(mockPlatform.lastLaunchedUrl, 'https://smartix.net');
    });

    test('openUrl preserves existing http/https protocols', () async {
      final result = await UrlLauncherService.openUrl('http://test-server.local/api');

      expect(result.isSuccess, isTrue);
      expect(mockPlatform.lastLaunchedUrl, 'http://test-server.local/api');
    });

    test('openUrl rejects empty string cleanly', () async {
      final result = await UrlLauncherService.openUrl('   ');

      expect(result.isSuccess, isFalse);
      expect(result.type, UrlLaunchType.webUrl);
      expect(result.message, contains('فارغ'));
      expect(mockPlatform.lastLaunchedUrl, isNull);
    });

    test('openInExternalBrowser forces LaunchMode.externalApplication', () async {
      await UrlLauncherService.openInExternalBrowser('https://flutter.dev');

      expect(mockPlatform.lastLaunchMode, PreferredLaunchMode.externalApplication);
      expect(mockPlatform.lastLaunchedUrl, 'https://flutter.dev');
    });

    test('openInAppBrowser forces LaunchMode.inAppBrowserView', () async {
      await UrlLauncherService.openInAppBrowser('https://dart.dev');

      expect(mockPlatform.lastLaunchMode, PreferredLaunchMode.inAppBrowserView);
      expect(mockPlatform.lastLaunchedUrl, 'https://dart.dev');
    });
  });

  group('Telephony & USSD Tests', () {
    test('callPhone sanitizes spaces, dashes, and invokes tel: scheme', () async {
      final result = await UrlLauncherService.callPhone('+967 777-123 (456)');

      expect(result.isSuccess, isTrue);
      expect(result.type, UrlLaunchType.phoneCall);
      expect(mockPlatform.lastLaunchedUrl, 'tel:+967777123456');
    });

    test('callPhone rejects empty or invalid number', () async {
      final result = await UrlLauncherService.callPhone('   ');

      expect(result.isSuccess, isFalse);
      expect(result.type, UrlLaunchType.phoneCall);
      expect(mockPlatform.lastLaunchedUrl, isNull);
    });

    test('sendSms formats query body properly with UTF-8 encoding', () async {
      final result = await UrlLauncherService.sendSms(
        '777123456',
        message: 'مرحباً، تفاصيل الحساب التجاري',
      );

      expect(result.isSuccess, isTrue);
      expect(result.type, UrlLaunchType.sms);
      expect(mockPlatform.lastLaunchedUrl, startsWith('sms:777123456?body='));
      expect(mockPlatform.lastLaunchedUrl, contains(Uri.encodeQueryComponent('مرحباً، تفاصيل الحساب التجاري')));
    });

    test('sendUssd encodes hash # symbol to %23 correctly for mobile dialer', () async {
      final result = await UrlLauncherService.sendUssd('*555*12345#');

      expect(result.isSuccess, isTrue);
      expect(result.type, UrlLaunchType.ussd);
      expect(mockPlatform.lastLaunchedUrl, 'tel:*555*12345%23');
    });
  });

  group('Email / Mailto Tests', () {
    test('sendEmail formats recipients, subject, body, cc, and bcc', () async {
      final result = await UrlLauncherService.sendEmail(
        to: 'support@smartix.net',
        subject: 'طلب ترقية باقة NetSales',
        body: 'نرجو ترقية الحساب إلى الباقة الماسية.',
        cc: ['sales@smartix.net'],
        bcc: ['admin@smartix.net'],
      );

      expect(result.isSuccess, isTrue);
      expect(result.type, UrlLaunchType.email);
      expect(mockPlatform.lastLaunchedUrl, startsWith('mailto:support@smartix.net?'));
      expect(mockPlatform.lastLaunchedUrl, contains('subject='));
      expect(mockPlatform.lastLaunchedUrl, contains('cc=sales%40smartix.net'));
      expect(mockPlatform.lastLaunchedUrl, contains('bcc=admin%40smartix.net'));
    });

    test('sendEmail rejects empty recipient', () async {
      final result = await UrlLauncherService.sendEmail(to: '');

      expect(result.isSuccess, isFalse);
      expect(result.type, UrlLaunchType.email);
      expect(mockPlatform.lastLaunchedUrl, isNull);
    });
  });

  group('Maps & Navigation Tests', () {
    test('openMapCoordinates formats Google Maps coordinates URL correctly', () async {
      final result = await UrlLauncherService.openMapCoordinates(
        latitude: 15.3694,
        longitude: 44.1910,
        label: 'المركز الرئيسي',
        preference: MapPlatformPreference.googleMaps,
      );

      expect(result.isSuccess, isTrue);
      expect(result.type, UrlLaunchType.mapCoordinates);
      expect(mockPlatform.lastLaunchedUrl, contains('https://www.google.com/maps/search/?api=1&query=15.3694,44.191'));
    });

    test('openMapCoordinates formats Waze URL correctly', () async {
      final result = await UrlLauncherService.openMapCoordinates(
        latitude: 15.3694,
        longitude: 44.1910,
        preference: MapPlatformPreference.waze,
      );

      expect(result.isSuccess, isTrue);
      expect(mockPlatform.lastLaunchedUrl, 'https://waze.com/ul?ll=15.3694,44.191&navigate=yes');
    });

    test('searchMap formats search query encoded with Google Maps', () async {
      final result = await UrlLauncherService.searchMap('صنعاء شارع الزبيري');

      expect(result.isSuccess, isTrue);
      expect(result.type, UrlLaunchType.mapSearch);
      expect(mockPlatform.lastLaunchedUrl, contains('https://www.google.com/maps/search/?api=1&query='));
    });
  });

  group('Messaging & Social Media Tests', () {
    test('openWhatsApp strips non-digits and constructs valid wa.me URL', () async {
      final result = await UrlLauncherService.openWhatsApp(
        phoneNumber: '+967 (77) 123-456',
        message: 'السلام عليكم، استفسار عن الخدمة',
      );

      expect(result.isSuccess, isTrue);
      expect(result.type, UrlLaunchType.whatsApp);
      expect(mockPlatform.lastLaunchedUrl, startsWith('https://wa.me/96777123456?text='));
    });

    test('openTelegram constructs username URL without @', () async {
      final result = await UrlLauncherService.openTelegram(
        username: '@SmartixSales',
        text: 'مرحبا',
      );

      expect(result.isSuccess, isTrue);
      expect(result.type, UrlLaunchType.telegram);
      expect(mockPlatform.lastLaunchedUrl, startsWith('https://t.me/SmartixSales?text='));
    });

    test('openSocialProfile supports various platforms seamlessly', () async {
      await UrlLauncherService.openSocialProfile(
        platform: SocialNetwork.linkedIn,
        usernameOrId: 'smartix-tech',
      );
      expect(mockPlatform.lastLaunchedUrl, 'https://www.linkedin.com/in/smartix-tech');

      await UrlLauncherService.openSocialProfile(
        platform: SocialNetwork.gitHub,
        usernameOrId: 'smartix-org',
      );
      expect(mockPlatform.lastLaunchedUrl, 'https://github.com/smartix-org');

      await UrlLauncherService.openSocialProfile(
        platform: SocialNetwork.youTube,
        usernameOrId: 'SmartixChannel',
      );
      expect(mockPlatform.lastLaunchedUrl, 'https://www.youtube.com/@SmartixChannel');
    });
  });

  group('App Stores & Deep Linking Tests', () {
    test('openStore resolves Android Google Play URL', () async {
      final result = await UrlLauncherService.openStore(
        androidPackageName: 'com.smartix.netsales',
      );

      expect(result.isSuccess, isTrue);
      expect(result.type, UrlLaunchType.appStore);
      expect(mockPlatform.lastLaunchedUrl, contains('com.smartix.netsales'));
    });

    test('openCustomScheme constructs formatted custom deep link URI', () async {
      final result = await UrlLauncherService.openCustomScheme(
        'netsales',
        path: 'payment/verify',
        queryParameters: {'txn_id': '987654', 'status': 'success'},
      );

      expect(result.isSuccess, isTrue);
      expect(result.type, UrlLaunchType.customScheme);
      expect(mockPlatform.lastLaunchedUrl, startsWith('netsales://payment/verify?'));
      expect(mockPlatform.lastLaunchedUrl, contains('txn_id=987654'));
    });
  });

  group('Failure & Callback Handling Tests', () {
    test('returns failure and triggers onMessage callback when platform cannot launch', () async {
      mockPlatform.canLaunchResult = false;

      String? caughtMessage;
      UrlLaunchResult? caughtResult;

      UrlLauncherService.configure(UrlLauncherConfig(
        enableLogging: false,
        copyToClipboardOnUnsupportedPlatform: false,
        onMessage: (msg, res) {
          caughtMessage = msg;
          caughtResult = res;
        },
      ));

      final result = await UrlLauncherService.openUrl('https://unreachable-scheme.test');

      expect(result.isSuccess, isFalse);
      expect(caughtMessage, isNotNull);
      expect(caughtResult, isNotNull);
      expect(caughtResult!.isSuccess, isFalse);
    });
  });
}
