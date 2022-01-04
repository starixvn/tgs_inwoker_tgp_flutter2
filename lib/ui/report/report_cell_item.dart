import 'package:api/entity/account_report.dart';
import 'package:api/entity/report_cell_item_type.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class ReportCellItem extends StatefulWidget {
  final List<dynamic> list;
  final ReportCellItemType type;
  final bool isEndRecord;
  final bool isUploadButton;
  final bool isDepositReport;
  final bool isWithdrawReport;
  final Function? getManualDepositId;
  final List<dynamic> reportList;

  ReportCellItem({
    required this.list,
    required this.reportList,
    required this.type,
    required this.isEndRecord,
    this.isUploadButton = false,
    this.getManualDepositId,
    this.isDepositReport = false,
    this.isWithdrawReport = false,
  });

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
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10.auto),
          child: Column(
            children: [
              widget.list[0].isEmpty
                  ? Container()
                  : Row(
                      children: [
                        Text(
                          getTranslatedText("order_number"),
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                        AutoSizeText(
                          widget.list[0] ?? "",
                          style: TextStyle(color: Colors.grey[700]),
                          minFontSize: 10,
                          maxFontSize: 12,
                          stepGranularity: 1,
                        )
                      ],
                    ),
              (widget.list[1]?.isEmpty ?? false) && !(widget.isDepositReport || widget.isWithdrawReport)
                  ? Container()
                  : Row(
                      children: [
                        Text(
                          getTranslatedText("gms_order_number"),
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                        AutoSizeText(
                          widget.list[1] ?? "",
                          style: TextStyle(color: Colors.grey[700]),
                          minFontSize: 10,
                          maxFontSize: 12,
                          stepGranularity: 1,
                        )
                      ],
                    ),
              Container(
                margin: EdgeInsets.only(top: 5.auto),
                child: Row(
                    children: List.generate(widget.list.length, (index) {
                  return (() {
                    if (index == 0 || index == 1)
                      return Container();
                    else if (index == 5 && widget.isDepositReport)
                      return Expanded(
                          flex: 2,
                          child: handleNullWidget(
                              !widget.isUploadButton,
                              ColorButton(
                                title: getTranslatedText("upload_prof"),
                                onClick: () => widget.getManualDepositId!(),
                                isEnabled: true,
                                radius: 4.8,
                                height: 30,
                                width: 45,
                                fontSize: 8.auto,
                                padding: 3,
                              )));
                    else if (index == 7 && widget.reportList is List<AccountReport>) {
                      return Expanded(
                        //first header (time) flex number is 2, others will be 1
                        flex: 2,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 2.auto),
                          child: AutoSizeText(
                            widget.list[index] ?? "",
                            style: TextStyle(color: widget.list[index].contains("-") ? Colors.red : Colors.green),
                            textAlign: index == 1 ? TextAlign.start : TextAlign.center,
                            minFontSize: 5,
                            maxFontSize: 12,
                            stepGranularity: 1,
                          ),
                        ),
                      );
                    }else
                      return Expanded(
                        //first header (time) flex number is 2, others will be 1
                        flex: 2,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 2.auto),
                          child: AutoSizeText(
                            widget.list[index] ?? "",
                            style: TextStyle(color: Colors.grey[700]),
                            textAlign: index == 1 ? TextAlign.start : TextAlign.center,
                            minFontSize: 5,
                            maxFontSize: 12,
                            stepGranularity: 1,
                          ),
                        ),
                      );
                  })();
                }).toList()),
              ),
            ],
          ),
        ),
        handleNullWidget(
            isLast,
            Divider(
              thickness: (1.0).auto,
              color: CustomColor.very_light_pink_four,
            ))
      ]);
}
