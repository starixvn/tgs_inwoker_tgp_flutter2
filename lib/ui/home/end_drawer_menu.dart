import 'package:api/extension/screen_apis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

import '../../environment_config.dart';
import '../../globalUtil/GlobalValueUtil.dart';
import '../../base_state.dart';
import '../../custom/wallet_text_container.dart';

class EndDrawerMenu extends StatefulWidget {
  final String username;
  final double width;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  EndDrawerMenu({
    required this.username,
    required this.width,
    this.scaffoldKey,
  });

  @override
  _EndDrawerMenuState createState() => _EndDrawerMenuState();
}

class _EndDrawerMenuState extends BaseState<EndDrawerMenu> {
  List<String> titleList = ["Messages", "Announcement", "Change Password", "Change Money PW", "Bet Record", "Language", "Signout"];
  List<String> iconList = ["ic_message", "ic_announcement", "ic_change_password", "ic_change_money_password", "ic_bet_record", "ic_language", "ic_signout"];
  double fontSize = 0.0;

  @override
  void initState() {
    fontSize = GlobalValueUtil.calculateFontSizeForLongestString(titleList, 20.auto, widget.width - 100.auto);
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
                    WalletTextContainer(height: context.screenHeight / 20, width: (widget.width * 0.7), balance: "₱ ${GlobalValueUtil.totalBalance}"),
                  if (widget.username.isNotEmpty) SizedBox(height: 30),
                  if (widget.username.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          "Please login...",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ]..addAll((widget.username.isNotEmpty) ? List.generate(titleList.length, (index) => _buildDrawerItem(index)) : []),
    );
  }

  _buildDrawerItem(int index) {
    print(fontSize);
    return SizedBox(
      height: 50,
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity(horizontal: 0, vertical: -4),
        leading: SvgPicture.asset(
          "images/drawer_menu/${iconList[index]}.svg",
          height: 20.auto,
          color: Colors.white,
        ),
        title: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          alignment: Alignment.centerLeft,
          child: Text(
            titleList[index],
            style: TextStyle(color: Colors.white, fontSize: fontSize),
            maxLines: 1,
          ),
        ),
        onTap: () {
          //
        },
      ),
    );
  }
}
