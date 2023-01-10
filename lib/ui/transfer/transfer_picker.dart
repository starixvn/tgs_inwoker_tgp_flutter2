import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class TransferPicker extends StatefulWidget {
  final String title;
  final String displayText;
  final List<dynamic> list;
  final Function onClick;
  final bool isHintText;

  TransferPicker({
    required this.title,
    required this.displayText,
    required this.list,
    required this.onClick,
    required this.isHintText,
  });

  @override
  _TransferPickerState createState() => _TransferPickerState();
}

class _TransferPickerState extends BaseState<TransferPicker> {
  Widget build(BuildContext context) {
    return InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          widget.onClick();
        },
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 9,
                child: AutoSizeText(
                  widget.displayText,
                  style: TextStyle(
                    color: CustomColor.theme_text_grey_color,
                  ),
                  maxFontSize: 20,
                  minFontSize: 8,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 1,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 18.0,
                ),
              )
            ],
          ),
        ));
  }
}
