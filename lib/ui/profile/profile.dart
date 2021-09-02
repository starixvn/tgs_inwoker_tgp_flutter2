import 'package:api/extension/format.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/login/login.dart';
import 'package:tgp_flutter2/ui/profile/profile_item.dart';
import 'package:tgp_flutter2/ui/profile/profile_view_model.dart';
import 'package:api/extension/screen_apis.dart';

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
        _vm.computeTotalBalance();
      } else {
        Navigator.of(context).pushNamed(RoutePath.login);
      }
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<ProfileViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: CustomColor.theme_bg_color,
              body: Container(
                padding: EdgeInsets.only(left: 20.auto, right: 20.auto, top: 30.auto),
                child: Column(
                  children: [_buildUserInfoContainer(), ProfileItem(), _buildLogoutButton()],
                ),
              ));
        });
  }

  _buildUserInfoContainer() => Container(
        padding: EdgeInsets.only(top: 20.auto, left: 20.auto, right: 20.auto),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_buildProfileImage(), _buildBalanceText()],
        ),
      );

  _buildProfileImage() => Column(
        children: [
          Container(
              width: 65.auto,
              height: 65.auto,
              decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(fit: BoxFit.fill, image: AssetImage("images/profile/profile_image.png")))),
          Container(
            margin: EdgeInsets.only(top: 3.auto),
            child: Text(
              _vm.userProfile?.username ?? " ",
              style: TextStyle(color: CustomColor.theme_text_grey_color),
            ),
          )
        ],
      );

  _buildBalanceText() => Container(
        width: context.screenWidth / 2,
        padding: EdgeInsets.only(left: 20.auto),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 5.auto),
              child: Row(
                children: [
                  Container(
                      margin: EdgeInsets.only(right: 5.auto),//decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.auto)),
                      child:ImageIcon(
                        AssetImage("images/profile/ic_balance.png"),
                        color: CustomColor.grey_five,
                      )),
                  Text(
                    " ¥ ${Format().currencyWithDecimalFormat(_vm.balance ?? 0)}",
                    style: TextStyle(color: CustomColor.theme_text_grey_color),
                  )
                ],
              ),
            ),
            Row(
              children: [
                Container(
                    margin: EdgeInsets.only(right: 5.auto),//decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.auto)),
                    child:ImageIcon(
                      AssetImage("images/profile/ic_balance.png"),
                      color: CustomColor.theme_button_color,
                    )),                Text(
                  _vm.totalBalance != null ? " ¥ ${Format().currencyWithDecimalFormat(_vm.totalBalance)}": "-",
                  style: TextStyle(color: CustomColor.theme_button_color),
                )
              ],
            )
          ],
        ),
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
    ProgressDialog.show(context);
    _vm.logout();
  }

  _navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //navigate to login and remove all previous route,
      Navigator.of(context)
          .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Login()), (Route<dynamic> route) => false);
    });
  }

  _handleApiState() {
    handleApiState(_vm.logoutApiState, onSuccess: () {
      _navigateToLogin();
    }, onError: (error, errorCode) {
      _navigateToLogin();
    });
    handleApiState(_vm.getWalletBalanceApiState, isAutoHideLoading: false, onSuccess: () {});
  }
}
