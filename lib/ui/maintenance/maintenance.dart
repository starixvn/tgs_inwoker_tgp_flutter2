import 'package:api/extension/format.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    if (widget.isShowCS) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _vm.getBrandCommunication();
        _vm.getLiveChatUrl(getCurrentLanguage().apiCode);
      });
    }
    if (widget.onResumeBgMusic != null) widget.onResumeBgMusic!();

    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
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
            appBar: widget.isShowsAppBar
                ? _buildAppBar()
                : PreferredSize(
                    child: Container(
                      color: Colors.black,
                    ),
                    preferredSize: Size.zero),
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
              child: Column(
                children: [
                  _buildText("我们正在维护中，请稍后再试。"),
                  _buildText("如您有任何问题，请联系客服。"),
                  _buildText(
                      "维护时间：${Format().timezoneFormat(_vm.config?.maintenanceDetail?["startTime"] ?? "2022-07-12T01:35:00.000Z")}" +
                          "~ " +
                          "${Format().timezoneFormat(_vm.config?.maintenanceDetail?["endTime"] ?? "2022-07-12T04:30:00.000Z")} (GMT+8)"),
                  _buildText("We are currently under maintenance,\n"
                      "please try again later."),
                  _buildText("If have any questions,", isNeedMargin: false),
                  _buildText("please contact our customer service,"),
                  _buildText(
                      "Maintenance time: ${Format().timezoneFormat(_vm.config?.maintenanceDetail?["startTime"] ?? "2022-07-12T01:35:00.000Z")}" +
                          "~ " +
                          "${Format().timezoneFormat(_vm.config?.maintenanceDetail?["endTime"] ?? "2022-07-12T04:30:00.000Z")} (GMT+8)"),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 40.auto),
                    child: _buildText(
                        "Hiện chúng tôi đang được bảo trì, bạn có thẻ liên hệ với bộ phận hồ trở khách hàng 24/7 của chúng tôi đễ biểt thêm thống tin"),
                  ),
                  Visibility(visible: widget.isShowCS, child: _buildButton())
                ],
              ),
            ),
          );
        });
  }

  _buildAppBar() => CustomAppBar(
        title: getTranslatedText("maintenance"),
        onPop: () {
          AssetsAudioPlayer().pause();
          Navigator.pop(context);
        },
      );

  _buildText(String text, {bool isNeedMargin = true}) => Container(
        margin: EdgeInsets.only(bottom: isNeedMargin ? 20.auto : 0),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.auto,
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
            fontSize: 13,
            color: Colors.white,
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
            height: 44.5,
            width: context.screenWidth / 3.5,
            padding: 5.auto,
            fontSize: 10,
            color: CustomColor.theme_button_color,
          ),
        ],
      );

  _handleApiState() {
    handleApiState(_vm.getLiveChatUrlApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getBrandCommunicationApiState, isAutoHideLoading: false, onSuccess: () {});
  }
}
