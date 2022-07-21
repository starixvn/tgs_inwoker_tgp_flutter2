import 'package:api/data/provider/input_validation_provider.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/custom_text_form_field.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/custom/otp_text_form_field.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/ui/profile_info/email/email_verification_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class EmailVerification extends StatefulWidget {
  final int popDirection;

  EmailVerification(this.popDirection);

  @override
  _EmailVerificationState createState() => _EmailVerificationState();
}

class _EmailVerificationState extends BaseState<EmailVerification> {
  var _vm = EmailVerificationViewModel();
  TextEditingController _emailController = TextEditingController(), _otpController = TextEditingController();
  var isButtonEnabled = false, isOtpEnabled = false, isTextFieldEnabled = false, isOtpCountdown = false;
  var buttonText;
  InputValidationProvider validate = new InputValidationProvider();

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
              body: _vm.userProfile == null
                  ? buildProgressDialog(_vm.brandLogoUrl)
                  : Container(
                      margin: EdgeInsets.only(
                        left: 10.auto,
                        right: 10.auto,
                      ),
                      child: Column(
                        children: [
                          //CustomTabBar(index:1),
                          _buildTextFormField(),
                          _buildOtpTextFormField(),
                          _buildButton(),
                          _buildEditEmailText()
                        ],
                      ),
                    ));
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
          focusNode: null,
          width: context.screenWidth - 40.auto,
          textInputType: TextInputType.text,
          textInputAction: TextInputAction.next,
          enabled: isTextFieldEnabled,
          bottomMargin: 0,
        ),
      );

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
        isVisible: _vm.userProfile.email == null,
      );

  _buildButton() => Container(
      width: context.screenWidth,
      margin: EdgeInsets.all(10.auto),
      child: ColorButton(
        title: buttonText ?? "",
        onClick: () {
          _onClick();
        },
        isEnabled: isButtonEnabled,
        color: CustomColor.theme_button_color,
        radius: 9.6,
      ));

  _buildEditEmailText() => InkWell(
        onTap: () {
          (_vm.config?.changesNotAllowed ?? false)
              ? Navigator.of(context).pushNamed("/customer_service")
              : Navigator.of(context)
                  .pushNamed(RoutePath.editEmail)
                  .then((value) => WidgetsBinding.instance!.addPostFrameCallback((_) {
                        _getUserProfile();
                      }));
        },
        child: RichText(
          text: TextSpan(
            text: getTranslatedText("edit_email_cs"),
            style: TextStyle(fontSize: 11.auto, color: CustomColor.theme_text_black_white_color),
            children: [
              TextSpan(
                text: (_vm.config?.changesNotAllowed ?? false)
                    ? getTranslatedText("online_cs")
                    : getTranslatedText("here"),
                style: TextStyle(
                    decoration: TextDecoration.underline, color: CustomColor.theme_button_color, fontSize: 11.auto),
              ),
            ],
          ),
        ),
      );

  _onTextChange() {
    setState(() {
      if (_otpController.text.isNotEmpty && _emailController.text.isNotEmpty) {
        isButtonEnabled = true;
      } else if (_emailController.text.isNotEmpty) {
        isOtpEnabled = true;
      } else {
        isButtonEnabled = false;
        isOtpEnabled = false;
      }
    });
  }

  _getUserProfile() {
    var _email = _vm.userProfile.email;
    setState(() {
      if (_email != null) {
        if (_email.isNotEmpty) {
          _emailController.text = _email;
          buttonText = getTranslatedText("verified");
          isButtonEnabled = false;
          isTextFieldEnabled = false;
        }
      } else {
        buttonText = getTranslatedText("done");
        isTextFieldEnabled = true;
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
        CustomToast.show(getTranslatedText("success"));
        _getUserProfile();
        if (widget.popDirection == 1) Navigator.of(context).pop(true);
      });
    }, onError: (_) {
      if (_vm.emailVerifyApiState.errorCode == 409) {
        CustomToast.show(getTranslatedText("email_duplicate"));
      } else
        showApiErrorMessage(_vm.emailVerifyApiState);
    });
  }
}
