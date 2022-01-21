import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:api/entity/language.dart';
import 'package:api/localizations/language_provider.dart';
import 'package:tgp_flutter2/main.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/login/login_password_text_form_field.dart';
import 'package:tgp_flutter2/ui/login/login_text_form_field.dart';
import 'package:tgp_flutter2/ui/login/login_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class LoginContent extends StatefulWidget {
  final child;
  final LoginViewModel vm;

  LoginContent({this.child, required this.vm}) ;

  @override
  _LoginContentState createState() => _LoginContentState();
}

class _LoginContentState extends BaseState<LoginContent> {
  bool _obscurePassword = true;
  bool _isRememberMe = true;
  var username = TextEditingController();
  var password = TextEditingController();
  var _vm ;

  @override
  void initState() {
    _vm = widget.vm;
    super.initState();
    initData();
  }

  initData() async {
    username.text = await _vm.getUsername();
    password.text = await _vm.getPassword();
  }

  void _changeLanguage(Language language) async {
    Locale? _locale = await LanguageProvider.getSingleton().setLocale(language);
    MyApp.setLocale(context, _locale!);
    await _vm.getApiError();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<LoginViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return Column(
            children: [
              _buildUsernameTextFormField(),
              _buildPasswordTextFormField(),
              _buildRememberAndForgotPassword(),
              _buildLoginButton(),
              _buildLoginLaterButton(),
              _buildChangeLanguageText()
            ],
          );
        });
  }

  _buildUsernameTextFormField() => Container(
        margin: EdgeInsets.only(bottom: 10.auto),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.8)
        ),
        child: LoginTextFormField(
          icon: SvgPicture.asset(
            "images/login/ic_login_username.svg",
            matchTextDirection: true,
            height: 20.auto,
          ),
          hintText: getTranslatedText("enter_username_hint"),
          //onChanged: (value) => null,
          //onFieldSubmitted: (value) => null,
          controller: username,
          width: context.screenWidth,
         // textInputType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.next,
        ),
      );

  _buildPasswordTextFormField() => LoginPasswordTextFormField(
        icon: SvgPicture.asset(
          "images/login/ic_login_password.svg",
          height: 20.auto,
        ),
        hintText: getTranslatedText("enter_password_hint"),
        onChanged: (value) => null,
        onFieldSubmitted: (value) => _login(),
        controller: password,
        width: context.screenWidth,
        textInputType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.done,
        onShowPassword: () {
          setState(() => this._obscurePassword = !this._obscurePassword);
        },
        obscurePassword: _obscurePassword,
      );

  _buildRememberAndForgotPassword() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_buildCheckBox(), _buildForgotPassword()],
      );

  _buildForgotPassword() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(RoutePath.forgotPassword);
            },
            child: Text(
              getTranslatedText("forgot_password_with_question_mark"),
              style: TextStyle(color: CustomColor.theme_text_black_white_color, decoration: TextDecoration.underline, fontSize: 12.auto),
            ),
          )
        ],
      );

  _buildCheckBox() => Row(
        children: [
          Checkbox(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            value: this._isRememberMe,
            checkColor: Colors.white,
            activeColor: Colors.black,
            onChanged: (val) => this.setState(() {
              this._isRememberMe = !this._isRememberMe;
              if (!_isRememberMe) _vm.removePrefs();
            }),
          ),
          Text(
            getTranslatedText("rmb_password"),
            style: TextStyle(color: CustomColor.theme_text_black_white_color, fontSize: 12.auto),
          ),
        ],
      );

  _buildLoginButton() => Container(
        margin: EdgeInsets.only(top: 50.auto, bottom: 10.auto),
        child: ColorButton(
          title: getTranslatedText("login"),
          onClick: () => _login(),
          isEnabled: true,
          padding: 0,
        ),
      );

  _buildLoginLaterButton() => ColorButton(
        title: getTranslatedText("login_later"),
        onClick: () => _navigateToHome(),
        isEnabled: true,
        color: CustomColor.theme_grey_button_color,
      );

  _buildChangeLanguageText() {
    var list = LanguageProvider.getSingleton().list;
    var deviceLanguage = list.singleWhere((e) => e.locale == Localizations.localeOf(context));
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Container(
        margin: EdgeInsets.only(top: 10.auto),
        child: IntrinsicHeight(
            child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(list.length, (index) {
            return Row(
              children: [
                InkWell(
                    onTap: () {
                      _changeLanguage(list[index]);
                    },
                    child: Text(
                      list[index].name,
                      style:
                          TextStyle(color: deviceLanguage == list[index] ? CustomColor.theme_button_color : CustomColor.theme_text_black_white_color),
                    )),
                Visibility(
                  visible: index+1 != list.length,
                  child: VerticalDivider(
                    color: CustomColor.theme_text_black_white_color,
                  ),
                )
              ],
            );
          }),
        )),
      ),
    );
  }

  _login() {
    if (username.text == "") {
      setState(() {
        CustomToast.show(getTranslatedText("enter_username_hint"));
      });
    } else if (password.text == "") {
      setState(() {
        CustomToast.show(getTranslatedText("enter_password_hint"));
      });
    } else {
      ProgressDialog.show(context, _vm.brandLogo.mobileUrl);
      _vm.login(username.text, password.text, _isRememberMe);
    }
  }

  _navigateToHome() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("login_later", true);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => MyHomePage(
                    isFirstRun: false,
                  )),
          (Route<dynamic> route) => false);
    });
  }

  _handleApiState() {
    handleApiState(_vm.loginApiState, isCheckSessionExpired: false, onSuccess: () {
      _navigateToHome();
    });
  }
}
