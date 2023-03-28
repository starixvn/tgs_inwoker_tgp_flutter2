import 'package:api/extension/format.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/login/login.dart';
import 'package:tgp_flutter2/ui/profile/T2/profile_bottom_item.dart';
import 'package:tgp_flutter2/ui/profile/profile_item.dart';
import 'package:tgp_flutter2/ui/profile/T2/profile_top_item.dart';
import 'package:tgp_flutter2/ui/profile/profile_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class ProfileT2 extends StatefulWidget {
  final ProfileViewModel vm;

  ProfileT2({required this.vm});

  @override
  _ProfileT2State createState() => _ProfileT2State();
}

class _ProfileT2State extends BaseState<ProfileT2> {
  late ProfileViewModel _vm;

  @override
  void initState() {
    _vm = widget.vm;
    super.initState();
  }

  Widget build(BuildContext context) {
    return _buildUserInfoContainerT2();
  }

  _buildUserInfoContainerT2() => Container(
          child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  color: CustomColor.theme_button_color,
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  color: Colors.white,
                ),
              )
            ],
          ),
          Container(
            height: context.screenHeight,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10.auto, left: 50.auto, right: 50.auto, bottom: 10.auto),
                  child: Row(
                    children: [
                      Container(
                          width: 65.auto,
                          height: 65.auto,
                          decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.fill, image: AssetImage("images/profile/profile_image.png")))),
                      _buildUserInfoText(),
                    ],
                  ),
                ),
                _buildProfileTopItem(),
                _buildGridViewLayout(),
              ],
            ),
          ),
        ],
      ));

  _buildProfileTopItem() => Container(
        margin: EdgeInsets.only(left: 15.auto, right: 15.auto),
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ProfileTopItem(title: "deposit", imagePath: "deposit", routePath: "deposit"),
              ProfileTopItem(title: "transfer", imagePath: "transfer", routePath: "wallet_transfer"),
              ProfileTopItem(title: "withdrawal", imagePath: "withdraw", routePath: "withdraw"),
            ],
          ),
        ),
      );

  _buildGridViewLayout() => Expanded(
        child: ScrollConfiguration(
          behavior: MyBehavior(),
          child: ListView(
            padding: EdgeInsets.only(left: 25.auto, right: 25.auto, bottom: 10.auto, top: 20.auto),
            shrinkWrap: true,
            primary: false,
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              GridView.count(
                padding: EdgeInsets.only(bottom: 30.auto),
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisSpacing: 15.auto,
                mainAxisSpacing: 15.auto,
                children: [
                  _buildProfileBottomItem("ic_profile", "profile_detail", "profile_info", 0),
                  _buildProfileBottomItem("ic_message", "message_center", "message", 0),
                  _buildProfileBottomItem("ic_account_report", "bet_history", "transaction", 0),
                  _buildProfileBottomItem("ic_deposit_report", "deposit_history", "transaction", 1),
                  _buildProfileBottomItem("ic_withdraw_report", "withdrawal_history", "transaction", 2),
                  _buildProfileBottomItem("ic_transfer_report", "transfer_history", "transaction", 3),
                  _buildProfileBottomItem("ic_account_report", "promotion_history", "transaction", 4),
                  _buildProfileBottomItem("ic_card_detail", "manage_card", "main_card", 0),
                  _buildProfileBottomItem("ic_vip", "VIP", "vip", 0),
                  if (_vm.haveAffiliate)
                    _buildProfileBottomItem("ic_affiliate", "affiliate", "affiliate", 0),
                  _buildProfileBottomItem("ic_lang", "language", "language", 0),
                ],
              ),
              _buildLogoutButton()
            ],
          ),
        ),
      );

  _buildProfileBottomItem(String imagePath, String title, String routePath, int navigationID,
          {bool isMessage = false}) =>
      ProfileBottomItem(
        title: getTranslatedText(title),
        imagePath: imagePath,
        routePath: routePath,
        navigationID: navigationID,
        isMessage: isMessage,
      );

  _buildUserInfoText() => Container(
        margin: EdgeInsets.only(left: 20.auto),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AutoSizeText(
            _vm.userProfile?.username ?? "",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                    style: TextStyle(color: Colors.white, fontSize: (11.2).auto),
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    " ${Format().currencyWithDecimalFormat(_vm.wallet?.main ?? 0)}",
                    style: TextStyle(color: Colors.white, fontSize: (11.2).auto),
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
                style: TextStyle(color: Colors.white, fontSize: (11.2).auto),
                textAlign: TextAlign.start,
              ),
              Text(
                (_vm.totalBalance != null ? " ${Format().currencyWithDecimalFormat(_vm.totalBalance ?? 0.0)}" : "-"),
                //"总资金  "+(_vm.totalBalance != null ?  "+ Format().currencyWithDecimalFormat(_vm.totalBalance) : "-"),
                style: TextStyle(color: Colors.white, fontSize: (11.2).auto),
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
      //navigate to login and remove all previous route,
      Navigator.of(context)
          .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Login()), (Route<dynamic> route) => false);
    });
  }
}
