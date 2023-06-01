import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info/package_info.dart';
import 'package:api/extension/screen_util.dart';
import 'package:tgp_flutter2/GlobalValueUtil.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:api/extension/screen_util.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/login/login_tab.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/login/login_view_model.dart';

import 'LoginInputVIew.dart';

class LoginTemplate02 extends StatefulWidget {
  final bool defaultRegisterTab;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  LoginTemplate02({this.defaultRegisterTab = false, this.onResumeBgMusic, this.onPauseBgMusic});

  @override
  _LoginTemplate02State createState() => _LoginTemplate02State();
}

class _LoginTemplate02State extends BaseState<LoginTemplate02> {
  var _vm = LoginViewModel();
  PackageInfo? packageInfo;
  String? version;
  final ScrollController controller = ScrollController();
  var isRegister = false;

  @override
  void initState() {
    _getPackageInfo();
    super.initState();
    // assetsAudioPlayer.pause();
    if (widget.onPauseBgMusic != null) widget.onPauseBgMusic!();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    GlobalValueUtil.playerStatus = AssetPlayerStatus.returnHome;
    if (GlobalValueUtil.playerStatus != AssetPlayerStatus.manualClickPause) {
      if (widget.onResumeBgMusic != null) widget.onResumeBgMusic!();
      // assetsAudioPlayer.play();
    }
    // if (widget.onResumeBgMusic != null) widget.onResumeBgMusic!();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return
      CustomScaffold(
      body: version == null
          ? buildProgressDialog(_vm.brandLogo.mobileUrl)
          : Container(
        height: context.screenHeight,
        width: context.screenWidth,
        decoration: BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(image: AssetImage("images/login/Sky8/loginbg.png"), fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Color(0x1B1D30).withOpacity(0.62), BlendMode.darken))),
        child:
        ScrollConfiguration( behavior: MyBehavior(),
          child: ListView.builder(
              // controller: controller,
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                      children: [
                        Container(
                          height: 100.auto,
                          child: _buildLogoImage(),
                        ),
                        Container(
                          height: (context.screenHeight * (isRegister ? 0.6 : 0.55)).auto + 120.auto,
                            // flex:6,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 15.auto),
                              child: LoginInputView(
                                config: _vm.config,
                                defaultRegisterTab: widget.defaultRegisterTab,
                                isRegister: (bool) {setState(() {
                                  isRegister = bool;
                                });} ,
                              ),
                            )),
                        Container(
                          height: 30.auto,
                          child: _buildVersionText(),
                        )
                      ],
                    );
              }
          ),
        // Column(
        //   children: [
        //     Container(
        //       height: 100.auto,
        //       child: _buildLogoImage(),
        //     ),
        //     Container(
        //       height: 1500.auto,
        //         // flex:6,
        //         child: Container(
        //           margin: EdgeInsets.symmetric(horizontal: 15.auto),
        //           child: LoginInputView(
        //             config: _vm.config,
        //             defaultRegisterTab: widget.defaultRegisterTab,
        //           ),
        //         )),
        //     Container(
        //       height: 100.auto,
        //       child: _buildVersionText(),
        //     )
        //   ],
        // )
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
      // color: Colors.red,
      margin: EdgeInsets.only(top: 0, left: 27.auto, right: 27.auto),
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
