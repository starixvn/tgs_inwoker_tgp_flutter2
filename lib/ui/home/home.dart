import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:api/entity/user_profile.dart';
import 'package:tgp_flutter2/custom/custom_login_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/card/add_card.dart';
import 'package:tgp_flutter2/ui/dialog/phone_verification_dialog.dart';
import 'package:tgp_flutter2/ui/home/balance_picker/balance_picker.dart';
import 'package:tgp_flutter2/ui/home/custom_home/home_wghk.dart';
import 'package:tgp_flutter2/ui/home/game/base_game.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/home_t1.dart';
import 'package:tgp_flutter2/ui/home/home_t10.dart';
import 'package:tgp_flutter2/ui/home/home_t100.dart';
import 'package:tgp_flutter2/ui/home/home_t11.dart';
import 'package:tgp_flutter2/ui/home/home_t2.dart';
import 'package:tgp_flutter2/ui/home/home_t3.dart';
import 'package:tgp_flutter2/ui/home/home_t4.dart';
import 'package:tgp_flutter2/ui/home/home_t8.dart';
import 'package:tgp_flutter2/ui/home/home_t9.dart';
import 'package:tgp_flutter2/ui/home/home_view_model.dart';
import 'package:tgp_flutter2/ui/dialog/marquee_dialog.dart';
import 'package:tgp_flutter2/ui/dialog/promotion_dialog.dart';
import 'package:tgp_flutter2/ui/dialog/roulette_dialog.dart';
import 'dart:io' show Platform;

import 'dart:math';

import 'package:tgp_flutter2/ui/profile_info/phone/phone_verification.dart';

class Home extends StatefulWidget {
  final bool isFirstRun;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final bool isDisplayGameView;
  final Function? onClickGameTab;

  Home({
    this.isFirstRun = false,
    this.onPauseBgMusic,
    this.onResumeBgMusic,
    this.isDisplayGameView = false,
    this.onClickGameTab,
  });

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends BaseState<Home> {
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
  var _vm = HomeViewModel();
  int _current = 0;
  CarouselController carouselController = CarouselController();
  var languageCode;
  var _gameViewModel = GameViewModel();
  var randomNumber;
  var _assetsAudioPlayer;
  var onClickFromSmallRoulette = false, isShowTransferUI = false;
  var onClickFromAnotherSmallRoulette = false;
  var isDisplayGameView =
      false; //to check either display jackpot or game view in t11

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
    task.add(_vm.getBankCardList());
    // TODO: temporary comment this code, since its for DAR and DAR only available next version.
    //task.add(_vm.getRoulettePlayCount());
    if (_vm.roulettePromo != null) task.add(_vm.getRouletteTodayResult());
    await Future.wait(task);
    getLanguage();
    randomNumber = _randomGenerator();
    _handleNavigationAndPopUpDialog();
    await _vm.getUserDetails();
    await _gameViewModel.getJackpotRecommendList();
  }

