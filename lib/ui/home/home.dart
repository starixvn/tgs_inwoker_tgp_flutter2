import 'dart:async';

import 'package:api/NotificationServices/NotificationServiceName.dart';
import 'package:api/NotificationServices/notification_center.dart';
import 'package:api/entity/campaign_details.dart';
import 'package:api/entity/dedicated_home_banner.dart';
import 'package:api/entity/promotion.dart';
import 'package:api/entity/promotion_roulette.dart';
import 'package:api/entity/response/ws_response.dart';
import 'package:api/websocket/web_socket_deposit.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/globalUtil/GlobalValueUtil.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:api/entity/user_profile.dart';
import 'package:tgp_flutter2/custom/custom_login_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/card/add_card.dart';
import 'package:tgp_flutter2/ui/dialog/another_roulette_dialog.dart';
import 'package:tgp_flutter2/ui/dialog/deposit_order_dialog.dart';
import 'package:tgp_flutter2/ui/dialog/phone_verification_dialog.dart';
import 'package:tgp_flutter2/ui/home/balance_picker/balance_picker.dart';
import 'package:tgp_flutter2/ui/home/game/base_game.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/home_t1.dart';
import 'package:tgp_flutter2/ui/home/home_t10.dart';
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

import 'dart:math';

import 'package:tgp_flutter2/ui/profile_info/phone/phone_verification.dart';

import '../../MyRouteObserver.dart';
import 'end_drawer_menu.dart';
import 'home_t14.dart';
import 'home_t15.dart';

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

class _HomeState extends BaseState<Home> implements RouteAware {
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
  CarouselController carouselController = CarouselController();

  var _gameViewModel = GameViewModel();
  var randomNumber;
  var onClickFromSmallRoulette = false, isShowTransferUI = false;
  var onClickFromAnotherSmallRoulette = false;
  var isDisplayGameView = false; //to check either display jackpot or game view in t11
  var isShowMarquee = false; //to check either hide show marquee in login app bar

  var token;
  var isCloseRouletteIcon = false; //handle users close roulette icon by themselves

  late Timer _generateTimer;

  @override
  void initState() {
    _initData();
    if (GlobalValueUtil.playerStatus != AssetPlayerStatus.manualClickPause && EnvironmentConfig.template_version == 15&& EnvironmentConfig.dark_mode) {
      // if (widget.onResumeBgMusic != null) widget.onResumeBgMusic!();
      GlobalValueUtil.playsong();
    }
    // if (widget.onResumeBgMusic != null) widget.onResumeBgMusic!();
    super.initState();
    routeObserver.subscribe(this);
  }

  @override
  void dispose() {
    print("leavehre???");
    _generateTimer.cancel();

    // if (widget.onPauseBgMusic != null) widget.onPauseBgMusic!();
    if (GlobalValueUtil.playerStatus != AssetPlayerStatus.manualClickPause && EnvironmentConfig.template_version == 15) {
      GlobalValueUtil.playerStatus = AssetPlayerStatus.leavePagePause;
      GlobalValueUtil.stopsong();
    }
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  _initData() async {
    var task = <Future>[];
    _generateNewNumberEveryFewSec();

    task.add(_vm.getPromotionList());
    if (EnvironmentConfig.template_version == 11) task.add(_gameViewModel.getJackpotRecommendList());
    randomGeneratedPlayerCount = _randomGenerator();
    task.add(_vm.getAnnouncement());
    task.add(_vm.getBanner());
    task.add(_vm.getBrandCommunication());
    task.add(_gameViewModel.getGameProviderList(isRefresh: true));
    task.add(_vm.getBankCardList());
    task.add(_vm.getRoulettePlayCount());

    if (_vm.roulettePromo != null) {
      task.add(_vm.getRouletteTodayResult());
    }
    //  if (_vm.depositRoulettePromo != null) {
    //    task.add(_vm.getDepositRouletteTodayResult());
    //  }
    await Future.wait(task);
    _handleNavigationAndPopUpDialog();
    await _vm.getUserDetails();
  }

  getToken() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    token = _prefs.getString('token');
  }

