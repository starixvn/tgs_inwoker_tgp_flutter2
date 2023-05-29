import 'package:api/entity/env_features_config.dart';
import 'package:flutter/material.dart';
import 'package:api/localizations/language_provider.dart';
import 'package:tgp_flutter2/custom/tab_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/login/CustomSky8/LoginContentView.dart';
import 'package:tgp_flutter2/ui/login/login_content.dart';
import 'package:tgp_flutter2/ui/login/login_view_model.dart';
import 'package:tgp_flutter2/ui/login/phone_re_verification/phone_re_verification.dart';
import 'package:tgp_flutter2/ui/login/register_content.dart';
import 'package:api/extension/screen_apis.dart';

import 'RegisterContentView.dart';

class LoginInputView extends StatefulWidget {
  final EnvFeaturesConfig? config;
  final bool defaultRegisterTab;

  LoginInputView({this.config, this.defaultRegisterTab = false});

  @override
  _LoginInputViewState createState() => _LoginInputViewState();
}

class _LoginInputViewState extends BaseState<LoginInputView>
    with TickerProviderStateMixin {
  int currentTabIndex = 0;
  String? username, password;
  TabController? tabController;
  var tab = [];
  LoginViewModel _vm = LoginViewModel();
  void _onCategoryPressed(int index) {
    setState(() {
      currentTabIndex = index;
    });
  }

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
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.44),
                border: Border.all(
                  color: Colors.black.withOpacity(0.44),
                ),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            height: context.screenHeight * 0.5,
            width: context.screenWidth,
            margin: EdgeInsets.symmetric(vertical: 20.auto),
            child: currentTabIndex == 0 ? LoginContentView(vm: _vm, onPressed: () => _onCategoryPressed(1)) : RegisterContentView(vm: _vm)

            // Row(
            //   children:
            //   currentTabIndex == 1 ?
            //   [LoginContent(vm: _vm), _categoryButtonView(true)] :
            //   [_categoryButtonView(false), RegisterContentView(vm: _vm)],
            //   // TabBarView(
            //   //   physics: NeverScrollableScrollPhysics(),
            //   //   controller: tabController,
            //   //   children: [
            //   //     LoginContent(vm: _vm),
            //   //     RegisterContent( vm: _vm),
            //   //   ],
            //   // )
            // )

            // TabBar(
            //   controller: tabController,
            //   onTap: (index) {
            //     setState(() {
            //       currentTabIndex = index;
            //     });
            //   },
            //   labelPadding: EdgeInsets.symmetric(horizontal: 5.auto),
            //   indicatorColor: Colors.transparent,
            //   indicator: BoxDecoration(),
            //   tabs: tab.map((item) {
            //     return Container(
            //         child: TabButton(
            //           text: getTranslatedText(item["text"]),
            //           index: int.parse(item['id']),
            //           currentTabIndex: currentTabIndex,
            //           width: context.screenWidth / 2,
            //           height: 40.auto,
            //         ));
            //   }).toList(),
            // ),
            ),
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
