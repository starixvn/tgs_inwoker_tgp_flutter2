import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

class TabButton extends StatelessWidget {
  final String text;
  final int index;
  final int currentTabIndex;
  final double? width;
  final double? height;

  TabButton({
    required this.text,
    required this.index,
    required this.currentTabIndex,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? context.screenWidth / 3,
      height: height ?? 40.auto,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: index == currentTabIndex ? CustomColor.tab_selected_color : CustomColor.tab_unselected_color,
                  width: 3))),
      child: Tab(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.auto),
          child: AutoSizeText(text,
              maxLines: 2,
              minFontSize: 8,
              maxFontSize: 14,
              stepGranularity: 1,
              style: TextStyle(
                  color: index == currentTabIndex ? CustomColor.tab_selected_color : CustomColor.tab_unselected_color)),
        ),
      ),
    );
  }
}