  getLanguage() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    languageCode =
        _prefs.getString("LANGUAGE_CODE") ?? EnvironmentConfig.default_lang;
  }

  Widget build(BuildContext context) {
    return ProviderWidget<HomeViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return Stack(
            children: [
              CustomScaffold(
                appBar: CustomLoginAppBar(
                  onClickLoginButton: () =>
                      Navigator.of(context).pushNamed(RoutePath.login),
                  onClickRegisterButton: () =>
                      Navigator.of(context).pushNamed(RoutePath.register),
                  onClickLogoutButton: () => _logout(),
                  isLogin: _vm.userProfile != null,
                  brandLogoUrl: _vm.brandLogoUrl,
                  userProfile: _vm.userProfile,
                  phone: _vm.phone,
                  config: _vm.config,
                  totalBalance: _vm.totalBalance,
                  //_vm.totalBalance,
                  brandName: EnvironmentConfig.brandName,
                  onClickBalance: () {
                    setState(() {
                      isShowTransferUI = !isShowTransferUI;
                    });
                  },
                  randomNumber: randomNumber ?? 0,
                ),
                body: Container(
                  child: Stack(
                    children: [
                      _getHomeTemplateView(),
                      _getSmallRouletteIcon(),
                      // TODO: temporary comment this code, since its for DAR and DAR only available next version.
                      // _getAnotherSmallRouletteIcon(),
                    ],
                  ),
                ),
              ),
              BalancePicker(
                isShow: isShowTransferUI,
                mainWalletBalance: _vm.totalBalance,
                walletList: _vm.walletList,
                gameTypeList: _gameViewModel.balanceGameTypeList,
              ),
            ],
          );
        });
  }

  _getHomeTemplateView() {
    switch (EnvironmentConfig.template_version) {
      case 1:
        return HomeT1(
          onPauseBgMusic: () =>
              (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null)
              ? widget.onResumeBgMusic!()
              : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomNumber,
          gameView: _buildGameView(),
        );
      case 2:
        return HomeT2(
          onPauseBgMusic: () =>
              (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null)
              ? widget.onResumeBgMusic!()
              : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomNumber,
          gameView: _buildGameView(),
        );
      case 3:
        return HomeT3(
          onPauseBgMusic: () =>
              (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null)
              ? widget.onResumeBgMusic!()
              : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomNumber,
          gameView: _buildGameView(),
        );
      case 4:
        return HomeT4(
          onPauseBgMusic: () =>
              (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null)
              ? widget.onResumeBgMusic!()
              : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomNumber,
          gameView: _buildGameView(),
        );
      case 8:
        return HomeT8(
          onPauseBgMusic: () =>
              (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null)
              ? widget.onResumeBgMusic!()
              : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomNumber,
          gameView: _buildGameView(),
        );
      case 9:
        return HomeT9(
          onPauseBgMusic: () =>
              (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null)
              ? widget.onResumeBgMusic!()
              : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          gameView: _buildGameView(),
        );
      case 10:
        return HomeT10(
          onPauseBgMusic: () =>
              (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null)
              ? widget.onResumeBgMusic!()
              : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomNumber,
          gameView: _buildGameView(),
        );
      case 11:
        return HomeT11(
          onPauseBgMusic: () =>
              (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null)
              ? widget.onResumeBgMusic!()
              : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomNumber,
          gameView: _buildGameView(),
        );
      case 100:
        //the reason it's 100 is because apparently all existing using int data type
        //to prevent for everything become fucked up, custom homepage (non T related will start from 100)
        return HomeWGHK(
          onPauseBgMusic: () =>
              (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null)
              ? widget.onResumeBgMusic!()
              : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomNumber,
          gameView: _buildGameView(),
        );
      default:
        return HomeT1(
          onPauseBgMusic: () =>
              (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null)
              ? widget.onResumeBgMusic!()
              : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          gameView: _buildGameView(),
        );
    }
  }

  _buildGameView() => BaseGame(
        vm: _gameViewModel,
        onRefreshHomePage: () => _initData(),
        onPauseBgMusic: () =>
            (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
        onResumeBgMusic: () =>
            (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
        isDisplayGameView: widget.isDisplayGameView,
        onClickGameTab: (value) => (widget.onClickGameTab != null)
            ? widget.onClickGameTab!(value)
            : null,
      );

  _getSmallRouletteIcon() => Visibility(
        visible: (_vm.config?.homePagePromoRoulette ?? false) &&
            _vm.roulettePromo != null,
        child: Positioned(
          top: context.screenHeight / 5 - 60.auto,
          left: -5,
          child: Container(
            width: context.screenHeight / 10,
            height: context.screenHeight / 10,
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: () {
                //prevent click more than once
                if (!onClickFromSmallRoulette) {
                  _displayRouletteDialog();
                  setState(() {
                    onClickFromSmallRoulette = true;
                  });
                }
              },
              child: Image.asset("images/roulette/small_roulette.png"),
            ),
          ),
        ),
      );

  _getAnotherSmallRouletteIcon() => Visibility(
        visible: (_vm.config?.homePagePromoRoulette ?? false) &&
            _vm.roulettePromo != null,
        child: Positioned(
          top: context.screenHeight / 5 - 60.auto,
          left: 75,
          child: Container(
            width: context.screenHeight / 10,
            height: context.screenHeight / 10,
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: () {
                //prevent click more than once
                if (!onClickFromAnotherSmallRoulette) {
                  _displayAnotherRouletteDialog();
                  setState(() {
                    onClickFromAnotherSmallRoulette = true;
                  });
                }
              },
              child: Image.asset("images/roulette/small_roulette.png"),
            ),
          ),
        ),
      );

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

  _displayRouletteDialog() async {
    if (_vm.roulettePromo != null) await _vm.getRouletteTodayResult();
    if ((_vm.campaign?.length ?? 0) > 0)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => RouletteDialog(
          onTapCloseIcon: () {
            Navigator.pop(context);
            if (!onClickFromSmallRoulette) _displayDialog();
            setState(() {
              onClickFromSmallRoulette = false;
            });
          },
          userProfile: _vm.userProfile,
          isPlayed: _vm.isRoulettePlayed,
          vm: _vm,
          // getRouletteResult: () => _vm.getRouletteResult(),
          campaign: _vm.campaign,
        ),
      );
    else
      _displayDialog();
  }

  _displayAnotherRouletteDialog() async {
    if (_vm.roulettePromo != null) await _vm.getRouletteTodayResult();
    if ((_vm.campaign?.length ?? 0) > 0)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => RouletteDialog(
          onTapCloseIcon: () {
            Navigator.pop(context);
            if (!onClickFromAnotherSmallRoulette) _displayDialog();
            setState(() {
              onClickFromAnotherSmallRoulette = false;
            });
          },
          userProfile: _vm.userProfile,
          isPlayed: _vm.isRoulettePlayed,
          vm: _vm,
          // getRouletteResult: () => _vm.getRouletteResult(),
          campaign: _vm.campaign,
        ),
      );
    else
      _displayDialog();
  }

  _displayDialog() {
    if (isShowAnnouncement()) {
      _displayMarqueeDialog();
    } else if (isShowPromotion()) _displayPromotionDialog();
  }

  _displayPhoneVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: !(_vm.config?.forcedVerification ?? true),
      builder: (BuildContext context2) => PhoneVerificationDialog(),
    );
  }

  _displayMarqueeDialog() {
    EnvironmentConfig.template_version == 11
        ? showDialog(
            context: context,
            builder: (BuildContext context2) => MarqueeDialog(
                title: (_vm.marqueeDialog?.localization?.subject ??
                    _vm.marqueeDialog?.subject),
                description: (_vm.marqueeDialog?.localization?.content ??
                    _vm.marqueeDialog?.content),
                onClick: () {
                  if (isShowPromotion()) {
                    _displayPromotionDialog();
                  }
                }),
          )
        : showDialog(
            context: context,
            builder: (BuildContext context2) => CustomDialog(
                title: (_vm.marqueeDialog?.localization?.subject ??
                    _vm.marqueeDialog?.subject),
                description: (_vm.marqueeDialog?.localization?.content ??
                    _vm.marqueeDialog?.content),
                buttonText1: getTranslatedText("confirm"),
                onPopBeforeTriggerOnClick: isShowPromotion() ||
                    (!isShowPromotion() && isShowAnnouncement()),
                onClick: () {
                  if (isShowPromotion()) {
                    _displayPromotionDialog();
                  }
                }),
          );
  }

  _displayPromotionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => PromotionDialog(
        promotionList: _vm.promotionList!,
        onClick: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  _handleNavigationAndPopUpDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((_vm.config?.smsVerification ?? false) &&
          !(_vm.userProfile?.registerCompleted ?? true) &&
          (_vm.config?.forcedVerification ?? false)) {
        _displayPhoneVerificationDialog();
      } else if ((_vm.config.registerShowPhone ?? false) &&
          !(_vm.userProfile?.registerCompleted ?? true) &&
          (_vm.config?.forcedVerification ?? false)) {
        _navigateToPhoneVerification();
      } else if (!(_vm.userProfile?.registerCompleted ?? true) &&
          (_vm.bankCardList == null || _vm.bankCardList.length == 0)) {
        _navigateToAddCard();
      } else if (_vm.config?.homePagePromoRoulette ?? false)
        _displayRouletteDialog();
      else
        _displayDialog();
    });
  }

  _navigateToAddCard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddCard(isNavigateFromRegister: true)));
      //Navigator.pushNamed(context, RoutePath.addCard);
    });
  }

  _navigateToPhoneVerification() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Navigator.of(context).pushNamed(RoutePath.phoneVerification);
      var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PhoneVerification(isFromRegister: true)),
      );
      if (result) _handleNavigationAndPopUpDialog();
    });
  }

  isShowAnnouncement() =>
      (_vm.config?.popupAnnouncement ?? false) && _vm.marqueeDialog != null;

  isShowPromotion() =>
      (_vm.config?.popupPromotion ?? false) &&
      (_vm.promotionList?.isNotEmpty ?? false);

  _randomGenerator() {
    Random _random = new Random();
    int min = EnvironmentConfig.template_version == 11 ? 500 : 20000;
    int max = EnvironmentConfig.template_version == 11 ? 1200 : 30000;
    int result = min + _random.nextInt(max - min);
    return result;
  }

  _logout() {
    ProgressDialog.show(context, _vm.brandLogoUrl);
    _vm.logout();
  }

  _handleApiState() {
    if (widget.isFirstRun) {
      if (_vm.isNotLogin) {
        navigateToLogin();
        _vm.markIsNotLogin();
      } else if (_vm.isExpired) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayLoginDialog();
        });
      }
    }
    handleApiState(_vm.logoutApiState, isLogoutApiState: true, onSuccess: () {
      ProgressDialog.hide();
    }, onLogout: () {
      ProgressDialog.hide();
    });
    handleApiState(_vm.getBasicInfoApiState,
        isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getAnnouncementApiState,
        isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getBannerApiState,
        isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getPromotionListApiState,
        isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getTodayRouletteResultApiState,
        isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getRouletteApiState,
        isAutoHideLoading: false, onSuccess: () {});
  }
}
