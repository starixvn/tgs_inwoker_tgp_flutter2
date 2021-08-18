import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';

class GradientButton extends StatelessWidget {
  final String title;
  final Function onClick;
  final bool isEnabled;
  final double radius;
  final double height;
  final double fontSize;
  final double width;

  GradientButton(
      {Key key,
      @required this.title,
      @required this.onClick,
      @required this.isEnabled,
      @required this.radius,
      @required this.height,
      this.fontSize,
        this.width
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isEnabled
        ? TextButton(
            onPressed: () => this.onClick(),
            style: ButtonStyle(
              padding: MaterialStateProperty.all(EdgeInsets.zero),
            ),
            child: Container(
              alignment: Alignment.center,
              height: height.auto,
              width: width??context.screenWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [CustomColor.theme_bar_gradient_1, CustomColor.theme_bar_gradient_2],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular((radius).auto),
              ),
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: fontSize ?? 16.auto),
              ),
            ),
          )
        : TextButton(
            onPressed: null,
            style: ButtonStyle(
              padding: MaterialStateProperty.all(EdgeInsets.zero),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular((radius).auto),
              )),
              backgroundColor: MaterialStateProperty.all(Colors.grey),
            ),
            child: Container(
              alignment: Alignment.center,
              height: height.auto,
              width: width??context.screenWidth,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
  }
}
