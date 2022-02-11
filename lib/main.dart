import 'package:api/api.dart';
import 'package:api/entity/language_option.dart';
import 'package:api/entity/response/login_response.dart';
import 'package:api/network/event_result.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/main_view_model.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/affiliate/affiliate.dart';
import 'package:tgp_flutter2/ui/blacklisted_user/blacklisted_user.dart';
import 'package:tgp_flutter2/ui/card/add_card.dart';
import 'package:tgp_flutter2/ui/card/main_card.dart';
import 'package:tgp_flutter2/ui/customer_service/customer_service.dart';
import 'package:tgp_flutter2/ui/customer_service/customer_service_web_view.dart';
import 'package:tgp_flutter2/ui/deposit/deposit.dart';
import 'package:tgp_flutter2/ui/forgot_password/forgot_password.dart';
import 'package:tgp_flutter2/ui/home/child_game/child_game.dart';
import 'package:tgp_flutter2/ui/home/home_t1.dart';
import 'package:tgp_flutter2/ui/home/home_t2.dart';
import 'package:tgp_flutter2/ui/home/home_t3.dart';
import 'package:tgp_flutter2/ui/language/language_view.dart';
import 'package:tgp_flutter2/ui/login/login.dart';
import 'package:tgp_flutter2/ui/login/phone_re_verification/phone_re_verification.dart';
import 'package:tgp_flutter2/ui/maintenance/maintenance.dart';
import 'package:tgp_flutter2/ui/menu/menu.dart';
import 'package:tgp_flutter2/ui/message/message_view.dart';
import 'package:tgp_flutter2/ui/profile/profile.dart';
import 'package:tgp_flutter2/ui/profile_info/email/edit_email.dart';
import 'package:tgp_flutter2/ui/profile_info/email/email_verification.dart';
import 'package:tgp_flutter2/ui/profile_info/password/edit_password.dart';
import 'package:tgp_flutter2/ui/profile_info/pay_password/pay_password.dart';
import 'package:tgp_flutter2/ui/profile_info/pay_password/reset_pay_password.dart';
import 'package:tgp_flutter2/ui/profile_info/phone/edit_phone.dart';
import 'package:tgp_flutter2/ui/profile_info/phone/phone_verification.dart';
import 'package:tgp_flutter2/ui/profile_info/profile_info.dart';
import 'package:tgp_flutter2/ui/profile_info/qq_account/qq_account.dart';
import 'package:tgp_flutter2/ui/profile_info/real_name/real_name_verification.dart';
import 'package:tgp_flutter2/ui/profile_info/wechat/wechat.dart';
import 'package:tgp_flutter2/ui/promotion/promotion.dart';
import 'package:tgp_flutter2/ui/report/report_view.dart';
import 'package:tgp_flutter2/ui/splash/splash.dart';
import 'package:api/localizations/language_provider.dart';
import 'package:api/localizations/my_localizations.dart';
import 'package:tgp_flutter2/ui/transfer/wallet_transfer.dart';
import 'package:tgp_flutter2/ui/vip/vip.dart';
import 'package:tgp_flutter2/ui/withdraw/withdraw.dart';
import 'package:url_launcher/url_launcher.dart';

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

class _MyAppState extends BaseState<MyApp> {
  final appTitle = EnvironmentConfig.appTitleName;

  Locale? _locale;
  var langList;
  var _vm = MainViewModel();
  var firstInit = true;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  _getLocale() {
    LanguageProvider.getSingleton().refreshLangList();
    LanguageProvider.getSingleton().getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
  }

