import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/main.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/menu/menu_item_t2.dart';

class MenuT2 extends StatefulWidget {
  final Function? onCloseMenu;

  MenuT2({this.onCloseMenu});

  @override
  _MenuT2State createState() => _MenuT2State();
}

class _MenuT2State extends BaseState<MenuT2> {
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(top: 10.auto, left: 10.auto, right: 10.auto),
          child: Wrap(children: [
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              children: [
                MenuItemT2(
                  image: "ic_menu_deposit",
                  text: getTranslatedText("deposit"),
                  navigationPath: "deposit",
                  navigationID: 0,
                ),
                MenuItemT2(
                  image: "ic_menu_transfer",
                  text: getTranslatedText("transfer"),
                  navigationPath: "wallet_transfer",
                  navigationID: 0,
                ),
                MenuItemT2(
                  image: "ic_menu_withdraw",
                  text: getTranslatedText("withdrawal"),
                  navigationPath: "withdraw",
                  navigationID: 0,
                ),
                /*MenuItemT2(
                  image: "ic_menu_transfer_history",
                  text: getTranslatedText("transfer_history"),
                  navigationPath: "transaction",
                  navigationID: 0,
                ),*/
                MenuItemT2(
                  image: "ic_menu_bet_history",
                  text: getTranslatedText("bet_history"),
                  navigationPath: "transaction",
                  navigationID: 0,
                ),
                MenuItemT2(
                  image: "ic_menu_deposit_history",
                  text: getTranslatedText("deposit_history"),
                  navigationPath: "transaction",
                  navigationID: 1,
                ),
                MenuItemT2(
                  image: "ic_menu_withdraw_history",
                  text: getTranslatedText("withdrawal_history"),
                  navigationPath: "transaction",
                  navigationID: 2,
                ),
                MenuItemT2(
                  image: "ic_menu_withdraw_history",
                  text: getTranslatedText("transfer_history"),
                  navigationPath: "transaction",
                  navigationID: 3,
                ),
                MenuItemT2(
                  image: "ic_menu_withdraw_history",
                  text: getTranslatedText("promotion_history"),
                  navigationPath: "transaction",
                  navigationID: 4,
                ),
                MenuItemT2(
                  image: "ic_menu_card",
                  text: getTranslatedText("manage_card"),
                  navigationPath: "main_card",
                  navigationID: 0,
                ),
                MenuItemT2(
                  image: "ic_menu_message_center",
                  text: getTranslatedText("message_center"),
                  navigationPath: "message",
                  navigationID: 0,
                ),
              ],
            ),
            Container(
                margin: EdgeInsets.only(top: 30.auto, bottom: 20.auto),
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: ImageIcon(
                    AssetImage("images/menu/ic_menu_close.png"),
                    size: 25.auto,
                    color: Colors.white,
                  ),
                )),
          ]),
        ));
  }
}
