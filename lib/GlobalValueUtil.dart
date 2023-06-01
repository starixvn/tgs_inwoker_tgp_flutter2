import 'package:assets_audio_player/assets_audio_player.dart';

enum AssetPlayerStatus { leavePagePause, manualClickPause, normal, returnHome }
class GlobalValueUtil {
  static AssetPlayerStatus playerStatus =
      AssetPlayerStatus.normal;

  static AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer.newPlayer();
}