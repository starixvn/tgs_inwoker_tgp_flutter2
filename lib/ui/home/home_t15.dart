import 'package:api/extension/format.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:tgp_flutter2/ui/home/home_view_model.dart';

import '../../GlobalValueUtil.dart';

class HomeT15 extends StatefulWidget {
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final Function initData;
  final HomeViewModel homeViewModel;
  final GameViewModel gameViewModel;
  final int? randomNumber;
  final Widget gameView;

  HomeT15({
    this.onPauseBgMusic,
    this.onResumeBgMusic,
    required this.initData,
    required this.homeViewModel,
    required this.gameViewModel,
    this.randomNumber,
    required this.gameView,
  });

  @override
  _HomeT15State createState() => _HomeT15State();
}

class _HomeT15State extends BaseState<HomeT15> implements RouteAware {
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
  int _current = 0;
  CarouselController carouselController = CarouselController();
  var isLogin = false;

  @override
  void initState() {
    isLogin = widget.homeViewModel.userProfile != null;
    if (widget.onResumeBgMusic != null) widget.onResumeBgMusic!();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: _buildImageSlider(),
        ),
        Expanded(
          flex: 3,
          child: Container(
            margin: EdgeInsets.only(top: 10.auto, left: 5.auto, right: 5.auto),
            child: Column(
              children: [
                _buildTextMarquee(),
                widget.gameView,
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildImageSlider() => Container(
        height: context.screenHeight / 5,
        child: widget.homeViewModel.bannerList == null ||
                widget.homeViewModel.bannerList!.isEmpty
            ? buildEmptyContainer(borderRadius: 0)
            : ImageSlideshow(
                initialPage: 0,
                indicatorColor: Colors.transparent,
                indicatorBackgroundColor: Colors.transparent,
                children: List.generate(
                    widget.homeViewModel.bannerList!.length,
                    (index) =>
                        widget.homeViewModel.bannerList![index].mobileUrl ==
                                null
                            ? buildEmptyContainer(borderRadius: 20)
                            : ClipRRect(
                                // borderRadius: BorderRadius.all(Radius.circular(20)),
                                child: CachedNetworkImage(
                                  placeholder: (context, url) =>
                                      buildEmptyContainer(borderRadius: 0),
                                  imageUrl: widget.homeViewModel
                                      .bannerList![index].mobileUrl!,
                                  //handling error
                                  fit: BoxFit.fill,
                                  errorWidget: (context, url, error) =>
                                      buildEmptyContainer(borderRadius: 0),
                                ),
                              )),
                isLoop: true,
                autoPlayInterval: 3000),
      );

  _buildTextMarquee() {
    var announcement = _removeMultiLine(
        parseHtmlString(widget.homeViewModel.announcement ?? ""));
    return Container(
        height: 80.auto,
        padding: EdgeInsets.only(top: 0.auto, bottom: 5.auto),
        child: Column(
          children: [
            Expanded(
              flex:0,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SvgPicture.asset(
                      "images/home/T15/announce.svg",
                      height: 21.auto,
                      color: CustomColor.announcement_icon_color,
                    ),
                  ),
                  Expanded(
                      flex: 8,
                      child: handleNullWidget(
                        announcement.isEmpty,
                        Container(
                          // decoration: BoxDecoration(color: CustomColor.theme_bar_gradient_1, borderRadius: BorderRadius.circular(10.0)),
                          margin: EdgeInsets.only(left: 10.auto, right: 10.auto),
                          height: 18.auto,
                          child: Marquee(
                              text: announcement,
                              style: TextStyle(
                                color: CustomColor.theme_marquee_text_color,
                                fontSize: 10.auto,
                              ),
                              scrollAxis: Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              blankSpace: 300.auto,
                              pauseAfterRound: Duration(seconds: 1),
                              showFadingOnlyWhenScrolling: false),
                        ),
                      ))
                ],
              ),
            ),
            Expanded(
              flex:1,
              child: Row(
                children: [
                  Expanded(child: _getBalanceDescView()),
                  Container(
                      margin: EdgeInsets.only(right: 5.auto),
                      width: 120,
                      child: Row(children: [
                        Expanded(
                            child: _getWalletView(getTranslatedText("deposit"), "deposit")),
                        Expanded(
                            child:
                                _getWalletView(getTranslatedText("withdrawal"), "withdraw")),
                      ]))
                ],
              ),
            )
          ],
        ));
  }

  _getBalanceDescView() => Container(
      margin: EdgeInsets.only(left: 5.auto, top: 7.auto),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLogin
                ? (widget.homeViewModel.userProfile.username ?? "")
                : getTranslatedText("home_login_hint2"),
            style: TextStyle(
              color: CustomColor.theme_app_bar_text_color,
              fontWeight: FontWeight.bold,
              fontSize: 14.auto,
            ),
          ),
          !isLogin
              ? InkWell(
                  onTap: () {
                    showPreLoginDialog();
                  },
                  child: Text(
                    getTranslatedText("home_login_hint3"),
                    style: TextStyle(
                      color: CustomColor.theme_app_bar_text_color,
                      fontWeight: FontWeight.normal,
                      fontSize: 14.auto,
                    ),
                  ),
                )
              : Row(
                  children: [
                    Text(
                      widget.homeViewModel.totalBalance != null
                          ? Format().amountFormat(
                              widget.homeViewModel.totalBalance ?? 0)
                          : "-",
                      style: TextStyle(
                        color: CustomColor.theme_app_bar_text_color,
                        fontWeight: FontWeight.normal,
                        fontSize: 14.auto,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    InkWell(
                      onTap: () => widget.homeViewModel.getUserDetails(),
                      child: Container(
                        width: 25.auto,
                        height: 25.auto,
                        // decoration: BoxDecoration(
                        //   borderRadius: BorderRadius.circular(10),
                        //   color: CustomColor.theme_button_color,
                        // ),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(1),
                        child: SvgPicture.asset(
                          "images/home/T15/refresh.svg",
                          height: 18.auto,
                          color: CustomColor.announcement_icon_color,
                        ),
                      ),
                    ),
                  ],
                )
        ],
      ));

