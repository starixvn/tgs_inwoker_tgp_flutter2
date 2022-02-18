import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_text_form_field.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/custom/otp_text_form_field.dart';
import 'package:api/data/provider/input_validation_provider.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/phone_text_form_field.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/forgot_password/forgot_password_view_model.dart';
import 'package:tgp_flutter2/ui/forgot_password/update_forgot_password.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends BaseState<ForgotPassword> {
  var _vm = ForgotPasswordViewModel();
  TextEditingController _emailController = TextEditingController(), _otpController = TextEditingController();
  var isButtonEnabled = false, isOtpEnabled = false, isOtpCountdown = false;
  InputValidationProvider validate = new InputValidationProvider();
  String? display;

  @override
  void initState() {
    display = _vm.config.phonePrefix;
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<ForgotPasswordViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: CustomColor.theme_bg_color,
            appBar: CustomAppBar(
              title: getTranslatedText("forgot_password"),
            ),
            body: Container(
              margin: EdgeInsets.all(10.auto),
              child: Column(
                children: [
                  //CustomTabBar(index:1),
                  (_vm.config?.smsVerification ?? false) ? _buildPhoneTextFormField() : _buildTextFormField(),
                  _buildOtpTextFormField(),
                  _buildButton()
                ],
              ),
            ),
          );
        });
  }

  _buildTextFormField() => Container(
        margin: EdgeInsets.only(top: 15.auto),
        child: CustomTextFormField(
          title: getTranslatedText("email"),
          hintText: getTranslatedText("email_hint"),
          onChanged: (value) => _onTextChange(),
          onFieldSubmitted: (value) {},
          controller: _emailController,
          width: context.screenWidth - 40.auto,
          textInputType: TextInputType.text,
          textInputAction: TextInputAction.next,
        ),
      );

  _buildPhoneTextFormField() => Container(
        margin: EdgeInsets.only(top: 15.auto),
        child: PhoneTextFormField(
          onChanged: (value) => _onTextChange(),
          onFieldSubmitted: (value) {},
          controller: _emailController,
          width: context.screenWidth - 30.auto,
          textInputAction: TextInputAction.next,
          enabled: true,
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

  _buildOtpTextFormField() => OtpTextFormField(
        hintText: getTranslatedText("enter_email_otp_hint"),
        onChanged: (value) => _onTextChange(),
        controller: _otpController,
        textInputAction: TextInputAction.done,
        getOtpCode: () {
          _getSmsCode();
        },
        isEnabled: isOtpEnabled,
        isCountdown: isOtpCountdown,
        onCountDownEnd: () => {
          setState(() {
            isOtpCountdown = false;
          })
        },
        isVisible: true,
      );

  _buildButton() => Container(
      margin: EdgeInsets.only(top: 30.auto, bottom: 20.auto, left: 10.auto, right: 10.auto),
      child: ColorButton(
        title: getTranslatedText("next"),
        onClick: () {
          _checkValidation();
        },
        isEnabled: isButtonEnabled,
        radius: 9.6,
      ));

  _checkValidation() {
    _navigateToUpdatePassword();
  }

  _onTextChange() {
    setState(() {
      if (_otpController.text.isNotEmpty && _emailController.text.isNotEmpty) {
        isOtpEnabled = true;
        isButtonEnabled = true;
      } else if (_emailController.text.isNotEmpty) {
        isOtpEnabled = true;
        isButtonEnabled = false;
      } else {
        isOtpEnabled = false;
        isButtonEnabled = false;
      }
    });
  }

  _getSmsCode() {
    if (_vm.config?.smsVerification ?? false) {
      if (!validate.validatePhoneLength(_emailController.text)) {
        setState(() {
          CustomToast.show(getTranslatedText("phone_format_error_msg"));
        });
      } else {
        ProgressDialog.show(context, _vm.brandLogoUrl);
        _vm.getForgotPasswordCode(phone: _emailController.text, areaCode: display);
      }
    } else {
      if (!validate.validateEmail(_emailController.text)) {
        setState(() {
          CustomToast.show(getTranslatedText("email_format_error_msg"));
        });
      } else {
        ProgressDialog.show(context, _vm.brandLogoUrl);
        _vm.getForgotPasswordCode(email: _emailController.text);
      }
    }
  }

  _handleApiState() {
    handleApiState(_vm.getForgotPasswordCodeApiState, onSuccess: () {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        CustomToast.show(getTranslatedText("verification_code_success"));
        setState(() {
          isOtpCountdown = true;
        });
      });
    });
  }

  _navigateToUpdatePassword() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UpdateForgotPassword(code: _otpController.text, securityKey: _vm.securityKey)));
  }
}
