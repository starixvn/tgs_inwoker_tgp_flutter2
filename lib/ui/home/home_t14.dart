import 'package:api/NotificationServices/NotificationServiceName.dart';
import 'package:api/NotificationServices/notification_center.dart';
import 'package:api/entity/game.dart';
import 'package:api/entity/game_type.dart';
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
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/home/game/game_t14/game_item_t14.dart';
import 'package:tgp_flutter2/ui/home/game/game_t14/home_game_t14.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/home_view_model.dart';

import '../../globalUtil/GlobalValueUtil.dart';
import '../../my_behavior.dart';
import '../../provider/provider_widget.dart';
import '../withdraw/withdraw.dart';
import 'child_game/T14/child_game_t14.dart';
import 'game/game_t14/game_t14.dart';

class HomeT14 extends StatefulWidget {
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final Function initData;
  final HomeViewModel homeViewModel;
  final GameViewModel gameViewModel;
  final int? randomNumber;
  final Widget gameView;
  final ValueChanged<bool> updateShowMarquee;

  HomeT14({
    this.onPauseBgMusic,
    this.onResumeBgMusic,
    required this.initData,
    required this.homeViewModel,
    required this.gameViewModel,
    this.randomNumber,
    required this.gameView,
    required this.updateShowMarquee,
  });

  @override
  _HomeT14State createState() => _HomeT14State();
}

class _HomeT14State extends BaseState<HomeT14> {
  List<String> imgList = [
    '1',
    '2',
    //'images/banner_2.jpg'
  ];
  String marquee = "《GD真人维护公告》GD真人将于 7 月 2 8 日 09:00 至 14:00 进行维护 维护期间不提供游戏相关服务。若有问题欢迎与在线客服联系 如有问题欢迎与在线客服联系，谢谢";
  ScrollController controller = ScrollController();
  var currentTabIndex = "0";
  UserProfile? user;
  var currentBottomIndex = 0;
  var isMenu = false;

  var itemHeightRatio = 335 / 90;
  int _current = 0;
  CarouselController carouselController = CarouselController();
  var languageCode;
  var isLogin = false;
  bool isDisplayGameView = false;
  GameType? currGameType;
  String? currGamePlatformCode;

  @override
  void initState() {
    getLanguage();
    _initData();
    super.initState();
  }

  _initData() async {}

