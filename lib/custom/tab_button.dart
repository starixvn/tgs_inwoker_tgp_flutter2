import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

class TabButton extends StatelessWidget {
  final String text;
  final int index;
  final int currentTabIndex;
  final double width;
  final double height;

  TabButton(
      {Key key,
      @required this.text,
      @required this.index,
      @required this.currentTabIndex,
      this.width,
      this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (width.auto)?? context.screenWidth/3,
      height: (height.auto)?? 40.auto,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: index == currentTabIndex ? CustomColor.theme_button_color : Colors.white,
                  width: 3))),
      child: Tab(
        child: Text(text,
            style: TextStyle(
                fontSize: 16.auto,
                color: index == currentTabIndex ? CustomColor.theme_button_color : Colors.white)),
      ),
    );
  }
}
