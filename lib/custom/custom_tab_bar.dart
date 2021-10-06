import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class CustomTabBar extends StatefulWidget {
  final int index;
  final String step1Text;
  final String step2Text;

  CustomTabBar({Key key, this.index, this.step1Text, this.step2Text}) : super(key: key);

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends BaseState<CustomTabBar> {
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Text("STEP 1",
                  style: TextStyle(
                      fontFamily: 'PingFang',
                      fontSize: 10.auto,
                      color: (widget.index == 0) ? CustomColor.theme_button_color : Colors.grey),
                  textAlign: TextAlign.center),
              Container(
                width: context.screenWidth / 2 - 20.auto,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      bottomLeft: Radius.circular(25.0),
                    ),
                    border: Border.all(
                        width: 2.0, color: (widget.index == 0) ? CustomColor.theme_button_color : Colors.grey)),
                margin: EdgeInsets.symmetric(vertical: 3.auto),
              ),
              AutoSizeText(getTranslatedText(widget.step1Text),
                style: TextStyle(
                    fontFamily: 'PingFang', color: (widget.index == 0) ? CustomColor.theme_button_color : Colors.grey),
                textAlign: TextAlign.center,
                minFontSize: 10,
                stepGranularity: 1,
                maxLines: 1,
              )
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
              children: [
              Text("STEP 2",
              style: TextStyle(
                  fontFamily: 'PingFang',
                  fontSize: 10.auto,
                  color: (widget.index == 1) ? CustomColor.theme_button_color : Colors.grey),
              textAlign: TextAlign.center),
          Container(
            width: context.screenWidth / 2 - 20.auto,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25.0),
                  bottomRight: Radius.circular(25.0),
                ),
                border: Border.all(
                    width: 2.0, color: (widget.index == 1) ? CustomColor.theme_button_color : Colors.grey)),
            margin: EdgeInsets.symmetric(vertical: 3.auto),
          ),
          AutoSizeText(getTranslatedText(widget.step2Text),
            style: TextStyle(
                fontFamily: 'PingFang', color: (widget.index == 0) ? CustomColor.theme_button_color : Colors.grey),
            textAlign: TextAlign.center,
            minFontSize: 10,
            stepGranularity: 1,
            maxLines: 1,
          )
            ],
          ),
        ),
      ],
    );
  }
}
