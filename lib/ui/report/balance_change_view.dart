import 'package:api/entity/report_cell_item_type.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/format.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tgp_flutter2/ui/report/base_report.dart';
import 'package:tgp_flutter2/ui/report/report_cell_item.dart';
import 'package:tgp_flutter2/ui/report/report_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class BalanceChangesView extends StatefulWidget {
  final ReportViewModel vm;

  BalanceChangesView({
    //required this.transactionHeaderList,
    required this.vm,
  });

  @override
  BalanceChangesViewState createState() => BalanceChangesViewState();
}

class BalanceChangesViewState extends BaseState<BalanceChangesView> {
  ScrollController _scrollController = ScrollController();
  var isLoading = false;
  RefreshController _refreshController = RefreshController();
  var pickerText1;
  var filterIndex = 0;
  ReportViewModel _vm = ReportViewModel();

  void initState() {
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
            transactionHeaderList: [],
            getPickerBox: Container(),
            filterIndex: filterIndex,
            expandedHeight: 130,
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
            list: _vm.balanceChangesList ?? [],
            displayItemList: _getList(),
            isUploadButton: false,
            url: _vm.brandLogoUrl,
          );
        });
  }

  List<Widget> _getList() => _vm.balanceChangesList == null
      ? []
      : [
          Container(
            padding: EdgeInsets.only(top: 5.auto),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: 10.auto,
                    left: 20.auto,
                    right: 20.auto,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [],
                  ),
                ),
              ],
            ),
          ),
          for (int index = 0; index < _vm.balanceChangesList!.length; index++)
            Container(
              color: Colors.transparent,
              child: ReportCellItem(
                type: _getReportItemType(index),
                isEndRecord: _vm.endRecord,
                buildReportCellItemLayout: _buildReportCellItemLayout(index),
              ),
            ),
        ];

  _inputLayout(String title, String data) {
    return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(bottom: 3.auto),
        child: Row(
          children: [
            AutoSizeText(
              title + ": ",
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
              minFontSize: 10,
              maxFontSize: 12,
              stepGranularity: 1,
              maxLines: 1,
            ),
            AutoSizeText(
              data,
              style: TextStyle(
                color: Colors.grey[700],
              ),
              minFontSize: 10,
              maxFontSize: 12,
              stepGranularity: 1,
              maxLines: 1,
            )
          ],
        ));
  }

  _buildReportCellItemLayout(int index) => Column(children: [
        Container(
            margin: EdgeInsets.symmetric(horizontal: 10.auto),
            child: Flex(
              direction: Axis.vertical,
              children: [
                _inputLayout(
                    getTranslatedText("time"),
                    Format().dateTimezoneFormat(
                        _vm.balanceChangesList![index].recordedon ?? "")),
                _inputLayout(
                    getTranslatedText("bcr_type"),
                    userRepo.apiError![_vm.balanceChangesList![index].type] ??
                        ""),
                _inputLayout(getTranslatedText("bcr_amount"),
                    (_vm.balanceChangesList![index].amount.toString())),
              ],
            )),
      ]);

  _getReportItemType(int index) {
    if (_vm.balanceChangesList!.length == 1) {
      return ReportCellItemType.SINGLE;
    } else {
      if (index == 0 && !(_vm.config?.reportShowRoundsTotal ?? true)) {
        return ReportCellItemType.TOP;
      } else if (index == (_vm.balanceChangesList!.length - 1)) {
        return ReportCellItemType.BOTTOM;
      } else {
        return ReportCellItemType.CENTER;
      }
    }
  }

  _scrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent) {
      setState(() {
        isLoading = true;
      });
      _getReport(isLoadMore: true);
    }
  }

  _getReport({bool isLoadMore = false}) async {
    await _vm.getBalanceChangeRecord(isLoadMore: isLoadMore);
  }

  _handleApiState() {
    handleApiState(_vm.getBalanceChangesApiState,
        isAutoHideLoading: false, onSuccess: () {});
  }
}
