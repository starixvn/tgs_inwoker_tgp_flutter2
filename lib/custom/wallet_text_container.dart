import 'package:api/extension/screen_apis.dart';
import 'package:flutter/material.dart';

import '../base_state.dart';
import '../src/custom_color.dart';

class WalletTextContainer extends StatefulWidget {
  final String balance;
  final double width;
  final double height;

  // final GlobalKey<ScaffoldState> scaffoldKey;

  WalletTextContainer({
    required this.balance,
    required this.width,
    required this.height,
    // required this.scaffoldKey,
  });

  @override
  _WalletTextContainerState createState() => _WalletTextContainerState();
}

class _WalletTextContainerState extends BaseState<WalletTextContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: Color(0xff000326), borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(right: 10),
                child: Text(
                  widget.balance,
                  style: TextStyle(
                    color: CustomColor.theme_button_color,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 0,
            child: Icon(
              Icons.refresh,
              size: context.screenHeight / 30,
              color: CustomColor.theme_button_color,
            ),
          ),
        ],
      ),
    );
  }
}
