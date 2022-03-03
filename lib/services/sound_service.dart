import 'package:audioplayers/audioplayers.dart';

class SoundService {
  AudioCache audioCache = AudioCache();
  AudioPlayer? player;
  Future<void> playAlert() async {
    player = await audioCache.loop("sound/alert.mp3");
  }

  Future<void> stopAlert() async {
    await player!.stop();
  }
}
