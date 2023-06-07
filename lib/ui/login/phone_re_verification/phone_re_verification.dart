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
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/main.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/login/CustomSky8/LoginOtpInputView.dart';
import 'package:tgp_flutter2/ui/login/CustomSky8/LoginPhoneInputView.dart';
import 'package:tgp_flutter2/ui/login/login_password_text_form_field.dart';
import 'package:tgp_flutter2/ui/login/phone_re_verification/login_otp_text_form_field.dart';
import 'package:tgp_flutter2/ui/login/phone_re_verification/login_phone_text_form_field.dart';
import 'package:tgp_flutter2/ui/login/login_text_form_field.dart';
import 'package:tgp_flutter2/ui/login/login_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class PhoneReVerification extends StatefulWidget {
  final LoginViewModel? vm;

  //check for from register content view / from dialog / from user profile
  final bool isRegister;

  // check for api is calling init-phone / register
  final bool isIdrRegister;

  PhoneReVerification({
    this.vm,
    this.isRegister = false,
    this.isIdrRegister = false,
  });

  @override
  _PhoneReVerificationState createState() => _PhoneReVerificationState();
}

class _PhoneReVerificationState extends BaseState<PhoneReVerification> with AutomaticKeepAliveClientMixin {
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
  bool get wantKeepAlive => true;

  @override
  void initState() {
    if (widget.vm == null)
      _vm = LoginViewModel();
    else
      _vm = widget.vm;
    display = _vm.config?.phonePrefix ?? "+852";
    _initData();
    super.initState();
  }

  _initData() {
    _usernameController.text = _vm.username ?? "";
    _passwordController.text = _vm.password ?? "";
  }

  Widget build(BuildContext context) {
    super.build(context);

    return ProviderWidget<LoginViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          if (_vm.isPhoneReVerificationReset) {
            _initData();
            _vm.setIsPhoneReVerificationResetToFalse();
          }
          return Container(
            child: Expanded(
              child: ListView(
                children: [
                  //CustomTabBar(index:1),
                  _buildPhoneTextFormField(),
                  _buildOtpTextFormField(),
                  _buildButton()
                ],
              ),
            ),
          );
        });
  }

  _buildPhoneTextFormField() => Container(
        margin: EnvironmentConfig.template_version == 15
            ? EdgeInsets.only(left: 10.auto, right: 10.auto, bottom: 10.auto, top: 15.auto)
            : EdgeInsets.only(top: 15.auto),
        child: EnvironmentConfig.template_version == 15 && widget.isRegister
            ? LoginPhoneTextFormField(
                onChanged: (value) => _onTextChange(),
                onFieldSubmitted: (value) {},
                controller: _phoneController,
                width: context.screenWidth - 70.auto,
                textInputAction: TextInputAction.next,
                enabled: isTextFieldEnabled,
                onAreaCodeClicked: (value) => _onAreaCodeClicked(value),
                displayedAreaCode: display,
                maxLength: _vm.config?.maxPhoneLength ?? 10,
              )
            : LoginPhoneInputView(
                onChanged: (value) => _onTextChange(),
                onFieldSubmitted: (value) {},
                controller: _phoneController,
                width: context.screenWidth - 70.auto,
                textInputAction: TextInputAction.next,
                enabled: isTextFieldEnabled,
                onAreaCodeClicked: (value) => _onAreaCodeClicked(value),
                displayedAreaCode: display,
                maxLength: _vm.config?.maxPhoneLength ?? 10,
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
        child: Container(
          margin: EnvironmentConfig.template_version == 15
              ? EdgeInsets.only(left: 10.auto, right: 10.auto, bottom: 10.auto, top: 0.auto)
              : EdgeInsets.only(top: 15.auto),
          child: EnvironmentConfig.template_version == 15 && widget.isRegister
              ? LoginOtpTextFormField(
                  hintText: getTranslatedText("enter_phone_otp_hint"),
                  onChanged: (value) => _onTextChange(),
                  controller: _otpController,
                  textInputAction: TextInputAction.done,
                  getOtpCode: () {
                    _getSmsCode();
                  },
                  isCountdown: isOtpCountdown,
                  isEnabled: true,
                  onCountDownEnd: () => {
                        setState(() {
                          isOtpCountdown = false;
                        })
                      })
              : LoginOtpInputView(
                  hintText: getTranslatedText("enter_phone_otp_hint"),
                  onChanged: (value) => _onTextChange(),
                  controller: _otpController,
                  textInputAction: TextInputAction.done,
                  getOtpCode: () {
                    _getSmsCode();
                  },
                  isCountdown: isOtpCountdown,
                  isEnabled: true,
                  onCountDownEnd: () => {
                        setState(() {
                          isOtpCountdown = false;
                        })
                      }),
        ),
      );

  _buildButton() => Container(
      width: context.screenWidth,
      margin: EnvironmentConfig.template_version == 15
          ? EdgeInsets.only(top: 30.auto, bottom: 20.auto, left: 25.auto, right: 25.auto)
          : EdgeInsets.only(top: 30.auto, bottom: 20.auto),
      child: ColorButton(
        title: getTranslatedText("submit"),
        onClick: () {
          _onClick();
        },
        isEnabled: isButtonEnabled,
        radius: EnvironmentConfig.template_version == 15 && widget.isRegister ? 20 : 9.6,
      ));

  _onTextChange() {
    setState(() {
      if (_phoneController.text.isNotEmpty && _otpController.text.isNotEmpty) {
        // isOtpEnabled = true;
        isButtonEnabled = true;
      } else if (_phoneController.text.isNotEmpty) {
        // isOtpEnabled = true;
        isButtonEnabled = false;
      } else {
        //isOtpEnabled = false;
        isButtonEnabled = false;
      }
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
      //ProgressDialog.show(context, _vm.brandLogoUrl);
      _vm.getReVerifyCode(display!, _phoneController.text);
    }
  }

  _onClick() async {
    ProgressDialog.show(context, _vm.brandLogo.mobileUrl);
    _vm.phoneVerify(_otpController.text, widget.isIdrRegister);
  }

  _handleApiState() {
    handleApiState(_vm.getReVerifyCodeApiState, onSuccess: () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomToast.show(getTranslatedText("verification_code_success"));
        setState(() {
          isOtpCountdown = true;
        });
      });
    });

    handleApiState(_vm.phoneReVerifyApiState, onSuccess: () async {
      if (widget.isRegister) await _vm.login(_vm.username, _vm.password, true);
      else{
        await _vm.getUserInfo();
      }
      if (_vm.config?.navigateToAddCard ?? false)
        _navigateToAddCard();
      else
        _navigateToHome();
    });
  }

  _navigateToHome() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamedAndRemoveUntil(RoutePath.myHome, (Route<dynamic> route) => false);
    });
  }

  _navigateToAddCard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MyHomePage(
                    index: 4,
                  )));
      Navigator.pushNamed(context, RoutePath.addCard);
    });
  }
}
