import 'package:audioplayers/audioplayers.dart';

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playSound({
    String soundPath = 'sounds/success.mp3',
    AndroidUsageType usageType = AndroidUsageType.notification,
  }) async {
    try {
      await _player.stop();
      await _player.play(
        AssetSource(soundPath),
        ctx: AudioContext(
          android: AudioContextAndroid(
            usageType: usageType,
            contentType: AndroidContentType.sonification,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );
    } catch (_) {}
  }

  void dispose() {
    _player.dispose();
  }
}
