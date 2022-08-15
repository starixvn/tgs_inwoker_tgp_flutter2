import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/environment_config.dart';
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
  final Widget? icon;
  final double minFontSize ;

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
    this.icon,
    this.minFontSize = 5,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isEnabled ? () => {this.onClick()} : null,
      style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.all(padding ?? 8)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(((() {
              if (radius != null)
                return radius!;
              else if(EnvironmentConfig.template_version==11)
                return 25.auto;
              else
                return (5.8).auto;
            })())),
            side: border ?? BorderSide(color: Colors.transparent),
          )),
          backgroundColor: MaterialStateProperty.all(
              isEnabled ? (color ?? CustomColor.theme_button_color) : CustomColor.theme_grey_button_color),
          minimumSize: MaterialStateProperty.all(Size(width ?? context.screenWidth, height ?? 45.auto))),
      child: Container(
        alignment: Alignment.center,
        /*width: width??context.screenWidth,
          height: 25.auto,*/
        child: SizedBox(
          width: (width ?? context.screenWidth) - 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              icon == null ? Container() : Expanded(flex: 1, child: icon!),
              Expanded(
                flex: 1,
                child: AutoSizeText(
                  title,
                  style: TextStyle(color: textColor ?? Colors.white),
                  minFontSize: minFontSize,
                  maxFontSize: fontSize ?? 12,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  stepGranularity: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
