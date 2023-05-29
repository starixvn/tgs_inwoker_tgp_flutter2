import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info/package_info.dart';
import 'package:api/extension/screen_util.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:api/extension/screen_util.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/login/login_tab.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/login/login_view_model.dart';

import 'LoginInputVIew.dart';

class LoginTemplate02 extends StatefulWidget {
  final bool defaultRegisterTab;

  LoginTemplate02({this.defaultRegisterTab = false});

  @override
  _LoginTemplate02State createState() => _LoginTemplate02State();
}

class _LoginTemplate02State extends BaseState<LoginTemplate02> {
  var _vm = LoginViewModel();
  PackageInfo? packageInfo;
  String? version;

  @override
  void initState() {
    _getPackageInfo();
    super.initState();
  }

  Widget build(BuildContext context) {
    return CustomScaffold(
      body: version == null
          ? buildProgressDialog(_vm.brandLogo.mobileUrl)
          : Container(
        height: context.screenHeight,
        width: context.screenWidth,
        decoration: BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(image: AssetImage("images/login/Sky8/loginbg.png"), fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Color(0x1B1D30).withOpacity(0.62), BlendMode.darken))),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: _buildLogoImage(),
            ),
            Expanded(
                flex:23,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.auto),
                  child: LoginInputView(
                    config: _vm.config,
                    defaultRegisterTab: widget.defaultRegisterTab,
                  ),
                )),
            Expanded(
              flex: 1,
              child: _buildVersionText(),
            )
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
            color: CustomColor.theme_text_grey_color,
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 5.auto, bottom: 3.auto),
          alignment: Alignment.centerRight,
          child: Text(
            "Version $version (${EnvironmentConfig.environmentStage})",
            style: TextStyle(fontSize: 8.auto, color: CustomColor.theme_text_grey_color),
          ),
        )
      ],
    );
  }

  _buildLogoImage() => Container(
      color: Colors.red,
      margin: EdgeInsets.only(top: ScreenUtil.getInstance().statusBarHeight, left: 27.auto, right: 27.auto),
      child: (_vm.brandLogo?.mobileUrl?.isEmpty ?? true)
          ? Container(
        height: 100.auto,
      )
          : CachedNetworkImage(
        width: 150.auto,
        height: 100.auto,
        placeholder: (context, url) => Container(),
        imageUrl: _vm.brandLogo.mobileUrl,
        //handling error
        errorWidget: (context, url, error) => Container(),
      ));

  _getPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      version = packageInfo!.version;
    });
  }
}
