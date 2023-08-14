import 'package:api/extension/format.dart';
import 'package:api/extension/screen_util.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/globalUtil/GlobalValueUtil.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/login/login.dart';
import 'package:tgp_flutter2/ui/profile/T14/profile_item_t14.dart';
import 'package:tgp_flutter2/ui/profile/T15_light/profile_item_t15_light.dart';
import 'package:tgp_flutter2/ui/profile/T2/profile_bottom_item.dart';
import 'package:tgp_flutter2/ui/profile/profile_view_model.dart';
import 'package:api/extension/screen_apis.dart';

import '../../../custom/wallet_text_container.dart';
import '../../../environment_config.dart';
import '../../deposit/deposit.dart';
import '../../report/report_view.dart';

class ProfileT15Light extends StatefulWidget {
  final ProfileViewModel vm;

  ProfileT15Light({required this.vm});

  @override
  _ProfileT15LightState createState() => _ProfileT15LightState();
}

class _ProfileT15LightState extends BaseState<ProfileT15Light> {
  late ProfileViewModel _vm;

  @override
  void initState() {
    _vm = widget.vm;
    super.initState();
  }

  Widget build(BuildContext context) {
    return Container(
      height: context.screenHeight,
      width: context.screenWidth,
      // padding: EdgeInsets.symmetric(horizontal: 10.auto, vertical: MediaQuery.of(context).viewPadding.top),
      child: CustomScrollView(
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
              alignment: Alignment.center,
              child: Text(
                getTranslatedText("member_center"),
                style: TextStyle(color: Colors.black, fontSize: 15.auto),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15.auto),
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: context.screenHeight / 10,
                  padding: EdgeInsets.all(10.auto),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pushNamed("/vip"),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              height: (context.screenHeight / 10) - 30.auto,
                              child: Image.asset(
                                "images/profile/t15_light/ic_vip.png",
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              getTranslatedText("vip_privilege"),
                              style: TextStyle(color: Colors.black),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 15.auto, horizontal: context.screenWidth / 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildProfileTopItem("deposit", getTranslatedText("deposit"), RoutePath.deposit),
                  _buildProfileTopItem("bet_record", getTranslatedText("report_bet"), RoutePath.transaction),
                  _buildProfileTopItem("account_report", getTranslatedText("account_record"), "transaction", navigationID: 5),
                  _buildProfileTopItem("profile_info", getTranslatedText("account_safety"), RoutePath.profileInfo),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: _buildGridViewLayout(),
          ),
        ],
      ),
    );
  }

  _buildProfileTopItem(String imagePath, String title, String routePath, {int navigationID = 0}) => InkWell(
        onTap: () {
          if (navigationID != 0)
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ReportView(
                          tabIndex: navigationID,
                        )));
          else if (routePath == RoutePath.deposit) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Deposit(isNewPage: true)));
          }
          else
            Navigator.of(context).pushNamed(routePath);
        },
        child: Container(
          width: context.screenWidth / 6,
          child: Column(
            children: [
              Image.asset(
                "images/profile/t15_light/ic_$imagePath.png",
                height: context.screenHeight / 20,
              ),
              Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 11.auto,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  _buildGridViewLayout() {
    List<Widget> list = [
      _buildProfileBottomItem("ic_profile", "profile_detail", "profile_info", 0),
      _buildProfileBottomItem("ic_message", "message_center", "message", 0, isMessage: true),
      // _buildProfileBottomItem("ic_message", "memo", "memo", 0),
      // _buildProfileBottomItem("ic_announcement", "announcement", "announcement", 0),
      _buildProfileBottomItem("ic_account_report", "bet_history", "transaction", 0),
      _buildProfileBottomItem("ic_withdraw_report", "withdrawal_history", "transaction", 1),
      _buildProfileBottomItem("ic_deposit_report", "deposit_history", "transaction", 2),
      _buildProfileBottomItem("ic_transfer_report", "transfer_history", "transaction", 3),
      _buildProfileBottomItem("ic_account_report", "promotion_history", "transaction", 5),
      _buildProfileBottomItem("ic_transfer_report", "balanceChangeRecords", "transaction", 4),
      // _buildProfileBottomItem("ic_favourite", "my_favorite", "favourite", 0),
      _buildProfileBottomItem("ic_vip", "VIP", "vip", 0),
      if (_vm.haveAffiliate) _buildProfileBottomItem("ic_affiliate", "affiliate", "affiliate", 0),
      _buildProfileBottomItem("ic_card_detail", "manage_card", "main_card", 0),
      _buildProfileBottomItem("ic_transfer", "transfer", "wallet_transfer", 0),
      _buildProfileBottomItem("ic_lang", "language", "language", 0),
      _buildProfileBottomItem("ic_signout", "exit", "language", -1),
    ];
    return ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      children: List.generate(list.length, (index) => list[index]),
    );
  }

  _buildProfileBottomItem(String imagePath, String title, String routePath, int navigationID, {bool isMessage = false}) => ProfileItemT15Light(
        title: getTranslatedText(title),
        imagePath: imagePath,
        routePath: routePath,
        navigationID: navigationID,
        isMessage: isMessage,
        logout: () => _logout(),
        isNotify: _vm.isNotify,
      );

  _logout() {
    ProgressDialog.show(context, _vm.brandLogoUrl);
    _vm.logout();
  }
}
