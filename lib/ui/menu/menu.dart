import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/menu/menu_view_model.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/ui/withdraw/withdraw.dart';

import '../deposit/deposit.dart';

class Menu extends StatefulWidget {
  final Function? onCloseMenu;

  Menu({this.onCloseMenu});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends BaseState<Menu> {
  var _vm = MenuViewModel();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: Container(
          width: context.screenWidth,
          padding: EdgeInsets.all(10.auto),
          color: EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode ? CustomColor.theme_bg_color : CustomColor.theme_text_grey_color,
          child: Wrap(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMenuButton(
                      "transfer",
                      "ic_menu_transfer.png",
                      EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode ? Color(0xffd2ff00) : CustomColor.menu_blue,
                      RoutePath.walletTransfer),
                  _buildMenuButton("deposit", "ic_menu_deposit",
                      EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode ? Color(0xffe7ff77) : CustomColor.menu_green, RoutePath.deposit),
                  _buildMenuButton(
                      "withdrawal",
                      "ic_menu_withdrawal.png",
                      EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode ? Color(0xffd2ff00) : CustomColor.menu_orange,
                      RoutePath.withdraw),
                ],
              ),
            ],
          )),
    );
  }

  _buildMenuButton(String title, String imagePath, Color color, String route) => InkWell(
        onTap: () {
          if (route == RoutePath.withdraw && (_vm.config?.addCardNotAllowedEditDelete ?? false) && (_vm.bankCardList?.isEmpty ?? false))
            _showNoCardDialog();
          else if (route == RoutePath.deposit) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Deposit(isNewPage: true)));
          } else if (route == RoutePath.withdraw) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Withdraw(isNewPage: true)));
          } else
            Navigator.of(context).pushNamed(route);
        },
        child: Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: color,
          ),
          width: 100.auto,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 10.auto),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(right: 10.auto),
                child: imagePath.contains(".png")
                    ? Image.asset(
                        "images/menu/$imagePath",
                        height: 18.auto,
                        color: EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode ? Colors.black : Colors.white,
                      )
                    : SvgPicture.asset(
                        "images/menu/$imagePath.svg",
                        matchTextDirection: true,
                        height: 18.auto,
                        color: EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode ? Colors.black : Colors.white,
                      ),
              ),
              AutoSizeText(
                getTranslatedText(title),
                textAlign: TextAlign.center,
                style: TextStyle(color: EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode ? CustomColor.theme_bg_color : Colors.white),
                minFontSize: 10,
                maxLines: 1,
                stepGranularity: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );

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
