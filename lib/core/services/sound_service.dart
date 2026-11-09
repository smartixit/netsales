import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// ============================================================================
/// خدمة المؤثرات الصوتية والتنبيهات المخصصة (Custom Sound Service)
/// ============================================================================
/// مسؤولة عن إدارة وتشغيل الأصوات والتنبيهات المميزة لنظام NetSales.
/// تعتمد على حزمة [just_audio] مع دعم أصيل لكافة المنصات بما فيها Windows عبر
/// [just_audio_windows] دون أي اعتماديات خارجية على NuGet.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  final AudioPlayer _player = AudioPlayer();

  /// تشغيل الصوت المخصص
  ///
  /// [soundPath]: مسار ملف الصوت (مثلاً: 'assets/sounds/netsales_notification.wav' أو 'sounds/netsales_notification.wav')
  /// [volume]: مستوى الصوت من 0.0 إلى 1.0 (افتراضياً: 1.0)
  Future<void> playSound({
    String soundPath = 'assets/sounds/netsales_notification.wav',
    double volume = 1.0,
  }) async {
    try {
      final assetKey = soundPath.startsWith('assets/')
          ? soundPath
          : 'assets/$soundPath';
      if (_player.playing) {
        await _player.stop();
      }
      await _player.setAsset(assetKey);
      await _player.setVolume(volume.clamp(0.0, 1.0));
      await _player.play();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        log('SoundService.playSound failed: $e', stackTrace: stackTrace);
      }
    }
  }

  void dispose() {
    _player.dispose();
  }
}
