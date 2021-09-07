import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/entity/transaction_cell_item_type.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class TransactionCellItem extends StatefulWidget {
  final List list;
  final TransactionCellItemType type;
  final bool isEndRecord;
  final bool isUploadButton;
  final Function getManualDepositId;

  TransactionCellItem({Key key, this.list, this.type, this.isEndRecord, this.isUploadButton, this.getManualDepositId})
      : super(key: key);

  @override
  _TransactionCellItemState createState() => _TransactionCellItemState();
}

class _TransactionCellItemState extends BaseState<TransactionCellItem> {
  var text1, text2, text3;

  Widget build(BuildContext context) {
    //only one item
    if (widget.type == TransactionCellItemType.SINGLE) {
      return Container(
        padding: EdgeInsets.only(bottom: 10.auto),
        child: Container(
          padding: EdgeInsets.only(top: 5.auto, bottom: 10.auto),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: _getTransactionCellItem(isLast: true),
        ),
      );
    }
    //top item
    else if (widget.type == TransactionCellItemType.TOP) {
      return Container(
          padding: EdgeInsets.only(top: 5.auto),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          child: _getTransactionCellItem());
    }
    //bottom item
    else if (widget.type == TransactionCellItemType.BOTTOM) {
      return Column(children: [
        Container(
          padding: EdgeInsets.only(bottom: 10.auto),
          child: Container(
              padding: EdgeInsets.only(bottom: 10.auto),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
              ),
              child: _getTransactionCellItem(isLast: true)),
        ),
        /*widget.isLoading?Container(
            height: 50,
            width: 50,
            padding: EdgeInsets.only(bottom: 10.auto),
            child: CircularProgressIndicator(),
          ):Container(),*/
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
      return Container(color: Colors.white, child: _getTransactionCellItem());
    }
  }

  _getTransactionCellItem({bool isLast = false}) => Column(children: [
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
                          widget.list[0],
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
                    if (index == 0)
                      return Container();
                    else if (index == 4)
                      return Expanded(
                        flex: 1,
                        child: widget.isUploadButton
                            ? ColorButton(
                                title: getTranslatedText("upload_prof"),
                                onClick: () => widget.getManualDepositId(),
                                isEnabled: true,
                                radius: 4.8,
                                height: 30,
                                width: 45,
                                fontSize: 8.auto,
                                padding: 3,
                              )
                            : Container(),
                      );
                    else
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
        isLast
            ? Container()
            : Divider(
                thickness: (1.0).auto,
                color: CustomColor.very_light_pink_four,
              )
      ]);
}
