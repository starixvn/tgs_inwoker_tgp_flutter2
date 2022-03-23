import 'package:api/entity/game_type.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:tgp_flutter2/ui/home/game/game_t3/game_t3.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/home_view_model.dart';

class HomeT3 extends StatefulWidget {
  final bool isFirstRun;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;

  HomeT3({this.isFirstRun = false, this.onResumeBgMusic, this.onPauseBgMusic});

  @override
  _HomeT3State createState() => _HomeT3State();
}

class _HomeT3State extends BaseState<HomeT3> {
  List<String> imgList = [
    '1',
    '2',
    //'images/banner_2.jpg'
  ];

  //var gameList = ["sport", "live", "slot", "fishing", "lotto", "e-game", "card"];
  ScrollController controller = ScrollController();
  var currentTabIndex = "0";
  UserProfile? user;
  var currentBottomIndex = 0;
  var isMenu = false;
  var itemHeightRatio = 335 / 90;
  var _vm = HomeViewModel();
  int _current = 0;
  final CarouselController _controller = CarouselController();
  String? languageCode, imageLanguageCode = "en-US";
  var _gameViewModel = GameViewModel();

  @override
  void initState() {
    _initData();
    super.initState();
  }

  _initData() async {
    await getLanguage();
    _vm.getAnnouncement();
    _vm.getBanner();
    _vm.getBrandCommunication();
    await _gameViewModel.getGameProviderList(isRefresh: true);
    _vm.getUserDetails();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if ((_vm.config?.popupAnnouncement ?? false) && _vm.firstAnnouncement != null) _displayMarqueeDialog();
    });
  }

  getLanguage() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    languageCode = _prefs.getString("LANGUAGE_CODE") ?? EnvironmentConfig.default_lang;
    imageLanguageCode = ((languageCode?.contains("th") ?? false)) ? languageCode : "en-US";
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
              totalBalance: _vm.totalBalance,
              brandName: EnvironmentConfig.brandName,
            ),
            body: /* Stack(
              children: [*/
                Container(
              padding: EdgeInsets.only(top: 10.auto, left: 10.auto, right: 10.auto),
              child: Column(
                children: [
                  _buildTextMarquee(),
                  _buildImageSlider(),
                  Expanded(
                      child: _gameViewModel.gameRowListT3 == null ||_gameViewModel.gameListT3 == null
                          ? buildProgressDialog(_vm.brandLogoUrl)
                          : ListView(
                    children: [_buildImageRow(), _buildGameImageGridView()],
                  ))
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

  _buildTextMarquee() {
    var announcement = _removeMultiLine(parseHtmlString(_vm.announcement ?? ""));
    return Container(
      padding: EdgeInsets.only(bottom: 5.auto),
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
            flex: _getNoticeFlex(),
            child: Container(
              // width: (languageCode?.contains("zh") ?? false) ? context.screenWidth / 10 : context.screenWidth / 5,
              child: Text(
                getTranslatedText("notice"),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: CustomColor.theme_text_black_white_color,
                  fontSize: 12.auto,
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
          )
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

  _removeMultiLine(String text) {
    return text.replaceAll("\n", " ");
  }

  _buildImageSlider() {
    String brand = EnvironmentConfig.appTitleName == "PG Gaming" ? "PGG" : EnvironmentConfig.appTitleName;
    return Container(
        height: context.screenHeight / 5,
        child: _vm.bannerList == null || _vm.bannerList!.isEmpty
            ? _buildEmptyContainer()
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    CarouselSlider(
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
                                        fit: BoxFit.cover,
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
              ));
  }

  _buildEmptyContainer() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: CustomColor.very_light_pink_four,
        ),
      );

  _buildImageRow() {
    getLanguage();
    return Container(
            height: 180.auto,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_gameViewModel.gameRowListT3!.length, (index) {
                  return InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GameT3(
                                    gamePlatformCode: "",
                                    gameType: _gameViewModel.gameRowListT3![index],
                                    index: index,
                                    config: _vm.config,
                                    onPauseBgMusic: () =>
                                        (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                                    onResumeBgMusic: () =>
                                        (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                                  ))),
                      child: Container(
                        width: context.screenWidth / 2 - 15.auto,
                        child: Image.asset(
                            "images/game_tab/t3/$imageLanguageCode/${_gameViewModel.gameRowListT3![index].getImagePath()}.gif"),
                      ));
                })),
          );
  }

  _buildGameImageGridView() {
    return Container(
            height: 260.auto,
            margin: EdgeInsets.only(top: 8.auto, bottom: 10.auto),
            child: StaggeredGridView.countBuilder(
              crossAxisCount: 2,
              itemCount: _gameViewModel.gameListT3!.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) => InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GameT3(
                              gamePlatformCode: "",
                              gameType: _gameViewModel.gameListT3![index],
                              index: index,
                              config: _vm.config,
                              onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                              onResumeBgMusic: () =>
                                  (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                            ))),
                child: Image.asset(
                    "images/game_tab/t3/$imageLanguageCode/${_gameViewModel.gameListT3![index].getImagePath()}.gif"),
              ),
              staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
              mainAxisSpacing: 15.auto,
              crossAxisSpacing: 15.auto,
            ),
          );
  }

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
