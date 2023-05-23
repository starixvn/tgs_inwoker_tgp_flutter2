import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:api/entity/brand_communication.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/customer_service/customer_service_view_model.dart';
import 'package:tgp_flutter2/ui/customer_service/customer_service_web_view.dart';

class CustomerService extends StatefulWidget {
  @override
  _CustomerServiceState createState() => _CustomerServiceState();
}

class _CustomerServiceState extends BaseState<CustomerService> {
  CustomerServiceViewModel _vm = CustomerServiceViewModel();
  var isShowing = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm.getBrandCommunication();
      _vm.getLiveChatUrl(getCurrentLanguage().apiCode ?? "en-US");
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<CustomerServiceViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return CustomScaffold(
              appBar: CustomAppBar(
                title: getTranslatedText("customer_service") == "customer_service" ? "Customer Service" : getTranslatedText("customer_service"),
              ),
              body: _vm.communicationList == null
                  ? buildProgressDialog(_vm.brandLogoUrl)
                  : Stack(
                      children: [
                        Container(
                          width: context.screenWidth,
                          height: context.screenHeight,
                          padding: EdgeInsets.only(top: 260.auto, left: 20.auto, right: 20.auto),
                          decoration: BoxDecoration(image: _getCsBgImage()),
                          child: ListView(shrinkWrap: true, children: [
                            buildLiveChatRow(),
                            ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: List.generate(_vm.communicationList!.length, (index) {
                                return Container(
                                  child: _buildCSRow(_vm.communicationList![index].type, "cs_join", "cs_qr_code",
                                      "support-" + (_vm.communicationList![index].type ?? "").toLowerCase(),
                                      qrCode: _vm.communicationList![index]),
                                );
                              }),
                            )
                          ]),
                        ),
                        Visibility(
                          visible: _vm.config?.displayPhone ?? false,
                          child: Positioned(
                            top: context.screenWidth / 2.1,
                            right: context.screenWidth / 10,
                            child: Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 30.auto, right: 3.auto),
                                  child: SvgPicture.asset(
                                    "images/support/ic_phone.svg",
                                    matchTextDirection: true,
                                    height: 20.auto,
                                    color: Color(0xfffD18206),
                                  ),
                                ),
                                AutoSizeText(
                                  _vm.phone ?? "",
                                  style: TextStyle(color: Color(0xfffD18206), fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left,
                                  minFontSize: 5,
                                  stepGranularity: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ));
        });
  }

  _getCsBgImage() {
    var language;
    String code = getCurrentLanguage().apiCode;
    if (code == "zh-CN" || code == "zh-TW")
      language = code;
    else
      language = "en-US";

    //cs_bg_t2, cs_bg_t3, cs_bg_t10_dark

    return DecorationImage(
        image: AssetImage("images/support/cs_bg/$language/cs_bg_t${_getCsTemplateVersionPath()}.png"), fit: BoxFit.fitWidth, alignment: Alignment.topLeft);
  }

  _getCsTemplateVersionPath() {
    switch (EnvironmentConfig.template_version) {
      case 3:
        return "3";
      case 10:
        return (EnvironmentConfig.dark_mode) ? "10_dark" : "2";
      default:
        return "2";
    }
  }

  buildLiveChatRow() => Visibility(
        visible: _vm.liveChatUrl == null ? false : true,
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CustomerServiceWebView(
                          //to remove whitespace in url
                          url: _vm.liveChatUrl!.replaceAll(" ", ""),
                          brandLogoUrl: _vm.brandLogoUrl,
                        )));
          },
          child: Container(
            padding: EdgeInsets.only(left: 15.auto, right: 20.auto, top: 0, bottom: 0),
            margin: EdgeInsets.only(top: 15.auto),
            height: 40.auto,
            decoration: BoxDecoration(
              color: EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode ? Color(0xff000520) : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SvgPicture.asset(
                    "images/support/support-call.svg",
                    matchTextDirection: true,
                    height: 20.auto,
                    color: CustomColor.theme_button_color,
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Container(
                    margin: EdgeInsets.only(left: 10.auto, top: 0, bottom: 0),
                    child: SizedBox.expand(
                      // to fix not showing full text in thai language
                      child: Container(
                        padding: EdgeInsets.only(top: 16),
                        child: AutoSizeText(
                          getTranslatedText("online_cs"),
                          style: TextStyle(color: EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode ? CustomColor.theme_text_black_white_color:CustomColor.theme_text_black_color),
                          maxLines: 1,
                          minFontSize: 13,
                          stepGranularity: 1,
                          maxFontSize: 15,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: AutoSizeText(
                    getTranslatedText("contact"),
                    style: TextStyle(color:EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode
                        ? Colors.white
                        :  CustomColor.theme_button_color),
                    textAlign: TextAlign.end,
                    maxFontSize: 15,
                    minFontSize: 5,
                    maxLines: 1,
                    stepGranularity: 1,
                  ),
                )
              ],
            ),
          ),
        ),
      );

  _buildCSRow(String? title, String text, String routePath, String? imagePath, {BrandCommunication? qrCode}) => InkWell(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.only(left: 15.auto, right: 20.auto),
          margin: EdgeInsets.only(top: 15.auto),
          height: 40.auto,
          decoration: BoxDecoration(
            color: EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode ? Color(0xff000520) : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: SvgPicture.asset(
                  "images/support/$imagePath.svg",
                  matchTextDirection: true,
                  height: 20.auto,
                  color: CustomColor.theme_button_color,
                ),
              ),
              Expanded(
                flex: 10,
                child: Container(
                  margin: EdgeInsets.only(left: 10.auto),
                  child: Text(
                    getTranslatedText(title) ?? title,
                    style: TextStyle(color: EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode ? CustomColor.theme_text_black_white_color:CustomColor.theme_text_black_color),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: () {
                    var contact = qrCode?.appId ?? qrCode?.phone;
                    if (contact != null) {
                      Clipboard.setData(ClipboardData(text: contact));
                      _handleDeepLinkApps(title ?? "", contact);
                    }

                    // CustomToast.show(getTranslatedText("copy_text"));
                  },
                  child: /*ImageIcon(
                    AssetImage("images/support/ic_copy.png"),
                    size: 23.auto,
                    color: CustomColor.theme_text_black_color,
                  ),*/
                      Text(
                    getTranslatedText("cs_join"),
                    style: TextStyle(
                        color: EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode
                            ? Colors.white
                            : CustomColor.theme_button_color),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  _handleApiState() {
    handleApiState(_vm.getBrandCommunicationApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getBrandCommunicationApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getLiveChatUrlApiState, isAutoHideLoading: false, onSuccess: () {});
  }

  _handleDeepLinkApps(String comType, String value) {
    // ProgressDialog.show(context, _vm.brandLogoUrl);
    handleDeepLink(comType, value);
  }
}
