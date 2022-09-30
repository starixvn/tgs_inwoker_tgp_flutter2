import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marquee/marquee.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:api/entity/user_profile.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/home_user_info_view.dart';
import 'package:tgp_flutter2/ui/home/home_view_model.dart';

class HomeWGHK extends StatefulWidget {
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final Function initData;
  final HomeViewModel homeViewModel;
  final GameViewModel gameViewModel;
  final String? language;
  final int? randomNumber;
  final Widget gameView;

  HomeWGHK({
    this.onPauseBgMusic,
    this.onResumeBgMusic,
    required this.initData,
    required this.homeViewModel,
    required this.gameViewModel,
    this.language,
    this.randomNumber,
    required this.gameView,
  });

  @override
  _HomeWGHKState createState() => _HomeWGHKState();
}

class _HomeWGHKState extends BaseState<HomeWGHK> {
  UserProfile? user;

  //var widget.gameViewModel = GameViewModel();
  var languageCode;

  @override
  void initState() {
    getLanguage();
    super.initState();
  }

  getLanguage() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    languageCode =
        _prefs.getString("LANGUAGE_CODE") ?? EnvironmentConfig.default_lang;
  }

  _buildButton() => Container(
        child: Positioned(
          child: Container(
            height: 50,
            width: 200,
            margin: EdgeInsets.only(
                left: 10.auto, right: 10.auto, top: 15.auto, bottom: 75.auto),
            child: ColorButton(
              title: getTranslatedText("loginregister"),
              onClick: () {
                Navigator.of(context).pushNamed("/login");
              },
              isEnabled: true,
              //rgb(255, 153, 0) color
              color: Color(0xFFFF9900),

              radius: 9.6,
            ),
          ),
        ),
      );

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.theme_button_color,
      body: SafeArea(
        top: true,
        child: Container(
            height: context.screenHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("images/homepage/wghk/background.png"),
                  fit: BoxFit.cover),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //empty container that takes hgalf of the screen
                Container(
                  height: context.screenHeight / 2,
                  width: double.infinity,
                ),

                _buildButton(),
              ],
            )),
      ),
    );
  }
}
