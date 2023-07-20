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

import '../../GlobalValueUtil.dart';
import 'T14/language_dialog.dart';

class Login extends StatefulWidget {
  final bool defaultRegisterTab;

  Login({this.defaultRegisterTab = false});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends BaseState<Login> {
  var _vm = LoginViewModel();
  PackageInfo? packageInfo;
  String? version;
  int currentTabIndex = 0;

  @override
  void initState() {
    _getPackageInfo();
    GlobalValueUtil.pausesong();
    currentTabIndex = widget.defaultRegisterTab ? 1 : 0;
    super.initState();
  }

  updateIndex(int newValue) {
    setState(() {
      currentTabIndex = newValue;
    });
  }

  Widget build(BuildContext context) {
    return CustomScaffold(
      body: version == null
          ? buildProgressDialog(_vm.brandLogo.mobileUrl)
          : Container(
              padding: EdgeInsets.only(top: ScreenUtil.getInstance().statusBarHeight),
              height: context.screenHeight,
              width: context.screenWidth,
              decoration: EnvironmentConfig.template_version != 11
                  ? BoxDecoration(color: CustomColor.theme_bg_color)
                  : BoxDecoration(image: DecorationImage(image: AssetImage("images/t11_bg/login_bg.png"), fit: BoxFit.fill)),
              child: Column(
                children: [
                  Container(
                    height: ScreenUtil.getInstance().appBarHeight,
                    width: context.screenWidth,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                FittedBox(fit: BoxFit.fitHeight, child: Icon(Icons.arrow_back_ios_new, color: Colors.white)),
                                SizedBox(width: 10),
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  height: double.infinity,
                                  child: FittedBox(
                                    fit: BoxFit.fitHeight,
                                    child: Text(
                                      getTranslatedText("back"),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: ScreenUtil.getInstance().appBarHeight,
                          width: ScreenUtil.getInstance().appBarHeight,
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () => showLanguageDialog(),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Image.asset(
                                "images/login/ic_language.png",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: EnvironmentConfig.template_version != 14?4:2,
                    child: (EnvironmentConfig.template_version != 14)
                        ? _buildLogoImage()
                        : Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(top: 0,left: 27.auto, right: 27.auto),
                            child: Text(
                              (currentTabIndex == 0 ? getTranslatedText("login") : getTranslatedText("register")).toString().toUpperCase(),
                              style: TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold),
                            ),
                          ),
                  ),
                  Expanded(
                      flex: 15,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 27.auto),
                        child: LoginTab(config: _vm.config, defaultRegisterTab: widget.defaultRegisterTab, updateIndex: this.updateIndex),
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

  showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => LanguageDialog(
        languageList: _vm.languageList,
        changeLanguage: (language) {
          _vm.changeLanguage(language, context);
          Navigator.pop(context);
        },
      ),
    );
  }
}
