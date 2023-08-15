import 'package:api/entity/brand_logo.dart';
import 'package:api/entity/env_features_config.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:shared_preferences/shared_preferences.dart';

import '../environment_config.dart';

enum AssetPlayerStatus { leavePagePause, manualClickPause, normal, returnHome }

enum BottomNavigationIcon { home, promotion, wallet, cs, profile, deposit, withdraw }

class GlobalValueUtil {
   // static GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  static AssetPlayerStatus playerStatus = AssetPlayerStatus.normal;

  static AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer.newPlayer();

  static double? totalBalance;
  static String? phone;

  static EnvFeaturesConfig? featuresConfig;
  static BrandLogo? brandLogo;

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

  static String removeMultiLine(String text) {
    return text.replaceAll("\n", " ");
  }

  static String parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString = parse(document.body?.text).documentElement!.text;
    return parsedString;
  }

  static Size calculateTextSize({
    required String text,
    required TextStyle style,
    required BuildContext context,
  }) {
    final double textScaleFactor = context != null ? MediaQuery.of(context).textScaleFactor : WidgetsBinding.instance.window.textScaleFactor;

    final TextDirection textDirection = context != null ? Directionality.of(context) : TextDirection.ltr;

    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      textScaleFactor: textScaleFactor,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    return textPainter.size;
  }

  static double calculateFontSizeForLongestString(List<String> textList, double fixedFontSize, double containerWidth) {
    double longestTextWidth = 0.0;
    for (String text in textList) {
      final TextSpan textSpan = TextSpan(text: text, style: TextStyle(fontSize: fixedFontSize));
      final TextPainter textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        maxLines: countSpace(text, " "),
      )..layout();

      final double textWidth = textPainter.width;
      if (textWidth > longestTextWidth) {
        longestTextWidth = textWidth;
      }
    }

    // Calculate the font size needed for the longest string to fit in the container.
    double fontSizeForLongestString = containerWidth / longestTextWidth * fixedFontSize;

    return fontSizeForLongestString;
  }

  static int countSpace(String text, String letter) {
    int count = 0;
    for (int i = 0; i < text.length; i++) {
      if (text[i] == letter) {
        count++;
      }
    }
    return count==0?1:count;
  }

  static void updateTotalBalance(double balance) {
    totalBalance = balance;
  }

  static void updateLanguageCode() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    languageCode = (_prefs.getString("LANGUAGE_CODE") ?? EnvironmentConfig.default_lang);
  }

}
