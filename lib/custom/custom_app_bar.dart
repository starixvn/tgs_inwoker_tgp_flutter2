import 'package:api/extension/format.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter/services.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({
    required this.title,
    this.widget,
    this.walletBalance,
    this.isPopTwice = false,
    this.onPop,
    this.isPassTrueWhenPop = false,
  });

  final String title;
  final Widget? widget;
  final double? walletBalance;
  final bool isPopTwice;
  final Function? onPop;
  final bool isPassTrueWhenPop;

  @override
  Size get preferredSize => const Size.fromHeight(45);

  Widget build(BuildContext context) {
    if (EnvironmentConfig.template_version == 1)
      return AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: gradientDecoration,
        ),
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(fontSize: 16.auto, color: CustomColor.theme_app_bar_text_color),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: EnvironmentConfig.light_mode ? Colors.black : Colors.white,
          ),
          onPressed: () => _onPress(context),
        ),
        actions: [_getAppBarWidget()],
      );
    else if (EnvironmentConfig.template_version == 8 && (EnvironmentConfig.dark_mode)) {
      return AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.transparent.withOpacity(1.0), Color(0xff000129)], begin: Alignment.bottomCenter, end: Alignment.topCenter, stops: [0, 0.5]),
          ),
        ),
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(fontSize: 16.auto),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => _onPress(context),
        ),
        actions: [_getAppBarWidget()],
      );
    } else if (EnvironmentConfig.template_version == 9 && (EnvironmentConfig.dark_mode)) {
      return AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(1.0),
                Color.fromRGBO(0, 1, 41, 1),
                Color.fromRGBO(0, 1, 41, 1),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(fontSize: 16.auto),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => _onPress(context),
        ),
        actions: [_getAppBarWidget()],
      );
    } else
      return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: CustomColor.theme_app_bar_color,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          // Status bar color

          statusBarColor: CustomColor.theme_app_bar_color,
        ),
        //widget == null ? true : false,
        title: Text(
          title,
          style: TextStyle(fontSize: 16.auto, color: CustomColor.theme_app_bar_text_color),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: EnvironmentConfig.template_version == 8 ||
                (EnvironmentConfig.template_version == 9 && !EnvironmentConfig.dark_mode) ||
                EnvironmentConfig.light_mode
                ? Colors.black
                : Colors.white,
          ),
          onPressed: () => _onPress(context),
        ),
        actions: [_getAppBarWidget()],
      );
  }

  _getAppBarWidget() {
    return SafeArea(
        child: (() {
      if (walletBalance != null && EnvironmentConfig.template_version==14) {
        return Container(
            margin: EdgeInsets.only(right: 15.auto),
            alignment: Alignment.center,
            child: Text(
              EnvironmentConfig.brandName == "IDR1"
                  //without decimal places
                  ? Format().currencyFormat((walletBalance ?? 0).toInt())
                  //with 2 decimal places
                  : Format().currencyWithDecimalFormat(walletBalance ?? 0),
              style: TextStyle(color: _getWalletBalanceTextColor()),
            ));
      } else if (widget != null) {
        return widget!;
      }
      return Container();
    }()));
  }

  Color _getWalletBalanceTextColor() {
    switch (EnvironmentConfig.template_version) {
      case 8:
        return Colors.black;
      case 14:
        return CustomColor.theme_button_color;
      default:
        return Colors.white;
    }
  }

  _onPress(BuildContext context) {
    if (onPop == null) {
      if (isPopTwice) {
        Navigator.pop(context);
        Navigator.pop(context);
      } else if (isPassTrueWhenPop) {
        Navigator.pop(context, true);
      } else
        Navigator.pop(context);
    } else
      this.onPop!();
  }
}
