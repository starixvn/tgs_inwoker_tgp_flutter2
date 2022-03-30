import 'package:api/entity/game_type.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:marquee/marquee.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:api/entity/user_profile.dart';
import 'package:tgp_flutter2/custom/custom_login_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/main.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/home/game/game_t1/game_t1.dart';
import 'package:tgp_flutter2/ui/home/game/game_t2/game_t2.dart';
import 'package:tgp_flutter2/ui/home/game/game_t8/game_t8.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/home_view_model.dart';
import 'dart:math';

class HomeT8Dark extends StatefulWidget {
  final bool isFirstRun;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;

  HomeT8Dark({this.isFirstRun = false, this.onPauseBgMusic, this.onResumeBgMusic});

  @override
  _HomeT8DarkState createState() => _HomeT8DarkState();
}

class _HomeT8DarkState extends BaseState<HomeT8Dark> {
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
  var _vm = HomeViewModel();
  int _current = 0;
  CarouselController carouselController = CarouselController();
  var languageCode;
  var _gameViewModel = GameViewModel();
  var randomNumber;
  var _assetsAudioPlayer;

  @override
  void initState() {
    _initData();

    super.initState();
  }

  _initData() async {
    _vm.getAnnouncement();
    _vm.getBanner();

    _vm.getBrandCommunication();
    await _gameViewModel.getGameProviderList(isRefresh: true);
    getLanguage();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if ((_vm.config?.popupAnnouncement ?? false) && _vm.firstAnnouncement != null) _displayMarqueeDialog();
    });
    randomNumber = _randomGenerator();
  }

  getLanguage() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    languageCode = _prefs.getString("LANGUAGE_CODE") ?? EnvironmentConfig.default_lang;
  }

  Widget build(BuildContext context) {
    return ProviderWidget<HomeViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: CustomColor.theme_bg_color,
            appBar: CustomLoginAppBar(
              onClickLoginButton: () {
                Navigator.of(context).pushNamed(RoutePath.login);
              },
              onClickRegisterButton: () {
                Navigator.of(context).pushNamed(RoutePath.register);
              },
              onClickLogoutButton: () {
                _logout();
              },
              isLogin: _vm.userProfile != null,
              brandLogoUrl: _vm.brandLogoUrl,
              userProfile: _vm.userProfile,
              phone: _vm.phone,
              config: _vm.config,
              totalBalance: _vm.totalBalance,
              brandName: EnvironmentConfig.brandName,
            ),
            body: Column(
              children: [
                Expanded(flex:1,child: _buildImageSlider(),),
                Expanded(
                  flex:3,
                  child: Container(
                    margin: EdgeInsets.only(top: 10.auto, left: 10.auto, right: 10.auto),
                    child: Column(
                      children: [
                        _buildTextMarquee(),
                        _buildGameView(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  _buildImageSlider() => Container(
        height: context.screenHeight / 5,
        child: _vm.bannerList == null || _vm.bannerList!.isEmpty
            ? _buildEmptyContainer()
            : ImageSlideshow(
                initialPage: 0,
                indicatorColor: Colors.transparent,
                indicatorBackgroundColor: Colors.transparent,
                children: List.generate(
                    _vm.bannerList!.length,
                    (index) => _vm.bannerList![index].mobileUrl == null
                        ? _buildEmptyContainer()
                        : CachedNetworkImage(
                            placeholder: (context, url) => _buildEmptyContainer(),
                            imageUrl: _vm.bannerList![index].mobileUrl!,
                            //handling error
                            fit: BoxFit.fill,
                            errorWidget: (context, url, error) => _buildEmptyContainer(),
                          )),
                isLoop: true,
                autoPlayInterval: 3000),
      );

  _buildEmptyContainer() => Container(
        color: CustomColor.very_light_pink_four,
      );

  _buildTextMarquee() {
    var announcement = _removeMultiLine(parseHtmlString(_vm.announcement ?? ""));
    return Container(
      padding: EdgeInsets.only(top: 3.auto, bottom: 5.auto),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_vm.config?.onlineUser ?? false)
            Expanded(
              flex: (languageCode?.contains("zh") ?? false) ? 2 : 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslatedText("online_user") + " :",
                    style: TextStyle(fontSize: 10.auto),
                  ),
                  Container(
                    child: Text(
                      (randomNumber ?? 26500).toString(),
                      style: TextStyle(fontSize: 10.auto),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            flex: 1,
            child: SvgPicture.asset(
              "images/home/ic_marquee.svg",
              height: 15.auto,
              color: CustomColor.theme_button_color,
            ),
          ),
          Expanded(
            flex: _getNoticeFlex(),
            child: Container(
              // width: (languageCode?.contains("zh") ?? false) ? context.screenWidth / 10 : context.screenWidth / 5,
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
              flex: 7,
              child: handleNullWidget(
                announcement.isEmpty,
                Container(
                  // decoration: BoxDecoration(color: CustomColor.theme_bar_gradient_1, borderRadius: BorderRadius.circular(10.0)),
                  margin: EdgeInsets.only(left: 10.auto, right: 10.auto),
                  height: 18.auto,
                  child: Marquee(
                      text: announcement,
                      style: TextStyle(
                        color: CustomColor.theme_text_grey_color,
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
    );
  }

  _getNoticeFlex() {
    if ((languageCode?.contains("zh") ?? false))
      return 1;
    else if (languageCode == "th-TH" || languageCode == "vi-VN")
      return 2;
    else
      return 4;
  }

  _removeMultiLine(String text) {
    return text.replaceAll("\n", " ");
  }

  _buildGameView() => GameT8(
        vm: _gameViewModel,
        onRefreshHomePage: () => _initData(),
        onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
        onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
      );

  navigateToLogin() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(RoutePath.login);
    });
  }

  _displayLoginDialog() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var loginLater = prefs.getBool("login_later") ?? false;
    if (_vm.userProfile == null && !loginLater) {
      showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          title: getTranslatedText("login_expired"),
          description: getTranslatedText("login_again"),
          buttonText1: getTranslatedText("login"),
          buttonText2: getTranslatedText("no"),
          onClick: this.navigateToLogin,
          onClick2: () {
            prefs.setBool("login_later", true);
            Navigator.pop(context);
          },
        ),
      );
    }
  }

  _logout() {
    ProgressDialog.show(context, _vm.brandLogoUrl);
    _vm.logout();
  }

  _displayMarqueeDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: (_vm.firstAnnouncement?.localization?.subject ?? _vm.firstAnnouncement?.subject),
        description: (_vm.firstAnnouncement?.localization?.content ?? _vm.firstAnnouncement?.content),
        buttonText1: getTranslatedText("confirm"),
        onClick: () => Navigator.of(context).pop(),
      ),
    );
  }

  _randomGenerator() {
    Random _random = new Random();
    int min = 20000;
    int max = 30000;
    int result = min + _random.nextInt(max - min);
    return result;
  }

  _handleApiState() {
    if (widget.isFirstRun) {
      if (_vm.isNotLogin) {
        navigateToLogin();
        _vm.markIsNotLogin();
      } else if (_vm.isExpired) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          _displayLoginDialog();
        });
      }
    }
    handleApiState(_vm.logoutApiState, isLogoutApiState: true, onSuccess: () {
      ProgressDialog.hide();
    }, onLogout: () {
      ProgressDialog.hide();
    });
    handleApiState(_vm.getBasicInfoApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getAnnouncementApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getBannerApiState, isAutoHideLoading: false, onSuccess: () {});
  }
}
