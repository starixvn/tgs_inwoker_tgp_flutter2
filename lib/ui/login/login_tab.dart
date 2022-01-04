import 'package:flutter/material.dart';
import 'package:api/localizations/language_provider.dart';
import 'package:tgp_flutter2/custom/tab_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/login/login_content.dart';
import 'package:tgp_flutter2/ui/login/phone_re_verification/phone_re_verification.dart';
import 'package:tgp_flutter2/ui/login/register_content.dart';
import 'package:api/extension/screen_apis.dart';

class LoginTab extends StatefulWidget {
  @override
  _LoginTabState createState() => _LoginTabState();
}

class _LoginTabState extends BaseState<LoginTab> with TickerProviderStateMixin {
  int currentTabIndex = 0;
  String? username, password;
  TabController? tabController;
  var tab = [];

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      initialIndex: currentTabIndex,
      length: _isHKJP() ? 3 : 2,
      vsync: this,
    );
    tab = _isHKJP()
        ? [
            {"id": "0", "text": "login"},
            {"id": "1", "text": "register"},
            {"id": "2", "text": "phone_re-verify"}
          ]
        : [
            {"id": "0", "text": "login"},
            {"id": "1", "text": "register"}
          ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 40.auto,
          width: context.screenWidth,
          margin: EdgeInsets.symmetric(vertical: 20.auto),
          child: TabBar(
            controller: tabController,
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
                index: int.parse(item['id']),
                currentTabIndex: currentTabIndex,
                width: context.screenWidth / 2,
                height: 40.auto,
              ));
            }).toList(),
          ),
        ),
        Container(
            height: context.screenHeight - 320.auto,
            width: context.screenWidth,
            child: TabBarView(
              controller: tabController,
              children: _isHKJP()
                  ? [
                      LoginContent(),
                      RegisterContent(
                        onSubmitUsernameAndPassword: (value) => _navigateToPhoneReVerification(value),
                      ),
                      PhoneReVerification(
                        username: username,
                        password: password,
                      )
                    ]
                  : [
                      LoginContent(),
                      RegisterContent(
                        onSubmitUsernameAndPassword: (value) => _navigateToPhoneReVerification(value),
                      ),
                    ],
            ))
      ],
    );
  }

  _navigateToPhoneReVerification(List<String> list) {
    setState(() {
      username = list[0];
      password = list[1];
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      tabController!.animateTo(2);
    });
  }

  _isHKJP() => EnvironmentConfig.isShowSmsVerification;
}
