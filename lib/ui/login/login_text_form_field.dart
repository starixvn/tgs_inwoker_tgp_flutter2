import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

class LoginTextFormField extends StatelessWidget {
  final Widget icon;
  final String hintText;
  //final ValueChanged<String> onFieldSubmitted;
   final ValueChanged<String> onChanged;
 // final Function onShowPassword;
  final TextEditingController controller;
  final double width;
  //final Widget button;
  final TextInputType textInputType;
  final TextInputAction textInputAction;

  LoginTextFormField({
    Key key,
    this.icon,
    this.hintText,
     this.onChanged,
    //this.onFieldSubmitted,
    //this.onShowPassword,
    this.controller,
    this.width,
    //this.button,
    this.textInputType,
    this.textInputAction,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return Container(
      height: 40.auto,
      padding: EdgeInsets.symmetric(horizontal: 10.auto),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.8)),
      child: Row(
        children: [
          icon == null
              ? Container()
              : Container(
                  margin: EdgeInsets.only(right: 10.auto),
                  child: icon,
                ),
          Expanded(
            child: TextFormField(
              autofocus: false,
              //  onChanged: (value) => onChanged(value),
              controller: controller,
              //onFieldSubmitted: (value) => onChanged(value),
              keyboardType: textInputType,
              textInputAction: textInputAction,
              style: TextStyle(fontSize: 13.auto),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(color: CustomColor.very_light_pink_two, fontSize: 13.auto),
              ),
            ),
          )
        ],
      ),
    );
  }
}
