import 'dart:async';
import 'dart:io';

import 'package:api/network/event_result.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:tgp_flutter2/globalUtil/GlobalValueUtil.dart';
import 'package:tgp_flutter2/MyRouteObserver.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/main_view_model.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/BaseNavigate/BottomNavigationController.dart';
import 'package:tgp_flutter2/ui/affiliate/affiliate.dart';
import 'package:tgp_flutter2/ui/announcement/announcement.dart';
import 'package:tgp_flutter2/ui/blacklisted_user/blacklisted_user.dart';
import 'package:tgp_flutter2/ui/card/add_card.dart';
import 'package:tgp_flutter2/ui/card/main_card.dart';
import 'package:tgp_flutter2/ui/customer_service/customer_service.dart';
import 'package:tgp_flutter2/ui/customer_service/customer_service_web_view.dart';
import 'package:tgp_flutter2/ui/deposit/deposit.dart';
import 'package:tgp_flutter2/ui/dialog/network_issue_dialog.dart';
import 'package:tgp_flutter2/ui/forgot_password/forgot_password.dart';
import 'package:tgp_flutter2/ui/language/language_view.dart';
import 'package:tgp_flutter2/ui/login/login.dart';
import 'package:tgp_flutter2/ui/login/CustomSky8/LoginTemplate02.dart';
import 'package:tgp_flutter2/ui/maintenance/maintenance.dart';
import 'package:tgp_flutter2/ui/memo/memo.dart';
import 'package:tgp_flutter2/ui/menu/menu.dart';
import 'package:tgp_flutter2/ui/menu/menu_t2.dart';
import 'package:tgp_flutter2/ui/message/message_view.dart';
import 'package:tgp_flutter2/ui/profile/profile.dart';
import 'package:tgp_flutter2/ui/profile_info/birthdate/birthdate.dart';
import 'package:tgp_flutter2/ui/profile_info/email/edit_email.dart';
import 'package:tgp_flutter2/ui/profile_info/email/email_verification.dart';
import 'package:tgp_flutter2/ui/profile_info/line/line.dart';
import 'package:tgp_flutter2/ui/profile_info/messenger/messenger.dart';
import 'package:tgp_flutter2/ui/profile_info/password/edit_password.dart';
import 'package:tgp_flutter2/ui/profile_info/pay_password/pay_password.dart';
import 'package:tgp_flutter2/ui/profile_info/pay_password/reset_pay_password.dart';
import 'package:tgp_flutter2/ui/profile_info/phone/edit_phone.dart';
import 'package:tgp_flutter2/ui/profile_info/phone/phone_verification.dart';
import 'package:tgp_flutter2/ui/profile_info/profile_info.dart';
import 'package:tgp_flutter2/ui/profile_info/qq_account/qq_account.dart';
import 'package:tgp_flutter2/ui/profile_info/real_name/real_name_verification.dart';
import 'package:tgp_flutter2/ui/profile_info/telegram/telegram.dart';
import 'package:tgp_flutter2/ui/profile_info/viber/viber.dart';
import 'package:tgp_flutter2/ui/profile_info/wechat/wechat.dart';
import 'package:tgp_flutter2/ui/profile_info/whatsapp/whatsapp.dart';
import 'package:tgp_flutter2/ui/promotion/promotion.dart';
import 'package:tgp_flutter2/ui/report/report_view.dart';
import 'package:tgp_flutter2/ui/splash/splash.dart';
import 'package:api/localizations/language_provider.dart';
import 'package:api/localizations/my_localizations.dart';
import 'package:tgp_flutter2/ui/transfer/wallet_transfer.dart';
import 'package:tgp_flutter2/ui/vip/vip.dart';
import 'package:tgp_flutter2/ui/withdraw/withdraw.dart';
import 'package:tgp_flutter2/ui/favourite/favourite.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) async {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state!.setLocale(newLocale);
  }
}

class _MyAppState extends BaseState<MyApp> with WidgetsBindingObserver {
  final appTitle = EnvironmentConfig.appTitleName;

