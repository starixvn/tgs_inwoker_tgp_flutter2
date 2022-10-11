import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marquee/marquee.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:api/entity/user_profile.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
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
              title: token == null
                  ? getTranslatedText("loginregister")
                  : getTranslatedText("start_game"),
              onClick: () {
                token == null
                    ? Navigator.of(context).pushNamed("/login")
                    : Navigator.of(context).pushNamed("/login");
              },
              isEnabled: true,
              //rgb(255, 153, 0) color
              color: Color(0xFFFF9900),

              radius: 9.6,
            ),
          ),
        ),
      );

  _removeMultiLine(String text) {
    return text.replaceAll("\n", " ");
  }

  _buildMarqueeRow() => Container(
        width: context.screenWidth,
        color: Colors.white,
        padding: EdgeInsets.only(left: 10.auto, top: 15.auto, bottom: 8.auto),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: SvgPicture.asset(
                "images/home/ic_marquee.svg",
                height: 15.auto,
                color: CustomColor.theme_button_color,
              ),
            ),
            Expanded(
              flex: 13,
              child: _buildTextMarquee(),
            )
          ],
        ),
      );

  _buildTextMarquee() {
    var announcement = _removeMultiLine(
        parseHtmlString(widget.homeViewModel.announcement ?? ""));
    return Container(
      decoration: BoxDecoration(
          color: CustomColor.theme_button_color,
          borderRadius: BorderRadius.circular(10.0)),
      margin: EdgeInsets.only(right: 10.auto),
      height: 18.auto,
      child: announcement.isEmpty
          ? Container()
          : Marquee(
              text: announcement,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.auto,
              ),
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              blankSpace: 300.auto,
              pauseAfterRound: Duration(seconds: 1),
              showFadingOnlyWhenScrolling: false),
    );
  }

  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SafeArea(
        minimum: EdgeInsets.only(top: 30),
        child: Column(
          children: [
            token == null || token == ""
                ? Container()
                : Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildMarqueeRow(),
                        HomeUserInfoView(
                          userProfile: widget.homeViewModel.userProfile,
                          wallet: widget.homeViewModel.totalBalance,
                          onLoginTap: () => navigateToLogin(),
                          onRefreshHomePage: () => widget.initData(),
                          randomNumber: widget.randomNumber,
                          gapless: true,
                        ),
                      ],
                    ),
                  ),
            Expanded(
              flex: 5,
              child: Container(
                //height based on available screen height
                //height = fit content

                height: context.screenHeight,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/homepage/wghk/background.png"),
                      fit: BoxFit.cover),
                ),
                child: Container(
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
            ),
          ],
        ),
      ),
    );
  }
}
