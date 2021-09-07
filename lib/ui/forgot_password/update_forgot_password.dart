import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_text_form_field.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:api/data/provider/input_validation_provider.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/forgot_password/forgot_password_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class UpdateForgotPassword extends StatefulWidget {
  final String code;
  final String securityKey;

  UpdateForgotPassword({this.code, this.securityKey});

  @override
  _UpdateForgotPasswordState createState() => _UpdateForgotPasswordState();
}

class _UpdateForgotPasswordState extends BaseState<UpdateForgotPassword> {
  var _vm = ForgotPasswordViewModel();
  TextEditingController _newPasswordController = TextEditingController(),
      _confirmPasswordController = TextEditingController();
  var isButtonEnabled = false;
  InputValidationProvider validate = new InputValidationProvider();

  @override
  void initState() {
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
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      )),
                  padding: EdgeInsets.only(top: 10.auto, left: 10.auto, right: 10.auto),
                  child: Column(
                    children: [
                      _buildTextFormField("new_password", "enter_new_password_hint", _newPasswordController),
                      _buildTextFormField(
                          "confirm_new_password", "confirm_new_password_hint", _confirmPasswordController),
                      _buildButton()
                      //_buildFooterText()
                    ],
                  )));
        });
  }

  _buildTextFormField(String title, String hint, TextEditingController controller) => Container(
        margin: EdgeInsets.only(top: 15.auto),
        child: CustomTextFormField(
          title: getTranslatedText(title),
          hintText: getTranslatedText(hint),
          onChanged: (value) => _onTextChange(),
          onFieldSubmitted: (value) {},
          controller: controller,
          focusNode: null,
          width: context.screenWidth - 70.auto,
          textInputType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.next,
        ),
      );

  /*_buildFooterText(){
    var _footerText1, _footerText2;
    if(isUpdateForgotPasswordVerified){
      _footerText1 = "如需修改号码，请点击";
      _footerText2 = "这里";
    }else{
      _footerText1 = "如有任何问题，请联系";
      _footerText2 = "线上客服";
   // }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _footerText1,
          style: TextStyle(
              fontSize: 12.auto,
              color: CustomColor.black
          ),
        ),
        InkWell(
          onTap: isUpdateForgotPasswordVerified?(){
            Navigator.of(context).push((widget: route));("/edit_email");
          }:(){
            //customer service
          },
          child: Text(
            _footerText2,
            style: TextStyle(
                fontSize: 12.auto,
                color: CustomColor.sand_brown
            ),
          ),
        )
      ],
    );
  }*/
  _buildButton() => Container(
      width: context.screenWidth,
      padding: EdgeInsets.only(top: 50.auto, bottom: 20.auto),
      child: ColorButton(
        title: getTranslatedText("done"),
        onClick: () {
          _onClick();
        },
        isEnabled: isButtonEnabled ?? false,
        radius: 9.6,
      ));

  _onTextChange() {
    setState(() {
      if (_newPasswordController.text.isNotEmpty && _confirmPasswordController.text.isNotEmpty) {
        isButtonEnabled = true;
      } else {
        isButtonEnabled = false;
      }
    });
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
      _vm.resetPassword(widget.securityKey, widget.code, _newPasswordController.text);
    }
  }

  _handleApiState() {
    handleApiState(_vm.resetPasswordApiState, onSuccess: () {
      CustomToast.show(getTranslatedText("success"));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        var count = 0;
        Navigator.popUntil(context, (route) {
          return count++ == 2;
        });
      });
    });
  }
}