  Locale? _locale;
  var langList;
  var _vm = MainViewModel();
  var firstInit = true;

  var trackAutomaticEvents = true;
  Mixpanel? mixpanel;

  late Future<EventResult<dynamic>> _future;
  bool isOffline = false;

  // var _assetsAudioPlayer;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  _getLocale() async {
    await LanguageProvider.getSingleton().refreshLangList();
    await LanguageProvider.getSingleton().getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
  }

  Future<EventResult<dynamic>> initData() async {
    _checkNetworkConnection();

    if (firstInit) {
      LanguageProvider.getSingleton().init(EnvironmentConfig.brandName);

      // if (_vm.authApiState?.isMaintenance ?? false) {
      //   //prevent loop
      //   return _vm.authApiState; //return if maintenance
      // }
      // if (_vm.authApiState?.isError ?? false) {
      //   _getLocale();
      //   return _vm.authApiState;
      // }

      await _vm.getAuthToken();

      if (_vm.authApiState?.isMaintenance ?? false) {
        _getLocale(); //temp for localization for mainteance page
        await _vm.getEnvFeatures(); // call when authApiState is Maintenance
        return _vm.authApiState; //return if maintenance
      }

      if (_vm.authApiState?.isError ?? false) {
        await _getLocale();
        return _vm.authApiState;
      }

      await _vm.getEnvFeatures();
      if (_vm.config?.haveDownloadFeature ?? false) {
        await _vm.getVersion();
      }

      await _vm.getLanguageOption();
      _vm.getApiError();
      _vm.getBrandLogo();
      await _vm.resumeIfNeed();
      _vm.getPayment();
      // _vm.autoLogin();
      setState(() {
        firstInit = false;
      });
      _getLocale();
      langList = LanguageProvider.getSingleton().list.map((e) => e.locale).toList();
      _getAssetsAudioPlayer();
      GlobalValueUtil.updateLanguageCode();
      return _vm.getLanguageApiState;
    } else
      // _getAssetsAudioPlayer();
      return EventResult.loading();
  }

