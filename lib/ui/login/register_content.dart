import 'package:api/NotificationServices/NotificationServiceName.dart';
import 'package:api/NotificationServices/notification_center.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:api/data/provider/input_validation_provider.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/main.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/BaseNavigate/BottomNavigationController.dart';
import 'package:tgp_flutter2/ui/card/add_card.dart';
import 'package:tgp_flutter2/ui/login/CustomSky8/CustomCheckbox.dart';
import 'package:tgp_flutter2/ui/login/login_password_text_form_field.dart';
import 'package:tgp_flutter2/ui/login/login_text_form_field.dart';
import 'package:tgp_flutter2/ui/login/login_view_model.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/login/phone_re_verification/login_otp_text_form_field.dart';
import 'package:tgp_flutter2/ui/login/phone_re_verification/login_phone_text_form_field.dart';
import 'package:tgp_flutter2/ui/login/phone_re_verification/phone_re_verification.dart';

class RegisterContent extends StatefulWidget {
  // final ValueChanged<dynamic>? onSubmitUsernameAndPassword;
  final LoginViewModel vm;

  RegisterContent({required this.vm});

  @override
  _RegisterContentState createState() => _RegisterContentState();
}

class _RegisterContentState extends BaseState<RegisterContent> with AutomaticKeepAliveClientMixin {
  bool _obscurePassword = true, _obscureConfirmPassword = true;
  var username = TextEditingController(),
      password = TextEditingController(),
      confirmPassword = TextEditingController(),
      pay = TextEditingController(),
      confirmPay = TextEditingController(),
      invitationCode = TextEditingController(),
      phone = TextEditingController(),
      email = TextEditingController();
  InputValidationProvider validate = new InputValidationProvider();
  var _vm;
  bool isOtpEnabled = false, isOtpCountdown = false, _isRegisterSuccess = false;

  bool _isTermsChecked = true;
  String? agentPlayer = 'player';
  List agentPlayerList = ['agent', 'player'];

