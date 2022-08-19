import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tgp_flutter2/custom/custom_picker.dart';
import 'package:tgp_flutter2/custom/custom_picker_dialog.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class PhoneTextFormField extends StatefulWidget {
  final ValueChanged<String> onFieldSubmitted;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final double width;
  final TextInputAction textInputAction;
  final bool enabled;
  final ValueChanged<String> onAreaCodeClicked;
  final String? displayedAreaCode;
  final int maxLength;

  PhoneTextFormField({
    required this.onChanged,
    required this.onFieldSubmitted,
    required this.controller,
    required this.width,
    required this.textInputAction,
    required this.enabled,
    required this.onAreaCodeClicked,
    required this.displayedAreaCode,
    required this.maxLength,
  });

  @override
  _PhoneTextFormFieldState createState() => _PhoneTextFormFieldState();
}

class _PhoneTextFormFieldState extends BaseState<PhoneTextFormField> {
  // List areaCodeList = ["+852", "+86", "+60", "+66"];

  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: widget.width,
          alignment: Alignment.topLeft,
          child: Text(
            getTranslatedText("phone_number"),
            style: TextStyle(color: CustomColor.theme_text_black_white_color, fontSize: 12.auto),
            textAlign: TextAlign.start,
          ),
        ),
        Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 5,
          //margin:EdgeInsets.only(top:15.auto,),
          margin: EdgeInsets.symmetric(vertical: 8.auto, horizontal: 10.auto),
          child: Container(
            width: widget.width,
            height: 40.auto,
            padding: EdgeInsets.symmetric(horizontal: 10.auto),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: widget.enabled
                          ? () {
                              _buildBottomSheet();
                            }
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            flex: 5,
                            child: AutoSizeText(
                              widget.displayedAreaCode ?? "",
                              style: TextStyle(
                                color: EnvironmentConfig.template_version != 11
                                    ? CustomColor.theme_text_black_color
                                    : Color(0xff4B4B4B),
                              ),
                              maxFontSize: 12,
                              minFontSize: 8,
                              maxLines: 1,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 18.0,
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: Container(
                                height: 30.auto,
                                child: VerticalDivider(
                                  color: Colors.black,
                                  thickness: 1,
                                  width: 0.5,
                                ),
                              ))
                        ],
                      )),
                ),
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    textAlign: TextAlign.left,
                    enabled: widget.enabled,
                    autofocus: false,
                    onChanged: (value) => widget.onChanged(value),
                    controller: widget.controller,
                    onFieldSubmitted: (value) => widget.onChanged(value),
                    keyboardType: TextInputType.phone,
                    textInputAction: widget.textInputAction,
                    style: TextStyle(
                        color: EnvironmentConfig.template_version != 11
                            ? CustomColor.theme_text_black_color
                            : Color(0xff4B4B4B),
                        fontSize: 13.auto),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: getTranslatedText("enter_phone_hint"),
                      hintStyle: TextStyle(color: CustomColor.very_light_pink_two, fontSize: 13.auto),
                      counterText: '',
                      counterStyle: TextStyle(fontSize: 0),
                    ),
                    maxLength: widget.maxLength,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return CustomPickerDialog(
              title: "area_code",
              list: [widget.displayedAreaCode],
              onChanged: (value) => widget.onAreaCodeClicked(value));
        });
  }
}
