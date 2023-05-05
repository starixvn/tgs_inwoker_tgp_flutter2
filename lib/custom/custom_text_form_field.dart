import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class CustomTextFormField extends StatefulWidget {
  final String title;
  final String hintText;
  final ValueChanged<String> onFieldSubmitted;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final double width;
  final Widget? button;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final bool enabled;
  final double bottomMargin;
  final String? tipsText;
  final Widget? customPart;

  CustomTextFormField({
    required this.title,
    required this.hintText,
    required this.onChanged,
    required this.onFieldSubmitted,
    required this.controller,
    this.focusNode,
    required this.width,
    this.button,
    required this.textInputType,
    required this.textInputAction,
    this.enabled = true,
    this.bottomMargin = 15,
    this.tipsText,
    this.customPart,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends BaseState<CustomTextFormField> {
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: (widget.bottomMargin).auto),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.auto),
            alignment: Alignment.topLeft,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                            color: CustomColor.theme_text_black_white_color,
                            fontSize: 12.auto),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    widget.customPart == null
                        ? SizedBox.shrink()
                        : Container(
                            child: widget.customPart!,
                          )
                  ],
                ),
                if (widget.tipsText != null)
                  Container(
                    margin: EdgeInsets.only(left: 10.auto),
                    child: Text(
                      widget.tipsText!,
                      style: TextStyle(
                          fontSize: 10.auto,
                          color: CustomColor.theme_button_color),
                    ),
                  ),
              ],
            ),
          ),
          Card(
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 8.auto, horizontal: 10.auto),
            child: Container(
              height: 40.auto,
              padding: EdgeInsets.symmetric(horizontal: 10.auto),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 9,
                    child: TextFormField(
                      enabled: widget.enabled,
                      autofocus: false,
                      onChanged: (value) => widget.onChanged(value),
                      focusNode: widget.focusNode,
                      controller: widget.controller,
                      onFieldSubmitted: (value) => widget.onChanged(value),
                      keyboardType: widget.textInputType,
                      inputFormatters:
                          widget.textInputType == TextInputType.number
                              ? <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ]
                              : null,
                      textInputAction: widget.textInputAction,
                      style: TextStyle(
                          color: EnvironmentConfig.template_version != 11
                              ? CustomColor.theme_text_black_color
                              : Color(0xff4B4B4B),
                          fontSize: 13.auto),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: widget.hintText,
                        isDense: true,
                        hintStyle: TextStyle(
                            color: CustomColor.very_light_pink_two,
                            fontSize: 13.auto),
                      ),
                    ),
                  ),
                  widget.button == null
                      ? Container()
                      : Expanded(
                          flex: 1,
                          child: widget.button!,
                        )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
