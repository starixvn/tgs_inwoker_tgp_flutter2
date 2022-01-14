import 'package:api/entity/game_type.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/home_view_model.dart';

class HomeT1 extends StatefulWidget {
  final bool isFirstRun;

  HomeT1({this.isFirstRun = false});

  @override
  _HomeT1State createState() => _HomeT1State();
}

class _HomeT1State extends BaseState<HomeT1> {
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

  @override
  void initState() {
    _initData();
    super.initState();
  }

  _initData() async {
    _vm.getAnnouncement();
    _vm.getBanner();
    _vm.getTotalBalance();
    _vm.getBrandCommunication();
    await _gameViewModel.getGameProviderList(isRefresh: true);
    getLanguage();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if ((_vm.config?.popupAnnouncement ?? false) && _vm.firstAnnouncement != null) _displayMarqueeDialog();
    });
  }

  getLanguage() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    languageCode = _prefs.getString("LANGUAGE_CODE") ?? "en-US";
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
              onClickLoginButton: () => Navigator.of(context).pushNamed(RoutePath.login),
              onClickRegisterButton: () => Navigator.of(context).pushNamed(RoutePath.register),
              onClickLogoutButton: () => _logout(),
              isLogin: _vm.userProfile != null,
              brandLogoUrl: _vm.brandLogoUrl,
              userProfile: _vm.userProfile,
              phone: _vm.phone,
              config: _vm.config,
            ),
            body: /* Stack(
              children: [*/
                Container(
              margin: EdgeInsets.only(top: 10.auto, left: 10.auto, right: 10.auto),
              child: Column(
                children: [
                  _buildImageSlider(),
                  _buildTextMarquee(),
                  _buildGameView(),
                ],
              ),
            ),
            /*_buildOverlay(),
                _buildMenu(),
              ],
            ),*/
          );
        });
  }

  _buildImageSlider() {
    String brand = EnvironmentConfig.appTitleName == "PG Gaming" ? "PGG" : EnvironmentConfig.appTitleName;
    return Container(
      height: context.screenHeight / 5,
      child: _vm.bannerList == null || _vm.bannerList!.isEmpty
          ? _buildEmptyContainer()
          : Stack(
              children: [
                CarouselSlider(
                  carouselController: carouselController,
                  items: List.generate(
                      _vm.bannerList!.length,
                      (index) => ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _vm.bannerList![index].mobileUrl == null
                                ? _buildEmptyContainer()
                                : CachedNetworkImage(
                                    height: 400,
                                    width: context.screenWidth,
                                    placeholder: (context, url) => _buildEmptyContainer(),
                                    imageUrl: _vm.bannerList![index].mobileUrl!,
                                    //handling error
                                    fit: BoxFit.fill,
                                    errorWidget: (context, url, error) => _buildEmptyContainer(),
                                  ),
                          )),
                  options: CarouselOptions(
                    height: 400,
                    aspectRatio: context.screenWidth / 400,
                    viewportFraction: 1,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 3),
                    autoPlayAnimationDuration: Duration(milliseconds: 500),
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, _) {
                      setState(() {
                        _current = index;
                      });
                    },
                  ),
                ),
                InkWell(
                  onTap: () {
                    carouselController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.linear);
                  },
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ),
                ),
                Container(
                  height: 400,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(_vm.bannerList!.length, (index) {
                      return Container(
                        width: 8.auto,
                        height: 8.auto,
                        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: _current == index ? Colors.redAccent : Colors.grey),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }

  _buildEmptyContainer() => Container(
        color: CustomColor.very_light_pink_four,
      );

  _buildTextMarquee() {
    var announcement = _removeMultiLine(parseHtmlString(_vm.announcement ?? ""));
    return Container(
      padding: EdgeInsets.only(top: 3.auto, bottom: 5.auto),
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
            flex: 2,
            child: Container(
              width: (languageCode?.contains("zh") ?? false) ? context.screenWidth / 10 : context.screenWidth / 5,
              child: AutoSizeText(
                getTranslatedText("notice"),
                style: TextStyle(fontWeight: FontWeight.w600),
                maxFontSize: 13,
                minFontSize: 5,
                maxLines: 1,
                stepGranularity: 1,
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

  _removeMultiLine(String text) {
    return text.replaceAll("\n", " ");
  }

  _buildGameView() => GameT1(
        vm: _gameViewModel,
        onRefreshHomePage: () => _initData(),
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