  Future<EventResult<dynamic>> initData() async {
    if (firstInit) {
      LanguageProvider.getSingleton().init(EnvironmentConfig.brandName);
      if (_vm.authApiState?.isMaintenance == true) {
        //prevent loop
        return _vm.authApiState; //return if maintenance
      }

      await _vm.getAuthToken();
      //_vm.authApiState.isMaintenance = true;
      if (_vm.authApiState.isMaintenance) {
        _getLocale(); //temp for localization for mainteance page
        return _vm.authApiState; //return if maintenance
      }
      await _vm.getEnvFeatures();
      if (_vm.config?.haveDownloadFeature ?? false) {
        await _vm.getVersion();
      }
      await _vm.getLanguageOption();
      _vm.getApiError();
      _vm.getBrandLogo();
      _vm.resumeIfNeed();
      // _vm.autoLogin();
      setState(() {
        firstInit = false;
      });
      _getLocale();
      langList = LanguageProvider.getSingleton().list.map((e) => e.locale).toList();
      return _vm.getLanguageApiState;
    } else
      return EventResult.loading();
  }

/*  Future<EventResult<LoginResponse>> initAuthToken() async {
    if (firstInit) {
      await _vm.getAuthToken();
      return _vm.authApiState;
    } else
      return EventResult.loading();
  }*/

