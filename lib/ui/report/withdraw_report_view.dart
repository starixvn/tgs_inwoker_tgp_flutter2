import 'package:api/entity/report_cell_item_type.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/custom_picker_dialog.dart';
import 'package:api/entity/status.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/deposit_picker.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/report/base_report.dart';
import 'package:tgp_flutter2/ui/report/report_cell_item.dart';
import 'package:tgp_flutter2/ui/report/report_view_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class WithdrawReportView extends StatefulWidget {
  final ReportViewModel vm;

  WithdrawReportView({
    required this.vm,
  });

  @override
  WithdrawReportViewState createState() => WithdrawReportViewState();
}

class WithdrawReportViewState extends BaseState<WithdrawReportView> {
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
            transactionHeaderList: ["time", "status", "amount"],
            getPickerBox: _getPickerBox(),
            filterIndex: filterIndex,
            expandedHeight: 210,
            vm: _vm,
            getReport: (mIsLoadMore, mStatus) {
              _getReport(isLoadMore: mIsLoadMore, status: mStatus);
            },
            setIndex: (value) {
              setState(() {
                filterIndex = value;
              });
            },
            scrollController: _scrollController,
            refreshController: _refreshController,
            list: _vm.withdrawReportList ?? [],
            displayItemList: _getList(),
            isUploadButton: false,
            url: _vm.brandLogoUrl,
          );
        });
  }

  List<Widget> _getList() => _vm.withdrawReportList == null
      ? []
      : List.generate(_vm.withdrawReportList!.length, (index) {
          return Container(
            child: ReportCellItem(
              type: _getReportItemType(index),
              isEndRecord: _vm.endRecord,
              buildReportCellItemLayout: _buildReportCellItemLayout(index),
            ),
          );
        }).toList();

  _buildReportCellItemLayout(int index) => Container(
      margin: EdgeInsets.symmetric(horizontal: 10.auto),
      child: Flex(
        direction: Axis.vertical,
        children: [
          Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(bottom: 3.auto),
              child: AutoSizeText(
                getTranslatedText("gms_order_number") +
                    (_vm.withdrawReportList![index].orderNo ?? ""),
                style: TextStyle(color: Colors.grey[700]),
                minFontSize: 10,
                maxFontSize: 12,
                stepGranularity: 1,
                maxLines: 1,
              )),
          Container(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    Format().dateTimezoneFormat(
                        _vm.withdrawReportList![index].createdOn),
                    style: TextStyle(color: Colors.grey[700]),
                    minFontSize: 10,
                    maxFontSize: 12,
                    stepGranularity: 1,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    _vm.withdrawReportList![index].status.getName(context),
                    style: TextStyle(color: Colors.grey[700]),
                    minFontSize: 10,
                    maxFontSize: 12,
                    stepGranularity: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    _vm.withdrawReportList![index].amount.toString(),
                    style: TextStyle(color: Colors.grey[700]),
                    minFontSize: 10,
                    maxFontSize: 12,
                    stepGranularity: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ));

  _getPickerBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.auto),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DepositPicker(
              title: "status",
              displayText:
                  pickerText1 == null ? getTranslatedText("all") : pickerText1,
              list: _vm.withdrawalStatusList,
              isHintText: false,
              width: context.screenWidth - 70.auto,
              onClick: () {
                _buildPickerDialog("status", _vm.withdrawalStatusList);
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
                    _getReport(status: value);
                  }
                  Navigator.pop(context);
                  // ProgressDialog.show(context, _vm.brandLogoUrl);
                });
              });
        });
  }

  _getReportItemType(int index) {
    if (_vm.withdrawReportList!.length == 1) {
      return ReportCellItemType.SINGLE;
    } else {
      if (index == 0) {
        return ReportCellItemType.TOP;
      } else if (index == _vm.withdrawReportList!.length - 1) {
        return ReportCellItemType.BOTTOM;
      } else {
        return ReportCellItemType.CENTER;
      }
    }
  }

  _scrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent) {
      _getReport(isLoadMore: true);
      setState(() {
        isLoading = true;
      });
    }
  }

  _getReport({Status? status = Status.All, bool isLoadMore = false}) async {
    await _vm.getWithdrawReport(isLoadMore: isLoadMore, status: status);
  }

  _handleApiState() {
    handleApiState(_vm.getWithdrawReportApiState,
        isAutoHideLoading: false, onSuccess: () {});
  }
}
