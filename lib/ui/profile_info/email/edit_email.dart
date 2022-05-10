import 'package:api/data/provider/input_validation_provider.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/custom_tab_bar.dart';
import 'package:tgp_flutter2/custom/custom_text_form_field.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/custom/otp_text_form_field.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/ui/profile_info/email/email_verification_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class EditEmail extends StatefulWidget {
  @override
  _EditEmailState createState() => _EditEmailState();
}

class _EditEmailState extends BaseState<EditEmail> {
  var _vm = EmailVerificationViewModel();
  TextEditingController _emailController = TextEditingController(), _otpController = TextEditingController();
  var isButtonEnabled = false, isOtpEnabled = true, isTextFieldEnabled = true, isOtpCountdown = false;
  InputValidationProvider validate = new InputValidationProvider();
  int currIndex = 0;
  String? display;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _getUserProfile();
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<EmailVerificationViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return CustomScaffold(
              appBar: CustomAppBar(
                title: getTranslatedText("email"),
              ),
              body: Container(
                margin: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 20.auto),
                child: Column(
                  children: [
                    //CustomTabBar(index:1),
                    CustomTabBar(
                      index: currIndex,
                      step1Text: "verify_current_email",
                      step2Text: "set_new_email",
                    ),
                    _buildEmailTextFormField(), _buildOtpTextFormField(), _buildButton()
                  ],
                ),
              ));
        });
  }

  _buildEmailTextFormField() => Container(
        margin: EdgeInsets.only(top: 15.auto),
        child: CustomTextFormField(
          title: getTranslatedText("email"),
          hintText: getTranslatedText("email_hint"),
          onChanged: (value) => _onTextChange(),
          onFieldSubmitted: (value) {},
          controller: _emailController,
          focusNode: null,
          width: context.screenWidth - 40.auto,
          textInputType: TextInputType.text,
          textInputAction: TextInputAction.next,
          enabled: isTextFieldEnabled,
        ),
      );

  _buildOtpTextFormField() => Opacity(
      opacity: isOtpEnabled ? 1 : 0.4,
      child: Container(
        margin: EdgeInsets.only(top: 15.auto),
        child: OtpTextFormField(
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
        ),
      ));

  _buildButton() => Container(
      width: context.screenWidth,
      margin: EdgeInsets.all(10.auto),
      child: ColorButton(
        title: currIndex == 0 ? getTranslatedText("next") : getTranslatedText("done"),
        onClick: () {
          _onClick();
        },
        isEnabled: isButtonEnabled,
        color: CustomColor.theme_button_color,
        radius: 9.6,
      ));

  _onTextChange() {
    setState(() {
      if (_otpController.text.isNotEmpty) {
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

  _getUserProfile() {
    var email = _vm.userProfile.email;
    setState(() {
      if (email != null) {
        if (email.isNotEmpty) {
          _emailController.text = email;
          isOtpEnabled = true;
        }
      }
    });
  }

  _getSmsCode() {
    if (!validate.validateEmail(_emailController.text)) {
      setState(() {
        CustomToast.show(getTranslatedText("email_format_error_msg"));
      });
    } else {
      ProgressDialog.show(context, _vm.brandLogoUrl);
      _vm.getEmailCode(_emailController.text);
    }
  }

  _onClick() async {
    ProgressDialog.show(context, _vm.brandLogoUrl);
    _vm.emailVerify(_otpController.text);
  }

  _handleApiState() {
    handleApiState(_vm.getEmailCodeApiState, onSuccess: () {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        CustomToast.show(getTranslatedText("verification_code_success"));
        setState(() {
          isOtpCountdown = true;
        });
      });
    });
    handleApiState(_vm.emailVerifyApiState, onSuccess: () {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        if (currIndex == 0) {
          setState(() {
            _clearTextField();
            currIndex = 1;
          });
        } else {
          CustomToast.show(getTranslatedText("success"));
          Navigator.pop(context);
        }
      });
    }, onError: (_) {
      if (_vm.emailVerifyApiState.errorCode == 409) {
        CustomToast.show(getTranslatedText("email_duplicate"));
      } else
        showApiErrorMessage(_vm.emailVerifyApiState);
    });
  }

  _clearTextField() {
    _emailController.clear();
    _otpController.clear();
    isButtonEnabled = false;
    isOtpEnabled = false;
    isTextFieldEnabled = true;
  }
}
