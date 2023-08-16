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
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/home_view_model.dart';
import 'dart:math' as math;

import '../../globalUtil/GlobalValueUtil.dart';
import '../deposit/deposit.dart';
import '../withdraw/withdraw.dart';

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

class _HomeT15State extends BaseState<HomeT15> with SingleTickerProviderStateMixin implements RouteAware {
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
  var isLogin = false;
  late AnimationController _controller;
  late CurvedAnimation _animation;
  var isClickAnimate = false;

  @override
  void initState() {
    isLogin = widget.homeViewModel.userProfile != null;
    if (widget.onResumeBgMusic != null) widget.onResumeBgMusic!();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = new CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
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
      );

  _buildTextMarquee() {
    var announcement = widget.homeViewModel.announcement;
    return Container(
        height: 80.auto,
        padding: EdgeInsets.only(top: 0.auto, bottom: 5.auto),
        child: Column(
          children: [
            Expanded(
              flex: 0,
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
              flex: 1,
              child: Row(
                children: [
                  Expanded(child: _getBalanceDescView()),
                  Container(
                      margin: EdgeInsets.only(right: 5.auto),
                      width: 180,
                      child: Row(children: [
                        Expanded(child: _getWalletView("deposit", getTranslatedText("deposit"), RoutePath.deposit)),
                        Expanded(child: _getWalletView("account_report", getTranslatedText("withdrawal"), RoutePath.withdraw)),
                        if ((widget.homeViewModel.config.haveVIPFeature ?? true) && (widget.homeViewModel.config.homePageDisplayVIP ?? true))
                          Expanded(child: _getWalletView("deposit", "VIP", RoutePath.vip)),
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isLogin
            ? [
                Wrap(
                  children: [
                    Text(
                      (widget.homeViewModel.userProfile.username ?? ""),
                      style: TextStyle(
                        color: EnvironmentConfig.light_mode ? CustomColor.theme_button_color : CustomColor.theme_app_bar_text_color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.auto,
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.auto),
                      decoration: BoxDecoration(color: Color(0xffceb296), borderRadius: BorderRadius.all(Radius.circular(2.5))),
                      child: Text(
                        "VIP ${(widget.homeViewModel.userProfile.vipLevel ?? "")}",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      widget.homeViewModel.totalBalance != null ? Format().amountFormat(widget.homeViewModel.totalBalance ?? 0) : "-",
                      style: TextStyle(
                        color: CustomColor.theme_button_color,
                        fontWeight: FontWeight.normal,
                        fontSize: 15.auto,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(width: 10),
                    InkWell(
                      onTap: () async {
                        widget.homeViewModel.getUserDetails();
                        if (!isClickAnimate) _controller.repeat();
                        setState(() {
                          isClickAnimate = true;
                        });
                        await Future.delayed(Duration(seconds: 2), () {
                          _controller.stop();
                          setState(() {
                            isClickAnimate = false;
                          });
                        });
                      },
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (_, child) {
                          return Transform.rotate(
                            angle: _controller.value * 2 * math.pi,
                            child: child,
                          );
                        },
                        child: SvgPicture.asset(
                          "images/home/T15/refresh.svg",
                          height: 13.auto,
                          color: EnvironmentConfig.light_mode ? Color(0xff7d7d7f) : CustomColor.announcement_icon_color,
                        ),
                      ),

                      // RotationTransition(
                      //   turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                      //   child: SvgPicture.asset(
                      //     "images/home/T15/refresh.svg",
                      //     height: 13.auto,
                      //     color: EnvironmentConfig.light_mode ? Color(0xff7d7d7f) : CustomColor.announcement_icon_color,
                      //   ),
                      // ),
                    ),
                  ],
                )
              ]
            : [
                Text(
                  getTranslatedText("home_login_hint2"),
                  style: TextStyle(
                    color: EnvironmentConfig.light_mode ? Colors.black : CustomColor.theme_app_bar_text_color,
                    fontWeight: EnvironmentConfig.light_mode ? FontWeight.normal : FontWeight.bold,
                    fontSize: 14.auto,
                  ),
                ),
                InkWell(
                  onTap: () {
                    showPreLoginDialog();
                  },
                  child: Text(
                    getTranslatedText("home_login_hint3"),
                    style: TextStyle(
                      color: EnvironmentConfig.light_mode ? Color(0xff9aa4c2) : CustomColor.theme_app_bar_text_color,
                      fontWeight: FontWeight.normal,
                      fontSize: 14.auto,
                    ),
                  ),
                )
              ],
      ));

  _getWalletView(String imagePath, String typeName, String path) => Container(
          // margin: EdgeInsets.only(right: 5),
          child: InkWell(
        onTap: () {
          if (!isLogin) {
            showPreLoginDialog();
          } else {
            _checkDisableMusic();
            if (path == RoutePath.deposit) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Deposit(isNewPage: true)));
            } else if (path == RoutePath.withdraw) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Withdraw(isNewPage: true)));
            } else
              Navigator.pushNamed(context, RoutePath.vip);
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
                  imagePath == "deposit" ? "images/home/T15/$imagePath.png" : "images/profile/t15_light/ic_$imagePath.png",
                  matchTextDirection: true,
                  height: 30.auto,
                ),
              ),
              Expanded(
                flex: 1,
                child: AutoSizeText(
                  typeName,
                  style: TextStyle(color: EnvironmentConfig.light_mode ? CustomColor.theme_app_bar_text_color : CustomColor.theme_button_color),
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

  _checkDisableMusic() {
    if (EnvironmentConfig.template_version == 15 && widget.onPauseBgMusic != null) {
      if (GlobalValueUtil.playerStatus != AssetPlayerStatus.manualClickPause) {
        widget.onPauseBgMusic!();
        GlobalValueUtil.playerStatus = AssetPlayerStatus.leavePagePause;
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
