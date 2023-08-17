import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

import '../../custom/custom_progress_dialog.dart';
import '../../environment_config.dart';
import '../../globalUtil/GlobalValueUtil.dart';
import '../../base_state.dart';
import '../../custom/wallet_text_container.dart';

class EndDrawerMenu extends StatefulWidget {
  final String username;
  final double width;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final VoidCallback logout;

  EndDrawerMenu({
    required this.username,
    required this.width,
    this.scaffoldKey,
    required this.logout,
  });

  @override
  _EndDrawerMenuState createState() => _EndDrawerMenuState();
}

class _EndDrawerMenuState extends BaseState<EndDrawerMenu> {
  List<Map<String, String>> itemList = [
    //title, icon, routepath
    {"index": "0", "title": "message_center", "icon": "ic_message", "routePath": "message"},
    {"index": "1", "title": "announcement", "icon": "ic_announcement", "routePath": "announcement"},
    {"index": "2", "title": "edit_password", "icon": "ic_change_password", "routePath": "edit_password"},
    {"index": "3", "title": "bet_record", "icon": "ic_bet_record", "routePath": "transaction"},
    {"index": "4", "title": "language", "icon": "ic_language", "routePath": "language"},
    {"index": "5", "title": "exit", "icon": "ic_signout", "routePath": ""},
  ];

  // List<String> titleList = ["Messages", "Announcement", "Change Password", "Bet Record", "Language", "Signout"];
  //
  // List<String> iconList = ["ic_message", "ic_announcement", "ic_change_password", "ic_bet_record", "ic_language", "ic_signout"];
  double fontSize = 0.0;

  @override
  void initState() {
    List<String> list = itemList.map((element) => element["title"] ?? "").toList();
    fontSize = GlobalValueUtil.calculateFontSizeForLongestString(list, 20.auto, widget.width - 100.auto);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: [
        Container(
          height: context.screenHeight / 3.5,
          child: DrawerHeader(
            padding: EdgeInsets.zero,
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: Color(0xff252957)),
            child: Container(
              height: context.screenHeight / 5,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        if (EnvironmentConfig.template_version == 14) widget.scaffoldKey?.currentState?.closeEndDrawer();
                      },
                      child: Container(
                        height: 25,
                        width: 25,
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.white),
                        child: Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  if (widget.username.isNotEmpty)
                    Container(
                      height: context.screenHeight / 20,
                      width: widget.width * 0.7,
                      child: FittedBox(
                        fit: BoxFit.fitHeight,
                        child: Text(
                          widget.username,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (widget.username.isNotEmpty) SizedBox(height: 10),
                  if (widget.username.isNotEmpty)
                    WalletTextContainer(height: context.screenHeight / 20, width: (widget.width * 0.7), balance: "${GlobalValueUtil.totalBalance != null ? "₱ ${Format().amountFormat(GlobalValueUtil.totalBalance ?? 0)}" : " - "}"),
                  if (widget.username.isNotEmpty) SizedBox(height: 30),
                  if (widget.username.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          getTranslatedText("home_login_hint"),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ]..addAll((widget.username.isNotEmpty) ? List.generate(itemList.length, (index) => _buildDrawerItem(index)) : []),
    );
  }

  _buildDrawerItem(int index) {
    return SizedBox(
      height: 50,
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity(horizontal: 0, vertical: -4),
        leading: SvgPicture.asset(
          "images/drawer_menu/${itemList[index]["icon"]}.svg",
          height: 20.auto,
          color: Colors.white,
        ),
        title: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          alignment: Alignment.centerLeft,
          child: Text(
            getTranslatedText(itemList[index]["title"] ?? ""),
            style: TextStyle(color: Colors.white, fontSize: fontSize),
            maxLines: 1,
          ),
        ),
        onTap: () {
          if (itemList[index] == itemList.last) {
            widget.logout();
          } else {
            Navigator.of(context).pushNamed("/${itemList[index]["routePath"]}");
          }
        },
      ),
    );
  }
}
