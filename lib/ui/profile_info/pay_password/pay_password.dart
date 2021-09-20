import 'dart:ui';

import 'package:api/data/provider/input_validation_provider.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_text_form_field.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/profile_info/pay_password/pay_password_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class PayPassword extends StatefulWidget {
  @override
  _PayPasswordState createState() => _PayPasswordState();
}

class _PayPasswordState extends BaseState<PayPassword> {
  var _vm = PayPasswordViewModel();
  TextEditingController _newPasswordController = TextEditingController(),
      _confirmPasswordController = TextEditingController();
  var isButtonEnabled = false;
  InputValidationProvider validate = new InputValidationProvider();

  @override
  void initState() {
    _checkEmailIsSet();
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
                title: _vm.userProfile.isSetPayPassword
                    ? getTranslatedText("edit_pay_password")
                    : getTranslatedText("add_pay_password"),
              ),
              body: _vm.userProfile == null
                  ? buildProgressDialog(_vm.brandLogoUrl)
                  : Container(
                  padding: EdgeInsets.only(top: 20.auto, left: 10.auto, right: 10.auto),
                  child: _buildSetPayPassword()));
        });
  }

  _buildSetPayPassword() {
    return Column(
      children: [
        _buildTextFormField("new_password", "enter_new_password_hint", _newPasswordController, false),
        _buildTextFormField("confirm_new_password", "confirm_new_password_hint", _confirmPasswordController, true),
        _buildButton()
      ],
    );
  }

  _buildTextFormField(String title, String hint, TextEditingController controller, bool isLast) => Container(
    child: CustomTextFormField(
      title: getTranslatedText(title),
      hintText: getTranslatedText(hint),
      onChanged: (value) => _onTextChange(),
      onFieldSubmitted: (value) {},
      controller: controller,
      focusNode: null,
      width: context.screenWidth - 40.auto,
      textInputType: TextInputType.visiblePassword,
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
    ),
  );

  _buildButton() => Container(
      width: context.screenWidth,
      padding: EdgeInsets.all(10.auto),
      child: ColorButton(
        title: getTranslatedText("confirm"),
        onClick: () => _onClick(),
        isEnabled: isButtonEnabled,
        color: CustomColor.theme_button_color,
        radius: 9.6,
      ));

  _checkEmailIsSet() {
    if (!_vm.userProfile.isSetPayPassword) {
      if (_vm.userProfile.email == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (BuildContext context) => CustomDialog(
              description: getTranslatedText("email_dialog"),
              buttonText1: getTranslatedText("confirm"),
              onClick: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/email_verification');
                Navigator.popAndPushNamed(context, '/email_verification');
              },
            ),
          );
        });
      }
    }else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamed("/reset_pay_password");
      });
    }
  }

  _onTextChange() {
    setState(() {
      if (!_vm.userProfile.isSetPayPassword) {
        if (_newPasswordController.text.isNotEmpty && _confirmPasswordController.text.isNotEmpty) {
          isButtonEnabled = true;
        }
      } else if (_vm.userProfile.isSetPayPassword) {
        if (_newPasswordController.text.isNotEmpty &&
            _confirmPasswordController.text.isNotEmpty) {
          isButtonEnabled = true;
        }
      } else {
        isButtonEnabled = false;
      }
    });
  }

  _onClick() async {
    if (!validate.validateUsernamePassword(_newPasswordController.text)) {
      setState(() {
        CustomToast.show(getTranslatedText("enter_pay_password_error_msg"));
      });
    } else if (!validate.validatePasswordLength(_newPasswordController.text)) {
      setState(() {
        CustomToast.show(getTranslatedText("pay_password_length_error_msg"));
      });
    } else if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        CustomToast.show(getTranslatedText("confirm_pay_password_error_msg"));
      });
    } else {
      ProgressDialog.show(context, _vm.brandLogoUrl);
      _vm.addPayPassword(_newPasswordController.text);
    }
  }

  _handleApiState() {
    handleApiState(_vm.addPayPasswordApiState, onSuccess: () {
      CustomToast.show(getTranslatedText("success"));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context, true);
      });
    });
  }
}
