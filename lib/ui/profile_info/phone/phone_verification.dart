import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/custom_text_form_field.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/custom/otp_text_form_field.dart';
import 'package:api/data/provider/input_validation_provider.dart';
import 'package:tgp_flutter2/custom/phone_text_form_field.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/profile_info/phone/phone_verification_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class PhoneVerification extends StatefulWidget {
  final bool isFromRegister;
  final bool isFromRouletteRoute;

  PhoneVerification(
      {this.isFromRegister = false, this.isFromRouletteRoute = false});

  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends BaseState<PhoneVerification> {
  var _vm = PhoneVerificationViewModel();
  TextEditingController _phoneController = TextEditingController(),
      _otpController = TextEditingController();
  var isButtonEnabled = false,
      isOtpEnabled = false,
      isTextFieldEnabled = false,
      isOtpCountdown = false;
  var buttonText;

  var isCompleted = false;
  InputValidationProvider validate = new InputValidationProvider();
  String? display;

  @override
  void initState() {
    display = _vm.config?.phonePrefix ?? "+852";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getUserProfile();
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<PhoneVerificationViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return CustomScaffold(
              appBar: _buildAppBar(),
              body: Container(
                  child: Container(
                margin: EdgeInsets.only(
                    left: 10.auto, right: 10.auto, top: 10.auto),
                child: Column(
                  children: [
                    //CustomTabBar(index:1),
                    _buildTextFormField(),
                    _buildOtpTextFormField(),
                    _buildButton(),
                    _buildEditPhoneText()
                  ],
                ),
              )));
        });
  }

  _buildAppBar() => CustomAppBar(
      title: getTranslatedText("phone_number"),
      onPop: () {
        if (_vm.userProfile.phone == null &&
            !(_vm.userProfile?.registerCompleted ?? true) &&
            (_vm.config?.forcedVerification ?? false)) {
        } else if (isCompleted == true) {
          Navigator.of(context).pushNamed("/profile_info");
        } else if (widget.isFromRouletteRoute ||
            (_vm.userProfile.phone != null && widget.isFromRegister))
          //pop back to home page
          Navigator.pop(context, true);
        else
          Navigator.popUntil(context, ModalRoute.withName('/profile_info'));
      });

  _buildTextFormField() => Container(
        margin: EdgeInsets.only(top: 15.auto),
        child: PhoneTextFormField(
          onChanged: (value) => _onTextChange(),
          onFieldSubmitted: (value) {},
          controller: _phoneController,
          width: context.screenWidth - 30.auto,
          textInputAction: TextInputAction.next,
          enabled: isTextFieldEnabled,
          onAreaCodeClicked: (value) => _onAreaCodeClicked(value),
          displayedAreaCode: display,
          maxLength: _vm.config?.maxPhoneLength ?? 10,
        ),
      );

  _buildOtpTextFormField() {
    return Visibility(
        visible: _vm.config?.initPhoneWithoutVerify ?? false
            ? false
            : _vm.userProfile.phone == null &&
                    !(_vm.config?.profileDisableVerifyPhone ?? true) ||
                !(_vm.userProfile?.registerCompleted ?? true),
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
          isVisible: true,
        ));
  }

  _buildButton() => Container(
      width: context.screenWidth,
      margin: EdgeInsets.only(top: 30.auto),
      child: ColorButton(
        title: buttonText ?? "",
        onClick: () {
          _onClick();
        },
        isEnabled: isButtonEnabled,
        radius: 9.6,
      ));

  _buildEditPhoneText() => Visibility(
        visible: _vm.userProfile.phone != null,
        child: InkWell(
          onTap: () {
            _isNotAllowedEditPhone()
                ? Navigator.of(context).pushNamed("/customer_service")
                : Navigator.of(context).pushNamed(RoutePath.editPhone).then(
                    (value) =>
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _getUserProfile();
                        }));
          },
          child: Container(
            margin: EdgeInsets.only(top: 20.auto),
            child: RichText(
              text: TextSpan(
                text: getTranslatedText("edit_phone_cs"),
                style: TextStyle(
                    fontSize: 11.auto,
                    color: CustomColor.theme_text_black_white_color),
                children: [
                  TextSpan(
                    text: _isNotAllowedEditPhone()
                        ? getTranslatedText("online_cs")
                        : getTranslatedText("here"),
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: CustomColor.theme_button_color,
                        fontSize: 11.auto),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  _onTextChange() {
    setState(() {
      if (_phoneController.text.isNotEmpty &&
          _vm.config?.initPhoneWithoutVerify) {
        isOtpEnabled = false;
        isButtonEnabled = true;
      } else if (_otpController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty) {
        isOtpEnabled = true;
        isButtonEnabled = true;
      } else if (_phoneController.text.isNotEmpty) {
        isOtpEnabled = true;
        isButtonEnabled = false;
      } else {
        isOtpEnabled = false;
        isButtonEnabled = false;
      }
    });
  }

  _onAreaCodeClicked(String area) {
    setState(() {
      display = area;
      Navigator.of(context).pop();
    });
  }

  _getUserProfile() {
    setState(() {
      String? phone = _vm.userProfile.phone;
      if (phone?.isNotEmpty ?? false) {
        _phoneController.text = phone!;
        buttonText = getTranslatedText("verified");
        isButtonEnabled = false;
        isTextFieldEnabled = false;
      } else if ((_vm.config?.profileDisableVerifyPhone ?? false) &&
          (_vm.userProfile?.registerCompleted ?? true)) {
        buttonText = getTranslatedText("done");
        isButtonEnabled = false;
        isTextFieldEnabled = false;
      } else {
        buttonText = getTranslatedText("done");
        isTextFieldEnabled = true;
      }
    });
  }

  _setButtonToDone() {
    setState(() {
      buttonText = getTranslatedText("done");
      isButtonEnabled = false;
      isTextFieldEnabled = false;
    });
  }

  _getSmsCode() {
    if (!validate.validatePhoneLength(_phoneController.text)) {
      setState(() {
        CustomToast.show(getTranslatedText("phone_format_error_msg"));
      });
    }
    /*else if (!validate.validateAreaCodeAndPhone(display!, _phoneController.text)) {
      setState(() {
        CustomToast.show(getTranslatedText("phone_format_error_msg"));
      });
    }*/
    else {
      ProgressDialog.show(context, _vm.brandLogoUrl);
      _vm.getPhoneVerifyCode(display!, _phoneController.text,
          isFromRegister: widget.isFromRegister);
    }
  }

  _onClick() async {
    ProgressDialog.show(context, _vm.brandLogoUrl);

    if (_vm.userProfile.phone == null &&
        !(_vm.userProfile?.registerCompleted ?? true) &&
        (_vm.config?.initPhoneWithoutVerify ?? false)) {
      _vm.performSetPhoneDontCareDuplicate(display!, _phoneController.text);

      if (_vm.submitVerifyCodeApiState.isSuccess) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _getUserProfile();
        });
      }
    } else {
      _vm.submitVerifyCode(1, _otpController.text,
          isFromRegister: widget.isFromRegister);
    }
  }

  _isNotAllowedEditPhone() =>
      (_vm.config?.changesNotAllowed ?? false) ||
      (_vm.config?.profileNotAllowChangePhone ?? false) ||
      (_vm.config?.profileDisableEditPhone ?? false) ||
      (_vm.config?.registerShowPhone ?? false);

  _handleApiState() {
    handleApiState(_vm.getPhoneVerifyCodeApiState, onSuccess: () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomToast.show(getTranslatedText("verification_code_success"));
        setState(() {
          isOtpCountdown = true;
        });
      });
    });

    handleApiState(_vm.submitVerifyCodeApiState, onSuccess: () async {
      await _getUserProfile();
      isCompleted = true;
      _setButtonToDone();
      CustomToast.show(getTranslatedText("success"));
    });
  }
}
