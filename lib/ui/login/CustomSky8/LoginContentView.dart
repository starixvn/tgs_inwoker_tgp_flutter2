import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:api/entity/language.dart';
import 'package:api/localizations/language_provider.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/main.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/login/login_password_text_form_field.dart';
import 'package:tgp_flutter2/ui/login/login_text_form_field.dart';
import 'package:tgp_flutter2/ui/login/login_view_model.dart';
import 'package:api/extension/screen_apis.dart';

import 'CustomCheckbox.dart';

class LoginContentView extends StatefulWidget {
  final child;
  final LoginViewModel vm;
  final VoidCallback onPressed;
  LoginContentView({this.child, required this.vm, required this.onPressed});

  @override
  _LoginContentViewState createState() => _LoginContentViewState();
}

class _LoginContentViewState extends BaseState<LoginContentView>
    with AutomaticKeepAliveClientMixin {
  bool _obscurePassword = true;
  bool _isRememberMe = false;
  var username = TextEditingController();
  var password = TextEditingController();
  var _vm;
  void onChanged() {
    // setState(() {
    _isRememberMe = !_isRememberMe;
    if (!_isRememberMe) _vm.removePrefs();
    // });
  }

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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ProviderWidget<LoginViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return Container(
              child: Row(
            children: [
              Expanded(
                  child: ListView(
                children: [
                  _titleView(),
                  _buildUsernameTextFormField(),
                  _buildPasswordTextFormField(),
                  _buildRememberAndForgotPassword(),
                  _buildLoginButton(),
                  _buildLoginLaterButton(),
                  _buildChangeLanguageText()
                ],
              )),
              _categoryButtonView()
            ],
          ));

          Column(
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

  _categoryButtonView() {
    var text =
        getTranslatedText('register_member').toString(); //"会员注册"; // : "会员登录";\
    var langCode = getCurrentLanguage().apiCode;
    var isChinese = (langCode == "zh-CN" || langCode == "zh-TW");
    return GestureDetector(
        onTap: () {
          widget.onPressed();
        },
        child: Container(
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.44),
                border: Border.all(
                  color: Colors.black.withOpacity(0.44),
                ),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            // color: isRegister ? Colors.blueAccent : Colors.cyanAccent,
            width: 37.5.auto,
            height: double.infinity,
            child: Align(
                alignment: Alignment.center,
                child: !isChinese
                    ? RotatedBox(
                        quarterTurns: 1,
                        child: Text(
                          text,
                          style: TextStyle(
                              fontSize: 14.auto,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ) //your text
                        )
                    : Wrap(
                        runSpacing: 30,
                        direction: Axis.vertical,
                        alignment: WrapAlignment.center,
                        children: text
                            .split("")
                            .map((string) => Text(string,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)))
                            .toList(),
                      ))));
  }

  _titleView() => Container(
      height: 60.auto,
      // margin: EdgeInsets.only(bottom: 5),
      child: Center(
          child: Text(getTranslatedText("login"),
              style: TextStyle(
                  fontSize: 18.auto,
                  color: Colors.white,
                  fontWeight: FontWeight.bold))));

  _buildUsernameTextFormField() => Container(
        margin: EdgeInsets.only(
            left: 10.auto,
            right: 10.auto,
            bottom: 8.auto,
            top: 10.auto), //EdgeInsets.all(10.auto),
        child: LoginTextFormField(
          icon: Image.asset(
            "images/login/Sky8/icon-user.png",
            width: 20.auto,
            height: 20.auto,
          ),
          hintText: getTranslatedText("enter_username_hint"),
          //onChanged: (value) => null,
          //onFieldSubmitted: (value) => null,
          controller: username,
          width: context.screenWidth,
          textInputType: TextInputType.name,
          textInputAction: TextInputAction.next,
        ),
      );

  _buildPasswordTextFormField() => Container(
      margin: EdgeInsets.only(left: 10.auto, right: 10.auto, bottom: 10.auto),
      child: LoginPasswordTextFormField(
        icon: Image.asset(
          "images/login/Sky8/icon-unlock.png",
          width: 20.auto,
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
      ));

  _buildRememberAndForgotPassword() => Container(
      margin: EdgeInsets.only(left: 5.auto, right: 15.auto),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_buildCheckBox(), _buildForgotPassword()],
      ));

  _buildForgotPassword() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(RoutePath.forgotPassword);
            },
            child: Text(
              getTranslatedText("forgot_password_with_question_mark")
                  .replaceAll('?', ''),
              style: TextStyle(
                  color:
                      Colors.white, //CustomColor.theme_text_black_white_color,
                  // decoration: TextDecoration.underline,
                  fontSize: 12.auto),
            ),
          )
        ],
      );

  _buildCheckBox() => Row(
        children: [
          CustomCheckbox(
              checkColor: Colors.white,
              iconSize: 15.0,
              onChanged: () => onChanged()),

          // Checkbox(
          //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //   value: this._isRememberMe,
          //   checkColor: Colors.white,
          //   activeColor: Colors.black,
          //   fillColor:
          //       MaterialStateProperty.all(Colors.transparent),
          //   shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(
          //           20.auto)),
          //   side: MaterialStateBorderSide.resolveWith((states) => BorderSide(width: 1.0, color: Colors.white)),
          //   // visualDensity: const VisualDensity(horizontal: 1.0, vertical: 1.0),
          //   onChanged: (val) => this.setState(() {
          //     this._isRememberMe = !this._isRememberMe;
          //     if (!_isRememberMe) _vm.removePrefs();
          //   }),
          // ),
          Text(
            getTranslatedText("rmb_password"),
            style: TextStyle(
                color: Colors.white, //CustomColor.theme_text_black_white_color,
                fontSize: 12.auto),
          ),
        ],
      );

  _buildLoginButton() => Container(
        margin: EdgeInsets.only(
            top: 50.auto, bottom: 0.auto, left: 25.auto, right: 25.auto),
        child: ColorButton(
          title: getTranslatedText("login"),
          height: 37.5.auto,
          radius: 20,
          onClick: () => _login(),
          isEnabled: true,
          padding: 0,
        ),
      );

  _buildLoginLaterButton() => Container(
      height: 35.auto,
      child: ColorButton(
        // height: 30,
        title: getTranslatedText("login_later"),
        onClick: () => _navigateToHome(),
        isEnabled: true,
        color: Colors.transparent,
      ));

  _buildChangeLanguageText() {
    var list = LanguageProvider.getSingleton().list;
    var deviceLanguage =
        list.singleWhere((e) => e.locale == Localizations.localeOf(context));
    return  Container(

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
                      style: TextStyle(
                          color: deviceLanguage == list[index]
                              ? CustomColor.theme_button_color
                              : Colors
                                  .white /*CustomColor.theme_text_black_white_color*/),
                    )),
                Visibility(
                  visible: index + 1 != list.length,
                  child: VerticalDivider(
                    color: Colors
                        .white /*CustomColor.theme_text_black_white_color*/,
                  ),
                )
              ],
            );
          }),
        )),
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
      ProgressDialog.show(context, _vm.brandLogo?.mobileUrl ?? "");
      _vm.login(username.text, password.text, _isRememberMe);
    }
  }

  _navigateToHome() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("login_later", true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => MyHomePage(
                    isFirstRun: false,
                  )),
          (Route<dynamic> route) => false);
    });
  }

  _handleApiState() {
    handleApiState(_vm.loginApiState, isCheckSessionExpired: false,
        onSuccess: () {
      if (!_vm.isNavigateFromSmsVerification)
        _navigateToHome();
      else
        _vm.setIsNavigateFromSmsVerificationToTrue();
    });
  }
}
