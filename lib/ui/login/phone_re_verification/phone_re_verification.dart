import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_password_text_form_field.dart';
import 'package:tgp_flutter2/custom/custom_picker.dart';
import 'package:tgp_flutter2/custom/custom_picker_dialog.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_text_form_field.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/custom/otp_text_form_field.dart';
import 'package:tgp_flutter2/custom/phone_text_form_field.dart';
import 'package:api/data/provider/input_validation_provider.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/login/login_password_text_form_field.dart';
import 'package:tgp_flutter2/ui/login/phone_re_verification/login_otp_text_form_field.dart';
import 'package:tgp_flutter2/ui/login/phone_re_verification/login_phone_text_form_field.dart';
import 'package:tgp_flutter2/ui/login/login_text_form_field.dart';
import 'package:tgp_flutter2/ui/login/login_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class PhoneReVerification extends StatefulWidget {
  final LoginViewModel vm;

  PhoneReVerification({required this.vm});

  @override
  _PhoneReVerificationState createState() => _PhoneReVerificationState();
}

class _PhoneReVerificationState extends BaseState<PhoneReVerification> {
  var _vm;

  TextEditingController _phoneController = TextEditingController(),
      _otpController = TextEditingController(),
      _usernameController = TextEditingController(),
      _passwordController = TextEditingController();
  var isButtonEnabled = false, isOtpEnabled = false, isTextFieldEnabled = false, isOtpCountdown = false;
  var buttonText;
  InputValidationProvider validate = new InputValidationProvider();
  bool _obscurePassword = true;
  String? display;

  @override
  void initState() {
    _initData();
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<LoginViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return Container(
            child: Column(
              children: [
                //CustomTabBar(index:1),
                _buildUsernameTextFormField(),
                _buildPasswordTextFormField(),
                _buildPhoneTextFormField(),
                _buildOtpTextFormField(),
                _buildButton()
              ],
            ),
          );
        });
  }

  _buildUsernameTextFormField() => LoginTextFormField(
        icon: SvgPicture.asset(
          "images/login/ic_login_username.svg",
          height: 20.auto,
        ),
        hintText: getTranslatedText("signup_username_hint"),
        onChanged: (value) => _onTextChange(),
        //onFieldSubmitted: (value) => null,
        controller: _usernameController,
        width: context.screenWidth,
        textInputType: TextInputType.text,
        textInputAction: TextInputAction.next,
      );

  _buildPasswordTextFormField() => Container(
        margin: EdgeInsets.only(top: 10.auto),
        child: LoginPasswordTextFormField(
          icon: SvgPicture.asset(
            "images/login/ic_login_password.svg",
            height: 20.auto,
          ),
          hintText: getTranslatedText("signup_password_hint"),
          onChanged: (value) => _onTextChange(),
          onFieldSubmitted: (value) => null,
          controller: _passwordController,
          width: context.screenWidth,
          textInputType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.next,
          onShowPassword: () {
            setState(() => this._obscurePassword = !this._obscurePassword);
          },
          obscurePassword: _obscurePassword,
        ),
      );

  _buildPhoneTextFormField() => Container(
        margin: EdgeInsets.only(top: 15.auto),
        child: LoginPhoneTextFormField(
          onChanged: (value) => _onTextChange(),
          onFieldSubmitted: (value) {},
          controller: _phoneController,
          width: context.screenWidth - 70.auto,
          textInputAction: TextInputAction.next,
          enabled: isTextFieldEnabled,
          onAreaCodeClicked: (value) => _onAreaCodeClicked(value),
          displayedAreaCode: display,
        ),
      );

  _onAreaCodeClicked(String area) {
    setState(() {
      display = area;
      Navigator.of(context).pop();
    });
  }

  _buildOtpTextFormField() => Visibility(
        visible: true,
        child: Opacity(
          opacity: isOtpEnabled ? 1 : 0.4,
          child: Container(
            margin: EdgeInsets.only(top: 15.auto),
            child: LoginOtpTextFormField(
                hintText: getTranslatedText("enter_email_otp_hint"),
                onChanged: (value) => _onTextChange(),
                controller: _otpController,
                textInputAction: TextInputAction.done,
                getOtpCode: () {
                  _getSmsCode();
                },
                isCountdown: isOtpCountdown,
                isEnabled: isOtpEnabled,
                onCountDownEnd: () => {
                      setState(() {
                        isOtpCountdown = false;
                      })
                    }),
          ),
        ),
      );

  _buildButton() => Container(
      width: context.screenWidth,
      margin: EdgeInsets.only(top: 30.auto, bottom: 20.auto),
      child: ColorButton(
        title: getTranslatedText("submit"),
        onClick: () {
          _onClick();
        },
        isEnabled: isButtonEnabled,
        radius: 9.6,
      ));

  _onTextChange() {
    setState(() {
      if (_usernameController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty &&
          _otpController.text.isNotEmpty) {
        isOtpEnabled = true;
        isButtonEnabled = true;
      } else if (_usernameController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty) {
        isOtpEnabled = true;
        isButtonEnabled = false;
      } else {
        isOtpEnabled = false;
        isButtonEnabled = false;
      }
    });
  }

  _getSmsCode() {
    if (!validate.validateAreaCodeAndPhone(display!, _phoneController.text)) {
      setState(() {
        CustomToast.show(getTranslatedText("phone_format_error_msg"));
      });
    } else {
      //ProgressDialog.show(context, _vm.brandLogoUrl);
      _vm.getReVerifyCode(_usernameController.text, _passwordController.text, display!, _phoneController.text);
    }
  }

  _onClick() async {
    ProgressDialog.show(context, _vm.brandLogo.mobileUrl);
    _vm.phoneVerify(_otpController.text);
  }

  _initData() {
    _vm = widget.vm;
    display = _vm.config.phonePrefix;
    _usernameController.text = _vm.username ?? "";
    _passwordController.text = _vm.password ?? "";
  }

  _handleApiState() {
    handleApiState(_vm.getReVerifyCodeApiState, onSuccess: () {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        CustomToast.show(getTranslatedText("verification_code_success"));
        setState(() {
          isOtpCountdown = true;
        });
      });
    });

    handleApiState(_vm.phoneReVerifyApiState, onSuccess: () {
      _navigateToHome();
    });
  }

  _navigateToHome() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Navigator.of(context).pushNamedAndRemoveUntil(RoutePath.myHome, (Route<dynamic> route) => false);
    });
  }
}
