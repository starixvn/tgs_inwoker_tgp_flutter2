import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:tgp_flutter2/custom/custom_text_form_field.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

import 'card_view_model.dart';

class CardVerifyRealName extends StatefulWidget {
  @override
  _CardVerifyRealNameState createState() => _CardVerifyRealNameState();
}

class _CardVerifyRealNameState extends BaseState<CardVerifyRealName> {
  var _vm = CardViewModel();
  var isButtonEnabled = false;
  var _controller = TextEditingController();

  @override
  void initState() {
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
                          /*_vm.mainAccountBalance == null ? "-" : "¥ ${Format()
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
                  padding: EdgeInsets.only(
                    left: 10.auto,
                    right: 10.auto,
                    top: 5.auto,
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: ListView(
                    children: [
                      CustomTextFormField(
                        title: "真实姓名",
                        hintText: "请输入您的名字",
                        onChanged: (value) => _onTextChange(value),
                        onFieldSubmitted: (value) => _onTextChange(value),
                        controller: _controller,
                        focusNode: null,
                        width: context.screenWidth - 70.auto,
                        textInputType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                      ),
                      _getHintText(),
                      ColorButton(
                        title: "下一步",
                        onClick: () {
                          _onShowDialog();
                        },
                        isEnabled: isButtonEnabled,
                        color: CustomColor.theme_button_color,
                        radius: 9.6,
                      ),
                      _getReminder()
                    ],
                  ),
                )),
          );
        });
  }

  _getHintText() => Container(
        margin: EdgeInsets.only(top: 5.auto, bottom: 50.auto),
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
                "务必阅读一下重要提醒",
                style: TextStyle(fontSize: 9.auto, color: Colors.red),
              ),
            )
          ],
        ),
      );

  _getReminder() => Wrap(
        children: [
          Container(
            margin: EdgeInsets.only(top: 8.auto, left: 15.auto, right: 15.auto),
            child: Text(
              "重要提醒",
              style: TextStyle(color: Colors.grey, fontSize: 12.auto),
            ),
          ),
          _getReminderText("1.", "您输入的姓名将作为您提款时唯一认定的提款卡姓名，若此处填写姓名与您将要使用的提款银行卡姓名不一致，将无法提款。"),
          _getReminderText("2.", "您输入的姓名将作为实名认证时唯一认定的姓名，且实名认证影响到多种红利领取，请您务必填写正确姓名。"),
          _getReminderText("3.", "姓名一旦填写提交后不可随意修改，若不小心填错必须修改，请联系“线上客服”协助。"),
        ],
      );

  _getReminderText(String number, String text) => Container(
      margin: EdgeInsets.only(top: 8.auto, left: 15.auto, right: 15.auto),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              number,
              style: TextStyle(color: Colors.grey, fontSize: 12.auto),
            ),
          ),
          Expanded(
            flex: 25,
            child: Text(
              text,
              style: TextStyle(color: Colors.grey, fontSize: 12.auto),
            ),
          ),
        ],
      ));

  _onTextChange(String name) {
    if (_controller.text.isNotEmpty) {
      setState(() {
        isButtonEnabled = true;
      });
    } else {
      setState(() {
        isButtonEnabled = false;
      });
    }
  }

  _onShowDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        description: "请再次确认真实姓名是否正确？ \n" + "真实姓名将用于提款的姓名验证，若姓名填写错误将无法进行提款。",
        buttonText1: "确认",
        buttonText2: "取消",
        onClick: () => _editSurname(),
        onClick2: (){
          Navigator.pop(context);
        },
      ),
    );
  }

  _editSurname() {
    /* ProgressDialog.show(context);
    _vm.editSurname(_controller.text);
    if(_vm.editSurnameApiState.isSuccess){
       ProgressDialog.hide();
      _vm.resetApiState(isEditSurnameApiState: true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(_vm.userProfile.memberSafePassword.isEmpty){
          Navigator.of(context).pushReplacementNamed('/card_verify_withdraw_password');
          Navigator.of(context).popAndPushNamed("/card_verify_withdraw_password");
        }else{
          Navigator.pop(context);
        }
      });
    }*/
  }

  _handleApiState() {
    /*if (_vm.editSurnameApiState == null) {
      return;
    }
    if ((_vm.editSurnameApiState?.isError ?? false)) {
      CustomToast.show(_vm.editSurnameApiState.error);
       ProgressDialog.hide();
      FocusScope.of(context).requestFocus(FocusNode());
      _vm.resetApiState(isEditSurnameApiState: true);
    }*/
  }
}
