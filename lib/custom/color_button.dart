import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

class ColorButton extends StatelessWidget {
  final String title;
  final Function onClick;
  final bool isEnabled;
  final double? radius;
  final double? width;
  final double? height;
  final BorderSide? border;
  final double? padding;
  final double? fontSize;
  final Color? color;
  final Color? textColor;

  ColorButton({
    required this.title,
    required this.onClick,
    required this.isEnabled,
    this.radius,
    this.width,
    this.height,
    this.border,
    this.padding,
    this.fontSize,
    this.color,
    this.textColor,
  });

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
          backgroundColor: MaterialStateProperty.all(
              isEnabled ? (color ?? CustomColor.theme_button_color) : CustomColor.theme_grey_button_color),
          minimumSize: MaterialStateProperty.all(Size(width ?? context.screenWidth, height ?? 45.auto))),
      child: AutoSizeText(
        title,
        style: TextStyle(color: textColor??Colors.white),
        minFontSize: fontSize ?? 15,
        maxLines: 1,
        textAlign: TextAlign.center,
        stepGranularity: 1,
      ),
    );
  }
}
