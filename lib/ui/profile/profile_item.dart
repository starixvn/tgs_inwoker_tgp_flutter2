import 'package:api/entity/bank_card.dart';
import 'package:api/entity/env_features_config.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/report/report_view.dart';

class ProfileItem extends StatefulWidget {
  final EnvFeaturesConfig? config;
  final List<BankCard>? bankCardList;
  bool? haveAffiliate = false;

  ProfileItem({this.config, this.bankCardList, this.haveAffiliate});

  @override
  _ProfileItemState createState() => _ProfileItemState();
}

class _ProfileItemState extends BaseState<ProfileItem> {
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 30.auto),
      child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 5,
          child: _buildT1ProfileItem()),
    );
  }

  _buildT1ProfileItem() => Column(
        children: [
          _buildTopProfileItem(
              "ic_profile", "profile_detail", "profile_info", 0),
          _buildMiddleProfileItem("ic_message", "message_center", "message", 0),
          _buildMiddleProfileItem(
              "ic_account_report", "bet_history", "transaction", 0),
          _buildMiddleProfileItem(
              "ic_withdraw_report", "withdrawal_history", "transaction", 1),
          _buildMiddleProfileItem(
              "ic_deposit_report", "deposit_history", "transaction", 2),
          _buildMiddleProfileItem(
              "ic_transfer_report", "transfer_history", "transaction", 3),
          _buildMiddleProfileItem(
              "ic_transfer_report", "balanceChangeRecords", "transaction", 5),
          _buildMiddleProfileItem("ic_vip", "VIP", "vip", 0),
          (widget.haveAffiliate ?? false)
              ? _buildMiddleProfileItem(
                  "ic_affiliate", "affiliate", "affiliate", 0)
              : Container(),
          //  _buildMiddleProfileItem(
          //      "ic_account_report", "promotion_history", "transaction", 4),
          _buildMiddleProfileItem(
              "ic_card_detail", "manage_card", "main_card", 0),

          EnvironmentConfig.template_version == 11
              ? _buildMiddleProfileItem("ic_lang", "language", "language", 0)
              : _buildBottomProfileItem("ic_lang", "language", "language", 0),
          EnvironmentConfig.template_version == 11
              ? _buildBottomProfileItem(
                  "ic_transfer", "transfer", "wallet_transfer", 0)
              : Container(),
        ],
      );

  _buildOthersTemplateProfileItem() => Column(
        children: [
          _buildTopProfileItem(
              "ic_profile", "profile_detail", "profile_info", 0),
          _buildMiddleProfileItem("ic_message", "message_center", "message", 0),
          _buildMiddleProfileItem(
              "ic_bet_transaction", "bet_history", "transaction", 0),
          _buildMiddleProfileItem(
              "ic_transaction", "deposit_history", "transaction", 1),
          _buildMiddleProfileItem(
              "ic_transaction", "withdrawal_history", "transaction", 2),
          _buildMiddleProfileItem(
              "ic_transfer", "transfer_history", "transaction", 3),
          _buildMiddleProfileItem(
              "ic_transfer_report", "balanceChangeRecords", "transaction", 5),
          _buildMiddleProfileItem(
              "ic_transaction", "promotion_history", "transaction", 4),
          _buildMiddleProfileItem(
              "ic_card_detail", "manage_card", "main_card", 0),
          _buildMiddleProfileItem("ic_vip", "VIP", "vip", 0),
          (widget.haveAffiliate ?? false)
              ? _buildMiddleProfileItem(
                  "ic_affiliate", "affiliate", "affiliate", 0)
              : Container(),
          _buildBottomProfileItem("ic_lang", "language", "language", 0),
        ],
      );

  _buildTopProfileItem(
          String imagePath, String title, String routePath, int navigationID) =>
      InkWell(
          onTap: () => _navigate(routePath, navigationID),
          child: Container(
              padding:
                  EdgeInsets.only(top: 10.auto, left: 10.auto, right: 20.auto),
              child: Column(
                children: [
                  _buildProfileItem(imagePath, title, routePath, navigationID),
                  Divider(
                    thickness: (1.0).auto,
                    color: CustomColor.very_light_pink_four,
                  ),
                ],
              )));

  _buildBottomProfileItem(
          String imagePath, String title, String routePath, int navigationID) =>
      InkWell(
          onTap: () => _navigate(routePath, navigationID),
          child: Container(
              padding: EdgeInsets.only(
                  bottom: 10.auto, left: 10.auto, right: 20.auto),
              child: _buildProfileItem(
                  imagePath, title, routePath, navigationID)));

  _buildMiddleProfileItem(
          String imagePath, String title, String routePath, int navigationID) =>
      InkWell(
          onTap: () => _navigate(routePath, navigationID),
          child: Container(
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
              )));

  _buildProfileItem(
          String imagePath, String title, String routePath, int navigationID) =>
      Container(
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: /*EnvironmentConfig.template_version == 1
                  ? */
                    SvgPicture.asset(
                  "images/profile/t1/$imagePath.svg",
                  matchTextDirection: true,
                  height: 18.auto,
                  color: CustomColor.theme_button_color,
                )
                /*: ImageIcon(
                      AssetImage("images/profile/t2/$imagePath.png"),
                      size: title == "deposit" || title == "withdrawal" ? 20.auto : 15.auto,
                      color: CustomColor.theme_button_color,
                    ),*/
                ),
            Expanded(
                flex: 7,
                child: Container(
                  color: Colors.white,
                  child: Text(
                    getTranslatedText(title) ?? title,
                    style: TextStyle(
                        fontSize: 12.auto,
                        color: EnvironmentConfig.template_version == 11
                            ? Color(0xff707070)
                            : CustomColor.theme_text_grey_color),
                  ),
                ))
          ],
        ),
      );

  _navigate(String routePath, int navigationID) =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (routePath == "main_card" &&
            (widget.config?.addCardNotAllowedEditDelete ?? false) &&
            (widget.bankCardList?.isEmpty ?? false))
          _showNoCardDialog();
        else if (navigationID == 0) {
          Navigator.of(context).pushNamed("/$routePath");
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReportView(
                        tabIndex: navigationID,
                      )));
        }
      });

  _showNoCardDialog() => showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
          title: getTranslatedText("no_card_title"),
          description: getTranslatedText("no_card_description"),
          buttonText1: getTranslatedText("confirm"),
          onClick: () {
            Navigator.pop(context);
          }));
}
