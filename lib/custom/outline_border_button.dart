import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

class OutlineBorderButton extends StatelessWidget {
  final String title;
  final Function onClick;
  final bool isEnabled;
  final double? width;
  final double? height;
  final Color? color;
  final double fontSize;
  final double radius;
  final double padding;
  final bool isBold;
  final double minFontSize;

  OutlineBorderButton({
    required this.title,
    required this.onClick,
    required this.isEnabled,
    this.width,
    this.height,
    this.color,
    required this.fontSize,
    this.radius = 5,
    this.padding = 0.0,
    this.isBold = false,
    this.minFontSize = 5,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => {this.onClick()},
      style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius.auto),
            side: BorderSide(color: color ?? Colors.white),
          )),
          padding: MaterialStateProperty.all(EdgeInsets.all(padding.auto)),
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          minimumSize: MaterialStateProperty.all<Size>(Size(width ?? context.screenWidth, height ?? 45.auto))),
      child:
      Container(
        alignment: Alignment.center,
        /*width: width??context.screenWidth,
          height: 25.auto,*/
        child: SizedBox(
          width: (width ?? context.screenWidth) - 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 1,
                child: AutoSizeText(
                  title,
                  style: TextStyle(color: Colors.white),
                  minFontSize: minFontSize,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),/*Container(
        alignment: Alignment.center,
        *//*width: width??context.screenWidth,
          height: 25.auto,*//*
        child: SizedBox(
          width: (width ?? context.screenWidth) - 10,
          child: Expanded(
            flex: 1,
            child: AutoSizeText(
              title,
              style: TextStyle(color: color ?? Colors.white, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
              minFontSize: minFontSize,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),*/
    );
  }
}
