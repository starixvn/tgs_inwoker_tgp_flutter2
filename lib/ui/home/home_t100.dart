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
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/home_user_info_view.dart';
import 'package:tgp_flutter2/ui/home/home_view_model.dart';

class HomeT100 extends StatefulWidget {
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final Function initData;
  final HomeViewModel homeViewModel;
  final GameViewModel gameViewModel;
  final String? language;
  final int? randomNumber;
  final Widget gameView;

  HomeT100({
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
  _HomeT100State createState() => _HomeT100State();
}

class _HomeT100State extends BaseState<HomeT100> {
  List<String> imgList = [
    '1',
    '2',
    //'images/banner_2.jpg'
  ];
  String marquee =
      "《GD真人维护公告》GD真人将于 7 月 2 8 日 09:00 至 14:00 进行维护 维护期间不提供游戏相关服务。若有问题欢迎与在线客服联系 如有问题欢迎与在线客服联系，谢谢";
  ScrollController controller = ScrollController();
  var currentTabIndex = "0";
  UserProfile? user;
  var currentBottomIndex = 0;
  var isMenu = false;

  var itemHeightRatio = 335 / 90;

  //var widget.homeViewModel = HomeViewModel();
  CarouselController carouselController = CarouselController();

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

  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildMarqueeRow(),
          HomeUserInfoView(
            userProfile: widget.homeViewModel.userProfile,
            wallet: widget.homeViewModel.totalBalance,
            onLoginTap: () => navigateToLogin(),
            onRefreshHomePage: () => widget.initData(),
            randomNumber: widget.randomNumber,
            forWGHK: true,
          ),
        ],
      ),
    );
  }

  _buildMarqueeRow() => Container(
        width: context.screenWidth,
        padding: EdgeInsets.only(left: 10.auto, top: 10.auto),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                width: context.screenWidth,
                child: Expanded(
                  child: SvgPicture.asset(
                    "images/home/ic_marquee.svg",
                    height: 15.auto,
                    color: CustomColor.theme_button_color,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 11,
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

  _removeMultiLine(String text) {
    return text.replaceAll("\n", " ");
  }
}