/*  Future<EventResult<LoginResponse>> initAuthToken() async {
    if (firstInit) {
      await _vm.getAuthToken();
      return _vm.authApiState;
    } else
      return EventResult.loading();
  }*/

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init("1a61aa796c9652147bf4d602cd58de22", trackAutomaticEvents: true);
  }

  _checkNetworkConnection() {
    // Initialize and listen to network connectivity changes.
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        // Set isOffline based on the network connectivity result
        isOffline = result == ConnectivityResult.none;
      });
    });

    // Check the initial connectivity state.
    Connectivity().checkConnectivity().then((ConnectivityResult result) {
      setState(() {
        // Set isOffline based on the initial connectivity state
        isOffline = result == ConnectivityResult.none;
      });
    });
  }

  @override
  void initState() {
    // _assetsAudioPlayer = AssetsAudioPlayer.newPlayer();

    WidgetsBinding.instance.addObserver(this);

    initMixpanel();

    _future = initData();

    super.initState();
  }

  @override
  void dispose() {
    GlobalValueUtil.stopsong();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);

    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      if (EnvironmentConfig.template_version == 15 && EnvironmentConfig.dark_mode) {
        if (GlobalValueUtil.playerStatus != AssetPlayerStatus.manualClickPause) {
          GlobalValueUtil.playsong();
        }
      } else {
        GlobalValueUtil.playsong();
      }
    } else {
      print("stop when close");
      GlobalValueUtil.pausesong();
    }
  }

  // Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
  //
  //   print(state);

  // if (state == AppLifecycleState.resumed) {
  //   if (EnvironmentConfig.template_version == 15 && EnvironmentConfig.dark_mode) {
  //     if (GlobalValueUtil.playerStatus != AssetPlayerStatus.manualClickPause) {
  //       GlobalValueUtil.playsong();
  //     }
  //   } else {
  //     GlobalValueUtil.playsong();
  //   }
  //
  //   if(isOffline){
  //     setState(() {
  //       _future = initData();
  //     });
  //   }
  // } else {
  //   print("stop when close");
  //   GlobalValueUtil.pausesong();
  // }
  // }

  _getAssetsAudioPlayer() {
    if (_vm.config?.backgroundMusic ?? false || (EnvironmentConfig.template_version == 15 && EnvironmentConfig.dark_mode)) {
      // GlobalValueUtil.assetsAudioPlayer = AssetsAudioPlayer.newPlayer();
      GlobalValueUtil.assetsAudioPlayer.open(
        Playlist(audios: [
          Audio("audio/${EnvironmentConfig.template_version == 15 ? "sky8BgMusic.mp3" : "caishendao.mp3"}"),
        ]),
        loopMode: LoopMode.playlist, //loop the full playlist
      );
      print("diuneiiss");
      GlobalValueUtil.pausesong();
    }
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    // _handleApiState();
    // if (GlobalValueUtil.playerStatus == AssetPlayerStatus.returnHome){
    //   _assetsAudioPlayer.play();
    // }else {
    //   _assetsAudioPlayer.pause();
    // }
    return FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<EventResult<dynamic>> snapshot) {
          print(snapshot.connectionState);
          _handleApiState();

          if (!snapshot.hasData) {
            return MaterialApp(debugShowCheckedModeBanner: false, home: Splash(isOffline: isOffline));
          } else {
            return GestureDetector(
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                  currentFocus.focusedChild!.unfocus();
                }
              },
              child: MaterialApp(
                navigatorObservers: [routeObserver],
                theme: ThemeData(canvasColor: EnvironmentConfig.template_version == 15 ? CustomColor.theme_bg_color : Colors.white),
                debugShowCheckedModeBanner: false,
                title: appTitle,
                initialRoute: (() {
                  if (snapshot.data?.isMaintenance ?? false)
                    return RoutePath.splashMaintenance;
                  else if (snapshot.data?.isError ?? false)
                    return RoutePath.splash;
                  else
                    return RoutePath.myHome;
                }()),
                routes: {
                  RoutePath.splash: (context) => Splash(isOffline: isOffline),
                  RoutePath.myHome: (context) => BottomNavigationController(
                        versionUpdate: _vm.versionUpdateState,
                        isFirstRun: true,
                        // onPauseBgMusic: () => GlobalValueUtil.pausesong(),
                        // onResumeBgMusic: () => GlobalValueUtil.playsong(),
                      ),
                  RoutePath.profile: (context) => Profile(),
                  RoutePath.csWebView: (context) => CustomerServiceWebView(),
                  RoutePath.customerService: (context) => CustomerService(),
                  RoutePath.transaction: (context) => ReportView(),
                  RoutePath.login: (context) => EnvironmentConfig.template_version == 15
                      ? LoginTemplate02(
                          onResumeBgMusic: () => GlobalValueUtil.playsong(),
                          onPauseBgMusic: () => GlobalValueUtil.pausesong(),
                        )
                      : Login(),
                  RoutePath.register: (context) => EnvironmentConfig.template_version == 15
                      ? LoginTemplate02(
                          defaultRegisterTab: true,
                          onResumeBgMusic: () => GlobalValueUtil.playsong(),
                          onPauseBgMusic: () => GlobalValueUtil.pausesong(),
                        )
                      : Login(defaultRegisterTab: true),
                  RoutePath.forgotPassword: (context) => ForgotPassword(),
                  RoutePath.maintenance: (context) => Maintenance(
                        onResumeBgMusic: () => GlobalValueUtil.playsong(),
                      ),
                  RoutePath.splashMaintenance: (context) => Maintenance(
                        isShowCS: true,
                        isShowsAppBar: false,
                      ),
                  RoutePath.customerServiceWebView: (context) => CustomerServiceWebView(),
                  RoutePath.mainCard: (context) => MainCard(),
                  RoutePath.message: (context) => MessageView(),
                  RoutePath.emailVerification: (context) => EmailVerification(0),
                  RoutePath.qqAccount: (context) => QQAccount(),
                  RoutePath.wechat: (context) => Wechat(),
                  RoutePath.editPassword: (context) => EditPassword(),
                  RoutePath.resetPayPassword: (context) => ResetPayPassword(),
                  RoutePath.payPassword: (context) => PayPassword(),
                  RoutePath.language: (context) => LanguageView(),
                  RoutePath.addCard: (context) => AddCard(),
                  RoutePath.realNameVerification: (context) => RealNameVerification(),
                  RoutePath.profileInfo: (context) => ProfileInfo(),
                  RoutePath.promotion: (context) => Promotion(),
                  RoutePath.walletTransfer: (context) => WalletTransfer(),
                  RoutePath.menu: (context) => Menu(),
                  RoutePath.deposit: (context) => Deposit(),
                  RoutePath.withdraw: (context) => Withdraw(),
                  //RoutePath.childGame: (context) => ChildGame(),
                  RoutePath.blacklistedUser: (context) => BlacklistedUser(),
                  //RoutePath.phoneReVerification: (context) => PhoneReVerification(),
                  RoutePath.phoneVerification: (context) => PhoneVerification(),
                  RoutePath.editPhone: (context) => EditPhone(),
                  RoutePath.editEmail: (context) => EditEmail(),
                  RoutePath.csWebView: (context) => CustomerServiceWebView(),
                  RoutePath.affiliate: (context) => Affiliate(),
                  RoutePath.vip: (context) => VipView(),
                  RoutePath.menuT2: (context) => MenuT2(),
                  RoutePath.messenger: (context) => Messenger(),
                  RoutePath.telegram: (context) => Telegram(),
                  RoutePath.line: (context) => Line(),
                  RoutePath.viber: (context) => Viber(),
                  RoutePath.whatsapp: (context) => Whatsapp(),
                  RoutePath.birthdate: (context) => Birthdate(),
                  RoutePath.memo: (context) => Memo(),
                  RoutePath.announcement: (context) => Announcement(),
                  RoutePath.favourite: (context) => Favourite(),
                },
                localizationsDelegates: [
                  MyLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate
                ],
                // MyHomePage(title: appTitle),
                supportedLocales: LanguageProvider.getSingleton().list.map((e) => e.locale).toList(),
                locale: _locale,
                localeResolutionCallback: (locale, supportedLocales) {
                  for (var supportedLocale in supportedLocales) {
                    if (supportedLocale.languageCode == locale!.languageCode && supportedLocale.scriptCode == locale.scriptCode) {
                      return supportedLocale;
                    }
                  }
                  return supportedLocales.first;
                },
              ),
            );
          }
        });
  }

  _handleApiState() {
    handleApiState(_vm.getLanguageApiState, isAutoHideLoading: false, isSplashScreen: true, onSuccess: () {});
    handleApiState(_vm.getBrandLogoApiState, isAutoHideLoading: false, isSplashScreen: true, onSuccess: () {});
    handleApiState(_vm.authApiState, isAutoHideLoading: false, isSplashScreen: true, onSuccess: () {
      mixpanel?.track("Signed Up");
    }, onError: (errorMsg) {
      print("mixpanelllll tracked auth on error: $errorMsg");

      mixpanel?.track("Auth on error", properties: {'errorMsg': "whhwhshshs"});
    });
    handleApiState(_vm.autoLoginApiState, isAutoHideLoading: false, isSplashScreen: true, onSuccess: () {});
  }
}

