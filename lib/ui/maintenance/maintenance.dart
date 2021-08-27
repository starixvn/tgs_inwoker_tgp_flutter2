import 'package:flutter/material.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

class Maintenance extends StatefulWidget {
  @override
  _MaintenanceState createState() => _MaintenanceState();
}

class _MaintenanceState extends BaseState<Maintenance> {
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[100],
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
            Wrap(
              children: [
                _buildText("如您有任何问题，请联系"),
                _buildCSText("客服"),
                _buildText("。"),
              ],
            ),
            _buildText("We are currently under maintenance,\n"
                "please try again later."),
            _buildText(
                "If you have any questions,",isNeedMargin: false
            ),
            Wrap(
              children: [
                _buildText("please contact our "),
                _buildCSText("customer service"),
                _buildText(".")
              ],
            )
          ],
        ),
      ),
    );
  }

  _buildText(String text,{bool isNeedMargin = true}) =>
      Container(
        margin: EdgeInsets.only(bottom: isNeedMargin?20.auto:0),
        child: Text(
          text,
          style: TextStyle(color: CustomColor.theme_text_color2,
              fontSize: 12.auto,),
          textAlign: TextAlign.center,
        ),
      );

  _buildCSText(String text) => InkWell(
    onTap: (){
      Navigator.pushNamed(context, "/cs_web_view");
    },
    child: Text(
      text,
      style: TextStyle(
          color: CustomColor.theme_text_color2,
          fontSize: 12.auto,
          decoration:  TextDecoration.underline ),
      textAlign: TextAlign.center,
    ),
  );
}
