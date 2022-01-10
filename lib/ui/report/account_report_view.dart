import 'package:api/entity/report_cell_item_type.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/format.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tgp_flutter2/ui/report/base_report.dart';
import 'package:tgp_flutter2/ui/report/report_cell_item.dart';
import 'package:tgp_flutter2/ui/report/report_view_model.dart';

class AccountReportView extends StatefulWidget {
  final ReportViewModel vm;

  AccountReportView({
    //required this.transactionHeaderList,
    required this.vm,
  });

  @override
  AccountReportViewState createState() => AccountReportViewState();
}

class AccountReportViewState extends BaseState<AccountReportView> {
  ScrollController _scrollController = ScrollController();
  var isLoading = false;
  RefreshController _refreshController = RefreshController();
  var pickerText1;
  var filterIndex = 0;
  ReportViewModel _vm = ReportViewModel();

  void initState() {
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _getReport();
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<ReportViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return BaseReport(
            transactionHeaderList: ["bet_time", "bet_platform", "game", "bet_amount", "valid_bet_amount", "win_loss"],
            getPickerBox: Container(),
            filterIndex: filterIndex,
            expandedHeight: 170,
            vm: _vm,
            getReport: (mIsLoadMore, mStatus) {
              _getReport(isLoadMore: mIsLoadMore);
            },
            setIndex: (value) {
              setState(() {
                filterIndex = value;
              });
            },
            scrollController: _scrollController,
            refreshController: _refreshController,
            list: _vm.accountReportList ?? [],
            displayItemList: _getList(),
            isUploadButton: false,
            url: _vm.brandLogoUrl,
          );
        });
  }

  List<Widget> _getList() => _vm.accountReportList == null
      ? []
      : List.generate(_vm.accountReportList!.length, (index) {
          return Container(
            color: CustomColor.theme_bg_color,
            child: ReportCellItem(
              reportList: _vm.accountReportList!,
              list: [
                _vm.accountReportList![index].id,
                "",
                Format().dateTimezoneFormat(_vm.accountReportList![index].createdOn),
                _vm.accountReportList![index].gameProviderName,
                _vm.accountReportList![index].gameName,
                _vm.accountReportList![index].betAmount.toString(),
                _vm.accountReportList![index].validBetAmount.toString(),
                _vm.accountReportList![index].winLoss.toString(),
              ],
              type: _getReportItemType(index),
              isEndRecord: _vm.endRecord,
            ),
          );
        }).toList();

  _getReportItemType(int index) {
    if (_vm.accountReportList!.length == 1) {
      return ReportCellItemType.SINGLE;
    } else {
      if (index == 0) {
        return ReportCellItemType.TOP;
      } else if (index == _vm.accountReportList!.length - 1) {
        return ReportCellItemType.BOTTOM;
      } else {
        return ReportCellItemType.CENTER;
      }
    }
  }

  _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent) {
      setState(() {
        isLoading = true;
      });
      _getReport(isLoadMore: true);
    }
  }

  _getReport({bool isLoadMore = false}) async {
    await _vm.getAccountReport(isLoadMore: isLoadMore);
  }

  _handleApiState() {
    handleApiState(_vm.getReportApiState, isAutoHideLoading: false, onSuccess: () {});
  }
}
