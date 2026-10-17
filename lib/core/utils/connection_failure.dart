import 'dart:io';

import 'package:dio/dio.dart';

/// كاشف موحّد لفشل الاتصال بالشبكة — مصدر واحد يُستخدم في كل طبقات التطبيق
/// (ApiService, AppFailure, GitHub Update Provider) لتفادي تكرار المنطق.
///
/// الانقطاع الحقيقي يُرمى كـ `DioExceptionType.connectionError` مع
/// `SocketException`، لكن فشل مصافحة TLS أو شبكة بلا إنترنت أو بوابة
/// وسيطة يُرمى كـ `DioExceptionType.unknown` مع `HandshakeException`
/// (من عائلة IOException وليست SocketException) — لذا نوسع الكشف
/// ليشمل كل صور فشل الاتصال الشائعة.
class ConnectionFailureDetector {
  const ConnectionFailureDetector._();

  /// هل خطأ Dio ناتج عن انقطاع/ضعف الاتصال بالشبكة؟
  static bool isConnectionFailure(DioException e) {
    if (e.type == DioExceptionType.connectionError) return true;

    final error = e.error;
    if (error is SocketException ||
        error is HandshakeException ||
        error is HttpException ||
        error is OSError ||
        error is IOException) {
      return true;
    }

    if (e.type == DioExceptionType.unknown) {
      final text = error.toString().toLowerCase();
      const keywords = [
        'socket',
        'handshake',
        'connection failed',
        'connection closed',
        'connection refused',
        'failed host lookup',
        'unable to resolve host',
        'network is unreachable',
        'no route to host',
      ];
      return keywords.any(text.contains);
    }

    return false;
  }
}
