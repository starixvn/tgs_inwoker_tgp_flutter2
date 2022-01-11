import 'package:api/entity/account_report.dart';
import 'package:api/entity/report_cell_item_type.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class ReportCellItem extends StatefulWidget {
  //final List<dynamic> list;
  final ReportCellItemType type;
  final bool isEndRecord;

  /*  final bool isUploadButton;
  final bool isDepositReport;
  final bool isWithdrawReport;
  final Function? getManualDepositId;
  final List<dynamic> reportList;
  final List<String> headerList;*/
  final Widget buildReportCellItemLayout;

  ReportCellItem(
      {
      /*required this.list,
    required this.reportList,*/
      required this.type,
      required this.isEndRecord,
      /*this.isUploadButton = false,
    this.getManualDepositId,
    this.isDepositReport = false,
    this.isWithdrawReport = false,
    required this.headerList,*/
      required this.buildReportCellItemLayout});

  @override
  _ReportCellItemState createState() => _ReportCellItemState();
}

class _ReportCellItemState extends BaseState<ReportCellItem> {
  var text1, text2, text3;

  Widget build(BuildContext context) {
    //only one item
    if (widget.type == ReportCellItemType.SINGLE) {
      return Container(
        padding: EdgeInsets.only(bottom: 10.auto),
        child: Container(
          padding: EdgeInsets.only(top: 5.auto, bottom: 10.auto),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: _getReportCellItem(isLast: true),
        ),
      );
    }
    //top item
    else if (widget.type == ReportCellItemType.TOP) {
      return Container(
          padding: EdgeInsets.only(top: 5.auto),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          child: _getReportCellItem());
    }
    //bottom item
    else if (widget.type == ReportCellItemType.BOTTOM) {
      return Column(children: [
        Container(
          padding: EdgeInsets.only(bottom: 10.auto),
          child: Container(
              padding: EdgeInsets.only(bottom: 10.auto),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
              ),
              child: _getReportCellItem(isLast: true)),
        ),
        widget.isEndRecord
            ? Container(
                padding: EdgeInsets.only(bottom: 10.auto),
                child: Text(
                  getTranslatedText("no_more"),
                  style: TextStyle(fontSize: 12.auto, color: CustomColor.theme_text_grey_color),
                ),
              )
            : Container()
      ]);
    } else {
      return Container(color: Colors.white, child: _getReportCellItem());
    }
  }

  _getReportCellItem({bool isLast = false}) => Column(children: [
        Container(margin: EdgeInsets.symmetric(horizontal: 10.auto), child: widget.buildReportCellItemLayout),
        handleNullWidget(
            isLast,
            Divider(
              thickness: (1.0).auto,
              color: CustomColor.very_light_pink_four,
            ))
      ]);
}
