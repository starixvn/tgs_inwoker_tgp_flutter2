import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tgp_flutter2/custom/custom_picker.dart';
import 'package:tgp_flutter2/custom/custom_picker_dialog.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class PhoneTextFormField extends StatefulWidget {
  final ValueChanged<String> onFieldSubmitted;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final double width;
  final TextInputAction textInputAction;
  final bool enabled;
  final ValueChanged<String>  onAreaCodeClicked;
  final String displayedAreaCode;

  PhoneTextFormField(
      {Key key,
      this.onChanged,
      this.onFieldSubmitted,
      this.controller,
      this.width,
      this.textInputAction,
      this.enabled,
      this.onAreaCodeClicked,
      this.displayedAreaCode})
      : super(key: key);

  @override
  _PhoneTextFormFieldState createState() => _PhoneTextFormFieldState();
}

class _PhoneTextFormFieldState extends BaseState<PhoneTextFormField> {
  List areaCodeList = ["+852", "+86", "+60", "+66"];

  Widget build(BuildContext context) {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 5,
      //margin:EdgeInsets.only(top:15.auto,),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 15.auto, horizontal: 20.auto),
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Container(
            width: widget.width,
            alignment: Alignment.topLeft,
            child: Text(
              getTranslatedText("phone_number"),
              style: TextStyle(color: Colors.black, fontSize: 9.auto),
              textAlign: TextAlign.start,
            ),
          ),
          Row(
            children: [
              Container(
                width: 70.auto,
                height: 40.auto,
                child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      _buildBottomSheet();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          flex: 5,
                          child: AutoSizeText(
                            widget.displayedAreaCode ?? areaCodeList.first,
                            style: TextStyle(
                              color: CustomColor.theme_text_black_white_color,
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
              Container(
                width: widget.width - 70.auto,
                height: 40.auto,
                alignment: Alignment.center,
                child: TextFormField(
                  textAlign: TextAlign.left,
                  enabled: widget.enabled ?? true,
                  autofocus: false,
                  onChanged: (value) => widget.onChanged(value),
                  controller: widget.controller,
                  onFieldSubmitted: (value) => widget.onChanged(value),
                  keyboardType: TextInputType.phone,
                  textInputAction: widget.textInputAction,
                  style: TextStyle(color: CustomColor.theme_text_black_color, fontSize: 13.auto),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: getTranslatedText("enter_phone_hint"),
                    hintStyle: TextStyle(color: CustomColor.very_light_pink_two, fontSize: 13.auto),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  _buildBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return CustomPickerDialog(
              title: getTranslatedText("area_code"),
              list: areaCodeList,
              onChanged: (value) => widget.onAreaCodeClicked(value)
          );
        });
  }
}
