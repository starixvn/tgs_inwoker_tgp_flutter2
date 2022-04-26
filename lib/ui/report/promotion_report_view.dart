import 'package:api/entity/report_cell_item_type.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/entity/status.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/report/base_report.dart';
import 'package:tgp_flutter2/ui/report/report_cell_item.dart';
import 'package:tgp_flutter2/ui/report/report_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class PromotionReportView extends StatefulWidget {
  final ReportViewModel vm;

  PromotionReportView({
    required this.vm,
  });

  @override
  PromotionReportViewState createState() => PromotionReportViewState();
}

class PromotionReportViewState extends BaseState<PromotionReportView> {
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
              _getReport(isLoadMore: mIsLoadMore, status: mStatus);
            },
            setIndex: (value) {
              setState(() {
                filterIndex = value;
              });
            },
            scrollController: _scrollController,
            refreshController: _refreshController,
            list: _vm.promotionReportList,
            displayItemList: _getList(),
            isUploadButton: false,
            url: _vm.brandLogoUrl,
          );
        });
  }

  List<Widget> _getList() => _vm.promotionReportList == null
      ? []
      : List.generate(_vm.promotionReportList!.length, (index) {
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
                _buildReportSubItem(
                    "time",
                    Format().dateTimezoneFormat(
                        _vm.promotionReportList![index].joinedOn)),
                _buildReportSubItem("promotion_name",
                    (_vm.promotionReportList![index].promotionName ?? "")),
              ],
            )),
      ]);

  _buildReportSubItem(String title, String text) => Container(
      padding: EdgeInsets.only(bottom: 3.auto),
      alignment: Alignment.centerLeft,
      child: AutoSizeText(
        getTranslatedText(title) + " : " + text,
        style: TextStyle(color: Colors.grey[700]),
        minFontSize: 10,
        maxFontSize: 12,
        stepGranularity: 1,
        maxLines: 1,
      ));

  _getReportItemType(int index) {
    if (_vm.promotionReportList!.length == 1) {
      return ReportCellItemType.SINGLE;
    } else {
      if (index == 0) {
        return ReportCellItemType.TOP;
      } else if (index == _vm.promotionReportList!.length - 1) {
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

  _getReport({Status? status, bool isLoadMore = false}) async {
    await _vm.getPromotionReport(isLoadMore: isLoadMore);
  }

  _handleApiState() {
    handleApiState(_vm.getPromotionReportApiState,
        isAutoHideLoading: false, onSuccess: () {});
  }
}