  String? display;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _vm = widget.vm;
    display = _vm.config?.phonePrefix ?? "+852";
    _getAffiliateStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ProviderWidget<LoginViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return _isShowSmsVerification() && _isRegisterSuccess
              ? PhoneReVerification(vm: vm)
              : Container(
                  child: Column(
                    children: [
                      _buildUsernameTextFormField(),
                      _buildPasswordTextFormField(),
                      _buildConfirmPasswordTextFormField(),
                      //_buildPayPasswordTextFormField(),
                      if (_registerShowPhone()) _buildPhoneTextFormField(),
                      if (_registerShowEmail()) _buildEmailTextFormField(),
                      _buildPromotionCodeTextFormField(),
                      _buildRegisterTermsText(),
                      _buildRegisterButton(),
                      _buildCsButton()
                    ],
                  ),
                );
        });
  }

  _buildUsernameTextFormField() => LoginTextFormField(
        icon: EnvironmentConfig.template_version == 11 || EnvironmentConfig.template_version == 14
            ? Image.asset(
                "images/login/t11/ic_login_username.png",
                width: 20.auto,
                height: 20.auto,
                color: EnvironmentConfig.template_version == 11 ? Colors.white : CustomColor.theme_bg_color,
              )
            : SvgPicture.asset(
                "images/login/ic_login_username.svg",
                height: 20.auto,
              ),
        hintText: getTranslatedText("signup_username_hint"),
        //onChanged: (value) => null,
        //onFieldSubmitted: (value) => null,
        controller: username,
        width: context.screenWidth,
        textInputType: TextInputType.name,
        textInputAction: TextInputAction.next,
      );

  _buildPasswordTextFormField() => Container(
        margin: EdgeInsets.only(top: 10.auto),
        child: LoginPasswordTextFormField(
          icon: EnvironmentConfig.template_version == 11 || EnvironmentConfig.template_version == 14
              ? Image.asset(
                  "images/login/t11/ic_login_password.png",
                  width: 20.auto,
                  height: 20.auto,
                  color: EnvironmentConfig.template_version == 11 ? Colors.white : CustomColor.theme_bg_color,
                )
              : SvgPicture.asset(
                  "images/login/ic_login_password.svg",
                  height: 20.auto,
                ),
          hintText: getTranslatedText("signup_password_hint"),
          onChanged: (value) => null,
          onFieldSubmitted: (value) => null,
          controller: password,
          width: context.screenWidth,
          textInputType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.next,
          onShowPassword: () {
            setState(() => this._obscurePassword = !this._obscurePassword);
          },
          obscurePassword: _obscurePassword,
        ),
      );

  _buildConfirmPasswordTextFormField() => Container(
        margin: EdgeInsets.only(top: 10.auto),
        child: LoginPasswordTextFormField(
          icon: EnvironmentConfig.template_version == 11 || EnvironmentConfig.template_version == 14
              ? Image.asset(
                  "images/login/t11/ic_confirm_password.png",
                  width: 20.auto,
                  height: 20.auto,
                  color: EnvironmentConfig.template_version == 11 ? Colors.white : CustomColor.theme_bg_color,
                )
              : SvgPicture.asset(
                  "images/login/ic_login_password.svg",
                  height: 20.auto,
                ),
          hintText: getTranslatedText("confirm_password"),
          onChanged: (value) => null,
          onFieldSubmitted: (value) => null,
          controller: confirmPassword,
          width: context.screenWidth,
          textInputType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.next,
          onShowPassword: () {
            setState(() => this._obscureConfirmPassword = !this._obscureConfirmPassword);
          },
          obscurePassword: _obscureConfirmPassword,
        ),
      );

  _buildPayPasswordTextFormField() => Container(
        margin: EdgeInsets.only(top: 10.auto),
        child: LoginTextFormField(
          icon: SvgPicture.asset(
            "images/login/ic_login_pig.svg",
            height: 20.auto,
          ),
          hintText: getTranslatedText("signup_pay_password_hint"),
          //onChanged: (value) => null,
          //onFieldSubmitted: (value) => null,
          controller: pay,
          width: context.screenWidth,
          textInputType: TextInputType.name,
          textInputAction: TextInputAction.next,
        ),
      );

  _buildPhoneTextFormField() => Container(
        margin: EdgeInsets.only(top: 10.auto),
        child: LoginPhoneTextFormField(
          onChanged: (value) {},
          onFieldSubmitted: (value) {},
          controller: phone,
          width: context.screenWidth - 70.auto,
          textInputAction: TextInputAction.next,
          enabled: true,
          onAreaCodeClicked: (value) => _onAreaCodeClicked(value),
          displayedAreaCode: display,
          maxLength: _vm.config?.maxPhoneLength ?? 10,
        ),
      );

  _buildEmailTextFormField() => Container(
        margin: EdgeInsets.only(top: 10.auto),
        child: LoginTextFormField(
          icon: SvgPicture.asset(
            "images/login/login_email.svg",
            height: 20.auto,
          ),
          hintText: getTranslatedText("email_hint"),
          //onChanged: (value) => null,
          //onFieldSubmitted: (value) => null,
          controller: email,
          width: context.screenWidth,
          textInputType: TextInputType.name,
          textInputAction: TextInputAction.next,
        ),
      );

  _onAreaCodeClicked(String area) {
    setState(() {
      display = area;
      Navigator.of(context).pop();
    });
  }

  _buildPromotionCodeTextFormField() => Visibility(
        visible: !(_vm.brandLogo?.hasInvitationCode ?? false),
        child: Container(
          margin: EdgeInsets.only(top: 10.auto),
          child: LoginTextFormField(
              icon: EnvironmentConfig.template_version == 11
                  ? Container()
                  : SvgPicture.asset(
                      "images/login/ic_login_promotion.svg",
                      height: 20.auto,
                    ),
              hintText: getTranslatedText("signup_promotion_code_hint"),
              onChanged: (value) => null,
              onFieldSubmitted: (value) => _register(),
              controller: invitationCode,
              width: context.screenWidth,
              textInputType: TextInputType.name,
              textInputAction: TextInputAction.done,
              dropDown: Visibility(
                visible: (_vm.haveAffiliate ?? false),
                child: Container(
                  color: EnvironmentConfig.template_version == 14 ? Colors.white : CustomColor.very_light_pink_two,
                  padding: EdgeInsets.only(
                    left: 5.auto,
                  ),
                  margin: EdgeInsets.only(top: 8.auto, bottom: 8.auto),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      elevation: 0,
                      isExpanded: true,
                      icon: Icon(EnvironmentConfig.template_version == 14 ? Icons.keyboard_arrow_down_outlined : Icons.arrow_drop_down),
                      hint: Container(
                        child: AutoSizeText(
                          getTranslatedText(agentPlayer),
                          minFontSize: 2,
                          stepGranularity: 1,
                          maxLines: 1,
                        ),
                      ),
                      items: agentPlayerList.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(
                            getTranslatedText(value),
                            style: TextStyle(color: CustomColor.theme_title_text_color),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          agentPlayer = value.toString();
                        });
                      },
                      style: TextStyle(
                        color: CustomColor.theme_title_text_color,
                      ),
                    ),
                  ),
                ),
              )),
        ),
      );

  _buildRegisterButton() => Container(
        margin: EdgeInsets.only(top: 10.auto, bottom: 10.auto),
        child: ColorButton(
          title: getTranslatedText(_customFlowForIDR() ? "next" : "register"),
          onClick: () {
            _register();
          },
          isEnabled: _isTermsChecked,
        ),
      );

  _buildRegisterTermsText() => Container(
        margin: EdgeInsets.only(top: 10.auto),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: EnvironmentConfig.template_version == 14
                  ? CustomCheckbox(
                      activeBackgroundColor: Color(0xff9698af),
                      inactiveBackgroundColor: Colors.transparent,
                      activeIconColor: CustomColor.theme_bg_color,
                      inactiveIconColor: Color(0xff9698af),
                      borderColor: Color(0xff9698af),
                      iconSize: 15.0,
                      onChanged: () => onChangeCheckBox(),
                    )
                  : Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: this._isTermsChecked,
                      checkColor: Colors.white,
                      activeColor: Colors.black,
                      fillColor: MaterialStateProperty.all(CustomColor.theme_button_color),
                      onChanged: (val) => onChangeCheckBox(),
                    ),
            ),
            Expanded(
              flex: 9,
              child: Text(
                getTranslatedText("register_terms"),
                style: TextStyle(color: CustomColor.theme_text_black_white_color, fontSize: 12.auto),
              ),
            ),
          ],
        ),
      );

  _buildCsButton() => Container(
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SvgPicture.asset(
              "images/bottom_nav_bar/ic_cs.svg",
              matchTextDirection: true,
              height: 15.auto,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              getTranslatedText("online_chat"),
              style: TextStyle(
                color: Colors.white,
              ),
            )
          ],
        ),
      );

  onChangeCheckBox() => this.setState(() {
        this._isTermsChecked = !this._isTermsChecked;
      });

  _register() {
    if (!validate.validateUsernameLength(username.text) || !validate.validateUsernamePassword(username.text)) {
      setState(() {
        CustomToast.show(getTranslatedText("enter_username_error_message"));
      });
    } else if (!validate.validatePasswordLength(password.text)) {
      setState(() {
        CustomToast.show(getTranslatedText("enter_password_error_msg"));
      });
    } else if (password.text != confirmPassword.text) {
      setState(() {
        CustomToast.show(getTranslatedText("confirm_password_error_msg"));
      });
    } else if (pay.text != confirmPay.text) {
      setState(() {
        CustomToast.show(getTranslatedText("confirm_pay_error_msg"));
      });
    } else if (_registerShowPhone() && !validate.validatePhoneLength(phone.text)) {
      setState(() {
        CustomToast.show(getTranslatedText("phone_format_error_msg"));
      });
    } else if (_registerShowEmail() && !validate.validateEmail(email.text)) {
      setState(() {
        CustomToast.show(getTranslatedText("email_format_error_msg"));
      });
    } else {
      ProgressDialog.show(context, _vm.brandLogo.mobileUrl);
      _checkUsername();
    }
  }

  _checkUsername() async {
    _vm.checkUsername(username.text);
  }

  _registerShowPhone() => _vm.config?.registerShowPhone ?? false;

  _registerShowEmail() => _vm.config?.registerShowEmail ?? false;

  _customFlowForIDR() => _vm.config?.idrRegisterCustomFlow ?? false;

  _handleApiState() {
    handleApiState(_vm.loginApiState, onSuccess: () {
      if ((_vm.config?.navigateToAddCard ?? false))
        _navigateToAddCard();
      else
        _navigateToHome();
    });

    handleApiState(_vm.registerApiState, onSuccess: () {
      if (_vm.config?.smsVerification ?? false) {
        setState(() {
          _isRegisterSuccess = true;
        });
      } else {
        if (_registerShowPhone() || _registerShowEmail()) {
          _vm.idrLoginWithPhoneAndEmail(username.text, password.text, phone.text, display!, email.text);
        }
        /* else if (_registerShowPhone() && _registerShowEmail()) {
          _vm.loginWithPhoneAndEmail(username.text, password.text, phone.text, display!, email.text);
        }*/
        else {
          _vm.login(username.text, password.text, true);
        }
      }
    });
    handleApiState(_vm.checkUsernameApiState, isRequireResult: true, onSuccess: (result) {
      if (result.isExist) {
        CustomToast.show(getTranslatedText("username_exist"));
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ProgressDialog.show(context, _vm.brandLogo.mobileUrl);
          if (_registerShowPhone() || _registerShowEmail()) {
            _vm.idrRegister(
              username.text,
              password.text,
            );
          }
          /* else if (_registerShowPhone()) {
            //_vm.getReVerifyCode(username.text, password.text, display!, phone.text);
            _vm.getReVerifyCode(username, password, display!, phone, isIdrRegister: true);
          }*/
          else
            _vm.register(username.text, password.text, confirmPassword.text, invitationCode.text, agentPlayer == "agent");
        });
      }
    });

    handleApiState(_vm.phoneReVerifyApiState, onSuccess: () {});
    handleApiState(_vm.getAffiliateStatusState, onSuccess: () {});
  }

  _navigateToHome() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(RoutePath.myHome);
    });
  }

  _navigateToAddCard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationCenter().notify(NotificationServiceName().bottomNavigationIndex, data: 4);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BottomNavigationController(
                    // index: 4,
                  )));
      Navigator.push(context, MaterialPageRoute(builder: (context) => AddCard(isNavigateFromRegister: true)));
      //Navigator.pushNamed(context, RoutePath.addCard);
    });
  }

  _isShowSmsVerification() => (_vm.config?.smsVerification ?? false);

  _getAffiliateStatus() async {
    await _vm.getAffiliateStatus();
  }
}
