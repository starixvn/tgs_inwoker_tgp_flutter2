import 'package:flutter/material.dart';
import 'package:api/entity/game_provider.dart';
import 'package:api/entity/transaction_cell_item_type.dart';
import 'package:api/extension/format.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/transaction/base_transaction.dart';
import 'package:tgp_flutter2/ui/transaction/transaction_cell_item.dart';
import 'package:tgp_flutter2/ui/transaction/transaction_view_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AccountTransactionView extends StatefulWidget {

  final TransactionViewModel vm;

  AccountTransactionView({
    //required this.transactionHeaderList,
    required this.vm,
  });

  @override
  AccountTransactionViewState createState() => AccountTransactionViewState();
}

class AccountTransactionViewState extends BaseState<AccountTransactionView> {
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
            transactionHeaderList: ["bet_time", "bet_platform", "game", "bet_amount", "win_loss"],
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
            list: _vm.betTransactionList ??[],
            displayItemList: _getList(),
            isUploadButton: false,
          );
        });
  }

  List<Widget> _getList() => _vm.betTransactionList == null
      ? []
      : List.generate(_vm.betTransactionList!.length, (index) {
          return Container(
            color: CustomColor.theme_bg_color,
            child: TransactionCellItem(
              list: [
                _vm.betTransactionList![index].id,
                Format().dateTimeFormat(_vm.betTransactionList![index].createdOn),
                _vm.betTransactionList![index].gameProviderName,
                _vm.betTransactionList![index].gameName,
                _vm.betTransactionList![index].betAmount.toString(),
                _vm.betTransactionList![index].winLoss.toString(),
              ],
              type: _getTransactionItemType(index),
              isEndRecord: _vm.endRecord,
            ),
          );
        }).toList();

  _getTransactionItemType(int index) {
    if (_vm.betTransactionList!.length == 1) {
      return TransactionCellItemType.SINGLE;
    } else {
      if (index == 0) {
        return TransactionCellItemType.TOP;
      } else if (index == _vm.betTransactionList!.length - 1) {
        return TransactionCellItemType.BOTTOM;
      } else {
        return TransactionCellItemType.CENTER;
      }
    }
  }

  _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent) {
      setState(() {
        isLoading = true;
      });
      _getTransaction(isLoadMore: true);
    }
  }

  _getTransaction({bool isLoadMore = false}) async {
    await _vm.getTransaction(isLoadMore: isLoadMore) ;
  }

  _handleApiState() {
    handleApiState(_vm.getTransactionApiState, isAutoHideLoading: false, onSuccess: () {});
  }
}
