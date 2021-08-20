import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class CustomPicker extends StatefulWidget{
  final String title;
  final String displayText;
  final List<dynamic> list;
  final Function onClick;
  final bool isHintText;
  final double width;

  CustomPicker({Key key,
    this.title,
    this.displayText,
    this.list,
    this.onClick,
    this.isHintText,
    this.width
  }) : super(key: key);

  @override
  _CustomPickerState createState() => _CustomPickerState();
}

class _CustomPickerState extends BaseState<CustomPicker> {
  Widget build(BuildContext context) {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      child: Container(
        width: widget.width,
        height: 32.auto,
        padding: EdgeInsets.symmetric(horizontal: 10.auto),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
                onTap: () {
                  widget.onClick();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 8,
                      child: AutoSizeText(
                        widget.displayText ?? widget.title,
                        style: TextStyle(
                            color: widget.isHintText?CustomColor.theme_button_color:Colors.grey,
                        ),
                        maxFontSize: 12,
                        minFontSize: 8,
                        maxLines: 1,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 18.0,
                      ),
                    )
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}