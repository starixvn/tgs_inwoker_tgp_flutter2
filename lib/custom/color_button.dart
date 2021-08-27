import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

class ColorButton extends StatelessWidget {
  final String title;
  final Function onClick;
  final bool isEnabled;
  final double radius;
  final double width;
  final double height;
  final BorderSide border;
  final double padding;
  final double fontSize;
  final Color color;

  ColorButton(
      {Key key,
      @required this.title,
      @required this.onClick,
      @required this.isEnabled,
      this.radius,
      this.width,
      this.height,
      this.border,
      this.padding,
      this.fontSize,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isEnabled ? () => {this.onClick()} : null,
      style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.all(padding ?? 8)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular((radius ?? 5.8).auto),
            side: border ?? BorderSide(color: Colors.transparent),
          )),
          backgroundColor:
              MaterialStateProperty.all(isEnabled ? (color??CustomColor.theme_button_color) : CustomColor.theme_disable_color),
          minimumSize: MaterialStateProperty.all(Size(width ?? context.screenWidth, height ?? 45.auto))),
      child: AutoSizeText(
        title,
        style: TextStyle(color: CustomColor.theme_text_color2),
        minFontSize: fontSize ?? 15,
        maxLines: 1,
        textAlign: TextAlign.center,
      ),
    );
  }
}
