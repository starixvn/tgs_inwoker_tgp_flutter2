import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_picker.dart';
import 'package:tgp_flutter2/custom/custom_picker_dialog.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_tab_bar.dart';
import 'package:tgp_flutter2/custom/custom_text_form_field.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/custom/otp_text_form_field.dart';
import 'package:tgp_flutter2/custom/phone_text_form_field.dart';
import 'package:api/data/provider/input_validation_provider.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/profile_info/phone/phone_verification_view_model.dart';

class EditPhone extends StatefulWidget {
  @override
  _EditPhoneState createState() => _EditPhoneState();
}

class _EditPhoneState extends BaseState<EditPhone> {
  var _vm = PhoneVerificationViewModel();
  TextEditingController _phoneController = TextEditingController(), _otpController = TextEditingController();
  var isButtonEnabled = false, isOtpEnabled = false, isTextFieldEnabled = false, isOtpCountdown = false;
  InputValidationProvider validate = new InputValidationProvider();
  int currIndex = 0;
  String? display;

  @override
  void initState() {
    display = _vm.config.phonePrefix;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _getUserProfile();
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<PhoneVerificationViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: CustomColor.theme_bg_color,
              appBar: _buildAppBar(),
              body: Container(
                  padding: EdgeInsets.only(top: 10.auto, left: 10.auto, right: 10.auto),
                  child: Column(
                    children: [
                      CustomTabBar(
                        index: currIndex,
                        step1Text: "verify_current_phone_number",
                        step2Text: "set_new_phone_number",
                      ),
                      _buildVerifyOldPhoneNumber()
                      // currIndex == 0 ? _buildVerifyOldPhoneNumber() : _buildResetPayPassword()
                    ],
                  )));
        });
  }

  _buildAppBar() => CustomAppBar(
        title: getTranslatedText("phone_number"),
        onPop: () => Navigator.popUntil(context, ModalRoute.withName('/profile_info')),
      ) /*AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: gradientDecoration,
        ),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/profile_info'))),
        title: Text(

          style: TextStyle(fontSize: 16.auto),
        ),
      )*/
      ;

  _buildVerifyOldPhoneNumber() => Column(
        children: [_buildPhoneTextFormField(), _buildOtpTextFormField(), _buildButton()],
      );

  _buildPhoneTextFormField() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: EdgeInsets.only(top: 25.auto),
            child: PhoneTextFormField(
              onChanged: (value) => _onTextChange(),
              onFieldSubmitted: (value) {},
              controller: _phoneController,
              width: context.screenWidth - 40.auto,
              textInputAction: TextInputAction.next,
              enabled: isTextFieldEnabled,
              onAreaCodeClicked: (value) => _onAreaCodeClicked(value),
              displayedAreaCode: display,
            ),
          ),
        ],
      );

  _onAreaCodeClicked(String area) {
    setState(() {
      display = area;
      Navigator.of(context).pop();
    });
  }

  _buildOtpTextFormField() => Opacity(
        opacity: isOtpEnabled ? 1 : 0.4,
        child: Container(
          margin: EdgeInsets.only(top: 10.auto),
          child: OtpTextFormField(
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
      );

  _buildButton() => Container(
      width: context.screenWidth,
      margin: EdgeInsets.only(top: 30.auto, bottom: 20.auto),
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
      } else if (_phoneController.text.isNotEmpty) {
        isOtpEnabled = true;
        isButtonEnabled = false;
      } else {
        isOtpEnabled = false;
        isButtonEnabled = false;
      }
    });
  }

  _getUserProfile() {
    var phone = _vm.userProfile.phone;
    setState(() {
      if (phone != null) {
        if (phone.isNotEmpty) {
          _phoneController.text = phone;
          isOtpEnabled = true;
        }
      }
    });
  }

  _getSmsCode() {
    if (!validate.validateAreaCodeAndPhone(display!, _phoneController.text)) {
      setState(() {
        CustomToast.show(getTranslatedText("phone_format_error_msg"));
      });
    } else {
      ProgressDialog.show(context, _vm.brandLogoUrl);
      _vm.getPhoneVerifyCode(display!, _phoneController.text);
    }
  }

  _onClick() async {
    ProgressDialog.show(context, _vm.brandLogoUrl);
    _vm.submitVerifyCode(currIndex, _otpController.text);
  }

  _handleApiState() {
    handleApiState(_vm.getPhoneVerifyCodeApiState, onSuccess: () {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        CustomToast.show(getTranslatedText("verification_code_success"));
        setState(() {
          isOtpCountdown = true;
        });
      });
    });

    handleApiState(_vm.submitVerifyCodeApiState, onSuccess: () {
      if (currIndex == 0) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          setState(() {
            _clearTextField();
            currIndex = 1;
          });
        });
      } else {
        CustomToast.show(getTranslatedText("success"));
        //_getUserProfile();
        Navigator.pop(context);
      }
    });
  }

  _clearTextField() {
    _phoneController.clear();
    _otpController.clear();
    isButtonEnabled = false;
    isOtpEnabled = false;
    isTextFieldEnabled = true;
  }
}
