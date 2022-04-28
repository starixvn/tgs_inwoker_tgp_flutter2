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
            list: _vm.accountReportList ?? [],
            displayItemList: _getList(),
            isUploadButton: false,
            url: _vm.brandLogoUrl,
          );
        });
  }

  List<Widget> _getList() => _vm.accountReportList == null
      ? []
      : [
          if (_vm.config?.reportShowRoundsTotal ?? false)
            Container(
              padding: EdgeInsets.only(top: 5.auto),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.auto,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildReportSubItem("total_bet_amount", (_vm.accountReportTotal?.betAmount ?? 0).toString()),
                        _buildReportSubItem(
                            "total_valid_bet_amount", (_vm.accountReportTotal?.validBetAmount ?? 0).toString()),
                        _buildWinLossText("total_win_loss", (_vm.accountReportTotal?.winLoss ?? 0).toString()),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: (1.0).auto,
                    color: CustomColor.very_light_pink_four,
                  )
                ],
              ),
            ),
          for (int index = 0; index < _vm.accountReportList!.length; index++)
            Container(
              color: CustomColor.theme_bg_color,
              child: ReportCellItem(
                type: _getReportItemType(index),
                isEndRecord: _vm.endRecord,
                buildReportCellItemLayout: _buildReportCellItemLayout(index),
              ),
            ),
        ];

  _buildReportCellItemLayout(int index) => Column(children: [
        Container(
            margin: EdgeInsets.symmetric(horizontal: 10.auto),
            child: Flex(
              direction: Axis.vertical,
              children: [
                Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(bottom: 3.auto),
                    child: AutoSizeText(
                      getTranslatedText("order_number") + (_vm.accountReportList![index].id ?? ""),
                      style: TextStyle(color: Colors.grey[700]),
                      minFontSize: 10,
                      maxFontSize: 12,
                      stepGranularity: 1,
                      maxLines: 1,
                    )),
                Container(
                  height: 20.auto,
                  padding: EdgeInsets.only(bottom: 3.auto),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AutoSizeText(
                        (_vm.accountReportList![index].gameName ?? "") +
                            " - " +
                            (_vm.accountReportList![index].gameProviderName ?? ""),
                        style: TextStyle(color: Colors.grey[700]),
                        minFontSize: 10,
                        maxFontSize: 12,
                        stepGranularity: 1,
                      ),
                      AutoSizeText(
                        Format().dateTimezoneFormat(_vm.accountReportList![index].createdOn),
                        style: TextStyle(color: Colors.grey[700]),
                        minFontSize: 10,
                        maxFontSize: 12,
                        stepGranularity: 1,
                      )
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReportSubItem("bet_amount", _vm.accountReportList![index].betAmount.toString()),
                    _buildReportSubItem("valid_bet_amount", _vm.accountReportList![index].validBetAmount.toString()),
                    _buildWinLossText("win_loss", _vm.accountReportList![index].winLoss.toString()),
                  ],
                ),
              ],
            )),
      ]);

  _buildReportSubItem(String title, String text) => Expanded(
        flex: 1,
        child: AutoSizeText(
          getTranslatedText(title) + " : " + text,
          style: TextStyle(color: Colors.grey[700]),
          minFontSize: 5,
          maxFontSize: 12,
          stepGranularity: 1,
          textAlign: TextAlign.left,
        ),
      );

  _buildWinLossText(String title, String text) => Expanded(
        flex: 1,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AutoSizeText(
              getTranslatedText(title) + " : ",
              style: TextStyle(color: Colors.grey[700]),
              minFontSize: 5,
              maxFontSize: 12,
              stepGranularity: 1,
              textAlign: TextAlign.left,
            ),
            AutoSizeText(text,
                style: TextStyle(color: _getTextColor(text)),
                minFontSize: 5,
                maxFontSize: 12,
                stepGranularity: 1,
                textAlign: TextAlign.left),
          ],
        ),
      );

  _getTextColor(String? text) {
    if (text != null && text != "null")
      return (text.contains("-") ? Colors.red : Colors.green);
    else
      return Colors.grey[700];
  }

  _getReportItemType(int index) {
    if (_vm.accountReportList!.length == 1) {
      return ReportCellItemType.SINGLE;
    } else {
      if (index == 0 && !(_vm.config?.reportShowRoundsTotal ?? false)) {
        return ReportCellItemType.TOP;
      } else if (index == (_vm.accountReportList!.length - 1)) {
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
