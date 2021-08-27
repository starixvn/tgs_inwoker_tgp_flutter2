import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class LanguageItem extends StatefulWidget {
  final bool isSelected;
  final String imagePath;
  final String text;

  LanguageItem({
    Key key,
    this.isSelected,
    this.imagePath,
    this.text,
  }) : super(key: key);

  @override
  _LanguageItemState createState() => _LanguageItemState();
}

class _LanguageItemState extends BaseState<LanguageItem> {
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 10.auto, left: 10.auto, right: 15.auto),
          child: Row(
            children: [
              widget.imagePath != null
                  ? Container(
                      margin: EdgeInsets.only(right: 10.auto),
                      child: Image.asset(
                        widget.imagePath,
                        height: 25.auto,
                        width: 36.auto,
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.only(right: 10.auto),
                      height: 25.auto,
                      width: 36.auto,
                    ),
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(fontSize: 14.auto, color: CustomColor.theme_text_color2),
                ),
              ),
              Visibility(
                  visible: widget.isSelected,
                  child: Icon(
                    Icons.check,
                    size: 25.auto,
                  ))
            ],
          ),
        ),
        Divider(
          thickness: 1,
            color: CustomColor.theme_text_color2
        )
      ],
    );
  }
}