  @override
  Widget build(BuildContext context) {
    _handleApiState();
    return FutureBuilder(
        future: initData(),
        builder: (BuildContext context, AsyncSnapshot<EventResult<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return MaterialApp(debugShowCheckedModeBanner: false, home: Splash());
          } else {
            return GestureDetector(
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                  currentFocus.focusedChild!.unfocus();
                }
              },
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: appTitle,
                initialRoute: snapshot.data!.isMaintenance ? RoutePath.splashMaintenance : RoutePath.myHome,
                routes: {
                  RoutePath.myHome: (context) => MyHomePage(
                        versionUpdate: _vm.versionUpdateState,
                        isFirstRun: true,
                      ),
                  RoutePath.profile: (context) => Profile(),
                  RoutePath.csWebView: (context) => CustomerServiceWebView(),
                  RoutePath.customerService: (context) => CustomerService(),
                  RoutePath.transaction: (context) => ReportView(),
                  RoutePath.login: (context) => Login(),
                  RoutePath.register: (context) => Login(defaultRegisterTab: true),
                  RoutePath.forgotPassword: (context) => ForgotPassword(),
                  RoutePath.maintenance: (context) => Maintenance(),
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
                  RoutePath.childGame: (context) => ChildGame(),
                  RoutePath.blacklistedUser: (context) => BlacklistedUser(),
                  //RoutePath.phoneReVerification: (context) => PhoneReVerification(),
                  RoutePath.phoneVerification: (context) => PhoneVerification(),
                  RoutePath.editPhone: (context) => EditPhone(),
                  RoutePath.editEmail: (context) => EditEmail(),
                  RoutePath.csWebView: (context) => CustomerServiceWebView(),
                  RoutePath.affiliate: (context) => Affiliate(),
                  RoutePath.vip: (context) => Vip(),
                },
                localizationsDelegates: [
                  MyLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate
                ],
                // MyHomePage(title: appTitle),
                supportedLocales: LanguageProvider.getSingleton().list.map((e) => e.locale).toList(),
                locale: _locale,
                localeResolutionCallback: (locale, supportedLocales) {
                  for (var supportedLocale in supportedLocales) {
                    if (supportedLocale.languageCode == locale!.languageCode &&
                        supportedLocale.scriptCode == locale.scriptCode) {
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
    handleApiState(_vm.authApiState, isAutoHideLoading: false, isSplashScreen: true, onSuccess: () {});
  }
}

class MyHomePage extends StatefulWidget {
  final bool isFirstRun;
  final int? index;
  final dynamic versionUpdate;

  MyHomePage({this.isFirstRun = false, this.index, this.versionUpdate});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends BaseState<MyHomePage> with WidgetsBindingObserver {
  int currentBottomIndex = 0;
  List _page = [];
  var isMenu = false;
  var _vm = MainViewModel();
  var _assetsAudioPlayer;

  @override
  void initState() {
    if (widget.versionUpdate != null) {
      Future.delayed(Duration.zero, () => _showNewVersionUpdateDialog(widget.versionUpdate));
    }

    if (widget.index != null) currentBottomIndex = widget.index!;
    _page = [
      _getHomeTemplateVersion(),
      Promotion(),
      Menu(),
      CustomerService(),
      Profile(),
    ];

    _assetsAudioPlayer = AssetsAudioPlayer.newPlayer();
    if (widget.isFirstRun && (_vm.config?.backgroundMusic ?? false)) {
      _assetsAudioPlayer.open(
        Playlist(audios: [
          Audio("audio/caishendao.mp3"),
        ]),
        loopMode: LoopMode.playlist, //loop the full playlist
      );
    }
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _assetsAudioPlayer.play();
    } else {
      _assetsAudioPlayer.pause();
    }
  }

  _getHomeTemplateVersion() {
    switch (EnvironmentConfig.template_version) {
      case 1:
        return HomeT1(
          onPauseBgMusic: () => _assetsAudioPlayer.pause(),
          onResumeBgMusic: () => _assetsAudioPlayer.play(),
        );
      case 2:
        return HomeT2(
          onPauseBgMusic: () => _assetsAudioPlayer.pause(),
          onResumeBgMusic: () => _assetsAudioPlayer.play(),
        );
      case 3:
        return HomeT3(
          onPauseBgMusic: () => _assetsAudioPlayer.pause(),
          onResumeBgMusic: () => _assetsAudioPlayer.play(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: Scaffold(
        body: Stack(children: [
          Center(
            child: _page[currentBottomIndex],
          ),
          _buildOverlay(),
          _buildMenu()
        ]),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildBottomBarItem(0, "ic_home", "home"),
              _buildBottomBarItem(1, "ic_promotion", "promotion"),
              _buildBottomBarItem(2, "ic_deposit", "wallet", isNeedLogin: true),
              _buildBottomBarItem(3, "ic_cs", "customer_service"),
              _buildBottomBarItem(4, "ic_profile", "my_profile", isNeedLogin: true),
            ],
          ),
        ),
      ),
    );
  }

  _buildBottomBarItem(int index, String imagePath, String title,
          {bool isNewMessage = false, bool isNeedLogin = false}) =>
      Expanded(
        child: Stack(
          children: [
            SizedBox(
              height: context.screenWidth / 7,
              width: context.screenWidth / 5,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () {
                    if (isNeedLogin) {
                      if (_vm.userProfile == null) {
                        showPreLoginDialog();
                        return;
                      }
                    }
                    if (index == 1) {
                      Navigator.of(context).pushNamed("/promotion");
                    } else if (index == 3) {
                      Navigator.of(context).pushNamed("/customer_service");
                    } else if (index == 2) {
                      setState(() {
                        isMenu = !isMenu;
                      });
                    } else {
                      setState(() {
                        isMenu = false;
                        currentBottomIndex = index;
                      });
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _buildImageIcon(imagePath, index, isNewMessage),
                      Container(
                        margin: EdgeInsets.only(top: 3.auto),
                        child: Text(
                          getTranslatedText(title) ?? title,
                          style: TextStyle(
                            fontSize: 9.auto,
                            color: (currentBottomIndex == index && !isMenu)
                                ? CustomColor.bottom_nav_selected_color
                                : CustomColor.bottom_nav_unselected_color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  _buildImageIcon(String imagePath, int index, bool isNewMessage) => imagePath == "ic_deposit"
      ? Image.asset(
          "images/bottom_nav_bar/$imagePath.png",
          matchTextDirection: true,
          height: 18.auto,
        )
      : SvgPicture.asset(
          "images/bottom_nav_bar/$imagePath.svg",
          matchTextDirection: true,
          height: 18.auto,
          color: currentBottomIndex == index && !isMenu
              ? CustomColor.bottom_nav_selected_color
              : CustomColor.bottom_nav_unselected_color,
        );

  _closeMenu() {
    setState(() {
      isMenu = false;
    });
  }

  _buildMenu() => Visibility(
        visible: isMenu,
        child: Menu(),
      );

  _buildOverlay() => Visibility(
        visible: isMenu,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.black54, BlendMode.srcOut),
          child: Stack(
            children: [
              GestureDetector(
                onTap: _closeMenu,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  _showNewVersionUpdateDialog(dynamic data) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
            title: getTranslatedText("New update: ${data["version"]}"),
            description: data["content"],
            buttonText1: getTranslatedText("update"),
            onClick: () {
              Navigator.pop(
                context,
              );
              launch(data["link"]);
            }));
  }
}
