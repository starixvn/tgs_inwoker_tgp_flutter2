import 'package:api/entity/report_cell_item_type.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/format.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tgp_flutter2/ui/report/base_report.dart';
import 'package:tgp_flutter2/ui/report/report_cell_item.dart';
import 'package:tgp_flutter2/ui/report/report_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class TransferReportView extends StatefulWidget {
  final ReportViewModel vm;

  TransferReportView({
    required this.vm,
  });

  @override
  TransferReportViewState createState() => TransferReportViewState();
}

class TransferReportViewState extends BaseState<TransferReportView> {
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
            list: _vm.transferReportList ?? [],
            displayItemList: _getList(),
            isUploadButton: false,
            url: _vm.brandLogoUrl,
          );
        });
  }

  List<Widget> _getList() => _vm.transferReportList == null
      ? []
      : List.generate(_vm.transferReportList!.length, (index) {
          return Container(
            child: ReportCellItem(
              type: _getReportItemType(index),
              isEndRecord: _vm.endRecord,
              buildReportCellItemLayout: _buildReportCellItemLayout(index),
            ),
          );
        }).toList();

  _buildReportCellItemLayout(int index) => Column(children: [
        Container(
            margin: EdgeInsets.symmetric(horizontal: 10.auto),
            child: Flex(
              direction: Axis.vertical,
              children: [
                _buildReportSubItem("from", (_vm.transferReportList![index].from ?? "")),
                _buildReportSubItem("to", (_vm.transferReportList![index].to ?? "")),
                _buildReportSubItem(
                    "amount",
                    EnvironmentConfig.brandName == "IDR1"
                        //without decimal places
                        ? Format().currencyFormat((_vm.reportList?[index].amount ?? 0).toInt())
                        //with 2 decimal places
                        : (_vm.transferReportList![index].amount ?? 0).toString()),
                Container(
                    margin: EdgeInsets.only(top: 3.auto),
                    alignment: Alignment.centerLeft,
                    child: AutoSizeText(
                      Format().dateTimezoneFormat(_vm.transferReportList![index].balanceTime),
                      style: TextStyle(color: Colors.grey[700]),
                      minFontSize: 10,
                      maxFontSize: 12,
                      stepGranularity: 1,
                      maxLines: 1,
                    ))
              ],
            )),
      ]);

  _buildReportSubItem(String title, String text) => Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 3.auto),
      child: AutoSizeText(
        getTranslatedText(title) + " : " + text,
        style: TextStyle(color: Colors.grey[700]),
        minFontSize: 10,
        maxFontSize: 12,
        stepGranularity: 1,
        maxLines: 1,
      ));

  _getReportItemType(int index) {
    if (_vm.transferReportList!.length == 1) {
      return ReportCellItemType.SINGLE;
    } else {
      if (index == 0) {
        return ReportCellItemType.TOP;
      } else if (index == _vm.transferReportList!.length - 1) {
        return ReportCellItemType.BOTTOM;
      } else {
        return ReportCellItemType.CENTER;
      }
    }
  }

  _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent) {
      _getReport(isLoadMore: true);
      setState(() {
        isLoading = true;
      });
    }
  }

  _getReport({bool isLoadMore = false}) async {
    await _vm.getTransferReport(isLoadMore: isLoadMore);
  }

  _handleApiState() {
    handleApiState(_vm.getTransferReportApiState, isAutoHideLoading: false, onSuccess: () {});
  }
}
