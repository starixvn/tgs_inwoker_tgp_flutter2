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
        margin: EdgeInsets.symmetric(
            vertical: 15.auto, horizontal: 20.auto),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 8.auto,),
              child: Text(
                getTranslatedText(widget.title)??widget.title,
                style: TextStyle(
                  fontSize: 9.auto,
                ),
              ),
            ),
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
                      flex: 9,
                      child: AutoSizeText(
                        widget.displayText,
                        style: TextStyle(
                          color: widget.isHintText?CustomColor.theme_button_color:Colors.grey,
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
                )
            )
          ],
        ),
      ),
    );
  }
}