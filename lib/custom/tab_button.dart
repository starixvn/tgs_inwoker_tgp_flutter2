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
      width: EnvironmentConfig.template_version == 14 ? context.screenWidth / 3.5 : (width ?? context.screenWidth / 3),
      height: height ?? 40.auto,
      decoration: EnvironmentConfig.template_version == 14
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: index == currentTabIndex ? CustomColor.theme_button_color : Colors.transparent,
            )
          : BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: index == currentTabIndex ? CustomColor.tab_selected_color : CustomColor.tab_unselected_color, width: 3))),
      child: Tab(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.auto),
          child: AutoSizeText(
            EnvironmentConfig.template_version == 14 ? text.toUpperCase() : text,
            maxLines: 2,
            minFontSize: 8,
            maxFontSize: 14,
            stepGranularity: 1,
            style: TextStyle(color: index == currentTabIndex ? CustomColor.tab_selected_color : CustomColor.tab_unselected_color),
          ),
        ),
      ),
    );
  }
}
