import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

class OutlineBorderButton extends StatelessWidget {
  final String title;
  final Function onClick;
  final bool isEnabled;
  final double width;
  final double height;
  final Color color;
  final double fontSize;
  final double radius;
  final double padding;

  OutlineBorderButton({
    Key key,
    this.title,
    this.onClick,
    this.isEnabled,
    this.width,
    this.height,
    this.color,
    this.fontSize,
    this.radius,
    this.padding
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => {this.onClick()},
      style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular((radius??5).auto),
            side: BorderSide(color: color?? Colors.white),
          )),
          padding: MaterialStateProperty.all(EdgeInsets.all((padding??2).auto)),
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          minimumSize: MaterialStateProperty.all<Size>(Size(width ?? context.screenWidth, height ?? 29.auto))),
      child: Container(
        alignment: Alignment.center,
        /*width: width??context.screenWidth,
          height: 25.auto,*/
        child: SizedBox(
          width: width-20,
          child: AutoSizeText(
            title,
            style: TextStyle(color: color?? Colors.white),
            minFontSize: 7,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
