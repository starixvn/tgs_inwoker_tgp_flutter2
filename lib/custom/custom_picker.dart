import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class CustomPicker extends StatefulWidget {
  final String title;
  final String displayText;
  final List<dynamic>? list;
  final Function onClick;
  final bool isHintText;
  final double width;
  final String? tipsText;

  CustomPicker(
      {required this.title,
      required this.displayText,
      this.list,
      required this.onClick,
      required this.isHintText,
      required this.width,
      this.tipsText});

  @override
  _CustomPickerState createState() => _CustomPickerState();
}

class _CustomPickerState extends BaseState<CustomPicker> {
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 5.auto, right: 5.auto, bottom: 15.auto),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 5.auto, left: 5.auto),
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                Text(
                  getTranslatedText(widget.title) ?? widget.title,
                  style: TextStyle(fontSize: 12.auto, color: CustomColor.theme_text_black_white_color),
                ),
                if (widget.tipsText != null)
                  Container(
                    margin: EdgeInsets.only(left: 10.auto),
                    child: Text(
                      widget.tipsText!,
                      style: TextStyle(fontSize: 10.auto, color: CustomColor.theme_button_color),
                    ),
                  ),
              ],
            ),
          ),
          Card(
            semanticContainer: true,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 5,
            child: Container(
                width: context.screenWidth - 60.auto,
                height: 40.auto,
                margin: EdgeInsets.symmetric(horizontal: 10.auto),
                child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      widget.onClick();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 9,
                          child: AutoSizeText(
                            widget.displayText,
                            style: TextStyle(
                              color: widget.isHintText ? Colors.grey : CustomColor.theme_button_color,
                            ),
                            maxFontSize: 12,
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
                    ))),
          ),
        ],
      ),
    );
  }
}