  _getWalletView(String typeName, String path) => Container(
          // margin: EdgeInsets.only(right: 5),
          child: InkWell(
        onTap: () {
          if (!isLogin) {
            showPreLoginDialog();
          } else {
            _checkDisableMusic();
            Navigator.of(context).pushNamed("/${path.toLowerCase()}");
          }
        },
        child: Container(
          // width: 45,
          // height: 48.auto,
          alignment: Alignment.center,
          padding: EdgeInsets.all(1),
          child: Column(
            children: [
              Expanded(
                flex: 0,
                child: Image.asset(
                  "images/home/T15/deposit.png",
                  matchTextDirection: true,
                  height: 30.auto,
                ),
              ),
              Expanded(
                flex: 1,
                child: AutoSizeText(
                  typeName,
                  style: TextStyle(color: CustomColor.theme_button_color),
                  minFontSize: 10,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  stepGranularity: 1,
                ),
              ),
            ],
          ),
        ),
      ));

  _removeMultiLine(String text) {
    return text.replaceAll("\n", " ");
  }

  _checkDisableMusic() {
    if (EnvironmentConfig.template_version == 15 && widget.onPauseBgMusic != null) {
      if (GlobalValueUtil.playerStatus != AssetPlayerStatus.manualClickPause) {
        widget.onPauseBgMusic!();
        GlobalValueUtil.playerStatus =
            AssetPlayerStatus.leavePagePause;
      }
    }
  }

  @override
  void didPop() {
    if (GlobalValueUtil.playerStatus != AssetPlayerStatus.manualClickPause && EnvironmentConfig.template_version == 15) {
      if (widget.onResumeBgMusic != null) widget.onResumeBgMusic!();
    }
    // TODO: implement didPop
  }

  @override
  void didPopNext() {
    // TODO: implement didPopNext
  }

  @override
  void didPush() {
    // TODO: implement didPush
  }

  @override
  void didPushNext() {
    // TODO: implement didPushNext
  }
}
