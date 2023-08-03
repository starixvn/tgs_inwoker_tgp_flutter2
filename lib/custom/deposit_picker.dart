import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class DepositPicker extends StatefulWidget {
  final String title;
  final String displayText;
  final List<dynamic>? list;
  final Function onClick;
  final bool isHintText;
  final double width;

  DepositPicker({
    required this.title,
    required this.displayText,
    this.list,
    required this.onClick,
    required this.isHintText,
    required this.width,
  });

  @override
  _DepositPickerState createState() => _DepositPickerState();
}

class _DepositPickerState extends BaseState<DepositPicker> {
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 5.auto, right: 5.auto, bottom: 5.auto),
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
        child: Container(
            width: context.screenWidth - 60.auto,
            height: 40.auto,
            margin: EdgeInsets.symmetric(horizontal: 10.auto),
            child: InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  widget.onClick();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        getTranslatedText(widget.title) ?? widget.title,
                        style: TextStyle(
                          fontSize: 12.auto,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: AutoSizeText(
                        widget.displayText,
                        style: TextStyle(
                          color: widget.isHintText
                              ? Colors.grey
                              : ((EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode) || EnvironmentConfig.template_version == 14
                                  ? CustomColor.black
                                  : CustomColor.theme_button_color),
                        ),
                        maxFontSize: 12,
                        minFontSize: 8,
                        maxLines: 1,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 18.0,
                      ),
                    )
                  ],
                ))),
      ),
    );
  }
}
