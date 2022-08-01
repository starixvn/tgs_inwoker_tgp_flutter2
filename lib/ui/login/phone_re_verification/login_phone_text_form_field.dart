import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tgp_flutter2/custom/custom_picker.dart';
import 'package:tgp_flutter2/custom/custom_picker_dialog.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class LoginPhoneTextFormField extends StatefulWidget {
  final ValueChanged<String> onFieldSubmitted;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final double width;
  final TextInputAction textInputAction;
  final bool enabled;
  final ValueChanged<String> onAreaCodeClicked;
  final String? displayedAreaCode;
  final int maxLength;

  LoginPhoneTextFormField({
    required this.onChanged,
    required this.onFieldSubmitted,
    required this.controller,
    required this.width,
    required this.textInputAction,
    required this.enabled,
    required this.onAreaCodeClicked,
    this.displayedAreaCode,
    required this.maxLength,
  });

  @override
  _LoginPhoneTextFormFieldState createState() => _LoginPhoneTextFormFieldState();
}

class _LoginPhoneTextFormFieldState extends BaseState<LoginPhoneTextFormField> {
  // List areaCodeList = ["+852", "+86", "+60", "+66"];

  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        flex: 1,
        child: Container(
          height: 40.auto,
          padding: EdgeInsets.symmetric(horizontal: 10.auto),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
          child: InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                _buildBottomSheet();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.displayedAreaCode ?? "", //?? areaCodeList.first,
                    style: TextStyle(color: CustomColor.theme_text_black_color, fontSize: 13.auto),
                    maxLines: 1,
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18.0,
                  ),
                ],
              )),
        ),
      ),
      Expanded(
        flex: 2,
        child: Container(
          height: 40.auto,
          margin: EdgeInsets.only(left: 5.auto),
          padding: EdgeInsets.symmetric(horizontal: 10.auto),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
          alignment: Alignment.center,
          child: TextFormField(
            autofocus: false,
            onChanged: (value) => widget.onChanged(value),
            controller: widget.controller,
            onFieldSubmitted: (value) => widget.onChanged(value),
            keyboardType: TextInputType.phone,
            textInputAction: widget.textInputAction,
            style: TextStyle(fontSize: 13.auto),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: getTranslatedText("enter_phone_hint"),
              hintStyle: TextStyle(color: CustomColor.very_light_pink_two, fontSize: 13.auto),
              counterText: '',
              counterStyle: TextStyle(fontSize: 0),
            ),
            maxLength: widget.maxLength,
          ),
        ),
      )
    ]);
  }

  _buildBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return CustomPickerDialog(
              title: getTranslatedText("area_code"),
              list: [widget.displayedAreaCode], //areaCodeList,
              onChanged: (value) => widget.onAreaCodeClicked(value));
        });
  }
}
