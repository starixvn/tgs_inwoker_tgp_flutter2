import 'package:lottie/lottie.dart';
import 'package:ndialog/ndialog.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
//import 'package:progress_dialog/progress_dialog.dart';

CustomProgressDialog _progressDialog;

class ProgressDialog {
  ProgressDialog.show(BuildContext context) {
    create(context);
    _progressDialog.show();
  }

  ProgressDialog.hide() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _progressDialog.dismiss();
    });
  }

  create(BuildContext context) {
    _progressDialog = CustomProgressDialog(context, blur: 2, dismissable: false);
    _progressDialog.setLoadingWidget(Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 100, height: 100, child: Image.asset("images/login/${EnvironmentConfig.imageLogo}.png")),
        //CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(CustomColor.theme_bar_gradient_2))
        Lottie.asset(
          "loading/loading.json",
          width: 150,
          height: 150,
        ),
      ],
    ));
  }
}
