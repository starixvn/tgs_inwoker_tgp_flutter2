import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info/package_info.dart';
import 'package:api/extension/screen_util.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:api/extension/screen_util.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/login/login_tab.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/login/login_view_model.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends BaseState<Login> {
  var _vm = LoginViewModel();
  PackageInfo packageInfo;
  String version;

  @override
  void initState() {
    _getPackageInfo();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: version == null
          ? buildProgressDialog()
          : Container(
              height: context.screenHeight,
              width: context.screenWidth,
              color: CustomColor.theme_bg_color,
              child: Column(
                children: [
                  _buildLogoImage(),
                  Expanded(
                      child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 27.auto),
                    child: LoginTab(),
                  )),
                  _buildVersionText(),
                ],
              ),
            ),
    );
  }

  _buildVersionText() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(right: 5.auto, left: 5.auto),
          child: Divider(
            color: CustomColor.theme_text_color,
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 5.auto, bottom: 3.auto),
          alignment: Alignment.centerRight,
          child: Text(
            "Version $version (${EnvironmentConfig.environmentStage})",
            style: TextStyle(fontSize: 8.auto, color: CustomColor.theme_text_color),
          ),
        )
      ],
    );
  }

  _buildLogoImage() => Container(
      margin: EdgeInsets.only(top: ScreenUtil.getInstance().statusBarHeight + 10.auto, bottom: 20.auto),
      child: SvgPicture.asset(
        "images/pg_logo.svg",
        height: 80.auto,
      ));

  _getPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }
}
