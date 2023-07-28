import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/tab_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/globalUtil/GlobalValueUtil.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/report/account_report_view.dart';
import 'package:tgp_flutter2/ui/report/balance_change_view.dart';
import 'package:tgp_flutter2/ui/report/deposit_report_view.dart';
import 'package:tgp_flutter2/ui/report/promotion_report_view.dart';
import 'package:tgp_flutter2/ui/report/report_view_model.dart';
import 'package:tgp_flutter2/ui/report/transfer_report_view.dart';
import 'package:tgp_flutter2/ui/report/withdraw_report_view.dart';

class ReportViewT14 extends StatefulWidget {
  final int? tabIndex;

  ReportViewT14({this.tabIndex});

  @override
  _ReportViewT14State createState() => _ReportViewT14State();
}

class _ReportViewT14State extends BaseState<ReportViewT14> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var currentTabIndex = 0;
  var tabList = [
    {"id": "0", "text": "report_bet"},
    {"id": "1", "text": "report_withdrawal"},
    {"id": "2", "text": "deposit"},
    {"id": "3", "text": "transfer"},
    {"id": "6", "text": "balanceChangeRecords"},
    {"id": "4", "text": "promotion_history"},
    /*{"id": "4", "text": "返水记录"},*/
  ];
  ReportViewModel _vm = ReportViewModel();

  @override
  void initState() {
    currentTabIndex = widget.tabIndex ?? 0;
    _tabController = TabController(length: tabList.length, vsync: this, initialIndex: currentTabIndex);
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<ReportViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          return CustomScaffold(
            appBar: CustomAppBar(
              title: getTranslatedText((tabList[currentTabIndex]["text"])!).toString().toUpperCase(),
              walletBalance: _vm.wallet?.totalBalance,
            ),
            body: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10.auto),
                  child: Wrap(
                    spacing: 10.auto, // Adjust the spacing between tabs
                    runSpacing: 10.auto, // Adjust the spacing between rows of tabs
                    alignment: WrapAlignment.center,
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
                                  border: Border(
                                    bottom: BorderSide(
                                      color: index == currentTabIndex ? CustomColor.tab_selected_color : CustomColor.tab_unselected_color,
                                      width: 3,
                                    ),
                                  ),
                                ),
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 17),
                          child: Text(
                            getTranslatedText((tabList[index]["text"])!) ?? tabList[currentTabIndex]["text"],
                            style: TextStyle(color: Colors.white, fontSize: 14.auto),
                          ),
                        ),
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
                      WithdrawReportView(vm: _vm),
                      DepositReportView(vm: _vm),
                      TransferReportView(vm: _vm),
                      BalanceChangesView(vm: _vm),
                      PromotionReportView(vm: _vm),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
