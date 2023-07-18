import 'package:api/extension/screen_apis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

import '../../base_state.dart';

class EndDrawerMenu extends StatefulWidget {
  final String username;
  final double width;
  final GlobalKey<ScaffoldState> scaffoldKey;

  EndDrawerMenu({
    required this.username,
    required this.width,
    required this.scaffoldKey,
  });

  @override
  _EndDrawerMenuState createState() => _EndDrawerMenuState();
}

class _EndDrawerMenuState extends BaseState<EndDrawerMenu> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: [
        Container(
          height: context.screenHeight / 4 + 11,
          child: DrawerHeader(
            padding: EdgeInsets.zero,
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: Color(0xff252957)),
            child: Container(
              height: context.screenHeight / 4 + 10,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        widget.scaffoldKey.currentState?.closeEndDrawer();
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
                  Container(
                    height: 40,
                    width: widget.width * 0.7,
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: Text(
                        "Username",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                      height: 50,
                      width: (widget.width * 0.7),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(color: Color(0xff000326), borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            flex: 1,
                            child: FittedBox(
                              fit: BoxFit.fitHeight,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(right: 10),
                                child: Text(
                                  "₱  103.16",
                                  style: TextStyle(
                                    color: CustomColor.theme_button_color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 0,
                            child: Icon(
                              Icons.refresh,
                              size: 30,
                              color: CustomColor.theme_button_color,
                            ),
                          ),
                        ],
                      )),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
        _buildDrawerItem("ic_message", "Messages"),
        _buildDrawerItem("ic_announcement", "Announcement"),
        _buildDrawerItem("ic_change_password", "Change Password"),
        _buildDrawerItem("ic_change_money_password", "Change Money PW"),
        _buildDrawerItem("ic_bet_record", "Bet Record"),
        _buildDrawerItem("ic_language", "Language"),
        _buildDrawerItem("ic_signout", "Signout"),
      ],
    );
  }

  _buildDrawerItem(String iconPath, String title) => SizedBox(
        height: 50,
        child: ListTile(
          dense: true,
          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
          leading: SvgPicture.asset(
            "images/drawer_menu/$iconPath.svg",
            height: 20.auto,
            color: Colors.white,
          ),
          title: Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          onTap: () {
            //
          },
        ),
      );
}
