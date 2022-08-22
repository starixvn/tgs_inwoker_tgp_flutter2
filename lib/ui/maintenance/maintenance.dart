import 'package:api/extension/format.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/main.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/ui/customer_service/customer_service_web_view.dart';
import 'package:tgp_flutter2/ui/maintenance/maintenance_dialog.dart';
import 'package:tgp_flutter2/ui/maintenance/maintenance_view_model.dart';

class Maintenance extends StatefulWidget {
  final bool isShowCS;
  final bool isShowsAppBar;
  final Function? onResumeBgMusic;

  Maintenance({this.isShowCS = false, this.isShowsAppBar = true, this.onResumeBgMusic});

  @override
  _MaintenanceState createState() => _MaintenanceState();
}

class _MaintenanceState extends BaseState<Maintenance> with WidgetsBindingObserver {
  var _vm = MaintenanceViewModel();
  var languageCode;

  @override
  void initState() {
    _initData();
    if (widget.onResumeBgMusic != null) widget.onResumeBgMusic!();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  _initData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var code = _prefs.getString("LANGUAGE_CODE") ?? EnvironmentConfig.default_lang;
    await _vm.getMaintenanceDetails();
    if (widget.isShowCS) {
      _vm.getBrandCommunication();
      _vm.getLiveChatUrl(code);
    }
    getLanguage();
  }

  getLanguage() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    languageCode = _prefs.getString("LANGUAGE_CODE") ?? EnvironmentConfig.default_lang;
    print(languageCode);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _vm.config == null) {
      _vm.getEnvFeatures();
    }
  }

  Widget build(BuildContext context) {
    return ProviderWidget<MaintenanceViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return CustomScaffold(
            appBar: widget.isShowsAppBar ? _buildAppBar() : PreferredSize(child: Container(), preferredSize: Size.zero),
            body: Container(
              padding: EdgeInsets.only(top: 100.auto),
              width: context.screenWidth,
              height: context.screenHeight,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                        "images/maintenance/maintenance${EnvironmentConfig.template_version == 8 ? "_t8" : ""}.png"),
                    fit: BoxFit.fill),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [_getContent(), Visibility(visible: widget.isShowCS, child: _buildButton())],
              ),
            ),
          );
        });
  }

  _getContent() {
      if (_vm.content?.isNotEmpty ?? false) {
      return Column(
        children: [
          _buildText("${getTranslatedText("maintenance_time")}: \n" + _getTime()),
          SizedBox(height: 20),
          _buildText(_vm.content!),
          SizedBox(height: 20),
        ],
      );
    } else
    return Column(
      children: [
        _buildText("我们正在维护中，请稍后再试。"),
        _buildText("如您有任何问题，请联系客服。"),
        _buildText("维护时间: " + _getTime()),
        _buildText("We are currently under maintenance,\n"
            "please try again later."),
        _buildText("If have any questions,", isNeedMargin: false),
        _buildText("please contact our customer service,"),
        _buildText("Maintenance time: " + _getTime()),
      ],
    );
  }

  _getTime() {
    var start = _vm.beginTime != null
        ? _vm.beginTime
        : Format().timezoneFormat(_vm.config?.maintenanceDetail?["startTime"] ?? "2022-07-12T01:35:00.000Z");
    var end = _vm.endTime != null
        ? _vm.endTime
        : Format().timezoneFormat(_vm.config?.maintenanceDetail?["endTime"] ?? "2022-07-12T04:30:00.000Z");

    return "$start" + " ~ " + "$end (GMT+8)";
  }

  _buildAppBar() => CustomAppBar(
        title: getTranslatedText("maintenance"),
        onPop: () {
          AssetsAudioPlayer().pause();
          Navigator.pop(context);
        },
      );

  _buildText(String text, {bool isNeedMargin = true, int font = 15}) => Container(
        margin: EdgeInsets.only(bottom: isNeedMargin ? 20.auto : 0),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: font.auto,
          ),
          textAlign: TextAlign.center,
        ),
      );

/*  _buildCSText(String text) => InkWell(
        onTap: () {
          Navigator.pushNamed(context, RoutePath.customerService);
        },
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 12.auto, decoration: TextDecoration.underline),
          textAlign: TextAlign.center,
        ),
      );*/

  _buildButton() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          OutlineBorderButton(
            onClick: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CustomerServiceWebView(
                            url: _vm.liveChatUrl,
                            brandLogoUrl: _vm.brandLogoUrl,
                          )));
            },
            title: getTranslatedText("contact_cs"),
            isEnabled: true,
            width: context.screenWidth / 3.5,
            height: context.screenHeight / 18,
            fontSize: 20,
            color: Colors.white,
            padding: 0,
            minFontSize: languageCode == "th-TH" ? 15 : 5,
          ),
          ColorButton(
            title: getTranslatedText("instant_messaging"),
            onClick: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => MaintenanceDialog(
                  communicationList: _vm.communicationList,
                ),
              );
            },
            isEnabled: true,
            radius: 5,
            height: context.screenHeight / 18,
            width: context.screenWidth / 3.5,
            minFontSize: 5,
            color: CustomColor.theme_button_color,
            fontSize: 20,
          ),
        ],
      );

  _handleApiState() {
    handleApiState(_vm.getLiveChatUrlApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getBrandCommunicationApiState, isAutoHideLoading: false, onSuccess: () {});
  }
}
