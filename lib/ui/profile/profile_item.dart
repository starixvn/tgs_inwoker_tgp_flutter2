import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/transaction/transaction.dart';

class ProfileItem extends StatefulWidget {
  final String title;
  final String imagePath;
  final String routePath;

  ProfileItem({
    Key key,
    this.title,
    this.imagePath,
    this.routePath,
  }) : super(key: key);

  @override
  _ProfileItemState createState() => _ProfileItemState();
}

class _ProfileItemState extends BaseState<ProfileItem> {
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 30.auto),
      child: Column(
        children: [
          _buildTopProfileItem("ic_profile", "profile_detail", "profile_info", 0),
          _buildMiddleProfileItem("ic_message", "message_center", "message", 0),
          _buildMiddleProfileItem("ic_bet_transaction", "bet_history", "transaction", 0),
          _buildMiddleProfileItem("ic_transaction", "deposit_history", "transaction", 1),
          _buildMiddleProfileItem("ic_transaction", "withdrawal_history", "transaction", 2),
          _buildMiddleProfileItem("ic_transfer", "transfer_history", "transaction", 3),
          _buildMiddleProfileItem("ic_card_detail", "manage_card", "main_card", 0),
          _buildMiddleProfileItem("ic_deposit", "deposit", "deposit", 0),
          _buildMiddleProfileItem("ic_transfer", "transfer", "wallet_transfer", 0),
          _buildMiddleProfileItem("ic_withdraw", "withdrawal", "withdraw", 0),
          _buildBottomProfileItem("ic_lang", "language", "language", 0),
        ],
      ),
    );
  }

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

  _buildBottomProfileItem(String imagePath, String title, String routePath, int navigationID) => Container(
      padding: EdgeInsets.only(bottom: 10.auto, left: 10.auto, right: 20.auto),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(5),
            bottomLeft: Radius.circular(5),
          ),
          color: Colors.white),
      child: _buildProfileItem(imagePath, title, routePath, navigationID));

  _buildMiddleProfileItem(String imagePath, String title, String routePath, int navigationID) => Container(
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

  _buildProfileItem(String imagePath, String title, String routePath, int navigationID) => Container(
    child: InkWell(
      onTap: () => _navigate(routePath, navigationID),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: ImageIcon(
              AssetImage("images/profile/$imagePath.png"),
              size: title=="deposit"||title=="withdrawal"?20.auto:15.auto,
              color: CustomColor.theme_button_color,
            ),
          ),
          Expanded(
              flex: 7,
              child: Text(
                getTranslatedText(title) ?? title,
                style: TextStyle(fontSize: 12.auto, color: CustomColor.theme_text_grey_color),
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
}
