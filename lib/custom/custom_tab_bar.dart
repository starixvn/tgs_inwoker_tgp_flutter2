import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class CustomTabBar extends StatefulWidget{
  final int index;

  CustomTabBar({Key key,
    this.index
  }) : super(key: key);

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends BaseState<CustomTabBar> {
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
                "STEP 1",
                style: TextStyle(
                  fontFamily: 'PingFang',
                  fontSize: 10.auto,
                    color: (widget.index ==0) ? CustomColor.theme_bar_gradient_2: Colors.grey
                ),
                textAlign: TextAlign.center
            ),
            Container(
              width: context.screenWidth/2 - 20.auto,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  bottomLeft: Radius.circular(25.0),
                ),
                border: Border.all(
                  width: 2.0,
                  color: (widget.index ==0) ? CustomColor.theme_bar_gradient_2: Colors.grey
                )
              ),
              margin: EdgeInsets.symmetric(vertical: 3.auto),
            ),
            Text(
                getTranslatedText("verify_current_email"),
                style: TextStyle(
                    fontFamily: 'PingFang',
                    fontSize: 14.auto,
                    color: (widget.index ==0) ? CustomColor.theme_bar_gradient_2: Colors.grey
                ),
                textAlign: TextAlign.center
            ),
          ],
        ),

        Column(
          children: [
            Text(
                "STEP 2",
                style: TextStyle(
                    fontFamily: 'PingFang',
                    fontSize: 10.auto,
                    color: (widget.index ==1) ? CustomColor.theme_bar_gradient_2: Colors.grey
                ),
                textAlign: TextAlign.center
            ),
            Container(
              width: context.screenWidth/2 - 20.auto,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25.0),
                    bottomRight: Radius.circular(25.0),
                  ),
                  border: Border.all(
                      width: 2.0,
                      color: (widget.index ==1) ? CustomColor.theme_bar_gradient_2: Colors.grey
                  )
              ),
              margin: EdgeInsets.symmetric(vertical: 3.auto),
            ),
            Text(
                getTranslatedText("set_new_pay_password"),
                style: TextStyle(
                    fontFamily: 'PingFang',
                    fontSize: 14.auto,
                    color: (widget.index ==1) ? CustomColor.theme_bar_gradient_2: Colors.grey
                ),
                textAlign: TextAlign.center
            ),
          ],
        ),
      ],
    );
  }
}