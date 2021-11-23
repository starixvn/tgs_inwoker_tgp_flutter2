import 'package:flutter/material.dart';
import 'package:api/entity/transaction_cell_item_type.dart';
import 'package:api/extension/format.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/transaction/base_transaction.dart';
import 'package:tgp_flutter2/ui/transaction/transaction_cell_item.dart';
import 'package:tgp_flutter2/ui/transaction/transaction_view_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TransferTransactionView extends StatefulWidget {
  final TransactionViewModel vm;

  TransferTransactionView({
    required this.vm,
  });

  @override
  TransferTransactionViewState createState() => TransferTransactionViewState();
}

class TransferTransactionViewState extends BaseState<TransferTransactionView> {
  ScrollController _scrollController = ScrollController();
  var isLoading = false;
  RefreshController _refreshController = RefreshController();
  var pickerText1;
  var filterIndex = 0;
  TransactionViewModel _vm = TransactionViewModel();

  void initState() {
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
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
            transactionHeaderList: ["trade_time", "transfer_from", "transfer_to", "amount"],
            getPickerBox: Container(),
            filterIndex: filterIndex,
            expandedHeight: 170,
            vm: _vm,
            getTransaction: (mIsLoadMore, mStatus) {
              _getTransaction(isLoadMore: mIsLoadMore);
            },
            setIndex: (value) {
              setState(() {
                filterIndex = value;
              });
            },
            scrollController: _scrollController,
            refreshController: _refreshController,
            list: _vm.transferTransactionList ?? [],
            displayItemList: _getList(),
            isUploadButton: false,
          );
        });
  }

  List<Widget> _getList() => _vm.transferTransactionList == null
      ? []
      : List.generate(_vm.transferTransactionList!.length, (index) {
          return Container(
            child: TransactionCellItem(
              list: [
                "",
                Format().dateTimeFormat(_vm.transferTransactionList![index].balanceTime),
                _vm.transferTransactionList![index].from,
                _vm.transferTransactionList![index].to,
                _vm.transferTransactionList![index].amount.toString(),
              ],
              type: _getTransactionItemType(index),
              isEndRecord: _vm.endRecord,
            ),
          );
        }).toList();

  _getTransactionItemType(int index) {
    if (_vm.transferTransactionList!.length == 1) {
      return TransactionCellItemType.SINGLE;
    } else {
      if (index == 0) {
        return TransactionCellItemType.TOP;
      } else if (index == _vm.transferTransactionList!.length - 1) {
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

  _getTransaction({bool isLoadMore = false}) async {
    await _vm.getTransferTransaction(isLoadMore: isLoadMore);
  }

  _handleApiState() {
    handleApiState(_vm.getTransferTransactionApiState, isAutoHideLoading: false, onSuccess: () {});
  }
}
