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
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
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
import 'package:tgp_flutter2/ui/home/home_t1.dart';
import 'package:tgp_flutter2/ui/home/home_t2.dart';
import 'package:tgp_flutter2/ui/home/home_t3.dart';
import 'package:tgp_flutter2/ui/home/home_t8.dart';
import 'package:tgp_flutter2/ui/home/home_t9.dart';
import 'package:tgp_flutter2/ui/home/home_view_model.dart';
import 'dart:math';

import 'package:tgp_flutter2/ui/home/promotion_dialog.dart';

class Home extends StatefulWidget {
  final bool isFirstRun;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;

  Home({this.isFirstRun = false, this.onPauseBgMusic, this.onResumeBgMusic});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends BaseState<Home> {
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
    var task = <Future>[];
    task.add(_vm.getAnnouncement());
    task.add(_vm.getPromotionList());
    task.add(_vm.getBanner());
    task.add(_vm.getBrandCommunication());
    task.add(_gameViewModel.getGameProviderList(isRefresh: true));
    await Future.wait(task);
    _vm.getUserDetails();
    getLanguage();
    randomNumber = _randomGenerator();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _displayDialog();
    });
  }

  _displayDialog() {
    if (isShowAnnouncement()) {
      _displayMarqueeDialog();
    } else if (isShowPromotion()) _displayPromotionDialog();
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
          return CustomScaffold(
            appBar: EnvironmentConfig.template_version == 2
                ? PreferredSize(
                    child: Container(),
                    preferredSize: Size.fromHeight(0),
                  )
                : CustomLoginAppBar(
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
            body: Container(
              child: _getHomeTemplateView(),
            ),
          );
        });
  }

  _getHomeTemplateView() {
    switch (EnvironmentConfig.template_version) {
      case 1:
        return HomeT1(
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomNumber,
        );
      case 2:
        return HomeT2(
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomNumber,
        );
      case 3:
        return HomeT3(
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomNumber,
        );
      case 8:
        return HomeT8(
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomNumber,
        );
      case 9:
        return HomeT9(
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomNumber,
        );
      default:
        return HomeT1(
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
        );
    }
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
          popIndex: 2,
        ),
      );
    }
  }

  _logout() {
    ProgressDialog.show(context, _vm.brandLogoUrl);
    _vm.logout();
  }

  _displayMarqueeDialog() {
    if (isShowAnnouncement()) {
      showDialog(
        context: context,
        builder: (BuildContext context2) => CustomDialog(
          title: (_vm.marqueeDialog?.localization?.subject ?? _vm.marqueeDialog?.subject),
          description: (_vm.marqueeDialog?.localization?.content ?? _vm.marqueeDialog?.content),
          buttonText1: getTranslatedText("confirm"),
          onClick: () {
            if (isShowPromotion()) {
              _displayPromotionDialog();
            } else
              Navigator.of(context2).pop();
          },
        ),
      );
    }
  }

  _displayPromotionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => PromotionDialog(
        promotionList: _vm.promotionList!,
        onClick: () {
          if (isShowAnnouncement()) {
            Navigator.of(context).pop();
          }
          Navigator.of(context).pop();
        },
      ),
    );
  }

  isShowAnnouncement() => (_vm.config?.popupAnnouncement ?? false) && _vm.marqueeDialog != null;

  isShowPromotion() => (_vm.config?.popupPromotion ?? false) && (_vm.promotionList?.isNotEmpty ?? false);

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
    handleApiState(_vm.getPromotionListApiState, isAutoHideLoading: false, onSuccess: () {});
  }
}
