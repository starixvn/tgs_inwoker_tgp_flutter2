import 'package:assets_audio_player/assets_audio_player.dart';

enum AssetPlayerStatus { leavePagePause, manualClickPause, normal, returnHome }

class GlobalValueUtil {
  static AssetPlayerStatus playerStatus = AssetPlayerStatus.normal;

  static AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer.newPlayer();

  static void playsong() async {
    await assetsAudioPlayer.play();
  }

  static void pausesong() async {
    await assetsAudioPlayer.pause();
  }

  static void stopsong() async {
    await assetsAudioPlayer.stop();
  }
}
