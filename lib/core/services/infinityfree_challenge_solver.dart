import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/pointycastle.dart';

/// حلاّق تحدّي الاستضافة المجانية InfinityFree (تحقق nginx "testcookie").
///
/// الاستضافة تصدّ أي طلبٍ قادم من عميلٍ لا يجري JavaScript مع صفحة HTML تتضمن
/// ثوابت `a` و`b` و`c`. المتصفح يحسب قيمة كوكي `__test` عبر
/// `slowAES.decrypt(c, 2, a, b)` ثم يعيد الطلب والكوكي مضبوطة.
///
/// نعيد نفس العملية هنا برمجياً (AES-128-CBC) دون أي محرك JavaScript.
class InfinityFreeChallengeSolver {
  InfinityFreeChallengeSolver._();

  static const _browserUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36';

  /// هل جسم الاستجابة هو صفحة تحدي InfinityFree؟
  static bool isChallengeBody(dynamic data) {
    if (data is! String) return false;
    final lower = data.toLowerCase();
    return lower.contains('aes.js') &&
        lower.contains('__test') &&
        lower.contains('tonumbers');
  }

  /// يحوّل أي نوع استجابة شائع من Dio إلى نص صفحة التحدي عند تطابقها.
  static String? challengeHtml(dynamic data) {
    final String? body;
    if (data is String) {
      body = data;
    } else if (data is List<int>) {
      try {
        body = utf8.decode(data);
      } on FormatException {
        return null;
      }
    } else {
      return null;
    }

    return isChallengeBody(body) ? body : null;
  }

  /// يحدد صفحة التحدي سواء أعادها Dio كنص أو كبايتات.
  static bool isChallengeResponse(dynamic data) {
    return challengeHtml(data) != null;
  }

  /// يحسب قيمة كوكي التحدي لأي نوع استجابة نصي/ثنائي يدعمه المحلل.
  static String? solveChallengeResponse(dynamic data) {
    final html = challengeHtml(data);
    if (html == null) return null;
    return solveChallenge(html);
  }

  /// يستخرج انتقال JavaScript من أي نوع استجابة يدعمه المحلل.
  static Uri? extractChallengeRedirectFromResponse(
    dynamic data, {
    required Uri requestUri,
  }) {
    final html = challengeHtml(data);
    if (html == null) return null;

    return extractChallengeRedirectUri(html, requestUri: requestUri);
  }

  /// استخراج الثوابت [a, b, c] مع تحمل اختلاف المسافات والتصغير.
  static List<String>? extractConstants(String html) {
    String? capture(String name) => RegExp(
      '\\b$name\\s*=\\s*toNumbers\\s*\\(\\s*"([0-9a-f]+)"\\s*\\)',
      caseSensitive: false,
    ).firstMatch(html)?.group(1);

    final key = capture('a');
    final iv = capture('b');
    final cipherText = capture('c');
    if (key == null || iv == null || cipherText == null) return null;
    return [key, iv, cipherText];
  }

  /// يحسب قيمة كوكي `__test` من الصفحة المعروضة (تُعيد null عند الفشل).
  static String? solveChallenge(String html) {
    final constants = extractConstants(html);
    if (constants == null) return null;
    return _decryptConstants(constants[0], constants[1], constants[2]);
  }

