import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/tab_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/report/account_report_view.dart';
import 'package:tgp_flutter2/ui/report/deposit_report_view.dart';
import 'package:tgp_flutter2/ui/report/promotion_report_view.dart';
import 'package:tgp_flutter2/ui/report/report_view_model.dart';
import 'package:tgp_flutter2/ui/report/transfer_report_view.dart';
import 'package:tgp_flutter2/ui/report/withdraw_report_view.dart';

class ReportView extends StatefulWidget {
  final int? tabIndex;

  ReportView({this.tabIndex});

  @override
  _ReportViewState createState() => _ReportViewState();
}

class _ReportViewState extends BaseState<ReportView>
    with SingleTickerProviderStateMixin {
  var _tabController;
  var currentTabIndex = 0;
  var tabList = [
    {"id": "0", "text": "bet_history"},
    {"id": "1", "text": "deposit_history"},
    {"id": "2", "text": "withdrawal_history"},
    {"id": "3", "text": "transfer_history"},
    {"id": "4", "text": "promotion_history"},
    /*{"id": "4", "text": "返水记录"},*/
  ];
  ReportViewModel _vm = ReportViewModel();

  @override
  void initState() {
    currentTabIndex = widget.tabIndex ?? 0;
    _tabController = TabController(
        length: tabList.length, vsync: this, initialIndex: currentTabIndex);
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<ReportViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          return CustomScaffold(
            appBar: CustomAppBar(
              title: getTranslatedText((tabList[currentTabIndex]["text"])!),
              walletBalance: _vm.wallet?.totalBalance,
            ),
            body: Column(
              children: [
                Container(
                  width: context.screenWidth,
              color: Colors.transparent,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    unselectedLabelColor: CustomColor.theme_text_grey_color,
                    labelColor: CustomColor.theme_button_color,
                    indicatorColor: Colors.transparent,
                    indicator: BoxDecoration(),
                    indicatorWeight: 3,
                    onTap: (index) {
                      setState(() {
                        currentTabIndex = index;
                      });
                    },
                    labelPadding: EdgeInsets.symmetric(
                        horizontal: 10.auto, vertical: 5.auto),
                    unselectedLabelStyle: TextStyle(color: CustomColor.grey),
                    tabs: List.generate(tabList.length, (index) {
                      return TabButton(
                        text: getTranslatedText((tabList[index]["text"])!) ??
                            tabList[currentTabIndex]["text"],
                        index: index,
                        currentTabIndex: currentTabIndex,
                        width: 90.auto,
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [
                      AccountReportView(vm: _vm),
                      DepositReportView(vm: _vm),
                      WithdrawReportView(vm: _vm),
                      TransferReportView(vm: _vm),
                      PromotionReportView(vm: _vm)
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
