import 'dart:ui';

import 'package:api/data/provider/input_validation_provider.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_tab_bar.dart';
import 'package:tgp_flutter2/custom/custom_text_form_field.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/custom/otp_text_form_field.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/profile_info/pay_password/pay_password_view_model.dart';

class ResetPayPassword extends StatefulWidget {
  @override
  _ResetPayPasswordState createState() => _ResetPayPasswordState();
}

class _ResetPayPasswordState extends BaseState<ResetPayPassword> {
  var _vm = PayPasswordViewModel();
  TextEditingController _payPasswordController = TextEditingController(),
      _confirmPayPasswordController = TextEditingController(),
      _emailController = TextEditingController(),
      _otpController = TextEditingController();
  var isSubmitButtonEnabled = false,
      isResetPassword = false,
      isCodeVisible = false,
      isOtpEnabled = true,
      isOtpCountdown = false,
      isNextButtonEnabled = false;
  InputValidationProvider validate = new InputValidationProvider();
  int currIndex = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_vm.userProfile.email != null && _vm.userProfile.email.isNotEmpty) {
        setState(() {
          _emailController.text = _vm.userProfile.email;
        });
      } else
        Navigator.of(context).pushNamed("/reset_pay_password");
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<PayPasswordViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: CustomColor.theme_bg_color,
              appBar: CustomAppBar(
                title: getTranslatedText("reset_pay_password"),
                isPopTwice: true,
              ),
              body: Container(
                  padding: EdgeInsets.only(top: 20.auto, left: 10.auto, right: 10.auto),
                  child: Column(
                    children: [
                      CustomTabBar(
                        index: currIndex,
                        step1Text: "verify_current_email",
                        step2Text: "set_new_pay_password",
                      ),
                      currIndex == 0 ? _buildVerifyEmail() : _buildResetPayPassword()
                    ],
                  )));
        });
  }

  _buildVerifyEmail() => Column(
        children: [
          _buildTextFormField("email", "email_hint", _emailController),
          _buildOtpTextFormField(),
          _buildNextButton()
        ],
      );

  _buildResetPayPassword() => Column(
        children: [
          _buildPasswordTextFormField("new_pay_password", "enter_new_pay_password", _payPasswordController),
          _buildPasswordTextFormField(
              "confirm_pay_password", "confirm_pay_password_hint", _confirmPayPasswordController),
          _buildSubmitButton(),
          _buildBackButton()
        ],
      );

  _buildTextFormField(String title, String hint, TextEditingController controller) => Container(
        child: CustomTextFormField(
          title: getTranslatedText(title),
          hintText: getTranslatedText(hint),
          onChanged: (value) => onPayPasswordTextChanged(),
          onFieldSubmitted: (value) {},
          controller: controller,
          focusNode: null,
          width: context.screenWidth - 40.auto,
          textInputType: TextInputType.number,
          textInputAction: TextInputAction.next,
          enabled: false,
        ),
      );

  _buildPasswordTextFormField(String title, String hint, TextEditingController controller) => Container(
        child: CustomTextFormField(
          title: getTranslatedText(title),
          hintText: getTranslatedText(hint),
          onChanged: (value) => onPayPasswordTextChanged(),
          onFieldSubmitted: (value) {},
          controller: controller,
          focusNode: null,
          width: context.screenWidth - 40.auto,
          textInputType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
        ),
      );

  _buildOtpTextFormField() => OtpTextFormField(
        hintText: getTranslatedText("enter_email_otp_hint"),
        onChanged: (value) => _onOtpTextChange(),
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

  _buildSubmitButton() => Container(
      width: context.screenWidth,
      padding: EdgeInsets.all(10.auto),
      child: ColorButton(
        title: getTranslatedText("submit"),
        onClick: () {
          _onClick();
        },
        isEnabled: isSubmitButtonEnabled,
        color: CustomColor.theme_button_color,
        radius: 9.6,
      ));

  _buildNextButton() => Container(
      width: context.screenWidth,
      padding: EdgeInsets.all(10.auto),
      child: ColorButton(
        title: getTranslatedText("next"),
        onClick: () {
          _onClick();
        },
        isEnabled: isNextButtonEnabled,
        color: CustomColor.theme_button_color,
        radius: 9.6,
      ));

  _buildBackButton() => Container(
      width: context.screenWidth,
      padding: EdgeInsets.only(bottom: 20.auto),
      child: ColorButton(
        title: getTranslatedText("back"),
        onClick: () {
          setState(() {
            currIndex = 0;
          });
        },
        isEnabled: true,
        color: CustomColor.theme_button_color,
        radius: 9.6,
      ));

  _getSmsCode() {
    ProgressDialog.show(context, _vm.brandLogoUrl);
    _vm.getPayPasswordCode();
  }

  _onOtpTextChange() {
    if (currIndex == 0 && _otpController.text.isNotEmpty) {
      setState(() {
        isNextButtonEnabled = true;
      });
    } else {
      setState(() {
        isNextButtonEnabled = false;
      });
    }
  }

  onPayPasswordTextChanged() {
    if (_payPasswordController.text.isNotEmpty && _confirmPayPasswordController.text.isNotEmpty) {
      setState(() {
        isSubmitButtonEnabled = true;
      });
    } else {
      setState(() {
        isSubmitButtonEnabled = false;
      });
    }
  }

  _onClick() async {
    if (currIndex == 0) {
      setState(() {
        currIndex = 1;
      });
    } else if (!validate.validateUsernamePassword(_payPasswordController.text)) {
      setState(() {
        CustomToast.show(getTranslatedText("enter_pay_password_error_msg"));
      });
    } else if (!validate.validatePasswordLength(_payPasswordController.text)) {
      setState(() {
        CustomToast.show(getTranslatedText("pay_password_length_error_msg"));
      });
    } else if (_payPasswordController.text != _confirmPayPasswordController.text) {
      setState(() {
        CustomToast.show(getTranslatedText("confirm_pay_password_error_msg"));
      });
    } else {
      ProgressDialog.show(context, _vm.brandLogoUrl);
      _vm.payPasswordVerify(_payPasswordController.text, _otpController.text);
    }
  }

  _handleApiState() {
    handleApiState(_vm.getPayPasswordCodeApiState, onSuccess: () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          isOtpCountdown = true;
        });
      });
    });

    handleApiState(_vm.payPasswordVerifyApiState, onSuccess: () {
      CustomToast.show(getTranslatedText("success"));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        Navigator.pop(context);
      });
    });
  }
}