// class MyHomePage extends StatefulWidget {
//   final bool isFirstRun;
//   final int? index;
//   final dynamic versionUpdate;
//   final Function? onResumeBgMusic;
//   final Function? onPauseBgMusic;
//   final bool isDisplayingDepositDialog = false;
//
//   MyHomePage({
//     this.isFirstRun = false,
//     this.index,
//     this.versionUpdate,
//     this.onPauseBgMusic,
//     this.onResumeBgMusic,
//   });
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends BaseState<MyHomePage> with WidgetsBindingObserver {
//   int currentBottomIndex = 0;
//   List _page = [];
//   var isMenu = false;
//   var _vm = MainViewModel();
//   var isDisplayGameView = false;
//
//   onClickGameTab(value) {
//     setState(() {
//       isDisplayGameView = value;
//     });
//   }
//
//   // _getAssetsAudioPlayer() {
//   //   if (_vm.config?.backgroundMusic ??
//   //       false || EnvironmentConfig.template_version == 15) {
//   //     this.assetsAudioPlayer.open(
//   //       Playlist(audios: [
//   //         Audio(
//   //             "audio/${EnvironmentConfig.template_version == 15 ? "sky8BgMusic.mp3" : "caishendao.mp3"}"),
//   //       ]),
//   //       loopMode: LoopMode.playlist, //loop the full playlist
//   //     );
//   //     print("diuneiiss");
//   //     assetsAudioPlayer.pause();
//   //   }
//   //   WidgetsBinding.instance.addObserver(this);
//   // }
//
//   // void didChangeAppLifecycleState(AppLifecycleState state) {
//   //   if (state == AppLifecycleState.resumed) {
//   //     if (EnvironmentConfig.template_version == 15) {
//   //       if (GlobalValueUtil.playerStatus !=
//   //           AssetPlayerStatus.manualClickPause) {
//   //         assetsAudioPlayer.play();
//   //       }
//   //     } else {
//   //       assetsAudioPlayer.play();
//   //     }
//   //   } else {
//   //     assetsAudioPlayer.pause();
//   //   }
//   // }
//
//   @override
//   void initState() {
//     if (widget.versionUpdate != null) {
//       Future.delayed(Duration.zero, () => _showNewVersionUpdateDialog(widget.versionUpdate));
//     }
//     // GlobalValueUtil.assetsAudioPlayer.stop();
//     // GlobalValueUtil.assetsAudioPlayer.play();
//     // assetsAudioPlayer = AssetsAudioPlayer.newPlayer();
//     // _getAssetsAudioPlayer();
//     if (widget.index != null) currentBottomIndex = widget.index!;
//     _page = EnvironmentConfig.template_version != 11
//         ? [
//             Home(
//               onPauseBgMusic: () => GlobalValueUtil.pausesong(),
//               onResumeBgMusic: () => GlobalValueUtil.playsong(),
//             ),
//             Promotion(),
//             EnvironmentConfig.template_version == 2 ? MenuT2() : Menu(),
//             CustomerService(),
//             Profile(),
//           ]
//         : [
//             Home(
//               isDisplayGameView: isDisplayGameView,
//               onClickGameTab: (value) => onClickGameTab(value),
//             ),
//             Promotion(),
//             Deposit(),
//             Withdraw(),
//             Profile(),
//           ];
//     print("masukkkk11");
//     // if (widget.onResumeBgMusic != null) widget.onResumeBgMusic!();
//     // if (widget.onPauseBgMusic != null) widget.onPauseBgMusic!();
//     /*if (EnvironmentConfig.brandName.toLowerCase().contains("idr")) */
//     _initWebSocket();
//     super.initState();
//   }
//
//   @override
//   void deactivate() {
//     GlobalValueUtil.stopsong();
//     super.deactivate();
//   }
//
//   @override
//   void dispose() {
//     GlobalValueUtil.stopsong();
//     super.dispose();
//   }
//
//   _initWebSocket() async {
//     bool _isOpen = false;
//     if (_vm.userProfile != null) {
//       print("connect to signalR");
//
//       WebSocketDeposit.getInstance(onReceive: (WsResponse value) {
//         print(value);
//
//         if (value.type?.toLowerCase() == "viprebate") {
//           // check previous dialog is showing
//           if (_isOpen) {
//             setState(() {
//               _isOpen = false;
//             });
//             Navigator.pop(context);
//           }
//
//           _isOpen = true;
//           showDialog(
//               context: context,
//               barrierColor: Color(0x01000000),
//               builder: (BuildContext context) => VipRebateDialog(
//                     data: value,
//                     closeDialog: () {
//                       //check is still showing
//                       if (_isOpen) {
//                         setState(() {
//                           _isOpen = false;
//                         });
//                         Navigator.pop(context);
//                       }
//                     },
//                   ));
//         } else {
//           showDialog(context: context, builder: (BuildContext context) => DepositOrderDialog(data: value, depositList: _vm.depositList));
//         }
//       })?.connect();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ScrollConfiguration(
//       behavior: MyBehavior(),
//       child: Stack(
//         children: [
//           Scaffold(
//             extendBody: false,
//             body: Stack(
//               children: [
//                 Center(
//                   child: _page[currentBottomIndex],
//                 ),
//                 _buildOverlay(),
//                 _buildMenu()
//               ],
//             ),
//             bottomNavigationBar: ((EnvironmentConfig.template_version == 8 || EnvironmentConfig.template_version == 9) && EnvironmentConfig.dark_mode)
//                 ? Container(
//                     child: BottomAppBar(
//                         child: Container(
//                       decoration: EnvironmentConfig.template_version == 8
//                           ? BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [Color(0xff011F60), Colors.transparent.withOpacity(1.0)],
//                                 begin: Alignment.bottomCenter,
//                                 end: Alignment.topCenter,
//                               ),
//                             )
//                           : BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [
//                                   //Color.fromRGBO(0, 1, 41, -0.1),
//                                   CustomColor.theme_bar_gradient_2,
//                                   Color.fromRGBO(199, 219, 231, 0.9),
//                                   // Colors.white.withOpacity(1.0)
//                                 ],
//                                 begin: Alignment.bottomCenter,
//                                 end: Alignment.topCenter,
//                               ),
//                             ),
//                       child: _buildBottomAppBarRow(),
//                     )),
//                   )
//                 : EnvironmentConfig.template_version == 15
//                     ? Container(
//                         decoration:
//                             BoxDecoration(borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)), color: Colors.white),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(30.0),
//                             topRight: Radius.circular(30.0),
//                           ),
//                           child: BottomAppBar(
//                             color: Colors.white,
//                             child: _buildBottomAppBarRow(),
//                           ),
//                         ))
//                     : BottomAppBar(
//                         color: CustomColor.theme_bottom_app_bar_color,
//                         child: _buildBottomAppBarRow(),
//                       ),
//           ),
//           /*Positioned(
//                 bottom: context.screenWidth / 7 + (IphoneHasNotch.hasNotch ? 20 : 0),
//                 right: -10,
//                 child: RawMaterialButton(
//                   onPressed: () {
//                     FlutterLivechatPlugin.beginChat("14246631");
//                   },
//                   elevation: 2.0,
//                   fillColor: Color(0xff6819d2),
//                   child: ImageIcon(
//                     AssetImage("images/livechat.png"),
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                   padding: EdgeInsets.all(15.0),
//                   shape: CircleBorder(),
//                 ),
//               ),*/
//         ],
//       ),
//     );
//   }
//
//   _getCustomThirdPositionItem() {
//     switch (EnvironmentConfig.template_version) {
//       case 2:
//         return _buildBottomBarItem(2, "ic_menu", "");
//       case 15:
//         return _buildBottomBarItem(6, "ic_cs", "customer_service");
//       default:
//         return _buildBottomBarItem(
//             2,
//             "ic_deposit",
//             (EnvironmentConfig.template_version == 11 || EnvironmentConfig.template_version == 15 || EnvironmentConfig.template_version == 14)
//                 ? "deposit"
//                 : "wallet",
//             isNeedLogin: true);
//     }
//   }
//
//   _getCustomFourthPositionItem() {
//     switch (EnvironmentConfig.template_version) {
//       case 11:
//         return _buildBottomBarItem(3, "ic_withdraw", "withdrawal", isNeedLogin: true);
//       case 15:
//         return _buildBottomBarItem(
//             2, "ic_deposit", (EnvironmentConfig.template_version == 11 || EnvironmentConfig.template_version == 15) ? "deposit" : "wallet",
//             isNeedLogin: true);
//       default:
//         return SizedBox.shrink();
//     }
//   }
//
//   _buildBottomAppBarRow() => Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           _buildBottomBarItem(
//             0,
//             "ic_home",
//             "home",
//           ),
//           _buildBottomBarItem(1, "ic_promotion", "promotion"),
//           _getCustomThirdPositionItem(),
//           _getCustomFourthPositionItem(),
//           EnvironmentConfig.template_version == 15 ? SizedBox.shrink() : _buildBottomBarItem(6, "ic_cs", "customer_service"),
//           _buildBottomBarItem(
//             4,
//             "ic_profile",
//             "my_profile",
//             isNeedLogin: true,
//           ),
//         ],
//       );
//
//   _buildBottomBarItem(int index, String imagePath, String title, {bool isNewMessage = false, bool isNeedLogin = false}) => Expanded(
//         child: Stack(
//           children: [
//             SizedBox(
//               height: context.screenWidth / 7,
//               width: context.screenWidth / 5,
//               child: Material(
//                 type: MaterialType.transparency,
//                 child: InkWell(
//                   onTap: () async {
//                     if (isNeedLogin) {
//                       if (_vm.userProfile == null) {
//                         showPreLoginDialog();
//                         return;
//                       }
//                     }
//                     if (EnvironmentConfig.template_version == 15 && widget.onPauseBgMusic != null) {
//                       if (GlobalValueUtil.playerStatus != AssetPlayerStatus.manualClickPause) {
//                         if (widget.onPauseBgMusic != null) widget.onPauseBgMusic!();
//                         GlobalValueUtil.pausesong();
//                         GlobalValueUtil.playerStatus = AssetPlayerStatus.leavePagePause;
//                       }
//                     }
//                     if (EnvironmentConfig.template_version == 11 && index == 0 && isDisplayGameView)
//                       //will refresh page for t11
//                       Navigator.pushReplacement(
//                         context,
//                         PageRouteBuilder(
//                           pageBuilder: (context, animation1, animation2) => BottomNavigationController(),
//                           transitionDuration: Duration.zero,
//                           reverseTransitionDuration: Duration.zero,
//                         ),
//                       );
//                     else if ((EnvironmentConfig.template_version == 11 ||
//                             EnvironmentConfig.template_version == 15 ||
//                             EnvironmentConfig.template_version == 14) &&
//                         index == 2)
//                       Navigator.of(context).pushNamed(RoutePath.deposit);
//                     else if ((EnvironmentConfig.template_version == 11 || EnvironmentConfig.template_version == 15) && index == 3)
//                       Navigator.of(context).pushNamed(RoutePath.withdraw);
//                     else if (index == 1)
//                       Navigator.push(context, MaterialPageRoute(builder: (context) => Promotion()));
//                     //Navigator.pushNamed(context, RoutePath.addCard);
//                     //   Navigator.of(context). pushNamed("/promotion");
//                     else if (index == 6)
//                       Navigator.of(context).pushNamed("/customer_service");
//                     else if (index == 2 && EnvironmentConfig.template_version != 2)
//                       setState(() {
//                         isMenu = !isMenu;
//                       });
//                     else if (index == 2 && EnvironmentConfig.template_version == 2)
//                       setState(() {
//                         Navigator.of(context).pushNamed(RoutePath.menuT2);
//                       });
//                     else
//                       setState(() {
//                         isMenu = false;
//                         currentBottomIndex = index;
//                       });
//                   },
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: <Widget>[
//                       _buildImageIcon(imagePath, index, isNewMessage),
//                       if (title.isNotEmpty)
//                         Container(
//                           margin: EdgeInsets.only(top: 3.auto),
//                           child: Text(
//                             getTranslatedText(title) ?? title,
//                             style: TextStyle(
//                               fontSize: 9.auto,
//                               color: (currentBottomIndex == index && !isMenu) ? CustomColor.bottom_nav_selected_color : CustomColor.bottom_nav_unselected_color,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//
//   _buildImageIcon(String imagePath, int index, bool isNewMessage) {
//     if (EnvironmentConfig.template_version == 11 && imagePath != "ic_home" && imagePath != "ic_profile" && imagePath != "ic_cs") {
//       return Container(
//         height: 30,
//         alignment: Alignment.topCenter,
//         child: Image.asset(
//           "images/bottom_nav_bar/T11/$imagePath.gif",
//           fit: BoxFit.fitHeight,
//         ),
//       );
//     } else if (index == 2 && imagePath == "ic_menu") {
//       return Container(
//         height: 35.auto,
//         padding: EdgeInsets.symmetric(vertical: 5),
//         child: CircleAvatar(
//           backgroundColor: CustomColor.theme_title_text_color,
//           child: ImageIcon(
//             AssetImage(
//               "images/bottom_nav_bar/$imagePath.png",
//             ),
//             size: 20.auto,
//             color: currentBottomIndex == index ? Colors.yellow : Colors.white,
//           ),
//         ),
//       );
//     } else if ((EnvironmentConfig.template_version == 2 && (imagePath == "ic_home" || imagePath == "ic_profile" || imagePath == "ic_promotion")) ||
//         (EnvironmentConfig.template_version == 11 && (imagePath == "ic_home" || imagePath == "ic_profile"))) {
//       return Container(
//         height: 20.auto,
//         child: ImageIcon(
//           AssetImage(
//             "images/bottom_nav_bar/T2/$imagePath.png",
//           ),
//           size: 20.auto,
//           color: currentBottomIndex == index ? CustomColor.bottom_nav_selected_color : CustomColor.bottom_nav_unselected_color,
//         ),
//       );
//     } else if (EnvironmentConfig.template_version == 15 ) {
//       return Container(
//           height: 25.auto,
//           child: Image.asset(
//             currentBottomIndex == index ? "images/bottom_nav_bar/T15/$imagePath-selected.png" : "images/bottom_nav_bar/T15/$imagePath.png",
//           ));
//     } else if (EnvironmentConfig.template_version == 14 && imagePath != "ic_cs") {
//       return Container(
//           height: 22.auto,
//           child: SvgPicture.asset(
//             "images/bottom_nav_bar/T14/$imagePath.svg",
//             height: 22.auto,
//           ));
//     } else {
//       return Container(
//         padding: (EnvironmentConfig.template_version == 15) ? EdgeInsets.zero : EdgeInsets.only(top: 5),
//         child: SvgPicture.asset(
//           "images/bottom_nav_bar/$imagePath.svg",
//           matchTextDirection: true,
//           height: 22.auto,
//           color: currentBottomIndex == index && !isMenu ? CustomColor.bottom_nav_selected_color : CustomColor.bottom_nav_unselected_color,
//         ),
//       );
//     }
//   }
//
//   _closeMenu() {
//     setState(() {
//       isMenu = false;
//     });
//   }
//
//   _buildMenu() => Visibility(
//         visible: isMenu,
//         child: Menu(),
//       );
//
//   _buildOverlay() => Visibility(
//         visible: isMenu,
//         child: ColorFiltered(
//           colorFilter: ColorFilter.mode(Colors.black54, BlendMode.srcOut),
//           child: Stack(
//             children: [
//               GestureDetector(
//                 onTap: _closeMenu,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.transparent,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//
//   _showNewVersionUpdateDialog(dynamic data) {
//     showDialog(
//         context: context,
//         builder: (BuildContext context) => CustomDialog(
//             title: getTranslatedText("New update: ${data["version"]}"),
//             description: data["content"],
//             buttonText1: getTranslatedText("update"),
//             onClick: () {
//               Navigator.pop(
//                 context,
//               );
//               launch(data["link"]);
//             }));
//   }
// }
