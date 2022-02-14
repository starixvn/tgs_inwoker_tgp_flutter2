import 'package:api/extension/format.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar(
      {required this.title,
      this.widget,
      this.walletBalance,
      this.isPopTwice = false,
      this.onPop,
      this.isPassTrueWhenPop = false});

  final String title;
  final Widget? widget;
  final double? walletBalance;
  final bool isPopTwice;
  final Function? onPop;
  final bool isPassTrueWhenPop;

  @override
  Size get preferredSize => const Size.fromHeight(45);

  Widget build(BuildContext context) {
    return EnvironmentConfig.template_version == 1
        ? AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: gradientDecoration,
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
          )
        : AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: CustomColor.theme_app_bar_color,
            centerTitle: true,
            //widget == null ? true : false,
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
  }

  _getAppBarWidget() {
    if (walletBalance != null) {
      return Container(
          margin: EdgeInsets.only(right: 15.auto),
          alignment: Alignment.center,
          child: Text(
            "${Format().currencyWithDecimalFormat(walletBalance ?? 0)}",
            style: TextStyle(color: Colors.white),
          ));
    } else if (widget != null) {
      return widget;
    } else
      return Container();
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
