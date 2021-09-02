import 'package:flutter/material.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/tab_button.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/transaction/account_transaction_view.dart';
import 'package:tgp_flutter2/ui/transaction/bet_transaction_view.dart';
import 'package:tgp_flutter2/ui/transaction/transfer_transaction_view.dart';
import 'package:tgp_flutter2/ui/transaction/transaction_view_model.dart';
import 'package:tgp_flutter2/ui/transaction/withdraw_transaction_view.dart';

class Transaction extends StatefulWidget {
  final int tabIndex;

  Transaction({Key key, this.tabIndex}) : super(key: key);

  @override
  _TransactionState createState() => _TransactionState();
}

class _TransactionState extends BaseState<Transaction> with SingleTickerProviderStateMixin {
  var _tabController;
  var currentTabIndex = 0;
  var tabList = [
    {"id": "0", "text": "bet_history"},
    {"id": "1", "text": "deposit_history"},
    {"id": "2", "text": "withdrawal_history"},
    {"id": "3", "text": "transfer_history"},
    /*{"id": "4", "text": "返水记录"},*/
  ];
  TransactionViewModel _vm = TransactionViewModel();

  @override
  void initState() {
    currentTabIndex = widget.tabIndex ?? 0;
    _tabController = TabController(length: tabList.length, vsync: this, initialIndex: currentTabIndex);
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<TransactionViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            appBar: CustomAppBar(
              title: getTranslatedText(tabList[currentTabIndex]["text"]),
              widget: Container(
            margin: EdgeInsets.only(right: 15.auto),
              alignment: Alignment.center,
              child: Text(
                "¥ ${Format().currencyWithDecimalFormat(_vm.wallet?.main ?? 0.0)}",
                style: TextStyle(color: CustomColor.theme_text_grey_color),
              )),
            ),
            body: Column(
              children: [
                Container(
                  width: context.screenWidth,
                  color: CustomColor.theme_bg_color,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    unselectedLabelColor: CustomColor.theme_text_grey_color,
                    labelColor: CustomColor.theme_button_color,
                    indicatorColor: Colors.transparent,
                    indicatorWeight: 3,
                    onTap: (index) {
                      setState(() {
                        currentTabIndex = index;
                      });
                    },
                    labelPadding: EdgeInsets.symmetric(horizontal: 10.auto, vertical: 5.auto),
                    unselectedLabelStyle: TextStyle(color: CustomColor.grey),
                    tabs: List.generate(tabList.length, (index) {
                      return TabButton(
                        text: getTranslatedText(tabList[index]["text"]) ?? tabList[currentTabIndex]["text"],
                        index: index,
                        currentTabIndex: currentTabIndex,
                        width: 90.auto,
                        height: 32.auto,
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      BetTransactionView(
                        vm: _vm,
                      ),
                      AccountTransactionView(
                        vm: _vm,
                      ),
                      WithdrawTransactionView(
                        vm: _vm,
                      ),
                      TransferTransactionView(vm: _vm)
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
