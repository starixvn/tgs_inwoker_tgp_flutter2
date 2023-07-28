import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:api/entity/status.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/report/report_date_item.dart';
import 'package:tgp_flutter2/ui/report/report_filter_button_item.dart';
import 'package:tgp_flutter2/ui/report/report_header_item.dart';
import 'package:tgp_flutter2/ui/report/report_view_model.dart';

class BaseReport extends StatefulWidget {
  final List<String> transactionHeaderList;
  final Widget getPickerBox;
  final int filterIndex;
  final int expandedHeight;
  final ReportViewModel vm;
  final Function(bool, Status?) getReport;
  final Function(int) setIndex;
  final ScrollController scrollController;
  final RefreshController refreshController;
  final List<dynamic>? list;
  final List<Widget>? displayItemList;
  final bool isUploadButton;
  final String url;

  BaseReport({
    required this.transactionHeaderList,
    required this.getPickerBox,
    required this.filterIndex,
    required this.expandedHeight,
    required this.vm,
    required this.getReport,
    required this.setIndex,
    required this.scrollController,
    required this.refreshController,
    this.list,
    this.displayItemList,
    required this.isUploadButton,
    required this.url,
  });

  @override
  BaseReportState createState() => BaseReportState();
}

class BaseReportState extends BaseState<BaseReport> {
  Widget build(BuildContext context) {
    return Container(
      height: context.screenHeight,
      color: Colors.transparent,
      child: ScrollConfiguration(
          behavior: MyBehavior(),
          child: SmartRefresher(
              controller: widget.refreshController,
              enablePullDown: true,
              onRefresh: () {
                widget.getReport(false, null);
                widget.refreshController.refreshCompleted();
              },
              child: widget.list == null
                  ? buildProgressDialog(widget.vm.brandLogoUrl)
                  : CustomScrollView(
                      controller: widget.scrollController,
                      slivers: [
                        SliverAppBar(
                          automaticallyImplyLeading: false,
                          pinned: true,
                          floating: false,
                          expandedHeight: widget.expandedHeight.auto,
                          backgroundColor: Colors.transparent,
                          flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.pin,
                            background: Column(
                              children: [
                                _getCalendarItem(),
                                Flexible(
                                  child: ReportFilterButtonItem(
                                    index: widget.filterIndex,
                                    onTextChanged: (value) => _onDateFilter(value),
                                  ),
                                ),
                                widget.getPickerBox
                              ],
                            ),
                          ),
                          bottom: PreferredSize(
                            preferredSize: Size.zero,
                            child: widget.transactionHeaderList.isNotEmpty
                                ? Center(
                                    child: ReportHeaderItem(
                                      headerList: widget.transactionHeaderList,
                                      isUploadButton: widget.isUploadButton,
                                    ),
                                  )
                                : Container(),
                          ),
                          toolbarHeight: widget.transactionHeaderList.isNotEmpty ? 40.auto : 0,
                          elevation: 0,
                        ),
                        _buildReportItem()
                      ],
                    ))),
    );
  }

  _buildReportItem() => SliverPadding(
        padding: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 5.auto),
        sliver: SliverList(
          delegate: SliverChildListDelegate(
            widget.list?.length == 0
                ? List.generate(
                    1,
                    (index) => Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(left: 10.auto, right: 10.auto),
                          height: 150.auto,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color: EnvironmentConfig.template_version == 14 ? Colors.transparent : Colors.white),
                          padding: EdgeInsets.symmetric(vertical: 10.auto),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 75.auto,
                                height: 75.auto,
                                child: Image.asset("images/transaction/${EnvironmentConfig.template_version == 14 ? "T14/" : ""}ic_no_record.png"),
                              ),
                              Text(
                                getTranslatedText("no_record"),
                                style: TextStyle(
                                  color: EnvironmentConfig.template_version == 14 ? Colors.white : Colors.black,
                                ),
                              )
                            ],
                          ),
                        ))
                : widget.displayItemList ?? [],
          ),
        ),
      );

  _getCalendarItem() => Container(
        padding: EdgeInsets.all(10.auto),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(left: 10.auto),
              child: Text("Date", style: TextStyle(fontSize: 12.auto, color: Colors.white)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ReportDateItem(
                  date: widget.vm.pStartDate,
                  title: getTranslatedText("start_time"),
                  onDateChanged: (value) {
                    _onCalendarClick(value, true);
                  },
                ),
                Container(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.remove,
                    size: 13.auto,
                    color: CustomColor.grey,
                  ),
                ),
                ReportDateItem(
                  date: widget.vm.pEndDate,
                  title: getTranslatedText("end_time"),
                  onDateChanged: (value) {
                    _onCalendarClick(value, false);
                  },
                ),
              ],
            ),
          ],
        ),
      );

  _onCalendarClick(DateTime date, bool isStartDate) {
    if (isStartDate) {
      widget.vm.setDate(startDate: date);
    } else {
      if (date.isBefore(widget.vm.pStartDate)) {
        CustomToast.show(getTranslatedText("transaction_after_start_date"));
        return;
      } else
        widget.vm.setDate(endDate: date);
    }
    _onDateFilter(-1);
  }

  _onDateFilter(int index) {
    var currentDate = DateTime.now();
    switch (index) {
      case 0: //today
        widget.vm.setDate(startDate: DateTime(currentDate.year, currentDate.month, currentDate.day, 0, 0, 0, 0, 0), endDate: currentDate);
        break;
      case 1: //week
        widget.vm.setDate(startDate: DateTime(currentDate.year, currentDate.month, currentDate.day - 7), endDate: currentDate);
        break;
      case 2: //month
        widget.vm.setDate(startDate: DateTime(currentDate.year, currentDate.month - 1, currentDate.day), endDate: currentDate);
        break;
      case -1: //click from calendar
        break;
      default:
        widget.vm.setDate();
        break;
    }
    widget.getReport(false, null);
    widget.setIndex(index);
  }
}
