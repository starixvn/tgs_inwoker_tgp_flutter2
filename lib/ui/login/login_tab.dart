import 'package:api/entity/env_features_config.dart';
import 'package:flutter/material.dart';
import 'package:api/localizations/language_provider.dart';
import 'package:tgp_flutter2/custom/tab_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/login/login_content.dart';
import 'package:tgp_flutter2/ui/login/login_view_model.dart';
import 'package:tgp_flutter2/ui/login/phone_re_verification/phone_re_verification.dart';
import 'package:tgp_flutter2/ui/login/register_content.dart';
import 'package:api/extension/screen_apis.dart';

class LoginTab extends StatefulWidget {
  final EnvFeaturesConfig? config;
  final bool defaultRegisterTab;
  final ValueChanged<int> updateIndex;

  LoginTab({this.config, this.defaultRegisterTab = false, required this.updateIndex});

  @override
  _LoginTabState createState() => _LoginTabState();
}

class _LoginTabState extends BaseState<LoginTab> with TickerProviderStateMixin {
  int currentTabIndex = 0;
  String? username, password;
  TabController? tabController;
  var tab = [];
  LoginViewModel _vm = LoginViewModel();

  @override
  void initState() {
    super.initState();
    if (widget.defaultRegisterTab) currentTabIndex = 1;

    tabController = TabController(
      initialIndex: currentTabIndex,
      length: 2,
      vsync: this,
    );
    tab = [
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
              widget.updateIndex(index);
            },
            labelPadding: EdgeInsets.symmetric(horizontal: 5.auto),
            indicatorColor: Colors.transparent,
            indicator: BoxDecoration(),
            tabs: tab.map((item) {
              return Container(
                  child: TabButton(
                text: getTranslatedText(item["text"]),
                index: int.parse(item['id']),
                currentTabIndex: currentTabIndex,
                width: EnvironmentConfig.template_version == 14 ? context.screenWidth / 3.5 : context.screenWidth / 2,
                height: 40.auto,
              ));
            }).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: tabController,
            children: [
              LoginContent(vm: _vm),
              RegisterContent(vm: _vm),
            ],
          ),
        )
      ],
    );
  }

  _navigateToPhoneReVerification(List<String> list) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        currentTabIndex = 2;
      });
      tabController!.animateTo(2);
    });
  }
}
