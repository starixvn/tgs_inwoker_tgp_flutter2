import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:api/entity/account_transaction.dart';
import 'package:api/entity/bet_transaction.dart';
import 'package:api/entity/daily_transaction.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/transaction/deposit_withdraw_transaction.dart';
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
    /*currentTabIndex = widget.tabIndex ?? 0;
    _tabController = TabController(length: tabList.length, vsync: this, initialIndex: currentTabIndex);*/
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<TransactionViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: CustomColor.theme_bg_color,
              appBar: CustomAppBar(
                title: "交易记录",
                widget: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 10.auto),
                      child: Text(
                        "¥ ${Format().currencyWithDecimalFormat(_vm.wallet?.main ?? 0.0)}",
                        style: TextStyle(fontSize: 8.auto, color: Colors.white),
                      ),
                    ),
                    Row(
                      children: [],
                    )
                  ],
                ),
              ),
              body: Column(children: [
                Expanded(
                  child: BetTransactionView(
                    vm: _vm,
                  ),
                )
              ]));
        });
  }
}
