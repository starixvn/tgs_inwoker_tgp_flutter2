import 'package:api/entity/env_features_config.dart';
import 'package:flutter/material.dart';
import 'package:api/localizations/language_provider.dart';
import 'package:tgp_flutter2/custom/tab_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/login/CustomSky8/LoginContentView.dart';
import 'package:tgp_flutter2/ui/login/login.dart';
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
  final List<String> sponsorTitleList = [
    'Liverpool',
    'Fiorentina',
    'Real Sociedad',
    'Lyon',
    'Schalke 04'
  ];

  // final List<String> sponsorDescList = [
  //   'Official Asian Partner',
  //   'Fiorentina',
  //   'Real Sociedad',
  //   'Lyon',
  //   'Schalke 04'
  // ];
//  亚洲官方合作伙伴

  void _onCategoryPressed(int index) {
    setState(() {
      _vm = LoginViewModel();
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
            constraints: BoxConstraints(maxHeight: double.infinity),
            height:
                context.screenHeight * (currentTabIndex == 0 ? 0.485 : 0.535),
            width: context.screenWidth,
            margin: EdgeInsets.symmetric(vertical: 20.auto),
            child: currentTabIndex == 0
                ? LoginContentView(
                    vm: _vm, onPressed: () => _onCategoryPressed(1))
                : RegisterContentView(
                    vm: _vm,
                    onPressed: () => _onCategoryPressed(0),
                  )

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
        Container(
          height: 150,
          child: Column(children: [_sponsorTitleView(), _sponsorListRow()]),
        )
      ],
    );
  }

  _sponsorTitleView() => Container(
      margin: EdgeInsets.only(top: 15.auto, left: 35.auto, right: 35.auto),
      child: Center(
        child: Row(
          children: [
            Expanded(
                child:
                    Container(height: 2, color: Colors.white.withOpacity(0.7))),
            Container(
                margin: EdgeInsets.only(left: 10.auto, right: 10.auto),
                child: Text(
                  'Sponsor',
                  style: TextStyle(
                      color: Colors
                          .white, //CustomColor.theme_text_black_white_color,
                      fontSize: 13.auto),
                )),
            Expanded(
                child:
                    Container(height: 2, color: Colors.white.withOpacity(0.7))),
          ],
        ),
      ));

  _sponsorListRow() => Expanded(
      child: Container(
          margin: EdgeInsets.only(top: 10.auto),
          child: Row(
            children: [
              ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: sponsorTitleList.length,
                itemBuilder: (BuildContext context, int index) {
                  String imageString =
                      "images/login/Sky8/sponsor-${index + 1}.png";
                  return Container(
                      width: (context.screenWidth - 30 - 52) /
                          sponsorTitleList.length,
                      // height: 100,
                      margin: EdgeInsets.all(5),
                      child: Column(
                        children: [
                          Container(
                              height: 50.auto,
                              width: 50.auto,
                              child: Image.asset(
                                imageString,
                              )),
                          Expanded(
                              child: Container(
                                  margin: EdgeInsets.only(top: 4.auto),
                                  child: Column(
                                    children: [
                                      Align(
                                          alignment: FractionalOffset.topCenter,
                                          child: Padding(
                                              padding:
                                                  EdgeInsets.only(top: 5.0),
                                              child: Text(
                                                sponsorTitleList[index],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10.auto),
                                              ))),
                                      Expanded(
                                          child: FittedBox( alignment: Alignment.topCenter,
                                              child: Text(
                                                  'Official Asian Partner',
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8.auto))))
                                    ],
                                  )))
                        ],
                      ));
                },
              ),
            ],
          )));

  _navigateToPhoneReVerification(List<String> list) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        currentTabIndex = 2;
      });
      tabController!.animateTo(2);
    });
  }
}
