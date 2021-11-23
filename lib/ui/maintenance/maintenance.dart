import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';
import 'package:tgp_flutter2/main.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/maintenance/maintenance_view_model.dart';

class Maintenance extends StatefulWidget {
  final bool isShowCS;
  final bool isShowsAppBar;

  Maintenance({this.isShowCS = false, this.isShowsAppBar = true});

  @override
  _MaintenanceState createState() => _MaintenanceState();
}

class _MaintenanceState extends BaseState<Maintenance> {
  var _vm = MaintenanceViewModel();

  @override
  void initState() {
    if (widget.isShowCS) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _vm.getBrandCommunication();
        _vm.getLiveChatUrl(getCurrentLanguage().apiCode);
      });
    }
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<MaintenanceViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.grey[100],
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
                image: DecorationImage(image: AssetImage("images/maintenance.png"), fit: BoxFit.fill),
              ),
              child: Column(
                children: [
                  _buildText("我们正在维护中，请稍后再试。"),
                  _buildText("如您有任何问题，请联系客服。"),
                  _buildText("We are currently under maintenance,\n"
                      "please try again later."),
                  _buildText("If you have any questions,", isNeedMargin: false),
                  _buildText("please contact our customer service,"),
                  Visibility(visible: widget.isShowCS, child: _buildButton())
                ],
              ),
            ),
          );
        });
  }

  _buildAppBar() => AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context)
                .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MyHomePage()), (route) => false);
          },
        ),
        title: Text(
          getTranslatedText("maintenance"),
          style: TextStyle(fontSize: 16.auto),
        ),
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
            onClick: () {},
            title: getTranslatedText("contact_cs"),
            isEnabled: true,
            width: context.screenWidth / 3.5,
            height: context.screenHeight / 18,
            fontSize: 13.auto,
            color: Colors.white,
          ),
          ColorButton(
            title: getTranslatedText("instant_messaging"),
            onClick: () {},
            isEnabled: true,
            radius: 20,
            height: 44.5,
            width: context.screenWidth / 3.5,
            padding: 5.auto,
            fontSize: 10.auto,
            color: CustomColor.theme_button_color,
          ),
        ],
      );

  _handleApiState() {
    handleApiState(_vm.getLiveChatUrlApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getBrandCommunicationApiState, isAutoHideLoading: false, onSuccess: () {});
  }
}
