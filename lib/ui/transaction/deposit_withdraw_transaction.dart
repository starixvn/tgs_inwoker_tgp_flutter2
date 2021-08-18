import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_picker.dart';
import 'package:tgp_flutter2/custom/custom_picker_dialog.dart';
import 'package:api/entity/status.dart';
import 'package:api/entity/transaction_cell_item_type.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/transaction/transaction_silver_app_bar.dart';
import 'package:tgp_flutter2/ui/transaction/transaction_cell_item.dart';
import 'package:tgp_flutter2/ui/transaction/transaction_view_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DepositWithdrawTransactionView extends StatefulWidget {
  final TransactionViewModel vm;

  DepositWithdrawTransactionView({
    Key key,
    this.vm,
  }) : super(key: key);

  @override
  DepositWithdrawTransactionViewState createState() => DepositWithdrawTransactionViewState();
}

class DepositWithdrawTransactionViewState extends BaseState<DepositWithdrawTransactionView> {
  ScrollController _scrollController = ScrollController();
  var isLoading = false;
  RefreshController _refreshController = RefreshController();
  var pickerText1;
  var filterIndex = 0;
  TransactionViewModel _vm = TransactionViewModel();


  void initState() {
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getTransaction();
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<TransactionViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
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
            body:TransactionSilverAppBar(
              transactionHeaderList: ["time", "status", "amount"],
              filterIndex: filterIndex,
              expandedHeight: 170,
              vm: _vm,
              getTransaction: (mIsLoadMore, index) {
                _getTransaction(isLoadMore: mIsLoadMore, index: index);
              },
              setIndex: (value) {
                setState(() {
                  filterIndex = value;
                });
              },
              scrollController: _scrollController,
              refreshController: _refreshController,
              list: _vm.accountTransactionList,
              displayItemList: _getList(),
            ),
          );
        });
  }

  _getList() => _vm.accountTransactionList ==null?[]:List.generate(_vm.accountTransactionList.length, (index) {
        return Container(
          child: TransactionCellItem(list: [
            _vm.accountTransactionList[index].id,
            Format().dateTimeFormat(_vm.accountTransactionList[index].createdOn),
            _vm.accountTransactionList[index].status.getName(context),
            _vm.accountTransactionList[index].amount.toString(),
          ], type: _getTransactionItemType(index), isEndRecord: _vm.endRecord),
        );
      }).toList();

  _getTransactionItemType(int index) {
    if (_vm.accountTransactionList.length == 1) {
      return TransactionCellItemType.SINGLE;
    } else {
      if (index == 0) {
        return TransactionCellItemType.TOP;
      } else if (index == _vm.accountTransactionList.length - 1) {
        return TransactionCellItemType.BOTTOM;
      } else {
        return TransactionCellItemType.CENTER;
      }
    }
  }



  _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent) {
      _getTransaction(isLoadMore: true);
      setState(() {
        isLoading = true;
      });
    }
  }

  _getTransaction({bool isLoadMore, int index}) async {
    await _vm.getAccountTransaction(isLoadMore: isLoadMore ?? false, status: Status.All);
  }

  _handleApiState() {
    handleApiState(_vm.getAccountTransactionApiState, isAutoHideLoading: false, onSuccess: () {});
  }
}
