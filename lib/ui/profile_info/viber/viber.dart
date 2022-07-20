import 'package:api/data/provider/input_validation_provider.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/custom_text_form_field.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/profile_info/viber/viber_view_model.dart';

class Viber extends StatefulWidget {
  @override
  _ViberState createState() => _ViberState();
}

class _ViberState extends BaseState<Viber> {
  var _vm = ViberViewModel();
  TextEditingController _viberController = TextEditingController();
  var isButtonEnabled = false, isTextFieldEnabled = false;
  var buttonText;
  InputValidationProvider validate = new InputValidationProvider();
  var _focusNode = FocusNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getUserProfile();
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<ViberViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return CustomScaffold(appBar: CustomAppBar(
                title: getTranslatedText("viber"),
                onPop: () => Navigator.pop(context, true),
              ),
              body: Container(
                  child:
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
        title: getTranslatedText("viber"),
        hintText: getTranslatedText("viber_hint"),
        onChanged: (value) => _onTextChange(),
        onFieldSubmitted: (value) {},
        controller: _viberController,
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
        visible: _vm.userProfile.viber != null,
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
              text: getTranslatedText("edit_viber_cs"),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var _viber = _vm.userProfile.viber;
      setState(() {
        if (_viber != null) {
          if (_viber.isNotEmpty) {
            _viberController.text = _viber;
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
    if (_viberController.text.isNotEmpty) {
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
    ProgressDialog.show(context, _vm.brandLogoUrl);
    _vm.setViberId(_viberController.text);
  }

  _handleApiState() {
    handleApiState(_vm.setViberIdApiState, onSuccess: () async {
      await _getUserProfile();
      CustomToast.show(getTranslatedText("success"));
    });
  }
}
