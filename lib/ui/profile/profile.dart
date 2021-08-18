import 'package:flutter/material.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/login/login.dart';
import 'package:tgp_flutter2/ui/profile/profile_bottom_item.dart';
import 'package:tgp_flutter2/ui/profile/profile_top_item.dart';
import 'package:tgp_flutter2/ui/profile/profile_view_model.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:api/extension/format.dart';
import 'package:tgp_flutter2/ui/transaction/transaction.dart';

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
                  children: [_buildUserInfoContainer(), _buildProfileColumn(), _buildLogoutButton()],
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
              "Claire",
              style: TextStyle(color: Colors.white),
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
                      margin: EdgeInsets.only(right: 5.auto),
                      width: 30.auto,
                      height: 30.auto,
                      decoration: new BoxDecoration(shape: BoxShape.circle, color: CustomColor.grey_five)),
                  Text(
                    "Claire117",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
            Row(
              children: [
                Container(margin: EdgeInsets.only(right: 5.auto), child: Image.asset("images/profile/ic_balance.png")),
                Text(
                  "0",
                  style: TextStyle(color: CustomColor.theme_button_color),
                )
              ],
            )
          ],
        ),
      );

  _buildProfileColumn() => Container(
        margin: EdgeInsets.only(top: 30.auto),
        child: Column(
          children: [
            _buildTopProfileItem("ic_profile", "profile_detail","profile_info", 0),
            _buildMiddleProfileItem("ic_message", "message_center", "message", 0),
            _buildMiddleProfileItem("ic_bet_transaction", "bet_history","transaction", 0),
            _buildMiddleProfileItem("ic_transaction", "账务记录","deposit_withdraw_transatcion_view",0),
            _buildMiddleProfileItem("ic_transfer", "transfer_history","transaction", 0),
            _buildMiddleProfileItem("ic_card_detail", "manage_card", "main_card", 0),
            _buildBottomProfileItem("ic_lang", "language","language",0),
          ],
        ),
      );

  _buildTopProfileItem(String imagePath, String title, String routePath, int navigationID) => Container(
      padding: EdgeInsets.only(top: 10.auto, left: 10.auto, right: 20.auto),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(5),
            topLeft: Radius.circular(5),
          ),
          color: Colors.white),
      child: Column(
        children: [
          _buildProfileItem(imagePath, title, routePath, navigationID),
          Divider(
            thickness: (1.0).auto,
            color: CustomColor.very_light_pink_four,
          ),
        ],
      ));

  _buildBottomProfileItem(String imagePath, String title,String routePath, int navigationID) => Container(
      padding: EdgeInsets.only(bottom: 10.auto, left: 10.auto, right: 20.auto),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(5),
            bottomLeft: Radius.circular(5),
          ),
          color: Colors.white),
      child: _buildProfileItem(imagePath, title, routePath, navigationID));

  _buildMiddleProfileItem(String imagePath, String title,String routePath, int navigationID) => Container(
      padding: EdgeInsets.only(left: 10.auto, right: 20.auto),
      color: Colors.white,
      child: Column(
        children: [
          _buildProfileItem(imagePath, title, routePath, navigationID),
          Divider(
            thickness: (1.0).auto,
            color: CustomColor.very_light_pink_four,
          ),
        ],
      ));

  _buildProfileItem(String imagePath, String title,String routePath, int navigationID) => Container(
        child: InkWell(
          onTap: () => _navigate(routePath, navigationID),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: ImageIcon(
                  AssetImage("images/profile/$imagePath.png"),
                  size: 15.auto,
                  color: CustomColor.theme_button_color,
                ),
              ),
              Expanded(
                  flex: 7,
                  child: Text(
                    getTranslatedText(title)?? title,
                    style: TextStyle(fontSize: 12.auto, color: CustomColor.theme_text_color),
                  ))
            ],
          ),
        ),
      );

  _navigate(String routePath, int navigationID) => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (navigationID == 0) {
      Navigator.of(context).pushNamed("/$routePath");
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Transaction(
                tabIndex: navigationID,
              )));
    }
  });

  _buildLogoutButton() => Container(
        padding: EdgeInsets.symmetric(vertical: 20.auto, horizontal: 5.auto),
        child: ColorButton(
          title: "登出",
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
