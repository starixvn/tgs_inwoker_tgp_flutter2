import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:api/entity/brand_communication.dart';
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
      _vm.getLiveChatUrl(getCurrentLanguage().apiCode);
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<CustomerServiceViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: CustomColor.theme_bg_color,
              appBar: CustomAppBar(
                title: getTranslatedText("customer_service"),
              ),
              body: _vm.communicationList == null
                  ? buildProgressDialog()
                  : Stack(
                      children: [
                        Container(
                          width: context.screenWidth,
                          height: context.screenHeight,
                          padding: EdgeInsets.only(top: 260.auto, left: 20.auto, right: 20.auto),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage("images/support/cs_bg.png"),
                                fit: BoxFit.fitWidth,
                                alignment: Alignment.topLeft),
                          ),
                          child: Column(children: [
                            buildLiveChatRow(),
                            Column(
                              children: List.generate(_vm.communicationList.length, (index) {
                                return Container(
                                  child: _buildCSRow(_vm.communicationList[index].type, "cs_join", "cs_qr_code",
                                      "support_" + _vm.communicationList[index].type.toLowerCase(),
                                      qrCode: _vm.communicationList[index]),
                                );
                              }),
                            )
                          ]),
                        ),
                      ],
                    ));
        });
  }

  buildLiveChatRow() => Visibility(
        visible: _vm.liveChatUrl == null ? false : true,
        child: InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => CustomerServiceWebView(url: _vm.liveChatUrl)));
          },
          child: Container(
            padding: EdgeInsets.only(left: 20.auto, right: 20.auto),
            margin: EdgeInsets.only(top: 15.auto),
            height: 40.auto,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ImageIcon(
                    AssetImage("images/support/support_call.png"),
                    size: 23.auto,
                    color: CustomColor.theme_bar_gradient_1,
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Container(
                    margin: EdgeInsets.only(left: 10.auto),
                    child: Text(
                      getTranslatedText("online_cs"),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    getTranslatedText("contact"),
                    style: TextStyle(color: CustomColor.theme_button_color),
                  ),
                )
              ],
            ),
          ),
        ),
      );

  _buildCSRow(String title, String text, String routePath, String imagePath, {BrandCommunication qrCode}) => InkWell(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.only(left: 20.auto, right: 20.auto),
          margin: EdgeInsets.only(top: 15.auto),
          height: 40.auto,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: ImageIcon(
                  AssetImage("images/support/$imagePath.png"),
                  size: 23.auto,
                  color: CustomColor.theme_button_color,
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.only(left: 10.auto),
                  child: Text(
                    getTranslatedText(title) ?? title,
                    style: TextStyle(color: CustomColor.theme_bg_color),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  qrCode.appId ?? qrCode.phone,
                  // getTranslatedText(text),
                  style: TextStyle(color: CustomColor.theme_button_color),
                ),
              ),
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: qrCode.appId ?? qrCode.phone));
                    CustomToast.show(getTranslatedText("copy_text"));
                  },
                  child: ImageIcon(
                    AssetImage("images/support/ic_copy.png"),
                    size: 23.auto,
                    color: CustomColor.theme_bg_color,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  _handleApiState() {
    handleApiState(_vm.getBrandCommunicationApiState,isAutoHideLoading: false, onSuccess: () {});
  }
}
