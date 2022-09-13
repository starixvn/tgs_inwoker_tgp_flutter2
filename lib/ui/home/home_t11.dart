import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_svg/svg.dart';
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
import 'package:tgp_flutter2/ui/home/jackpot/jackpot.dart';

class HomeT11 extends StatefulWidget {
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final Function initData;
  final HomeViewModel homeViewModel;
  final GameViewModel gameViewModel;
  final String? language;
  final int? randomNumber;
  final Widget gameView;

  HomeT11({
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
  _HomeT11State createState() => _HomeT11State();
}

class _HomeT11State extends BaseState<HomeT11> {
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
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/t11_bg/game_bg.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        children: [
          _buildImageSlider(),
          !(widget.homeViewModel.config?.hideMarquee ?? false)
              ? _buildTextMarquee()
              : SizedBox(
                  height: 10.auto,
                ),
          widget.gameView,
        ],
      ),
    );
  }

  _buildTextMarquee() {
    var announcement = _removeMultiLine(
        parseHtmlString(widget.homeViewModel.announcement ?? ""));
    return Container(
      padding: EdgeInsets.only(top: 5.auto, bottom: 5.auto),
      margin: EdgeInsets.only(top: 5.auto),
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: SvgPicture.asset(
              "images/home/ic_marquee.svg",
              height: 15.auto,
              color: CustomColor.announcement_icon_color,
            ),
          ),
          Expanded(
            flex: _getNoticeFlex(),
            child: Container(
              child: Text(
                getTranslatedText("notice"),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: CustomColor.theme_text_black_white_color,
                  fontSize: 11.auto,
                ),
                /* maxFontSize: 12,
                minFontSize: 5,*/
                maxLines: 1,
                //stepGranularity: 1,
              ),
            ),
          ),
          Expanded(
              flex: 8,
              child: Container(
                decoration: BoxDecoration(
                    color: CustomColor.theme_button_color.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10.0)),
                margin: EdgeInsets.symmetric(horizontal: 8.auto),
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
              ))
        ],
      ),
    );
  }

  _getNoticeFlex() {
    if ((languageCode?.contains("zh") ?? false))
      return 1;
    else if (languageCode == "th-TH" || languageCode == "vi-VN")
      return 2;
    else
      return 3;
  }

  _buildBorderCorner() => Positioned(
        top: context.screenHeight / 5.2,
        child: Container(
          width: context.screenWidth,
          height: context.screenHeight,
          decoration: BoxDecoration(
              color: Color(0xff181f24),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              )),
        ),
      );

  _buildImageSlider() {
    String brand = EnvironmentConfig.appTitleName == "PG Gaming"
        ? "PGG"
        : EnvironmentConfig.appTitleName;
    return Container(
      height: context.screenHeight / 5,
      child: widget.homeViewModel.bannerList == null ||
              widget.homeViewModel.bannerList!.isEmpty
          ? buildEmptyContainer()
          : ImageSlideshow(
              initialPage: 0,
              indicatorColor: CustomColor.theme_bar_gradient_2,
              indicatorBackgroundColor: Colors.grey,
              children: List.generate(
                  widget.homeViewModel.bannerList!.length,
                  (index) =>
                      widget.homeViewModel.bannerList![index].mobileUrl == null
                          ? buildEmptyContainer()
                          : CachedNetworkImage(
                              placeholder: (context, url) =>
                                  buildEmptyContainer(),
                              imageUrl: widget
                                  .homeViewModel.bannerList![index].mobileUrl!,
                              //handling error
                              fit: BoxFit.fill,
                              errorWidget: (context, url, error) =>
                                  buildEmptyContainer(),
                            )),
              isLoop: true,
              autoPlayInterval: 3000),
    );
  }

  _removeMultiLine(String text) {
    return text.replaceAll("\n", " ");
  }
}
