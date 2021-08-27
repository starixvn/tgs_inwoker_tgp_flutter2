import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tgp_flutter2/base_state.dart';
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
          color: CustomColor.theme_text_color,
          child: Wrap(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTransferButton(),
                  _buildMenuButton("存款", "ic_menu_deposit", CustomColor.menu_green),
                  _buildMenuButton("提款", "ic_menu_withdrawal", CustomColor.menu_orange),
                ],
              ),
              /* Container(
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
                    )),*/
            ],
          )),
    );
  }

  _buildTransferButton() => Container(
    margin: EdgeInsets.all(5),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      color: CustomColor.menu_blue,
    ),
    width: 100.auto,
    alignment: Alignment.center,
    padding: EdgeInsets.symmetric(vertical: 10.auto),
    child: Text(
      "平台转账",
      textAlign: TextAlign.center,
      style: TextStyle(color: CustomColor.theme_text_color2),
    ),
  );

  _buildMenuButton(String title, String imagePath, Color color) => Container(
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
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: CustomColor.theme_text_color2),
            ),
          ],
        ),
      );
}
