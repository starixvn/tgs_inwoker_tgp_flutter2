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
import 'package:tgp_flutter2/ui/profile_info/real_name/real_name_verification_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class RealNameVerification extends StatefulWidget {
  @override
  _RealNameVerificationState createState() => _RealNameVerificationState();
}

class _RealNameVerificationState extends BaseState<RealNameVerification> {
  var _vm = RealNameVerificationViewModel();
  TextEditingController _realNameController = TextEditingController(), _icNoController = TextEditingController();
  var isButtonEnabled = false, isTextFieldEnabled = false, isShowICNo;
  var buttonText;

  @override
  void initState() {
    _getUserProfile();
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<RealNameVerificationViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: CustomColor.theme_bg_color,
              appBar: CustomAppBar(
                title: getTranslatedText("ic_no"),
              ),
              body: Container(
                margin: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 20.auto),
                child: Column(
                  children: [
                    _buildTextFormField("realname", "enter_realname_hint", _realNameController, false),
                    Visibility(
                      visible: _vm.userProfile.realname == null,
                      child: _buildTextFormField("ic_no", "enter_ic_no_hint", _icNoController, true),
                    ),
                    _buildButton(),
                    //_buildFooterText()
                  ],
                ),
              ));
        });
  }

  _buildTextFormField(String title, String hint, TextEditingController controller, bool isLast) => CustomTextFormField(
        title: getTranslatedText(title),
        hintText: getTranslatedText(hint),
        onChanged: (value) => _onTextChange(),
        onFieldSubmitted: (value) {},
        controller: controller,
        focusNode: null,
        width: context.screenWidth - 40.auto,
        textInputType: TextInputType.text,
        textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
        enabled: isTextFieldEnabled,
      );

  _buildButton() => Container(
      width: context.screenWidth,
      margin: EdgeInsets.all(10.auto),
      child: ColorButton(
        title: buttonText ?? "Done",
        onClick: () {
          _onClick();
        },
        isEnabled: isButtonEnabled,
        color: CustomColor.theme_button_color,
        radius: 9.6,
      ));

  _buildFooterText() => Container(
        alignment: Alignment.center,
        child: InkWell(
          onTap: () => Navigator.of(context).pushNamed("/customer_service"),
          child: Wrap(
            children: [
              Text(
                getTranslatedText("edit_ic_no_cs"),
                style: TextStyle(fontSize: 12.auto, color: CustomColor.theme_title_text_color),
              ),
              Text(
                getTranslatedText("online_cs"),
                style: TextStyle(fontSize: 12.auto, color: CustomColor.theme_button_color),
              )
            ],
          ),
        ),
      );

  _getUserProfile() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      var _realname = _vm.userProfile.realname;
      setState(() {
        if (_realname != null) {
          if (_realname.isNotEmpty) {
            _realNameController.text = _realname;
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
    setState(() {
      if (_realNameController.text.isNotEmpty && _icNoController.text.isNotEmpty) {
        isButtonEnabled = true;
      } else {
        isButtonEnabled = false;
      }
    });
  }

  _onClick() async {
    ProgressDialog.show(context, _vm.brandLogoUrl);
    _vm.idVerify(_realNameController.text, _icNoController.text);
  }

  _handleApiState() {
    handleApiState(_vm.idVerifyApiState, onSuccess: () {
      CustomToast.show(getTranslatedText("success"));
      _getUserProfile();
    });
  }
}
