import 'package:api/entity/env_features_config.dart';
import 'package:api/entity/main_wallet.dart';
import 'package:api/entity/user_profile.dart';
import 'package:api/extension/format.dart';
import 'package:api/localizations/language_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter_svg/svg.dart';
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
      this.brandName,
      this.onClickBalance,
      required this.randomNumber});

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
  final Function? onClickBalance;
  final int randomNumber;

  @override
  _CustomLoginAppBarState createState() => _CustomLoginAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(90);
}

class _CustomLoginAppBarState extends BaseState<CustomLoginAppBar> {
  Widget build(BuildContext context) {
    if (EnvironmentConfig.template_version == 1) {
      return AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: gradientDecoration,
          child: _getAppBarWidget(),
        ),
        centerTitle: false,
      );
    } else if (EnvironmentConfig.template_version == 8 && (EnvironmentConfig.dark_mode)) {
      return AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.transparent.withOpacity(1.0), CustomColor.theme_bar_gradient_2],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [0, 0.5]),
          ),
          child: _getAppBarWidget(),
        ),
        centerTitle: false,
      );
    } else if (EnvironmentConfig.template_version == 9 && (EnvironmentConfig.dark_mode)) {
      return AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(1.0),
                CustomColor.theme_bar_gradient_2,
                CustomColor.theme_bar_gradient_2
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: _getAppBarWidget(),
        ),
        centerTitle: false,
      );
    } else {
      return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: CustomColor.theme_app_bar_color,
        centerTitle: false,
        flexibleSpace: Container(
          child: _getAppBarWidget(),
        ),
      );
    }
  }

  _getAppBarWidget() => SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _getAppBarTitle(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _getActionButton(),
                ),
                if (EnvironmentConfig.template_version == 11) _getOnlineUsersText(),
              ],
            ),
          ],
        ),
      );

  _getAppBarTitle() => (widget.brandLogoUrl?.isEmpty ?? true)
      ? Container()
      : Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.max,
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
          if (widget.config?.homePageDisplayVIP ?? false) _getVipButton(),
          _getLoginButton(),
          _getRegisterButton(),
        ];

  _getOnlineUsersText() => Padding(
        padding: EdgeInsets.only(right: 10),
        child: Text(
          "${getTranslatedText("online_user")} : ${widget.randomNumber}",
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.auto,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  _getLoginButton() => Container(
        padding: EdgeInsets.symmetric(horizontal: 5.auto, vertical: 10.auto),
        height: 50.auto,
        child: OutlineBorderButton(
          title: getTranslatedText("login"),
          onClick: () => widget.onClickLoginButton(),
          isEnabled: true,
          width: 60.auto,
          height: 17,
          color: ((() {
            if (_isDarkMode())
              return CustomColor.theme_text_black_color;
            else if (EnvironmentConfig.light_mode)
              return CustomColor.theme_button_color;
            else
              return Colors.white;
          })()),
          fontSize: 14,
          radius: 5,
          padding: 4,
        ),
      );

  _getRegisterButton() => Container(
        padding: EdgeInsets.symmetric(horizontal: 5.auto, vertical: 10.auto),
        height: 50.auto,
        child: ColorButton(
          title: getTranslatedText("register"),
          onClick: () => widget.onClickRegisterButton(),
          isEnabled: true,
          width: 60.auto,
          height: 17,
          fontSize: 14,
          radius: 5,
          padding: 4,
          textColor: _isDarkMode() || EnvironmentConfig.light_mode ? Colors.white : CustomColor.theme_app_bar_color,
          color: EnvironmentConfig.template_version == 3 ||
                  EnvironmentConfig.template_version == 4 ||
                  _isDarkMode() ||
                  EnvironmentConfig.light_mode
              ? CustomColor.theme_button_color
              : Colors.white,
        ),
      );

  _getVipButton() => EnvironmentConfig.template_version != 11
      ? Container(
          height: 50.auto,
          padding: EdgeInsets.all(10.auto),
          child: ColorButton(
            title: "VIP",
            onClick: () => Navigator.of(context).pushNamed("/vip"),
            isEnabled: true,
            width: 60.auto,
            height: 17,
            fontSize: 14,
            radius: 5,
            padding: 4,
            textColor:
                _isDarkMode() || EnvironmentConfig.light_mode ? Colors.white : CustomColor.theme_text_black_color,
            color: EnvironmentConfig.template_version == 3 || _isDarkMode() || EnvironmentConfig.light_mode
                ? CustomColor.theme_button_color
                : Colors.white,
            icon: Container(
              margin: EdgeInsets.only(right: 3.auto),
              child: Image.asset(
                "images/login_app_bar/vip.png",
                matchTextDirection: true,
                height: 18.auto,
              ),
            ),
          ),
        )
      : InkWell(
          onTap: () => Navigator.of(context).pushNamed("/vip"),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            padding: EdgeInsets.all(1),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black,
              ),
              padding: EdgeInsets.all(5),
              child: Image.asset(
                "images/login_app_bar/vip.png",
                matchTextDirection: true,
                height: 15.auto,
              ),
            ),
          ),
        );

  _getLogoutButton() => Container(
        height: 50.auto,
        padding: EdgeInsets.symmetric(vertical: 10.auto, horizontal: 10.auto),
        child: ColorButton(
          title: getTranslatedText("exit"),
          onClick: () => widget.onClickLogoutButton(),
          isEnabled: true,
          width: 60.auto,
          height: 17,
          radius: 5,
          padding: 2,
          textColor: _isDarkMode() || EnvironmentConfig.light_mode ? Colors.white : CustomColor.theme_app_bar_color,
          color: EnvironmentConfig.template_version == 3 || _isDarkMode() || EnvironmentConfig.light_mode
              ? CustomColor.theme_button_color
              : Colors.white,
        ),
      );

  _getUsernameText() => Container(
        padding: EdgeInsets.symmetric(vertical: 8.auto),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              widget.userProfile?.username ?? "",
              style: TextStyle(
                color: CustomColor.theme_app_bar_text_color,
                fontWeight: FontWeight.bold,
                fontSize: ((widget.config?.homePageDisplayBalance ?? false) || (widget.config?.newTransferUI ?? false))
                    ? 10.auto
                    : 14.auto,
              ),
            ),
            if (widget.config?.homePageDisplayBalance ?? false) _getBalanceText(),
            if (widget.config?.newTransferUI ?? false)
              InkWell(
                onTap: () => widget.onClickBalance != null ? widget.onClickBalance!() : null,
                child: Container(
                  height: 20.auto,
                  //  color: CustomColor.black,
                  child: Row(
                    children: [
                      Text(
                        getTranslatedText("balance") + ": ",
                        style: TextStyle(
                          color: CustomColor.theme_app_bar_text_color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.auto,
                        ),
                      ),
                      _getBalanceText()
                    ],
                  ),
                ),
              )
          ],
        ),
      );

  _getBalanceText() => Text(
        widget.totalBalance != null ? Format().amountFormat(widget.totalBalance ?? 0) : "-",
        style: TextStyle(
          color: (widget.config?.newTransferUI ?? false) && EnvironmentConfig.template_version == 3
              ? CustomColor.theme_button_color
              : CustomColor.theme_app_bar_text_color,
          fontWeight: FontWeight.bold,
          fontSize: (widget.config?.newTransferUI ?? false) ? 16.auto : 14.auto,
        ),
        textAlign: TextAlign.left,
      );

  _getUserDetailsRow() => _isDisplayUserDetailsRow()
      ? Container(
          height: 12.auto,
          margin: EdgeInsets.only(top: 5.auto, right: 10.auto),
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

  _isDarkMode() => ((EnvironmentConfig.template_version == 8 || EnvironmentConfig.template_version == 9) &&
      !EnvironmentConfig.dark_mode);

  _isDisplayUserDetailsRow() => ((widget.config?.displayPhone ?? false) || (widget.config?.customVIP ?? false));
}