  Widget build(BuildContext context) {
    print("masukkksssHome:");
    return ProviderWidget<HomeViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return Stack(
            children: [
              Container(
                color: EnvironmentConfig.template_version == 15 ? CustomColor.theme_app_bar_color : Colors.transparent,
                child: Stack(
                  children: [
                    _getHomeTemplateView(),
                    _rouletteHolder(),
                  ],
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

  _getTopBarDetails() => CustomLoginAppBar(
        onClickLoginButton: () => Navigator.of(context).pushNamed(RoutePath.login),
        onClickRegisterButton: () => Navigator.of(context).pushNamed(RoutePath.register),
        onClickLogoutButton: () => _logout(),
        isLogin: _vm.userProfile != null,
        // brandLogoUrl: _vm.brandLogoUrl,
        userProfile: _vm.userProfile,
        // phone: _vm.phone,
        // config: _vm.config,
        // totalBalance: _vm.totalBalance,
        //_vm.totalBalance,
        // brandName: EnvironmentConfig.brandName,
        onClickBalance: () {
          setState(() {
            isShowTransferUI = !isShowTransferUI;
          });
        },
        // onPauseMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
        // onResumeMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
        randomNumber: randomGeneratedPlayerCount ?? 0,
        isShowMarquee: isShowMarquee,
        marquee: _vm.announcement,
        isShowBarrier: false,
      );

  _getHomeTemplateView() {
    switch (EnvironmentConfig.template_version) {
      case 1:
        return HomeT1(
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomGeneratedPlayerCount ?? 0,
          gameView: _buildGameView(),
        );
      case 2:
        return HomeT2(
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomGeneratedPlayerCount ?? 0,
          gameView: _buildGameView(),
        );
      case 3:
        return HomeT3(
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomGeneratedPlayerCount ?? 0,
          gameView: _buildGameView(),
        );
      case 4:
        return HomeT4(
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomGeneratedPlayerCount ?? 0,
          gameView: _buildGameView(),
        );
      case 8:
        return HomeT8(
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomGeneratedPlayerCount ?? 0,
          gameView: _buildGameView(),
        );
      case 9:
        return HomeT9(
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomGeneratedPlayerCount ?? 0,
          gameView: _buildGameView(),
        );
      case 10:
        return HomeT10(
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomGeneratedPlayerCount ?? 0,
          gameView: _buildGameView(),
        );
      case 11:
        return HomeT11(
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomGeneratedPlayerCount ?? 0,
          gameView: _buildGameView(),
        );
      case 15:
        return HomeT15(
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomGeneratedPlayerCount ?? 0,
          gameView: _buildGameView(),
        );
      case 100:
        //the reason it's 100 is because apparently all existing using int data type
        //to prevent for everything become fucked up, custom homepage (non T related will start from 100)
        return HomeT11(
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomGeneratedPlayerCount ?? 0,
          gameView: _buildGameView(),
        );
      case 14:
        return HomeT14(
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          initData: () => _initData(),
          homeViewModel: _vm,
          gameViewModel: _gameViewModel,
          randomNumber: randomGeneratedPlayerCount ?? 0,
          gameView: _buildGameView(),
          updateShowMarquee: (show) => this.setState(() {
            isShowMarquee = show;
          }),
        );
      default:
        return HomeT1(
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
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
        onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
        onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
        isDisplayGameView: widget.isDisplayGameView,
        onClickGameTab: (value) => (widget.onClickGameTab != null) ? widget.onClickGameTab!(value) : null,
      );

  _getSmallRouletteIcon() => Visibility(
        visible: (_vm.config?.homePagePromoRoulette ?? false) && _vm.roulettePromo != null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: context.screenHeight / 5,
              height: context.screenHeight / 5,
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
            InkWell(
              onTap: () => setState(() {
                isCloseRouletteIcon = true;
              }),
              child: Container(
                width: 15,
                height: 15,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    width: 1,
                    color: Colors.black,
                  ),
                  color: Colors.transparent,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 10,
                ),
              ),
            ),
          ],
        ),
      );

  _rouletteHolder() => Visibility(
        visible: (_vm.config?.homePagePromoRoulette ?? false) && _vm.rouletteCount.isNotEmpty && !isCloseRouletteIcon,
        child: Positioned(
          //others template display in bottom right corner
          bottom: EnvironmentConfig.template_version == 15 ? null : 0,
          right: EnvironmentConfig.template_version == 15 ? null : 0,
          //t15 display above image slider
          top: EnvironmentConfig.template_version == 15 ? context.screenHeight / 10 : null,
          left: EnvironmentConfig.template_version == 15 ? 0 : null,
          child: Row(
            children: [_getSmallRouletteIcon(), _smallRouletteGenerator()],
          ),
        ),
      );

  var appearedDAR = [];

  _smallRouletteGenerator() {
    Promotion? _depositPromo;
    var rouletteWithPlayCounts = _vm.rouletteCount;

    print(appearedDAR);

    return Row(
      children: (EnvironmentConfig.template_version == 15)
          ? [
              if (_vm.rouletteCount.isNotEmpty)
                _getAnotherSmallRouletteIcon(
                  _depositPromo,
                  _vm.rouletteCount.first,
                )
            ]
          : List.generate(_vm.rouletteCount.length, (index) {
              // var isSameId = rouletteWithPlayCounts.any((element) => element.id == depositRoulettePromo[index].id);

//         //if the id is same, then get the play count
//         if (isSameId) {
//           // if the ID are the same save the id inside appearedDAR
//           if (!appearedDAR.contains(depositRoulettePromo[index].id)) {
//             appearedDAR.add(depositRoulettePromo[index].id);
//           }
//           //temporary comment
//
//           rouletteCount = rouletteWithPlayCounts
//               .firstWhere((element) => element.id == depositRoulettePromo[index].id)
//               .rouletteCount;
//         }
//
// //display the first item in depositRoulettePromo that matches id in appearedDAR
//         if (appearedDAR.isNotEmpty && depositRoulettePromo[index].id == appearedDAR.first) {

              if (_vm.depositRoulettePromo != null && _vm.depositRoulettePromo!.length > 0) {
                for (Promotion item in _vm.depositRoulettePromo!) {
                  if (item.id == _vm.rouletteCount[index].id) {
                    _depositPromo = item;
                  }
                }
              }

              if (_vm.rouletteCount[index] != null) {
                return _getAnotherSmallRouletteIcon(
                  _depositPromo,
                  _vm.rouletteCount[index],
                );
              } else {
                return Container();
              }
            }),

      //
    );
  }

  _getAnotherSmallRouletteIcon(Promotion? data, PromotionRoulette promotionRoulette) => Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: EnvironmentConfig.template_version == 15 ? context.screenHeight / 9 : context.screenHeight / 5,
              height: EnvironmentConfig.template_version == 15 ? context.screenHeight / 9 : context.screenHeight / 5,
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: () {
                  if (_vm.userProfile == null) {
                    navigateToLogin();
                  }
                  //prevent click more than once
                  if (!onClickFromAnotherSmallRoulette) {
                    // print("data id is: ${data.id}");
                    _displayAnotherRouletteDialog(data, promotionRoulette);
                    setState(() {
                      onClickFromAnotherSmallRoulette = true;
                    });
                  }
                },
                child: Image.asset(
                  "images/roulette/small_roulette.png",
                ),
              ),
            ),
            InkWell(
              onTap: () => setState(() {
                isCloseRouletteIcon = true;
              }),
              child: Container(
                width: 15,
                height: 15,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    width: 1,
                    color: Colors.black,
                  ),
                  color: Colors.transparent,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 10,
                ),
              ),
            ),
          ],
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

  _displayAnotherRouletteDialog(Promotion? data, PromotionRoulette? promotionRoulette) async {
    // if (_vm.depositRoulettePromo != null)
    await _vm.getDepositRouletteHistoryRecord(promotionRoulette?.id ?? "");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AnotherRouletteDialog(
        onTapCloseIcon: () {
          Navigator.pop(context);
          if (!onClickFromAnotherSmallRoulette) _displayDialog();
          setState(() {
            onClickFromAnotherSmallRoulette = false;
          });
        },
        userProfile: _vm.userProfile,
        isPlayed: _vm.isDepositRoulettePlayed,
        vm: _vm,
        promotionRoulette: promotionRoulette,
        contents: data,
        // getRouletteResult: () => _vm.getRouletteResult(),

        // playcount: playcount,
        // campaign: data.campaignDetails?.rouletteItems ?? [],
        // rouletteHistoryList: _vm.rouletteHistoryList,
        // prize: _vm.prize,
      ),
    );
    // else
    //   _displayDialog();
  }

  _displayDialog() {
    if (isShowDedicatedHomeBanner()) {
      showDedicatedHomeBanner();
    } else if (isShowAnnouncement()) {
      _displayMarqueeDialog();
    } else if (isShowPromotion()) _displayPromotionDialog();
  }

  void showDedicatedHomeBanner() async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: GestureDetector(
              onTap: () {
                NotificationCenter().notify(NotificationServiceName().bottomNavigationIndex, data: 1);
                Navigator.of(context).pop();
              },
              child: Image.network(
                _vm.config?.dedicatedHomeBanner.wap ?? "",
                height: context.screenHeight * 0.6,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      );
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
                title: (_vm.marqueeDialog?.localization?.subject ?? _vm.marqueeDialog?.subject),
                description: (_vm.marqueeDialog?.localization?.content ?? _vm.marqueeDialog?.content),
                onClick: () {
                  if (isShowPromotion()) {
                    _displayPromotionDialog();
                  }
                }),
          )
        : showDialog(
            context: context,
            builder: (BuildContext context2) => CustomDialog(
                title: (_vm.marqueeDialog?.localization?.subject ?? _vm.marqueeDialog?.subject),
                description: (_vm.marqueeDialog?.localization?.content ?? _vm.marqueeDialog?.content),
                buttonText1: getTranslatedText("confirm"),
                onPopBeforeTriggerOnClick: isShowPromotion() || (!isShowPromotion() && isShowAnnouncement()),
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
      if ((_vm.config?.forcedVerification ?? false) && _vm.userProfile?.registerCompleted == false && (_vm.config?.initPhoneWithoutVerify ?? false)) {
        Navigator.pushNamed(context, "/phone_verification");
      }

      if (_vm.config?.idrRegisterCustomFlow ?? false) {
        if (_vm.userProfile?.phone == "") {
          //navigate to add phone
          Navigator.pushNamed(context, "/phone_verification");
        } else if (_vm.userProfile?.email == "") {
          //navigate to add email
          Navigator.pushNamed(context, "/email_verification");
        } else if (_vm.userProfile?.registerCompleted == true) {
          //navigate to add card
          Navigator.pushNamed(context, "/add_card");
        }
      }

      if (_vm.userProfile?.registerCompleted ?? false) {
        print(_vm.userProfile?.registerCompleted ? "true" : "false");
      }
      if ((_vm.config?.smsVerification ?? false) && !(_vm.userProfile?.registerCompleted ?? true) && (_vm.config?.forcedVerification ?? false)) {
        _displayPhoneVerificationDialog();
      } else if ((_vm.config?.registerShowPhone ?? false) && !(_vm.userProfile?.registerCompleted ?? true) && (_vm.config?.forcedVerification ?? false)) {
        _navigateToPhoneVerification();
      } else if (!(_vm.userProfile?.registerCompleted ?? true) && (_vm.bankCardList == null || _vm.bankCardList.length == 0)) {
        _navigateToAddCard();
      } else if (_vm.config?.homePagePromoRoulette ?? false)
        _displayRouletteDialog();
      else
        _displayDialog();
    });
  }

  _navigateToAddCard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AddCard(isNavigateFromRegister: true)));
      //Navigator.pushNamed(context, RoutePath.addCard);
    });
  }

  _navigateToPhoneVerification() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Navigator.of(context).pushNamed(RoutePath.phoneVerification);
      var result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PhoneVerification(isFromRegister: true)),
      );
      if (result) _handleNavigationAndPopUpDialog();
    });
  }

  isShowAnnouncement() => (_vm.config?.popupAnnouncement ?? false) && _vm.marqueeDialog != null;

  isShowPromotion() => (_vm.config?.popupPromotion ?? false) && (_vm.promotionList?.isNotEmpty ?? false);

  isShowDedicatedHomeBanner() {
    if (_vm.config?.dedicatedHomeBanner?.wap?.isNotEmpty == true) {
      return true;
    } else {
      return false;
    }
  }


  var randomGeneratedPlayerCount;

  _generateNewNumberEveryFewSec() {
    Random _random = new Random();
    var checkIfHomeOnlineUsersIsNull = _vm.config?.homeOnlineUsers != null;
    int min = checkIfHomeOnlineUsersIsNull ? _vm.config.homeOnlineUsers["min"] : 20000;

    int max = checkIfHomeOnlineUsersIsNull ? _vm.config.homeOnlineUsers["max"] : 30000;
    _generateTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      try {
        if (mounted) {
          // Check whether the widget is still mounted before calling setState
          setState(() {
            randomGeneratedPlayerCount = min + _random.nextInt(max - min);
          });
        }
      } catch (e) {
        print('Error: $e');
      }
    });
  }

  _randomGenerator() {
    Random _random = new Random();
    var checkIfHomeOnlineUsersIsNull = _vm.config?.homeOnlineUsers != null;
    int min = checkIfHomeOnlineUsersIsNull ? _vm.config.homeOnlineUsers["min"] : 20000;

    int max = checkIfHomeOnlineUsersIsNull ? _vm.config.homeOnlineUsers["max"] : 30000;
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
    handleApiState(_vm.getBasicInfoApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getAnnouncementApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getBannerApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getPromotionListApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getTodayRouletteResultApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getRouletteApiState, isAutoHideLoading: false, onSuccess: () {});
  }

  @override
  void didPop() {
    print("didPop");
    if (GlobalValueUtil.playerStatus != AssetPlayerStatus.manualClickPause && EnvironmentConfig.template_version == 15) {
      if (widget.onResumeBgMusic != null) widget.onResumeBgMusic!();
    }
    // TODO: implement didPop
  }

  @override
  void didPopNext() {
    print("popNext");
    // TODO: implement didPopNext
  }

  @override
  void didPush() {
    print("push");
    // TODO: implement didPush
  }

  @override
  void didPushNext() {
    print("pushNext");
    // TODO: implement didPushNext
  }
}
