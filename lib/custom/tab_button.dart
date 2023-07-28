import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

import '../environment_config.dart';

class TabButton extends StatelessWidget {
  final String text;
  final int index;
  final int currentTabIndex;
  final double? width;
  final double? height;
  final bool isHideInactiveBg;
  final bool isWidthNull;

  TabButton({
    required this.text,
    required this.index,
    required this.currentTabIndex,
    this.width,
    this.height,
    this.isHideInactiveBg = false,
    this.isWidthNull = false,
  });

  @override
  Widget build(BuildContext context) {
    print("tabbuton widthhhh:::::${width}");
    return Container(
      width: isWidthNull ? null : (width ?? context.screenWidth / 3),
      height: height ?? 40.auto,
      padding: EdgeInsets.symmetric(vertical: 2.auto),
      decoration: EnvironmentConfig.template_version == 14
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: index == currentTabIndex ? CustomColor.tab_selected_color : (isHideInactiveBg ? Colors.transparent : CustomColor.tab_unselected_color),
            )
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: index == currentTabIndex ? CustomColor.tab_selected_color : CustomColor.tab_unselected_color,
                  width: 3,
                ),
              ),
            ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.auto),
        child: AutoSizeText(
          EnvironmentConfig.template_version == 14 ? text.toUpperCase() : text,
          maxLines: 2,
          minFontSize: 8,
          maxFontSize: 14,
          stepGranularity: 1,
          style: TextStyle(color: _getTextColor()),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Color _getTextColor() {
    switch (EnvironmentConfig.template_version) {
      case 14:
        return Colors.white;
      default:
        return index == currentTabIndex ? CustomColor.tab_selected_color : CustomColor.tab_unselected_color;
    }
  }
}