  getLanguage() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    languageCode = _prefs.getString("LANGUAGE_CODE") ?? EnvironmentConfig.default_lang;
  }

  Widget build(BuildContext context) {
    return ProviderWidget<GameViewModel>(
        model: widget.gameViewModel,
        builder: (ctx, vm, _) {
          // _handleApiState();
          return Container(
            width: context.screenWidth,
            height: context.screenHeight,
            color: Color(0xff000325),
            child: ScrollConfiguration(
                behavior: MyBehavior(),
                child: CustomScrollView(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        height: context.screenHeight / 12,
                        width: context.screenWidth,
                        child: ScrollConfiguration(
                          behavior: MyBehavior(),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            children: List.generate(widget.gameViewModel.gameTypeList.length, (index) {
                              var gameType = widget.gameViewModel.gameTypeList[index];
                              return _buildGameTab(index, gameType);
                            }),
                          ),
                        ),
                      ),
                    ),
                  ]..addAll(_getWidgetList()),
                )),
          );
        });
  }

  List<Widget> _getWidgetList() {
    if (!isDisplayGameView)
      return [
        _buildImageSlider(),
        _buildUserInfoContainer(),
        SliverToBoxAdapter(
          // hasScrollBody: false,
          //  fillOverscroll: true,
          child: HomeGameT14(
            onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
            onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
            vm: widget.gameViewModel,
            onRefreshHomePage: () {},
            onGameClick: (gameProvider) {},
          ),
        ),
      ];
    else {
      return [
        SliverFillRemaining(
          child: currGameType == GameType.Slot
              ? ChildGameT14(
                  onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                  onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                  vm: widget.gameViewModel,
                  gameType: currGameType,
                  gamePlatformCode: currGamePlatformCode,
                )
              : GameT14(
                  currGameType: currGameType ?? GameType.Slot,
                  onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                  onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                  vm: widget.gameViewModel,
                  onRefreshHomePage: () {},
                  onGameClick: (gameProvider) {},
                  onClickGameTab: (bool value) {},
                  onClickChildGame: (Game value) {},
                ),
        )
      ];
    }
  }

  _buildOnlineUserText() => Container(
        padding: EdgeInsets.all(5),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SvgPicture.asset(
              "images/bottom_nav_bar/ic_profile.svg",
              width: 10.auto,
              color: Colors.white,
            ),
            SizedBox(width: 5),
            Container(
              child: Text(
                (widget.randomNumber ?? 26500).toString(),
                style: TextStyle(fontSize: 10.auto, color: Colors.white),
              ),
            ),
          ],
        ),
      );

  _buildTextMarquee() {
    var announcement = widget.homeViewModel.announcement;
    return Expanded(
      flex: 2,
      child: announcement.isEmpty
          ? Container()
          : Container(
              // decoration: BoxDecoration(color: CustomColor.theme_bar_gradient_1, borderRadius: BorderRadius.circular(10.0)),
              margin: EdgeInsets.only(left: 3.auto, right: 10.auto),
              height: 18.auto,
              child: Marquee(
                text: announcement,
                style: TextStyle(
                  color: CustomColor.theme_text_black_white_color,
                  fontSize: 10.auto,
                ),
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                blankSpace: 300.auto,
                pauseAfterRound: Duration(seconds: 1),
                showFadingOnlyWhenScrolling: false,
              ),
            ),
    );
  }

  _buildUserInfoContainer() {
    return SliverToBoxAdapter(
      child: Container(
        height: context.screenHeight / 7.5,
        color: Color(0xff181c42),
        child: Column(
          children: [
            Row(
              children: [
                _buildTextMarquee(),
                _buildOnlineUserText(),
              ],
            ),
            Expanded(
              flex: 8,
              child: Container(
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: widget.homeViewModel.userProfile == null ? 10 : 30),
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              widget.homeViewModel.userProfile == null
                                  ? getTranslatedText("home_login_hint")
                                  : "Hi, ${widget.homeViewModel.userProfile.username ?? ""}",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )),
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.center,
                        color: Color(0xff242958),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                flex: 1,
                                child: InkWell(
                                    onTap: () {
                                      NotificationCenter().notify(NotificationServiceName().bottomNavigationIndex, data: 2);
                                    },
                                    child: _buildIconWithText("home/T14/deposit", getTranslatedText("deposit")))),
                            Expanded(
                                flex: 1,
                                child: InkWell(
                                    onTap: () {
                                      NotificationCenter().notify(
                                        NotificationServiceName().showDialogViewToHome,
                                        data: {"view": Withdraw(), "title": getTranslatedText("withdrawal")},
                                      );
                                      NotificationCenter().notifyWidget(NotificationServiceName().appBarTitle, getTranslatedText("withdrawal"));
                                    },
                                    child: _buildIconWithText("home/T14/withdrawal", getTranslatedText("withdrawal")))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildGameTab(int tabIndex, GameType gameType) {
    return InkWell(
      onTap: () {
        setState(() {
          if (isDisplayGameView) {
            if (currGameType == gameType) {
              isDisplayGameView = false;
              currGameType = null;
            } else
              currGameType = gameType;
          } else {
            isDisplayGameView = true;
            currGameType = gameType;
          }
          // if (!isDisplayGameView  && currGameType==gameType) {
          //   isDisplayGameView = !isDisplayGameView;
          //   currGameType = null;
          // } else
          //
          //   currGameType=gameType;
        });
        widget.updateShowMarquee(isDisplayGameView);
      },
      child: Container(
          width: context.screenWidth / 4,
          // padding: EdgeInsets.symmetric(vertical: 10.auto),
          child: _buildIconWithText(
              "game_tab/t14/ic_${gameType.getImagePath()}", gameType.getName(context, widget.gameViewModel.config?.menuItemShootFish ?? false))),
    );
  }

  _buildIconWithText(String iconPath, String title) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 20.auto,
            width: 20.auto,
            child: SvgPicture.asset(
              "images/$iconPath.svg",
              color: CustomColor.theme_button_color,
            ),
          ),
          SizedBox(height: 5),
          AutoSizeText(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CustomColor.theme_button_color,
            ),
            minFontSize: 2,
            maxFontSize: 12,
            stepGranularity: 1,
            maxLines: 2,
          ),
        ],
      );

  _buildImageSlider() => SliverToBoxAdapter(
        child: Container(
          height: context.screenHeight / 6.5,
          child: widget.homeViewModel.bannerList == null || widget.homeViewModel.bannerList!.isEmpty
              ? buildEmptyContainer(borderRadius: 0)
              : ImageSlideshow(
                  initialPage: 0,
                  indicatorColor: Colors.transparent,
                  indicatorBackgroundColor: Colors.transparent,
                  children: List.generate(
                      widget.homeViewModel.bannerList!.length,
                      (index) => widget.homeViewModel.bannerList![index].mobileUrl == null
                          ? buildEmptyContainer(borderRadius: 20)
                          : ClipRRect(
                              // borderRadius: BorderRadius.all(Radius.circular(20)),
                              child: CachedNetworkImage(
                                placeholder: (context, url) => buildEmptyContainer(borderRadius: 0),
                                imageUrl: widget.homeViewModel.bannerList![index].mobileUrl!,
                                //handling error
                                fit: BoxFit.fill,
                                errorWidget: (context, url, error) => buildEmptyContainer(borderRadius: 0),
                              ),
                            )),
                  isLoop: true,
                  autoPlayInterval: 3000),
        ),
      );

  _getBalanceDescView() => Container(
      margin: EdgeInsets.only(left: 5.auto, top: 7.auto),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLogin ? (widget.homeViewModel.userProfile.username ?? "") : getTranslatedText("home_login_hint2"),
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
                      widget.homeViewModel.totalBalance != null ? Format().amountFormat(widget.homeViewModel.totalBalance ?? 0) : "-",
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
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  stepGranularity: 1,
                ),
              ),
            ],
          ),
        ),
      ));

  _getNoticeFlex() {
    if ((languageCode?.contains("zh") ?? false))
      return 1;
    else if (languageCode == "th-TH" || languageCode == "vi-VN")
      return 2;
    else
      return 4;
  }

  _checkDisableMusic() {
    if (EnvironmentConfig.template_version == 15 && widget.onPauseBgMusic != null) {
      if (GlobalValueUtil.playerStatus != AssetPlayerStatus.manualClickPause) {
        widget.onPauseBgMusic!();
        GlobalValueUtil.playerStatus = AssetPlayerStatus.leavePagePause;
      }
    }
  }
}
