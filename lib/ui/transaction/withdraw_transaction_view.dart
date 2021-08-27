import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/custom_picker.dart';
import 'package:tgp_flutter2/custom/custom_picker_dialog.dart';
import 'package:api/entity/status.dart';
import 'package:api/entity/transaction_cell_item_type.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/transaction/base_transaction.dart';
import 'package:tgp_flutter2/ui/transaction/transaction_cell_item.dart';
import 'package:tgp_flutter2/ui/transaction/transaction_view_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class WithdrawTransactionView extends StatefulWidget {
  //final List<String> transactionHeaderList;
  final TransactionViewModel vm;

  WithdrawTransactionView({
    Key key,
    /*this.transactionHeaderList, */
    this.vm,
  }) : super(key: key);

  @override
  WithdrawTransactionViewState createState() => WithdrawTransactionViewState();
}

class WithdrawTransactionViewState extends BaseState<WithdrawTransactionView> {
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
          return BaseTransaction(
            transactionHeaderList: ["time", "status", "amount"],
            getPickerBox: _getPickerBox(),
            filterIndex: filterIndex,
            expandedHeight: 250,
            vm: _vm,
            getTransaction: (mIsLoadMore, mStatus) {
              _getTransaction(isLoadMore: mIsLoadMore, status: mStatus);
            },
            setIndex: (value) {
              setState(() {
                filterIndex = value;
              });
            },
            scrollController: _scrollController,
            refreshController: _refreshController,
            list: _vm.withdrawTransactionList,
            displayItemList: _getList(),
            isUploadButton: false,
          );
        });
  }

  _getList() => _vm.withdrawTransactionList ==null?[]:List.generate(_vm.withdrawTransactionList.length, (index) {
        return Container(
          child: TransactionCellItem(list: [
            _vm.withdrawTransactionList[index].id,
            Format().dateTimeFormat(_vm.withdrawTransactionList[index].createdOn),
            _vm.withdrawTransactionList[index].status.getName(context),
            _vm.withdrawTransactionList[index].amount.toString(),
          ], type: _getTransactionItemType(index), isEndRecord: _vm.endRecord, isUploadButton: false),
        );
      }).toList();

  _getPickerBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.auto),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomPicker(
              title: "status",
              displayText: pickerText1 == null ? getTranslatedText("all") : pickerText1,
              list: _vm.statusList,
              isHintText: true,
              width: context.screenWidth - 70.auto,
              onClick: () {
                _buildPickerDialog("status", _vm.statusList);
              }),
        ],
      ),
    );
  }

  _buildPickerDialog(String title, List<dynamic> list) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext bc) {
          return CustomPickerDialog(
              title: title,
              list: list,
              onChanged: (value) {
                setState(() {
                  if (value is Status) {
                    pickerText1 = value.getName(context);
                    _getTransaction(status: value);
                  }
                  Navigator.pop(context);
                  // ProgressDialog.show(context);
                });
              });
        });
  }

  _getTransactionItemType(int index) {
    if (_vm.withdrawTransactionList.length == 1) {
      return TransactionCellItemType.SINGLE;
    } else {
      if (index == 0) {
        return TransactionCellItemType.TOP;
      } else if (index == _vm.withdrawTransactionList.length - 1) {
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

  _getTransaction({Status status, bool isLoadMore}) async {
    await _vm.getWithdrawTransaction(isLoadMore: isLoadMore ?? false, status: status);
  }

  _handleApiState() {
    handleApiState(_vm.getWithdrawTransactionApiState, isAutoHideLoading: false, onSuccess: () {});
  }
}
