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
import 'package:tgp_flutter2/ui/profile_info/wechat/wechat_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class Wechat extends StatefulWidget {
  @override
  _WechatState createState() => _WechatState();
}

class _WechatState extends BaseState<Wechat> {
  var _vm = WechatViewModel();
  TextEditingController _wechatController = TextEditingController();
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
    return ProviderWidget<WechatViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: CustomColor.theme_bg_color,
              appBar: CustomAppBar(
                title: getTranslatedText("wechat_no"),
              ),
              body: Container(
                margin: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 20.auto),
                child: Column(
                  children: [
                    _buildTextFormField(),
                    _buildButton(),
                    _buildFooterText(),
                  ],
                ),
              ));
        });
  }

  _buildTextFormField() => CustomTextFormField(
        title: getTranslatedText("wechat_no"),
        hintText: getTranslatedText("wechat_no_hint"),
        onChanged: (value) => _onTextChange(),
        onFieldSubmitted: (value) {},
        controller: _wechatController,
        focusNode: _focusNode,
        width: context.screenWidth - 40.auto,
        textInputType: TextInputType.text,
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

  _buildFooterText() => InkWell(
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
        child: Wrap(
          children: [
            Text(
              getTranslatedText("edit_wechat_cs"),
              style: TextStyle(fontSize: 12.auto),
            ),
            Text(
              (_vm.config?.changesNotAllowed ?? false) ? getTranslatedText("online_cs") : getTranslatedText("here"),
              style: TextStyle(
                  decoration: TextDecoration.underline, color: CustomColor.theme_button_color, fontSize: 12.auto),
            ),
          ],
        ),
      );

  _getUserProfile() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      var wechat = _vm.userProfile.wechat;
      setState(() {
        if (wechat != null) {
          if (wechat.isNotEmpty) {
            _wechatController.text = wechat;
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
    if (_wechatController.text.isNotEmpty) {
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
    if (!validate.validateWechat(_wechatController.text)) {
      setState(() {
        CustomToast.show(getTranslatedText("enter_wechat_error_message"));
      });
    } else {
      ProgressDialog.show(context, _vm.brandLogoUrl);
      _vm.setWechatAccount(_wechatController.text);
    }
  }

  _handleApiState() {
    handleApiState(_vm.setWechatApiState, onSuccess: () {
      CustomToast.show(getTranslatedText("success"));
      _getUserProfile();
    });
  }
}
