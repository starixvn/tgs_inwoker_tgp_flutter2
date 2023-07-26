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
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/login/login.dart';
import 'package:tgp_flutter2/ui/profile/T14/profile_item_t14.dart';
import 'package:tgp_flutter2/ui/profile/T2/profile_bottom_item.dart';
import 'package:tgp_flutter2/ui/profile/profile_view_model.dart';
import 'package:api/extension/screen_apis.dart';

import '../../../custom/wallet_text_container.dart';
import '../../../environment_config.dart';

class ProfileT14 extends StatefulWidget {
  final ProfileViewModel vm;

  ProfileT14({required this.vm});

  @override
  _ProfileT14State createState() => _ProfileT14State();
}

class _ProfileT14State extends BaseState<ProfileT14> {
  late ProfileViewModel _vm;

  @override
  void initState() {
    _vm = widget.vm;
    super.initState();
  }

  Widget build(BuildContext context) {
    return Container(
      color: CustomColor.theme_bar_gradient_2,
      child: _buildUserInfoContainerT14(),
    );
  }

  _buildUserInfoContainerT14() => ScrollConfiguration(
        behavior: MyBehavior(),
        child: Column(
          children: [
            Expanded(flex:1,child:_buildProfileTopItem()),
            Expanded(flex:3,child:_buildGridViewLayout()),
          ],
        ),
        // CustomScrollView(
        //   shrinkWrap: true,
        //   physics: BouncingScrollPhysics(),
        //   slivers: [
        //     SliverToBoxAdapter(
        //       child: _buildProfileTopItem(),
        //     ),
        //     SliverFillRemaining(
        //       child: Flexible(
        //         fit: FlexFit.tight,
        //         child: _buildGridViewLayout(),
        //       ),
        //     ),
        //   ],
        // ),
      );

  _buildProfileTopItem() => Container(
        width: context.screenWidth,
        color: CustomColor.theme_bg_color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _vm.userProfile?.username ?? "",
              style: TextStyle(color: Colors.white, fontSize: 25.auto),
            ),
            SizedBox(height: 10),
            WalletTextContainer(height: context.screenHeight / 20, width: (context.screenWidth / 1.5), balance: "玩家总资金 ₱  ${GlobalValueUtil.totalBalance}"),
            SizedBox(height: 40),
            // Text(
            //   widget.vm.totalBalance != null ? Format().amountFormat(widget.vm.totalBalance ?? 0) : "-",
            //   style: TextStyle(
            //     color: (widget.vm.config?.newTransferUI ?? false) && EnvironmentConfig.template_version == 3
            //         ? CustomColor.theme_button_color
            //         : CustomColor.theme_app_bar_text_color,
            //     fontWeight: FontWeight.bold,
            //     fontSize: (widget.vm.config?.newTransferUI ?? false) ? 16.auto : 14.auto,
            //   ),
            //   textAlign: TextAlign.left,
            // ),
          ],
        ),
      );

  _buildGridViewLayout() {
    List<Widget> list = [
      _buildProfileBottomItem("ic_profile", "profile_detail", "profile_info", 0),
      _buildProfileBottomItem("ic_message", "message_center", "message", 0),
      _buildProfileBottomItem("ic_message", "站内信", "message", 0),
      _buildProfileBottomItem("ic_account_report", "bet_history", "transaction", 0),
      _buildProfileBottomItem("ic_withdraw_report", "withdrawal_history", "transaction", 2),
      _buildProfileBottomItem("ic_deposit_report", "deposit_history", "transaction", 1),
      _buildProfileBottomItem("ic_transfer_report", "transfer_history", "transaction", 3),
      _buildProfileBottomItem("ic_account_report", "promotion_history", "transaction", 4),
      _buildProfileBottomItem("ic_transfer_report", "balanceChangeRecords", "transaction", 5),
      _buildProfileBottomItem("ic_vip", "VIP", "vip", 0),
      if (_vm.haveAffiliate) _buildProfileBottomItem("ic_affiliate", "affiliate", "affiliate", 0),
      _buildProfileBottomItem("ic_card_detail", "manage_card", "main_card", 0),
      _buildProfileBottomItem("ic_transfer", "transfer", "wallet_transfer", 0),
      _buildProfileBottomItem("ic_lang", "language", "language", 0),
      _buildProfileBottomItem("ic_signout", "exit", "language", -1),
    ];
    return Container(
      child: AlignedGridView.count(
        padding: EdgeInsets.all(20.auto),
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        crossAxisSpacing: 10.auto,
        mainAxisSpacing: 10.auto,
        itemCount: list.length,
        // childAspectRatio: 2/3,
        // children: List.generate(list.length, (index) => list[index]),
        itemBuilder: (_, index) {
          return Expanded(
            child: list[index],
          );
        },
      ),
    );
  }

  _buildProfileBottomItem(String imagePath, String title, String routePath, int navigationID, {bool isMessage = false}) => ProfileItemT14(
        title: getTranslatedText(title),
        imagePath: imagePath,
        routePath: routePath,
        navigationID: navigationID,
        isMessage: isMessage,
        logout: () => _logout(),
      );

  _logout() {
    ProgressDialog.show(context, _vm.brandLogoUrl);
    _vm.logout();
  }
}
