import 'package:api/data/provider/input_validation_provider.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_text_form_field.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/profile_info/qq_account/qq_account_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class QQAccount extends StatefulWidget {
  @override
  _QQAccountState createState() => _QQAccountState();
}

class _QQAccountState extends BaseState<QQAccount> {
  var _vm = QQAccountViewModel();
  TextEditingController _qqController = TextEditingController();
  var isButtonEnabled = false, isTextFieldEnabled = false;
  var buttonText;
  InputValidationProvider validate = new InputValidationProvider();
  var _focusNode = FocusNode();

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _getUserProfile();
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<QQAccountViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: CustomColor.theme_bg_color,
              appBar: CustomAppBar(
                title: getTranslatedText("qq_no"),
                onPop: () => Navigator.pop(context, true),
              ),
              body: Container(
                  child: /*userProfile == null?
                  Center(child: CircularProgressIndicator(),):*/
                      Container(
                margin: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 20.auto),
                child: Column(
                  children: [
                    _buildTextFormField(),
                    _buildButton(),
                    _buildFooterText(),
                  ],
                ),
              )));
        });
  }

  _buildTextFormField() => CustomTextFormField(
        title: getTranslatedText("qq_no"),
        hintText: getTranslatedText("qq_no_hint"),
        onChanged: (value) => _onTextChange(),
        onFieldSubmitted: (value) {},
        controller: _qqController,
        focusNode: _focusNode,
        width: context.screenWidth - 40.auto,
        textInputType: TextInputType.number,
        textInputAction: TextInputAction.done,
        enabled: isTextFieldEnabled,
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

  _buildFooterText() => Visibility(
        visible: _vm.userProfile.qq != null,
        child: InkWell(
          onTap: () {
            (_vm.config?.changesNotAllowed ?? false)
                ? Navigator.of(context).pushNamed("/customer_service")
                : setState(() {
                    isTextFieldEnabled = true;
                    isButtonEnabled = true;
                    buttonText = getTranslatedText("edit");
                    _focusNode.requestFocus();
                  });
          },
          child: RichText(
            text: TextSpan(
              text: getTranslatedText("edit_qq_cs"),
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
        ),
      );

  _getUserProfile() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      var _qq = _vm.userProfile.qq;
      setState(() {
        if (_qq != null) {
          if (_qq.isNotEmpty) {
            _qqController.text = _qq;
            buttonText = getTranslatedText("verified");
            isButtonEnabled = false;
            isTextFieldEnabled = false;
          }
        } else {
          buttonText = getTranslatedText("done");
          isTextFieldEnabled = true;
        }
      });
    });
  }

  _onTextChange() {
    if (_qqController.text.isNotEmpty) {
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
    if (!validate.validateQQ(_qqController.text)) {
      setState(() {
        CustomToast.show(getTranslatedText("enter_qq_error_message"));
      });
    } else {
      ProgressDialog.show(context, _vm.brandLogoUrl);
      _vm.setQQAccount(_qqController.text);
    }
  }

  _handleApiState() {
    handleApiState(_vm.setQQApiState, onSuccess: () async {
      await _getUserProfile();
      CustomToast.show(getTranslatedText("success"));
    });
  }
}
