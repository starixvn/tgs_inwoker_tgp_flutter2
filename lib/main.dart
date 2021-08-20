import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/customer_service/customer_service.dart';
import 'package:tgp_flutter2/ui/customer_service/customer_service_web_view.dart';
import 'package:tgp_flutter2/ui/forgot_password/forgot_password.dart';
import 'package:tgp_flutter2/ui/home/home.dart';
import 'package:tgp_flutter2/ui/login/login.dart';
import 'package:tgp_flutter2/ui/maintenance/maintenance.dart';
import 'package:tgp_flutter2/ui/message/message.dart';
import 'package:tgp_flutter2/ui/profile/profile.dart';
import 'package:tgp_flutter2/ui/profile_info/email/email_verification.dart';
import 'package:tgp_flutter2/ui/profile_info/password/edit_password.dart';
import 'package:tgp_flutter2/ui/profile_info/pay_password/pay_password.dart';
import 'package:tgp_flutter2/ui/profile_info/pay_password/reset_pay_password.dart';
import 'package:tgp_flutter2/ui/profile_info/profile_info.dart';
import 'package:tgp_flutter2/ui/profile_info/qq_account/qq_account.dart';
import 'package:tgp_flutter2/ui/profile_info/real_name/real_name_verification.dart';
import 'package:tgp_flutter2/ui/profile_info/wechat/wechat.dart';
import 'package:tgp_flutter2/ui/promotion/promotion.dart';
import 'package:tgp_flutter2/ui/splash/splash.dart';
import 'package:api/localizations/language_provider.dart';
import 'package:api/localizations/my_localizations.dart';
import 'package:tgp_flutter2/ui/transaction/deposit_withdraw_transaction.dart';
import 'package:tgp_flutter2/ui/transaction/transaction.dart';

Future main() async {
  //await DotEnv.load();
  // await DotEnv.load(fileName: ".env");
  // PackageInfo packageInfo = await PackageInfo.fromPlatform();
  // DotEnv.env["appName"] = packageInfo.appName;
  // // String packageName = packageInfo.packageName;
  // // String version = packageInfo.version;
  // // String buildNumber = packageInfo.buildNumber;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) async {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(newLocale);
  }
}

class _MyAppState extends BaseState<MyApp> {
  final appTitle = EnvironmentConfig.appTitleName;

  Locale _locale;
  var langList = LanguageProvider().list.map((e) => e.locale).toList();

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LanguageProvider().getLocale().then((locale) {
        setState(() {
          this._locale = locale;
        });
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          currentFocus.focusedChild.unfocus();
        }
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: appTitle,
        initialRoute: '/',
        routes: {
          RoutePath.empty: (context) => Splash(),
          RoutePath.home: (context) => Home(),
          RoutePath.myHome: (context) => MyHomePage(),
          RoutePath.profile: (context) => Profile(),
          RoutePath.csWebView: (context) => CustomerServiceWebView(),
          RoutePath.customerService: (context) => CustomerService(),
          RoutePath.transaction: (context) => Transaction(),
          RoutePath.login: (context) => Login(),
          RoutePath.forgotPassword: (context) => ForgotPassword(),
          RoutePath.maintenance: (context) => Maintenance(),
          //RoutePath.mainCard: (context) => MainCard(),
          RoutePath.message: (context) => Message(),
          RoutePath.emailVerification: (context) => EmailVerification(0),
          RoutePath.qqAccount: (context) => QQAccount(),
          RoutePath.wechat: (context) => Wechat(),
          RoutePath.editPassword: (context) => EditPassword(),
          RoutePath.resetPayPassword: (context) => ResetPayPassword(),
          RoutePath.payPassword: (context) => PayPassword(),
          // RoutePath.language: (context) => LanguageView(),
          // RoutePath.addCard: (context) => AddCard(),
          RoutePath.realNameVerification: (context) => RealNameVerification(),
          RoutePath.profileInfo: (context) => ProfileInfo(),
          RoutePath.depositWithdrawTransaction: (context) => DepositWithdrawTransactionView(),
          RoutePath.promotion: (context) => Promotion(),
          /* RoutePath.menu: (context) => Menu(),

          RoutePath.childGame: (context) => ChildGame(),
          RoutePath.deposit: (context) => Deposit(),
          RoutePath.walletTransfer: (context) => WalletTransfer(),
          RoutePath.withdraw: (context) => Withdraw(),
          RoutePath.frequentQuestion: (context) => FrequentQuestion(),
          RoutePath.referFriend: (context) => ReferFriend(),
          RoutePath.realNameVerification: (context) => RealNameVerification(),
          RoutePath.phoneVerification: (context) => PhoneVerification(),
          RoutePath.address: (context) => Address(),

          RoutePath.securityAnswer: (context) => SecurityAnswer(),
          RoutePath.editSecurityAnswer: (context) => EditSecurityAnswer(),
          RoutePath.editSecurityAnswerBySecurityAnswer: (context) => EditSecurityAnswerBySecurityAnswer(),

          RoutePath.promotionItemDetails: (context) => PromotionItemDetails(),
          RoutePath.csQrCode: (context) => CustomerServiceQrCode()*/
        },
        localizationsDelegates: [
          MyLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        // MyHomePage(title: appTitle),
        supportedLocales: langList,
        locale: _locale,
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.scriptCode == locale.scriptCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final bool isFirstRun;
  final int index;

  MyHomePage({this.isFirstRun, this.index});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends BaseState<MyHomePage> {
  int currentBottomIndex = 0;
  List _page = [
    Promotion(),
    Transaction(),
    DepositWithdrawTransactionView(),
    CustomerService(),
    Profile(),
  ];
  var path;

  @override
  void initState() {
    if (widget.index != null) currentBottomIndex = widget.index;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: Scaffold(
        body: Center(
          child: _page[currentBottomIndex],
        ),
        bottomNavigationBar: SizedBox(
          height: 43.auto,
          child: BottomAppBar(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomBarItem(0, "ic_home", "首页"),
                _buildBottomBarItem(1, "ic_transaction", "账务"),
                _buildBottomBarItem(2, "ic_deposit", "存提"),
                _buildBottomBarItem(3, "ic_cs", "客服"),
                _buildBottomBarItem(4, "ic_profile", "我的"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildBottomBarItem(int index, String imagePath, String title, {bool isNewMessage = false}) => Expanded(
        child: Stack(
          children: [
            SizedBox(
              height: 58.auto,
              width: context.screenWidth / 5,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () {
                    if (index == 0) {
                      Navigator.of(context).pushNamed(RoutePath.home);
                    }
                    else if (index == 1) {
                      Navigator.of(context).pushNamed(RoutePath.transaction);
                    } else if (index == 2) {
                      Navigator.of(context).pushNamed(RoutePath.depositWithdrawTransaction);
                    } else if (index == 3) {
                      Navigator.of(context).pushNamed(RoutePath.customerService);
                    } else {
                      setState(() {
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
                          title,
                          style: TextStyle(
                            fontSize: 9.auto,
                            color: currentBottomIndex == index && currentBottomIndex!=0
                                ? CustomColor.theme_selected_color
                                : CustomColor.theme_bg_color,
                          ),
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

  _buildImageIcon(String imagePath, int index, bool isNewMessage) => SvgPicture.asset(
        "images/bottom_nav_bar/$imagePath.svg",
        matchTextDirection: true,
        height: 18.auto,
        color: currentBottomIndex == index && currentBottomIndex!=0? CustomColor.theme_selected_color : CustomColor.theme_bg_color,
      );
}
