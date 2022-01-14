import 'package:api/entity/env_features_config.dart';
import 'package:api/entity/user_profile.dart';
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
  CustomLoginAppBar(
      {required this.onClickLoginButton,
      required this.onClickRegisterButton,
      required this.onClickLogoutButton,
      required this.isLogin,
      this.brandLogoUrl,
      this.userProfile,
      this.phone,
      this.config});

  final Function onClickLoginButton;
  final Function onClickRegisterButton;
  final Function onClickLogoutButton;
  final bool isLogin;
  final String? brandLogoUrl;
  final UserProfile? userProfile;
  final String? phone;
  final EnvFeaturesConfig? config;

  @override
  _CustomLoginAppBarState createState() => _CustomLoginAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _CustomLoginAppBarState extends BaseState<CustomLoginAppBar> {
  Widget build(BuildContext context) {
    if (EnvironmentConfig.template_version == 1) {
      return AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: gradientDecoration,
        ),
        centerTitle: false,
        title: _getAppBarTitle(),
        actions: _getActionButton(),
      );
    } else {
      return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: CustomColor.theme_app_bar_color,
        centerTitle: false,
        title: _getAppBarTitle(),
        actions: _getActionButton(),
      );
    }
  }

  _getAppBarTitle() => (widget.brandLogoUrl?.isEmpty ?? true)
      ? Container()
      : Container(
          height: 50,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(),
                  imageUrl: widget.brandLogoUrl!,
                  //handling error
                  height: 30.auto,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerLeft,
                  errorWidget: (context, url, error) => Container(),
                ),
              ),
              Expanded(
                flex: (widget.config?.displayPhone ?? false) ? 1 : 0,
                child: _getUserDetailsRow(),
              )
            ],
          ),
        );

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
          onClick: () => widget.onClickRegisterButton(),
          isEnabled: true,
          width: 80,
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
          title: getTranslatedText("exit"),
          onClick: () => widget.onClickLogoutButton(),
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
          widget.userProfile?.username ?? "",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
          minFontSize: 10,
          stepGranularity: 1,
        ),
      );

  _getUserDetailsRow() => Container(
        margin: EdgeInsets.symmetric(vertical: 3.auto),
        child: Row(
          children: [_getPhoneText(), _getVipText()],
        ),
      );

  _getPhoneText() => Visibility(
        visible: (widget.config?.displayPhone ?? false),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 3.auto),
              child: Image.asset(
                "images/home/ic_phone.png",
                width: 10.auto,
                height: 10.auto,
              ),
            ),
            AutoSizeText(
              widget.phone ?? "",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
              minFontSize: 10,
              stepGranularity: 1,
            ),
          ],
        ),
      );

  _getVipText() => Visibility(
        visible: widget.config?.customVIP ?? false,
        child: Row(
          children: [
            Visibility(
              visible: widget.isLogin,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 3.auto),
                child: Image.asset(
                  "images/home/ic_vip.png",
                  width: 10.auto,
                  height: 10.auto,
                ),
              ),
            ),
            Visibility(
              visible: widget.isLogin,
              child: AutoSizeText(
                _getVipPresentText(widget.userProfile?.vipLevel ?? 0),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
                minFontSize: 5,
                stepGranularity: 1,
              ),
            ),
          ],
        ),
      );

  getTranslatedText(String? key) => LanguageProvider.getSingleton().getTranslated(context, key);

  _getVipPresentText(int level) {
    if (EnvironmentConfig.vipPresentType == 2) {
      switch (level) {
        case 1:
          return "VIP 1";
        case 2:
          return "Silver";
        case 3:
          return "Gold";
        case 4:
          return "Platinum";
        case 5:
          return "Diamond";
        default:
          return "";
      }
    } else {
      return "VIP $level";
    }
  }
}
