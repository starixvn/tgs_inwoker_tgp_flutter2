import 'dart:ui';
import 'package:api/entity/vip.dart';
import 'package:api/extension/format.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/memo/sent.dart';
import 'package:tgp_flutter2/ui/vip/vipT14.dart';
import 'package:tgp_flutter2/ui/vip/vip_view_model.dart';

import '../../custom/custom_text_form_field.dart';
import '../report/account_report_view.dart';
import 'compose.dart';
import 'inbox.dart';
import 'memo_view_model.dart';

class Memo extends StatefulWidget {
  @override
  _MemoState createState() => _MemoState();
}

class _MemoState extends BaseState<Memo> with SingleTickerProviderStateMixin {
  var _tabController;
  var currentTabIndex = 0;
  var tabList = [
    {"id": "0", "text": "compose"},
    {"id": "1", "text": "inbox"},
    {"id": "2", "text": "sent"},

    /*{"id": "4", "text": "返水记录"},*/
  ];
  MemoViewModel _vm = MemoViewModel();

  @override
  void initState() {
    _tabController = TabController(length: tabList.length, vsync: this, initialIndex: currentTabIndex);
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<MemoViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();

          return CustomScaffold(
            appBar: CustomAppBar(
              title: getTranslatedText("memo").toString().toUpperCase(),
            ),
            body: Column(
              children: [
                Container(
                  width: context.screenWidth,
                  padding: EdgeInsets.symmetric(horizontal: 10.auto),
                  margin: EdgeInsets.only(top: 10.auto),
                  child: Wrap(
                    spacing: 10.auto, // Adjust the spacing between tabs
                    runSpacing: 10.auto, // Adjust the spacing between rows of tabs
                    alignment: EnvironmentConfig.template_version == 14 ? WrapAlignment.center : WrapAlignment.start,
                    children: List.generate(tabList.length, (index) {
                      return InkWell(
                        onTap: () {
                          // Handle tab button press
                          setState(() {
                            currentTabIndex = index;
                          });
                          _tabController.animateTo(index);
                        },
                        child: Container(
                          decoration: EnvironmentConfig.template_version == 14
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: index == currentTabIndex ? CustomColor.tab_selected_color : CustomColor.tab_unselected_color,
                                )
                              : BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: index == currentTabIndex ? CustomColor.tab_selected_color : CustomColor.tab_selected_color.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                          padding: EdgeInsets.symmetric(
                              vertical: EnvironmentConfig.template_version == 14 ? 12 : 5, horizontal: EnvironmentConfig.template_version == 14 ? 17 : 10),
                          child: Text(
                            getTranslatedText((tabList[index]["text"])!) ?? tabList[currentTabIndex]["text"],
                            style: TextStyle(
                                color: EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode ? Colors.white : Colors.black,
                                fontSize: EnvironmentConfig.template_version == 14 ? 14.auto : 10.auto,
                                fontWeight: index == currentTabIndex ? FontWeight.w900 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [
                      Compose(vm: _vm),
                      Inbox(vm: _vm),
                      Sent(vm: _vm),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  _handleApiState() {
    handleApiState(_vm.getStationLetterListApiState, onSuccess: () {});
  }
}
