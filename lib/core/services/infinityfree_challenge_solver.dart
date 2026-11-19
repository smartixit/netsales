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

  /// يحاكي إزالة الذيل المتكرر في SlowAES unpadBytesOut.
  ///
  /// هذه ليست إزالة PKCS#7 قياسية: SlowAES تزيل عدد البايتات المتطابقة
  /// المتتالية في نهاية الناتج حتى لو كان عددها أقل من قيمة البايت نفسه.
  static Uint8List _unpadBytesOut(Uint8List data) {
    if (data.isEmpty) return data;
    final lastByte = data.last;
    if (lastByte > 16) return data;

    var trailingCount = 0;
    for (var i = data.length - 1;
        i >= 0 && trailingCount < 16 && data[i] == lastByte;
        i--) {
      trailingCount++;
    }

    if (trailingCount == 0) return data;
    return Uint8List.sublistView(data, 0, data.length - trailingCount);
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

  /// User-Agent شبيه بمتصفح — تشترطه الاستضافة بجانب الكوكي في كل طلب.
  static String get browserUserAgent => _browserUserAgent;

  /// القيمة المتوقعة لكوكي __test محسوبة من `c` في الصفحة المحفوظة.
  static String? computeFromBytes(Uint8List body) {
    try {
      return solveChallenge(utf8.decode(body));
    } catch (_) {
      return null;
    }
  }
}
