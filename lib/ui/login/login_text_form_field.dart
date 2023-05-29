import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

class LoginTextFormField extends StatelessWidget {
  final Widget? icon;
  final String hintText;
  final ValueChanged<String?>? onChanged;
  final ValueChanged<String?>? onFieldSubmitted;
  final TextEditingController controller;
  final double width;
  final TextInputAction textInputAction;
  final Widget? dropDown;
  final TextInputType textInputType;

  LoginTextFormField({
    this.icon,
    required this.hintText,
    this.onChanged,
    this.onFieldSubmitted,
    required this.controller,
    required this.width,
    required this.textInputAction,
    required this.textInputType,
    this.dropDown,
  });

  Widget build(BuildContext context) {
    return Container(
      height: 45.auto, //EnvironmentConfig.template_version == 15 ? 45.auto : 40.auto,
      padding: EdgeInsets.symmetric(horizontal: 10.auto),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.44),
        // EnvironmentConfig.template_version == 11 ? CustomColor.theme_button_color.withOpacity(0.8) :
        // EnvironmentConfig.template_version == 15 ? Colors.black.withOpacity(0.44) : Colors.white,
        borderRadius: BorderRadius.circular(
          10,//EnvironmentConfig.template_version == 11 ? 25 : 2,
        ),
      ),
      child: Row(
        children: [
          icon == null
              ? Container()
              : Container(
                  height: 20.auto,
                  width: 20.auto,
                  margin: EdgeInsets.only(right: 10.auto),
                  child: icon,
                ),
          Expanded(
            flex: 7,
            child: TextFormField(
              autofocus: false,
              //  onChanged: (value) => onChanged(value),
              controller: controller,
              //onFieldSubmitted: (value) => onChanged(value),
              autocorrect: false,
              keyboardType: textInputType,
              textInputAction: textInputAction,
              style: TextStyle(fontSize: 13.auto, color: EnvironmentConfig.template_version == 11 ? Colors.white : Colors.black),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(
                  color: EnvironmentConfig.template_version == 11 ? Colors.white.withOpacity(0.5) : CustomColor.very_light_pink_two,
                  fontSize: 13.auto,
                ),
              ),
            ),
          ),
          dropDown == null ? Container() : Expanded(flex: 2, child: dropDown!),
        ],
      ),
    );
  }
}
