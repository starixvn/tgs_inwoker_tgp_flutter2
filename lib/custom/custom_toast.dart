import 'package:flutter/material.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:api/extension/screen_apis.dart';

class CustomToast{

  CustomToast.show(String errorMsg) {
    Fluttertoast.showToast(
        msg: errorMsg,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        fontSize: 13.auto,
        textColor: CustomColor.theme_text_color2
    );
  }
}