import 'package:flutter/material.dart';
import 'package:api/localizations/language_provider.dart';
import 'package:tgp_flutter2/custom/tab_button.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/login/login_content.dart';
import 'package:tgp_flutter2/ui/login/register_content.dart';
import 'package:api/extension/screen_apis.dart';

class LoginTab extends StatefulWidget {
  @override
  _LoginTabState createState() => _LoginTabState();
}

class _LoginTabState extends BaseState<LoginTab> {
  int currentTabIndex = 0;
  var tab = [
    {"id": "0", "text": "login"},
    {"id": "1", "text": "register"}
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            height: 40.auto,
            width: context.screenWidth,
            margin: EdgeInsets.symmetric(vertical: 20.auto),
            child: TabBar(
              onTap: (index) {
                setState(() {
                  currentTabIndex = index;
                });
              },
              labelPadding: EdgeInsets.symmetric(horizontal: 5.auto),
              indicatorColor: Colors.transparent,
              tabs: tab.map((item) {
                return Container(
                    child: TabButton(
                  text: getTranslatedText(item["text"]),
                  index: int.parse(item['id']), currentTabIndex: currentTabIndex,
                      width: context.screenWidth/2,
                      height: 40.auto,
                ));
              }).toList(),
            ),
          ),
          Container(
            child: currentTabIndex == 0 ? LoginContent() : RegisterContent(),
          )
        ],
      ),
    );
  }

  _buildTab(String text, String index) => Container(
        width: context.screenWidth,
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: int.parse(index) == currentTabIndex ? CustomColor.theme_button_color : Colors.white,
                    width: 3))),
        child: Tab(
          child: Text(getTranslatedText(text),
              style: TextStyle(
                  fontSize: 16.auto,
                  color: int.parse(index) == currentTabIndex ? CustomColor.theme_button_color : Colors.white)),
        ),
      );
}
