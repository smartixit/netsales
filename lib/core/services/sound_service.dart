import 'package:audioplayers/audioplayers.dart';

/// ============================================================================
/// خدمة المؤثرات الصوتية والتنبيهات المخصصة (Custom Sound Service)
/// ============================================================================
/// مسؤولة عن إدارة وتشغيل الأصوات والتنبيهات المميزة لنظام NetSales.
/// تدعم البث عبر مجرى المنبه (STREAM_ALARM) لتجاوز الوضع الصامت والهزاز،
/// وجلسة صوت Playback لنظام iOS للعمل عبر مكبر الصوت حتى في وضع الصامت.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  final AudioPlayer _player = AudioPlayer();

  /// تشغيل الصوت المخصص
  ///
  /// [soundPath]: مسار ملف الصوت داخل assets/sounds (افتراضياً: 'sounds/netsales_notification.wav')
  /// [usageType]: نوع الاستخدام لأندرويد (افتراضياً: [AndroidUsageType.alarm] لتجاوز الصامت والهزاز)
  /// [volume]: مستوى الصوت (افتراضياً: 1.0 أقصى صوت)
  Future<void> playSound({
    String soundPath = 'sounds/netsales_notification.wav',
    AndroidUsageType usageType = AndroidUsageType.alarm,
    double volume = 1.0,
  }) async {
    try {
      await _player.stop();
      await _player.setVolume(volume.clamp(0.0, 1.0));
      await _player.play(
        AssetSource(soundPath),
        volume: volume.clamp(0.0, 1.0),
        ctx: AudioContext(
          android: AudioContextAndroid(
            usageType: usageType,
            contentType: AndroidContentType.sonification,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
            isSpeakerphoneOn: true,
            stayAwake: true,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {
              AVAudioSessionOptions.mixWithOthers,
              AVAudioSessionOptions.duckOthers,
            },
          ),
        ),
      );
    } catch (_) {}
  }

  void dispose() {
    _player.dispose();
  }
}
