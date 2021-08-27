import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:tgp_flutter2/custom/custom_text_form_field.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:api/data/provider/input_validation_provider.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

import 'card_view_model.dart';

class CardVerifyWithdrawPassword extends StatefulWidget {
  @override
  _CardVerifyWithdrawPasswordState createState() => _CardVerifyWithdrawPasswordState();
}

class _CardVerifyWithdrawPasswordState extends BaseState<CardVerifyWithdrawPassword> {
  var _vm = CardViewModel();
  var isButtonEnabled = false;
  var _passwordController = TextEditingController(), _confirmPasswordController = TextEditingController();
  InputValidationProvider validate = new InputValidationProvider();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDialog();
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<CardViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return ScrollConfiguration(
            behavior: MyBehavior(),
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.white,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  title: Text(
                    "管理银行卡",
                    style: TextStyle(fontSize: 20.auto),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(40),
                    child: Container(
                        margin: EdgeInsets.symmetric(vertical: 20.auto),
                        alignment: Alignment.center,
                        child: Text(
                          "¥ 0.00",
                          /* _vm.mainAccountBalance == null ? "-" : "¥ ${Format()
                              .currencyWithDecimalFormat(
                              _vm.mainAccountBalance)}",*/
                          style: TextStyle(fontSize: 16.auto, color: CustomColor.theme_text_color2),
                        )),
                  ),
                  flexibleSpace: Image(
                    image: AssetImage("images/home_user_info_bottom_bar_background.png"),
                    fit: BoxFit.scaleDown,
                  ),
                  backgroundColor: Colors.transparent,
                ),
                body: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.auto),
                  child: ListView(
                    children: [
                      Container(
                          margin: EdgeInsets.only(left: 20.auto, bottom: 10.auto),
                          alignment: Alignment.topLeft,
                          child: Text(
                            "提款密码设置",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          )),
                      CustomTextFormField(
                        title: "提款密码",
                        hintText: "请输入提款密码",
                        onChanged: (value) => _onTextChange(),
                        onFieldSubmitted: (value) => _onTextChange(),
                        controller: _passwordController,
                        focusNode: null,
                        width: context.screenWidth - 70.auto,
                        textInputType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.auto),
                        child: CustomTextFormField(
                          title: "再次输入提款密码",
                          hintText: "请再次输入提款密码",
                          onChanged: (value) => _onTextChange(),
                          onFieldSubmitted: (value) => _onTextChange(),
                          controller: _confirmPasswordController,
                          focusNode: null,
                          width: context.screenWidth - 70.auto,
                          textInputType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      _getHintText(),
                      ColorButton(
                        title: "下一步",
                        onClick: () {
                          _checkValidation();
                        },
                        isEnabled: isButtonEnabled,
                        color: CustomColor.theme_button_color,
                        radius: 9.6,
                      ),
                    ],
                  ),
                )),
          );
        });
  }

  _getHintText() => Container(
        margin: EdgeInsets.only(top: 2.auto, bottom: 20.auto),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "images/card/ic_hint.png",
              width: 15.auto,
              height: 15.auto,
            ),
            Container(
              margin: EdgeInsets.only(left: 5.auto),
              child: Text(
                "当你提款时，必须输入您的提款密码，请务必牢记！",
                style: TextStyle(fontSize: 9.auto, color: Colors.red),
              ),
            )
          ],
        ),
      );

  _onTextChange() {
    if (_passwordController.text.isNotEmpty && _confirmPasswordController.text.isNotEmpty) {
      setState(() {
        isButtonEnabled = true;
      });
    } else {
      setState(() {
        isButtonEnabled = false;
      });
    }
  }

  _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: "尊敬的用户",
        description: "因风控原因，进行本项操作以前，您需先创建提款密码。",
        buttonText1: "确认",
        onClick: () => Navigator.pop(context),
        onClick2: (){
          Navigator.pop(context);
        },
      ),
    );
  }

  _checkValidation() {
    if (!validate.validatePasswordLength(_passwordController.text)) {
      setState(() {
        CustomToast.show(getTranslatedText("enter_password_error_msg"));
      });
    } else if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        CustomToast.show(getTranslatedText("confirm_password_error_msg"));
      });
    } else {
      _updateWithdrawPassword();
    }
  }

  _updateWithdrawPassword() {
    /* ProgressDialog.show(context);
    _vm.updateWithdrawPassword(_passwordController.text);
    if(_vm.updateWithdrawPasswordApiState.isSuccess){
       ProgressDialog.hide();
      _vm.resetApiState(isUpdateWithdrawPasswordApiState: true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    }*/
  }

  _handleApiState() {
    /*if (_vm.updateWithdrawPasswordApiState == null) {
      return;
    }
    if ((_vm.updateWithdrawPasswordApiState?.isError ?? false)) {
      CustomToast.show(_vm.updateWithdrawPasswordApiState.error);
       ProgressDialog.hide();
      FocusScope.of(context).requestFocus(FocusNode());
      _vm.resetApiState(isUpdateWithdrawPasswordApiState: true);
    }*/
  }
}
