import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:api/data/provider/input_validation_provider.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/ui/login/login_password_text_form_field.dart';
import 'package:tgp_flutter2/ui/login/login_text_form_field.dart';
import 'package:tgp_flutter2/ui/login/login_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class RegisterContent extends StatefulWidget {
  final ValueChanged<dynamic>? onSubmitUsernameAndPassword;

  RegisterContent({
    this.onSubmitUsernameAndPassword,
  });

  @override
  _RegisterContentState createState() => _RegisterContentState();
}

class _RegisterContentState extends BaseState<RegisterContent> {
  bool _obscurePassword = true, _obscureConfirmPassword = true;
  var username = TextEditingController(),
      password = TextEditingController(),
      confirmPassword = TextEditingController(),
      pay = TextEditingController(),
      confirmPay = TextEditingController(),
      invitationCode = TextEditingController(),
      phone = TextEditingController();
  InputValidationProvider validate = new InputValidationProvider();
  LoginViewModel _vm = LoginViewModel();

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<LoginViewModel>(
      model: _vm,
      builder: (ctx, vm, _) {
        _handleApiState();
        return Container(
          child: Column(
            children: [
              _buildUsernameTextFormField(),
              _buildPasswordTextFormField(),
              _buildConfirmPasswordTextFormField(),
              //_buildPayPasswordTextFormField(),
              _buildPromotionCodeTextFormField(),
              _buildRegisterButton()
            ],
          ),
        );
      },
    );
  }

  _buildUsernameTextFormField() => LoginTextFormField(
        icon: SvgPicture.asset(
          "images/login/ic_login_username.svg",
          height: 20.auto,
        ),
        hintText: getTranslatedText("signup_username_hint"),
        //onChanged: (value) => null,
        //onFieldSubmitted: (value) => null,
        controller: username,
        width: context.screenWidth,
        textInputType: TextInputType.text,
        textInputAction: TextInputAction.next,
      );

  _buildPasswordTextFormField() => Container(
        margin: EdgeInsets.only(top: 10.auto),
        child: LoginPasswordTextFormField(
          icon: SvgPicture.asset(
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
          icon: SvgPicture.asset(
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
          textInputType: TextInputType.text,
          textInputAction: TextInputAction.next,
        ),
      );

  _buildPromotionCodeTextFormField() => Visibility(
    visible: !(_vm.brandLogo?.hasInvitationCode ?? false),
    child: Container(
      margin: EdgeInsets.only(top: 10.auto),
      child: LoginTextFormField(
        icon: SvgPicture.asset(
          "images/login/ic_login_promotion.svg",
          height: 20.auto,
        ),
        hintText: getTranslatedText("signup_promotion_code_hint"),
        onChanged: (value) => null,
        onFieldSubmitted: (value) => _register(),
        controller: invitationCode,
        width: context.screenWidth,
        textInputType: TextInputType.text,
        textInputAction: TextInputAction.done,
      ),
    ),
  );

  _buildRegisterButton() => Container(
        margin: EdgeInsets.only(top: 70.auto, bottom: 10.auto),
        child: ColorButton(
          title: getTranslatedText("register"),
          onClick: () {
            _register();
          },
          isEnabled: true,
        ),
      );

  _register() {
    if (!validate.validateUsernameLength(username.text) || !validate.validateUsernamePassword(username.text)) {
      setState(() {
        CustomToast.show(getTranslatedText("enter_username_error_message"));
      });
    } else if (!validate.validatePasswordLength(password.text) || !validate.validateUsernamePassword(password.text)) {
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
    } else {
      ProgressDialog.show(context, _vm.brandLogo.mobileUrl);
      _checkUsername();
    }
  }

  _checkUsername() async {
    _vm.checkUsername(username.text);
  }

  _handleApiState() {
    handleApiState(_vm.registerApiState, onSuccess: () {
      if (EnvironmentConfig.appTitleName == "HKJP" || EnvironmentConfig.isShowSmsVerification)
        widget.onSubmitUsernameAndPassword!([username.text, password.text]);
      else
        _navigateToHome();
    });
    handleApiState(_vm.checkUsernameApiState, isRequireResult: true, onSuccess: (result) {
      if (result.isExist) {
        CustomToast.show(getTranslatedText("username_exist"));
      } else {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          ProgressDialog.show(context, _vm.brandLogo.mobileUrl);
          _vm.register(username.text, password.text, confirmPassword.text, invitationCode.text);
        });
      }
    });
  }

  _navigateToHome() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(RoutePath.home);
    });
  }
}
