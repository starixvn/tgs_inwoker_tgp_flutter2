import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:api/entity/user_profile.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
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
    getToken();
    super.initState();
  }

  getLanguage() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    languageCode =
        _prefs.getString("LANGUAGE_CODE") ?? EnvironmentConfig.default_lang;
  }

  var token;

  getToken() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    token = _prefs.getString("auth_token");
  }

  _buildButton() => Container(
        child: Positioned(
          child: Container(
            height: 50,
            width: 200,
            margin: EdgeInsets.only(
                left: 10.auto, right: 10.auto, top: 15.auto, bottom: 75.auto),
            child: ColorButton(
              title: token != null
                  ? getTranslatedText("123")
                  : getTranslatedText("loginregister"),
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
    return Align(
      alignment: Alignment.topLeft,
      child: SafeArea(
        minimum: EdgeInsets.only(top: 30),
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
