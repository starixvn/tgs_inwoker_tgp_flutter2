import 'package:api/localizations/language_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';

class CustomLoginAppBar extends StatefulWidget implements PreferredSizeWidget {
  CustomLoginAppBar({
    required this.onClickLoginButton,
    required this.isLogin,
    this.brandLogoUrl,
    this.username,
  });

  final Function onClickLoginButton;
  final bool isLogin;
  final String? brandLogoUrl;
  final String? username;

  @override
  _CustomLoginAppBarState createState() => _CustomLoginAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(45);
}

class _CustomLoginAppBarState extends BaseState<CustomLoginAppBar> {
  Widget build(BuildContext context) {
    return EnvironmentConfig.template_version == 1
        ? AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: gradientDecoration,
            ),
            centerTitle: false,
            title: (widget.brandLogoUrl?.isEmpty ?? true)
                ? Container()
                : CachedNetworkImage(
                    placeholder: (context, url) => Container(),
                    imageUrl: widget.brandLogoUrl!,
                    //handling error
                    height: 30.auto,
                    fit: BoxFit.cover,
                    alignment: Alignment.centerLeft,
                    errorWidget: (context, url, error) => Container(),
                  ),
            actions: _getActionButton(),
          )
        : AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: CustomColor.theme_app_bar_color,
            centerTitle: false,
            title: (widget.brandLogoUrl?.isEmpty ?? true)
                ? Container()
                : CachedNetworkImage(
                    placeholder: (context, url) => Container(),
                    imageUrl: widget.brandLogoUrl!,
                    //handling error
                    height: 30.auto,
                    fit: BoxFit.cover,
                    color: Colors.white,
                    alignment: Alignment.centerLeft,
                    errorWidget: (context, url, error) => Container(),
                  ),
            actions: _getActionButton(),
          );
  }

  List<Widget> _getActionButton() => widget.isLogin
      ? [
          _getUsernameText(),
          _getLogoutButton(),
        ]
      : [
          _getLoginButton(),
          _getRegisterButton(),
        ];

  _getLoginButton() => Container(
        padding: EdgeInsets.symmetric(vertical: 10.auto, horizontal: 10.auto),
        child: OutlineBorderButton(
          title: getTranslatedText("login"),
          onClick: () => widget.onClickLoginButton(),
          isEnabled: true,
          width: 60,
          height: 17,
          color: Colors.white,
          fontSize: 14,
          radius: 5,
          padding: 4,
        ),
      );

  _getRegisterButton() => Container(
        padding: EdgeInsets.symmetric(vertical: 10.auto, horizontal: 10.auto),
        child: ColorButton(
          title: getTranslatedText("register"),
          onClick: () => widget.onClickLoginButton(),
          isEnabled: true,
          width: 60,
          height: 17,
          color: Colors.white,
          fontSize: 14,
          radius: 5,
          padding: 4,
          textColor: CustomColor.theme_text_black_color,
        ),
      );

  _getLogoutButton() => Container(
        padding: EdgeInsets.symmetric(vertical: 10.auto, horizontal: 10.auto),
        child: ColorButton(
          title: getTranslatedText("logout"),
          onClick: () => widget.onClickLoginButton(),
          isEnabled: true,
          width: 60,
          height: 17,
          color: Colors.white,
          fontSize: 14,
          radius: 5,
          padding: 4,
          textColor: CustomColor.theme_text_black_color,
        ),
      );

  _getUsernameText() => Container(
    alignment: Alignment.center,
    child: AutoSizeText(
          widget.username ?? "",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
          minFontSize: 10,
          stepGranularity: 1,
        ),
  );

  getTranslatedText(String? key) => LanguageProvider().getTranslated(context, key);
}
