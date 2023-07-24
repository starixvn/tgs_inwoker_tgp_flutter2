import 'package:api/extension/format.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_login_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/home/home.dart';
import 'package:tgp_flutter2/ui/login/CustomSky8/LoginTemplate02.dart';
import 'package:tgp_flutter2/ui/login/login.dart';
import 'package:tgp_flutter2/ui/profile/T14/profile_t14.dart';
import 'package:tgp_flutter2/ui/profile/T2/profile_bottom_item.dart';
import 'package:tgp_flutter2/ui/profile/profile_item.dart';
import 'package:tgp_flutter2/ui/profile/T2/profile_t2.dart';
import 'package:tgp_flutter2/ui/profile/T2/profile_top_item.dart';
import 'package:tgp_flutter2/ui/profile/profile_view_model.dart';
import 'package:api/extension/screen_apis.dart';

import '../../globalUtil/GlobalValueUtil.dart';
import '../home/end_drawer_menu.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends BaseState<Profile> {
  var _vm = ProfileViewModel();
  var currentBottomIndex = 4;
  var mainWallet;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_vm.userProfile != null) {
        // _vm.computeTotalBalance();
        _vm.getAffiliateStatus();
      } else {
        Navigator.of(context).pushNamed(RoutePath.login);
      }
    });
    GlobalValueUtil.pausesong();
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<ProfileViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return CustomScaffold(
              appBar: EnvironmentConfig.template_version == 14
                  ? CustomLoginAppBar(
                      onClickLoginButton: () => Navigator.of(context).pushNamed(RoutePath.login),
                      onClickRegisterButton: () => Navigator.of(context).pushNamed(RoutePath.register),
                      onClickLogoutButton: () => _logout(),
                      isLogin: _vm.userProfile != null,
                      brandLogoUrl: _vm.brandLogoUrl,
                      userProfile: _vm.userProfile,
                      phone: "",
                      config: _vm.config,
                      totalBalance: _vm.totalBalance,
                      //_vm.totalBalance,
                      brandName: EnvironmentConfig.brandName,
                      onClickBalance: () {},
                      onPauseMusic: () {},
                      onResumeMusic: () {},
                      randomNumber: 0,
                      isShowMarquee: true,
                      marquee: GlobalValueUtil.removeMultiLine(GlobalValueUtil.parseHtmlString(_vm.announcement ?? "")),
                    )
                  : PreferredSize(
                      preferredSize: Size.zero,
                      child: Container(),
                    ),
              endDrawer: Drawer(
                width: context.screenWidth * 0.65,
                backgroundColor: Color(0xff181c42),
                child: EndDrawerMenu(
                  username: _vm.userProfile?.username ?? "",
                  width: context.screenWidth * 0.65,
                  balance: _vm.totalBalance ?? 0.0,
                ),
              ),
              body: (() {
                switch (EnvironmentConfig.template_version) {
                  case 2:
                    return ProfileT2(vm: _vm);
                  case 14:
                    return ProfileT14(vm: vm);
                  default:
                    return Container(
                      padding: EdgeInsets.only(left: 20.auto, right: 20.auto, top: 30.auto),
                      child: ListView(
                        children: [
                          _buildUserInfoContainer(),
                          ProfileItem(config: _vm.config, bankCardList: _vm.bankCardList, haveAffiliate: _vm.haveAffiliate),
                          _buildLogoutButton()
                        ],
                      ),
                    );
                }
              }()));
        });
  }

  _buildUserInfoContainer() => /*EnvironmentConfig.template_version == 1
      ? */
      Padding(
        padding: EdgeInsets.only(top: 10.auto, left: 10.auto, right: 10.auto, bottom: 10.auto),
        child: Row(
          children: [
            Container(
                width: 65.auto,
                height: 65.auto,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle, image: new DecorationImage(fit: BoxFit.fill, image: AssetImage("images/profile/profile_image.png")))),
            _buildUserInfoText(),
          ],
        ),
      )
      /*: Container(
          padding: EdgeInsets.only(top: 20.auto, left: 20.auto, right: 20.auto),
          // margin: EdgeInsets.only(left: 10.auto),
          child: Row(
            children: [_buildProfileImage(), _buildBalanceText()],
          ),
        )*/
      ;

  _buildUserInfoText() => Container(
        margin: EdgeInsets.only(left: 20.auto),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AutoSizeText(
            _vm.userProfile?.username ?? "",
            style: TextStyle(color: CustomColor.theme_text_grey_white_color, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
            minFontSize: 10,
            stepGranularity: 1,
          ),
          Padding(
              padding: EdgeInsets.only(top: 3.auto, bottom: 3.auto),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  Text(
                    getTranslatedText("main_wallet") + " :",
                    style: TextStyle(color: CustomColor.theme_text_grey_white_color, fontSize: (11.2).auto),
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    EnvironmentConfig.brandName == "IDR1"
                        //without decimal places
                        ? Format().currencyFormat((_vm.wallet?.main ?? 0).toInt())
                        //with 2 decimal places
                        : " ${Format().currencyWithDecimalFormat(_vm.wallet?.main ?? 0)}",
                    style: TextStyle(color: CustomColor.theme_button_color, fontSize: (11.2).auto),
                    textAlign: TextAlign.start,
                  ),
                ],
              )),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text(
                getTranslatedText("total_balance") + " :",
                //"总资金  "+(_vm.totalBalance != null ?  "+ Format().currencyWithDecimalFormat(_vm.totalBalance) : "-"),
                style: TextStyle(color: CustomColor.theme_text_grey_white_color, fontSize: (11.2).auto),
                textAlign: TextAlign.start,
              ),
              Text(
                (_vm.totalBalance != null
                    ? ((EnvironmentConfig.brandName == "IDR1"
                        //without decimal places
                        ? Format().currencyFormat((_vm.totalBalance ?? 0).toInt())
                        //with 2 decimal places
                        : " ${Format().currencyWithDecimalFormat(_vm.totalBalance ?? 0.0)}"))
                    : "-"),
                //"总资金  "+(_vm.totalBalance != null ?  "+ Format().currencyWithDecimalFormat(_vm.totalBalance) : "-"),
                style: TextStyle(color: CustomColor.theme_button_color, fontSize: (11.2).auto),
                textAlign: TextAlign.start,
              )
            ],
          )
        ]),
      );

  _buildLogoutButton() => Container(
        padding: EdgeInsets.symmetric(vertical: 20.auto, horizontal: 5.auto),
        child: ColorButton(
          title: getTranslatedText("logout"),
          onClick: () => _logout(),
          isEnabled: true,
          radius: 5,
        ),
      );

  _logout() {
    ProgressDialog.show(context, _vm.brandLogoUrl);
    _vm.logout();
  }

  _navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (EnvironmentConfig.template_version == 14) {
        //navigate to home and remove all previous route, then navigate to login
        Navigator.of(context).pushNamedAndRemoveUntil(RoutePath.myHome, (Route<dynamic> route) => false);
        Navigator.pushNamed(context, RoutePath.login);
      } else {
        //navigate to login and remove all previous route,
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => EnvironmentConfig.template_version == 15 ? LoginTemplate02() : Login()), (Route<dynamic> route) => false);
      }
    });
  }

  _handleApiState() {
    handleApiState(_vm.logoutApiState, isLogoutApiState: true, onSuccess: () {
      _navigateToLogin();
    }, onLogout: () {
      _navigateToLogin();
    });
    handleApiState(_vm.getWalletBalanceApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getAffiliateStatusState, onSuccess: () {});
  }
}