  static Uint8List _toNumbers(String hex) {
    if (hex.length.isOdd) throw const FormatException('Invalid hex length');
    final out = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < out.length; i++) {
      out[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return out;
  }

  static String _toHex(Uint8List bytes) {
    final sb = StringBuffer();
    for (final b in bytes) {
      sb.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString();
  }

  /// تطابق خوارزمية SlowAES unpadBytesOut المرجعية، لا PKCS#7 الصارمة.
  ///
  /// تزيل عدد البايتات المتطابقة في الذيل، لكن إذا ظهر قبلها بايت آخر
  /// قيمته ضمن 1..16 فإن المرجع يلغي الإزالة كلها. أما البايت السابق
  /// الأكبر من 16 فينهي الفحص مع الإبقاء على عدد البايتات المتطابقة المكتشف.
  static Uint8List _unpadBytesOut(Uint8List data) {
    const blockSize = 16;
    // SlowAES skips unpadding for a single 16-byte AES block. Applying the
    // padding scan here changes valid browser output (notably a trailing 0x0d).
    if (data.length <= blockSize) return data;

    var padCount = 0;
    var padByte = -1;

    for (
      var i = data.length - 1;
      i >= 0 && i >= data.length - 1 - blockSize;
      i--
    ) {
      if (data[i] <= blockSize) {
        if (padByte == -1) padByte = data[i];

        if (data[i] != padByte) {
          padCount = 0;
          break;
        }

        padCount++;
      } else {
        break;
      }

      if (padCount == padByte) break;
    }

    if (padCount == 0) return data;
    return Uint8List.sublistView(data, 0, data.length - padCount);
  }

  static String? _decryptConstants(String aHex, String bHex, String cHex) {
    try {
      final key = _toNumbers(aHex);
      final iv = _toNumbers(bHex);
      final ciphertext = _toNumbers(cHex);

      if (key.length != 16 ||
          iv.length != 16 ||
          ciphertext.isEmpty ||
          ciphertext.length % 16 != 0) {
        return null;
      }

      final cipher = CBCBlockCipher(AESEngine());
      cipher.init(false, ParametersWithIV(KeyParameter(key), iv));

      final plaintext = Uint8List(ciphertext.length);
      for (var offset = 0; offset < ciphertext.length; offset += 16) {
        cipher.processBlock(ciphertext, offset, plaintext, offset);
      }

      return _toHex(_unpadBytesOut(plaintext));
    } catch (_) {
      return null;
    }
  }

  /// يحدّث كوكي التحدي مع الحفاظ على بقية الكوكيز الموجودة للوجهة نفسها.
  ///
  /// يمنع تكرار __test ويستبدل قيمته القديمة دون حذف جلسة الخادم أو XSRF.
  static String mergeChallengeCookie({
    required String? existingCookieHeader,
    required String challengeCookie,
  }) {
    final cookies = (existingCookieHeader ?? '')
        .split(';')
        .map((cookie) => cookie.trim())
        .where(
          (cookie) =>
              cookie.isNotEmpty &&
              !RegExp(r'^__test\s*=', caseSensitive: false).hasMatch(cookie),
        )
        .toList();

    cookies.add('__test=$challengeCookie');
    return cookies.join('; ');
  }

  /// User-Agent شبيه بمتصفح — تشترطه الاستضافة بجانب الكوكي في كل طلب.
  static String get browserUserAgent => _browserUserAgent;

  /// يستخرج عنوان الانتقال الذي ينفذه JavaScript بعد ضبط كوكي التحقق.
  ///
  /// لا نقبل إلا انتقالاً إلى نفس scheme/host/port/path للطلب الحالي؛
  /// نحتاج معامل التحقق (مثل i=1) فقط، ولا نتبع أي إعادة توجيه إلى وجهة أخرى.
  static Uri? extractChallengeRedirectUri(
    String html, {
    required Uri requestUri,
  }) {
    final match = RegExp(
      r'''location\s*\.\s*href\s*=\s*["']([^"']+)["']''',
      caseSensitive: false,
    ).firstMatch(html);
    final location = match?.group(1);
    if (location == null || location.isEmpty) return null;

    try {
      final targetUri = requestUri.resolve(location);
      final sameOrigin =
          targetUri.scheme.toLowerCase() == requestUri.scheme.toLowerCase() &&
          targetUri.host.toLowerCase() == requestUri.host.toLowerCase() &&
          targetUri.port == requestUri.port;
      final samePath = targetUri.path == requestUri.path;

      if (!sameOrigin || !samePath || !targetUri.hasQuery) {
        return null;
      }

      return targetUri;
    } on FormatException {
      return null;
    }
  }

  /// القيمة المتوقعة لكوكي __test محسوبة من `c` في الصفحة المحفوظة.
  static String? computeFromBytes(Uint8List body) {
    try {
      return solveChallenge(utf8.decode(body));
    } catch (_) {
      return null;
    }
  }
}
