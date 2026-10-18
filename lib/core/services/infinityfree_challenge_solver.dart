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

  /// استخراج الثوابت [a, b, c] من نص صفحة التحدي.
  static List<String>? extractConstants(String html) {
    final a = RegExp(
      r'var a=toNumbers\("([0-9a-f]+)"\)',
      caseSensitive: false,
    ).firstMatch(html);
    final b = RegExp(
      r'[a-z,]?b=toNumbers\("([0-9a-f]+)"\)',
      caseSensitive: false,
    ).firstMatch(html);
    final c = RegExp(
      r'[a-z,]?c=toNumbers\("([0-9a-f]+)"\)',
      caseSensitive: false,
    ).firstMatch(html);
    if (a == null || b == null || c == null) return null;
    return [a.group(1)!, b.group(1)!, c.group(1)!];
  }

  /// يحسب قيمة كوكي `__test` من الصفحة المعروضة (تُعيد null عند الفشل).
  static String? solveChallenge(String html) {
    final constants = extractConstants(html);
    if (constants == null) return null;
    return _decryptConstants(constants[0], constants[1], constants[2]);
  }

  /// مطابقة «toNumbers»: تحويل سلسلة hex إلى مصفوفة بايتات.
  static Uint8List _toNumbers(String hex) {
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

  /// مطابقة دالة «unpadBytesOut» في aes.js — تُزيل حشوة PKCS7 المبسّطة
  /// فقط عندما يتجاوز حجم الناتج كتلة واحدة (أيضاً 16 بايتً لا تُلمس).
  static Uint8List _unpadBytesOut(Uint8List data) {
    if (data.length <= 16) return data;
    var count = 0;
    var lastValue = -1;
    var i = data.length - 1;
    for (; i >= data.length - 1 - 16 && data[i] <= 16; i--) {
      if (lastValue == -1) lastValue = data[i];
      if (data[i] != lastValue) {
        count = 0;
        break;
      }
      count++;
      if (count == lastValue) break;
    }
    if (count > 0) {
      return Uint8List.sublistView(data, 0, data.length - count);
    }
    return data;
  }

  static String? _decryptConstants(String aHex, String bHex, String cHex) {
    try {
      final key = _toNumbers(aHex);
      final iv = _toNumbers(bHex);
      final ciphertext = _toNumbers(cHex);

      if (key.length != 16 || iv.length != 16 || ciphertext.length % 16 != 0) {
        return null;
      }

      final cipher = CBCBlockCipher(AESEngine());
      cipher.init(false, ParametersWithIV(KeyParameter(key), iv));

      final plaintext = Uint8List(ciphertext.length);
      for (var offset = 0; offset < ciphertext.length; offset += 16) {
        cipher.processBlock(ciphertext, offset, plaintext, offset);
      }

      final unpadded = _unpadBytesOut(plaintext);
      return _toHex(unpadded);
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
