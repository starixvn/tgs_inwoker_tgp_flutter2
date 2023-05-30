import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

class LoginPasswordTextFormField extends StatefulWidget {
  final Widget icon;
  final String hintText;
  final ValueChanged<String> onFieldSubmitted;
  final ValueChanged<String> onChanged;
  final Function onShowPassword;
  final TextEditingController controller;
  final double width;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final bool obscurePassword;

  LoginPasswordTextFormField({
    required this.icon,
    required this.hintText,
    required this.onChanged,
    required this.onFieldSubmitted,
    required this.onShowPassword,
    required this.controller,
    required this.width,
    required this.textInputType,
    required this.textInputAction,
    required this.obscurePassword,
  });

  @override
  _LoginPasswordTextFormFieldState createState() =>
      _LoginPasswordTextFormFieldState();
}

class _LoginPasswordTextFormFieldState
    extends BaseState<LoginPasswordTextFormField> {
  Widget build(BuildContext context) {
    return Container(
      height: 45
          .auto, //EnvironmentConfig.template_version == 15 ? 45.auto : 40.auto,
      padding: EdgeInsets.symmetric(horizontal: 10.auto),
      decoration: BoxDecoration(
        color: EnvironmentConfig.template_version == 11
            ? CustomColor.theme_button_color.withOpacity(0.8)
            : EnvironmentConfig.template_version == 15
                ? Colors.black.withOpacity(0.44)
                : Colors.white,
        borderRadius: BorderRadius.circular(
          EnvironmentConfig.template_version == 11
              ? 25
              : EnvironmentConfig.template_version == 15
                  ? 10
                  : 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 20.auto,
            width: 20.auto,
            margin: EdgeInsets.only(right: 10.auto),
            child: widget.icon,
          ),
          Expanded(
            child: TextFormField(
              autofocus: false,
              onChanged: (value) => widget.onChanged(value),
              controller: widget.controller,
              onFieldSubmitted: (value) => widget.onChanged(value),
              keyboardType: widget.textInputType,
              textInputAction: widget.textInputAction,
              obscureText: widget.obscurePassword,
              style: TextStyle(
                  fontSize: 13.auto,
                  color: (EnvironmentConfig.template_version == 11 || EnvironmentConfig.template_version == 15)
                      ? Colors.white
                      : Colors.black),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 13.5),
                isDense: true,
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: (EnvironmentConfig.template_version == 11 || EnvironmentConfig.template_version == 15)
                      ? Colors.white.withOpacity(0.5)
                      : CustomColor.very_light_pink_two,
                  fontSize: 13.auto,
                ),
                suffixIcon: IconButton(
                  iconSize: 18.auto,
                  padding: EdgeInsets.only(bottom: 0),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Icon(
                      widget.obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: EnvironmentConfig.template_version == 11
                          ? Colors.white
                          : CustomColor.very_light_pink_two),
                  onPressed: () => widget.onShowPassword(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
