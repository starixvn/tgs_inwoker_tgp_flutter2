import 'package:api/extension/screen_apis.dart';
import 'package:flutter/material.dart';

import '../../custom/color_button.dart';
import '../../environment_config.dart';
import '../../src/custom_color.dart';

class ErrorDialogUtils {
  static void showErrorDialog(BuildContext context, String message, String title, {int popCount = 1}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height / 40,
              horizontal: MediaQuery.of(context).size.width / 20,
            ),
            decoration: new BoxDecoration(
              color: EnvironmentConfig.template_version == 14 ? CustomColor.theme_bar_gradient_1 : Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.auto),
                  child: Text(
                    message,
                      style: TextStyle(color:Colors.black, fontSize: 17.auto, fontWeight: FontWeight.bold)
                  ),
                ),
                Container(
                  width: context.screenWidth * 0.4,
                  padding: EdgeInsets.all(10.auto),
                  child: ColorButton(
                    title: title,
                    onClick: () {
                      for (int i = 0; i < popCount; i++) {
                        Navigator.of(context).pop();
                      }
                    },
                    isEnabled: true,
                    color: CustomColor.theme_button_color,
                    radius: 9.6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
