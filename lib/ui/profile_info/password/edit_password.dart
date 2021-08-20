import 'dart:ui';

import 'package:api/data/provider/input_validation_provider.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_text_form_field.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/profile_info/password/edit_password_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class EditPassword extends StatefulWidget {
  @override
  _EditPasswordState createState() => _EditPasswordState();
}

class _EditPasswordState extends BaseState<EditPassword> {
  var _vm = EditPasswordViewModel();
  TextEditingController _oldPasswordController = TextEditingController(),
      _newPasswordController = TextEditingController(),
      _confirmPasswordController = TextEditingController();
  var isButtonEnabled = false;
  InputValidationProvider validate = new InputValidationProvider();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<EditPasswordViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: CustomColor.theme_bg_color,
              appBar: CustomAppBar(
                title: getTranslatedText("edit_password"),
              ),
              body: Container(
                  padding: EdgeInsets.only(top: 20.auto, left: 10.auto, right: 10.auto),
                  child: Column(
                    children: [
                      _buildTextFormField("old_password", "enter_old_password_hint", _oldPasswordController, false),
                      _buildTextFormField("new_password", "enter_new_password_hint", _newPasswordController, false),
                      _buildTextFormField(
                          "confirm_new_password", "confirm_new_password_hint", _confirmPasswordController, true),
                      _buildButton()
                      //_buildFooterText()
                    ],
                  )));
        });
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

  _onTextChange() {
    if (_oldPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty) {
      setState(() {
        isButtonEnabled = true;
      });
    } else {
      setState(() {
        isButtonEnabled = false;
      });
    }
  }

  _onClick() async {
    if (!validate.validatePasswordLength(_newPasswordController.text)) {
      setState(() {
        CustomToast.show(getTranslatedText("enter_password_error_msg"));
      });
    } else if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        CustomToast.show(getTranslatedText("confirm_password_error_msg"));
      });
    } else {
      ProgressDialog.show(context);
      _vm.editPassword(_oldPasswordController.text, _newPasswordController.text);
    }
  }

  _handleApiState() {
    handleApiState(_vm.editPasswordApiState, isCheckSessionExpired:false, onSuccess: () {
      CustomToast.show(getTranslatedText("success"));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    }, onError: (errorMsg){
      if(_vm.editPasswordApiState.errorCode == 101) CustomToast.show(getTranslatedText("invalid_old_password"));
      else CustomToast.show(errorMsg);
    });
  }
}
