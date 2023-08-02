import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'environment_config.dart';

enum AssetPlayerStatus { leavePagePause, manualClickPause, normal, returnHome }

class GlobalValueUtil {
  static AssetPlayerStatus playerStatus = AssetPlayerStatus.normal;

  static AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer.newPlayer();

  static String languageCode = "";

  static void playsong() async {
    if (playerStatus != AssetPlayerStatus.manualClickPause) await assetsAudioPlayer.play();
  }

  static void pausesong() async {
    await assetsAudioPlayer.pause();
  }

  static void stopsong() async {
    await assetsAudioPlayer.stop();
  }

  static void updateLanguageCode() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    languageCode = (_prefs.getString("LANGUAGE_CODE") ?? EnvironmentConfig.default_lang);
  }
}
