import 'package:api/NotificationServices/NotificationServiceName.dart';
import 'package:api/NotificationServices/notification_center.dart';
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

class CustomerServiceT15Light extends StatefulWidget {
  final CustomerServiceViewModel vm;

  CustomerServiceT15Light({
    required this.vm,
  });

  @override
  _CustomerServiceT15LightState createState() => _CustomerServiceT15LightState();
}

class _CustomerServiceT15LightState extends BaseState<CustomerServiceT15Light> {
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    // NotificationCenter().notify(NotificationServiceName().appBarTitle, data: getTranslatedText("customer_service") == "customer_service" ? "Customer Service" : getTranslatedText("customer_service"));
    return Container(
      height: context.screenHeight,
      width: context.screenWidth,
      child: Stack(
        children: [
          Container(
            height: context.screenHeight / 8,
            decoration: BoxDecoration(
              color: Color(0xffceb296),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(100),
                bottomRight: Radius.circular(100),
              ),
            ),
          ),
          ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).viewPadding.top),
            children: [
              Container(
                padding: EdgeInsets.all(15),
                alignment: Alignment.center,
                child: Text(
                  getTranslatedText('customer_support'),
                  style: TextStyle(color: Colors.white, fontSize: 15.auto),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25.auto),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 40.auto, vertical: 20.auto),
                child: Text(
                  getTranslatedText("welcome_customer_support"),
                  style: TextStyle(fontSize: 10.auto, color: CustomColor.theme_text_grey_color),
                ),
              ),
              SizedBox(height: 15),
              Container(
                height: context.screenHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    )),
                child: ListView(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 25.auto),
                  children: [
                    buildLiveChatRow(),
                  ]..addAll(
                      List.generate(
                        widget.vm.communicationList!.length,
                        (index) {
                          return Container(
                            child: _buildCSRow(widget.vm.communicationList![index].type, "cs_join", "cs_qr_code",
                                "support-" + (widget.vm.communicationList![index].type ?? "").toLowerCase(),
                                qrCode: widget.vm.communicationList![index]),
                          );
                        },
                      ),
                    ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  buildLiveChatRow() => Visibility(
        visible: widget.vm.liveChatUrl == null ? false : true,
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CustomerServiceWebView(
                          //to remove whitespace in url
                          url: widget.vm.liveChatUrl!.replaceAll(" ", ""),
                          brandLogoUrl: widget.vm.brandLogoUrl,
                        )));
          },
          child: Container(
            padding: EdgeInsets.only(left: 15.auto, right: 20.auto, top: 0, bottom: 0),
            margin: EdgeInsets.only(top: 15.auto),
            height: 50.auto,
            decoration: _getBoxDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 0,
                  child: SvgPicture.asset(
                    "images/support/support-call.svg",
                    matchTextDirection: true,
                    height: 30.auto,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 10.auto, top: 0, bottom: 0),
                    child: SizedBox.expand(
                      // to fix not showing full text in thai language
                      child: Container(
                        alignment: Alignment.centerLeft,
                        //padding: EdgeInsets.only(top: 16),
                        child: AutoSizeText(
                          getTranslatedText("online_cs"),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          minFontSize: 13,
                          stepGranularity: 1,
                          maxFontSize: 15,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 0,
                  child: Container(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.auto)),
                        color: Color(0xffceb296),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      margin: EdgeInsets.symmetric(vertical: 10.auto),
                      alignment: Alignment.centerRight,
                      child: AutoSizeText(
                        getTranslatedText("contact"),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.end,
                        maxFontSize: 15,
                        minFontSize: 5,
                        maxLines: 1,
                        stepGranularity: 1,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );

  _buildCSRow(String? title, String text, String routePath, String? imagePath, {BrandCommunication? qrCode}) => Container(
        padding: EdgeInsets.only(left: 15.auto, right: 20.auto),
        margin: EdgeInsets.only(top: 15.auto),
        height: 50.auto,
        decoration: _getBoxDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 0,
              child: SvgPicture.asset(
                "images/support/$imagePath.svg",
                matchTextDirection: true,
                height: 30.auto,
                color: Colors.white,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.only(left: 10.auto),
                child: Text(
                  getTranslatedText(title) ?? title,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: InkWell(
                onTap: () {
                  var contact = qrCode?.appId ?? qrCode?.phone;
                  if (contact != null) {
                    Clipboard.setData(ClipboardData(text: contact));
                    handleDeepLink(title ?? "", contact);
                  }
                  // CustomToast.show(getTranslatedText("copy_text"));
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.auto)),
                    color: Color(0xffceb296),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  margin: EdgeInsets.symmetric(vertical: 10.auto),
                  alignment: Alignment.center,
                  child: Text(
                    getTranslatedText("cs_join"),
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  _getBoxDecoration() => BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffe7beab), Color(0xfff7e3da)],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(1.0, 0.0),
          stops: [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(10),
      );

  Color _getItemBgColor() {
    if (EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode)
      return Color(0xff000520);
    else if (EnvironmentConfig.template_version == 14)
      return Color(0xff212238);
    else
      return Colors.white;
  }
}
