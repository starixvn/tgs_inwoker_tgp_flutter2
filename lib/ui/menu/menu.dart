import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

class Menu extends StatefulWidget {
  final Function onCloseMenu;

  Menu({this.onCloseMenu, Key key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends BaseState<Menu> {
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
          color: CustomColor.theme_text_grey_color,
          child: Wrap(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTransferButton(),
                  _buildMenuButton("deposit", "ic_menu_deposit", CustomColor.menu_green, RoutePath.deposit),
                  _buildMenuButton("withdrawal", "ic_menu_withdrawal", CustomColor.menu_orange, RoutePath.withdraw),
                ],
              ),
            ],
          )),
    );
  }

  _buildTransferButton() => InkWell(
    onTap: (){
      Navigator.of(context).pushNamed(RoutePath.walletTransfer);
    },
    child: Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: CustomColor.menu_blue,
      ),
      width: 100.auto,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 10.auto),
      child: Text(
        getTranslatedText("transfer"),
        textAlign: TextAlign.center,
        style: TextStyle(color: CustomColor.theme_text_grey_color),
      ),
    ),
  );

  _buildMenuButton(String title, String imagePath, Color color, String route) => InkWell(
    onTap: () => Navigator.of(context).pushNamed(route),
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
                child: SvgPicture.asset(
                  "images/menu/$imagePath.svg",
                  matchTextDirection: true,
                  height: 18.auto,
                ),
              ),
              Text(
                getTranslatedText(title),
                textAlign: TextAlign.center,
                style: TextStyle(color: CustomColor.theme_text_grey_color),
              ),
            ],
          ),
        ),
  );
}
