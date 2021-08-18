import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class TransactionHeaderItem extends StatefulWidget {
  final List<String> headerList;

  const TransactionHeaderItem({Key key, this.headerList}) : super(key: key);

  @override
  _TransactionHeaderItemState createState() => _TransactionHeaderItemState();
}

class _TransactionHeaderItemState extends BaseState<TransactionHeaderItem> {
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.auto, horizontal: 20.auto),
      child: Row(
          children: List.generate(widget.headerList.length, (index) {
        return Expanded(
          //first header (time) flex number is 2, others will be 1
          flex: 3,//index == 0 || index == 1 ? 4 : 3,
          child: AutoSizeText(
            getTranslatedText(widget.headerList[index]),
            minFontSize: 5,
            maxFontSize: 12,
            stepGranularity: 1,
            maxLines: 1,
            textAlign: index==0?TextAlign.start: TextAlign.center,
            style: TextStyle(
              color: Colors.white
            ),
          ),
        );
      }).toList()),
    );
  }
}
