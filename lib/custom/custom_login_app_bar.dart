import 'package:api/entity/env_features_config.dart';
import 'package:api/entity/main_wallet.dart';
import 'package:api/entity/user_profile.dart';
import 'package:api/extension/format.dart';
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
      this.config,
      this.totalBalance,
      this.brandName});

  final Function onClickLoginButton;
  final Function onClickRegisterButton;
  final Function onClickLogoutButton;
  final bool isLogin;
  final String? brandLogoUrl;
  final UserProfile? userProfile;
  final String? phone;
  final EnvFeaturesConfig? config;
  final double? totalBalance;
  final String? brandName;

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
    } else if (EnvironmentConfig.template_version == 8 &&( EnvironmentConfig.dark_mode)) {
      return AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.transparent.withOpacity(1.0), Color(0xff000129)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [0, 0.5]),
          ),
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
          height: 60,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                placeholder: (context, url) => Container(
                  height: 30.auto,
                  width: 30.auto,
                ),
                imageUrl: widget.brandLogoUrl!,
                //handling error
                height: _isDisplayUserDetailsRow() ? 38.auto : 50.auto,
                width: 100.auto,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
                errorWidget: (context, url, error) => Container(),
              ),
              _getUserDetailsRow(),
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
          color: EnvironmentConfig.template_version == 8 || EnvironmentConfig.template_version == 9? CustomColor.theme_text_black_color : Colors.white,
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
          fontSize: 14,
          radius: 5,
          padding: 4,
          textColor: EnvironmentConfig.template_version == 8 ||EnvironmentConfig.template_version == 9? Colors.white : CustomColor.theme_text_black_color,
          color: EnvironmentConfig.template_version == 3 || EnvironmentConfig.template_version == 8||EnvironmentConfig.template_version == 9
              ? CustomColor.theme_button_color
              : Colors.white,
        ),
      );

  _getLogoutButton() => Container(
        padding: EdgeInsets.symmetric(vertical: 10.auto, horizontal: 10.auto),
        child: ColorButton(
          title: getTranslatedText("exit"),
          onClick: () => widget.onClickLogoutButton(),
          isEnabled: true,
          width: getCurrentLanguage().apiCode == "th-TH" ? 80 : 60,
          height: 17,
          radius: 5,
          padding: 2,
          textColor: EnvironmentConfig.template_version == 8 ||EnvironmentConfig.template_version == 9? Colors.white : CustomColor.theme_text_black_color,
          color: EnvironmentConfig.template_version == 3 || EnvironmentConfig.template_version == 8||EnvironmentConfig.template_version == 9
              ? CustomColor.theme_button_color
              : Colors.white,
        ),
      );

  _getUsernameText() => Container(
        height: 60,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 8.auto),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              alignment: Alignment.center,
              child: AutoSizeText(
                widget.userProfile?.username ?? "",
                style: TextStyle(color: CustomColor.theme_app_bar_text_color, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
                minFontSize: 10,
                stepGranularity: 1,
              ),
            ),
            if (widget.config?.homePageDisplayBalance ?? false)
              Container(
                alignment: Alignment.center,
                child: AutoSizeText(
                  Format().amountFormat(widget.totalBalance ?? 0),
                  style: TextStyle(color: CustomColor.theme_app_bar_text_color, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                  minFontSize: 10,
                  stepGranularity: 1,
                ),
              ),
          ],
        ),
      );

  _getUserDetailsRow() => _isDisplayUserDetailsRow()
      ? Container(
          height: 12.auto,
          margin: EdgeInsets.only(top: 2.auto, right: 10.auto),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.config?.displayPhone ?? false) _getPhoneText(),
              if (widget.config?.customVIP ?? false) _getVipText()
            ],
          ),
        )
      : Container();

  _getPhoneText() => Row(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 3.auto),
            child: Image.asset(
              "images/home/ic_phone.png",
              width: 10.auto,
              height: 10.auto,
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 5.auto),
            child: AutoSizeText(
              widget.phone ?? "",
              style: TextStyle(color: CustomColor.theme_app_bar_text_color, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
              minFontSize: 10,
              stepGranularity: 1,
            ),
          ),
        ],
      );

  _getVipText() => Row(
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
              style: TextStyle(color: CustomColor.theme_app_bar_text_color, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
              minFontSize: 10,
              stepGranularity: 1,
            ),
          ),
        ],
      );

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

  _isDisplayUserDetailsRow() => ((widget.config?.displayPhone ?? false) || (widget.config?.customVIP ?? false));
}
