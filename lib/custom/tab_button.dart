import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/globalUtil/GlobalValueUtil.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

import '../base_state.dart';
import '../environment_config.dart';

class TabButton extends StatefulWidget {
  final String text;
  final int index;
  final int currentTabIndex;
  final double? width;
  final double? height;
  final bool isHideInactiveBg;
  final bool isWidthNull;
  final double? fontSize;

  TabButton({
    required this.text,
    required this.index,
    required this.currentTabIndex,
    this.width,
    this.height,
    this.isHideInactiveBg = false,
    this.isWidthNull = false,
    this.fontSize,
  });

  @override
  _TabButtonState createState() => _TabButtonState();
}

class _TabButtonState extends BaseState<TabButton> {
  @override
  Widget build(BuildContext context) {
    // print("tabbuton widthhhh:::::${widget.width}");
    return Container(
      width: widget.isWidthNull ? null : (widget.width ?? context.screenWidth / 3),
      height: widget.height ?? 40.auto,
      padding: EdgeInsets.symmetric(vertical: 2.auto),
      alignment: Alignment.center,
      decoration: EnvironmentConfig.template_version == 14
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: widget.index == widget.currentTabIndex
                  ? CustomColor.tab_selected_color
                  : (widget.isHideInactiveBg ? Colors.transparent : CustomColor.tab_unselected_color),
            )
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: widget.index == widget.currentTabIndex ? CustomColor.tab_selected_color : CustomColor.tab_unselected_color,
                  width: 3,
                ),
              ),
            ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.auto),
        child: widget.fontSize != null
            ? Text(
                EnvironmentConfig.template_version == 14 ? widget.text.toUpperCase() : widget.text,
                maxLines: _getTextMaxLines(),
                style: TextStyle(color: _getTextColor(), fontSize: widget.fontSize),
                textAlign: TextAlign.center,
              )
            : AutoSizeText(
                EnvironmentConfig.template_version == 14 ? widget.text.toUpperCase() : widget.text,
                maxLines: GlobalValueUtil.countSpace(EnvironmentConfig.template_version == 14 ? widget.text.toUpperCase() : widget.text, " "),
                minFontSize: 8,
                maxFontSize: 14,
                stepGranularity: 1,
                style: TextStyle(color: _getTextColor()),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }

  int _getTextMaxLines() {
    String str = EnvironmentConfig.template_version == 14 ? widget.text.toUpperCase() : widget.text;
    if (str.contains(" "))
      return 2;
    else
      return 1;
  }

  Color _getTextColor() {
    switch (EnvironmentConfig.template_version) {
      case 14:
        return Colors.white;
      default:
        return widget.index == widget.currentTabIndex ? CustomColor.tab_selected_color : CustomColor.tab_unselected_color;
    }
  }
}
