import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'package:ndialog/ndialog.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
//import 'package:progress_dialog/progress_dialog.dart';

CustomProgressDialog _progressDialog;

class ProgressDialog {
  ProgressDialog.show(BuildContext context, String url) {
    create(context, url);

    _progressDialog.show();
  }

  ProgressDialog.hide() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _progressDialog.dismiss();
    });
  }

  create(BuildContext context, String url) {
    _progressDialog = CustomProgressDialog(context, blur: 2, dismissable: false);
    _progressDialog.setLoadingWidget(Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CachedNetworkImage(
          placeholder: (context, url) => Container(),
          imageUrl: url,
          width: 200.auto,
          //handling error
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => Container(),
        ),
        //CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(CustomColor.theme_bar_gradient_2))
        Lottie.asset(
          "loading/loading_t${EnvironmentConfig.template_version}.json",
          width: 150,
          height: 150,
        ),
      ],
    ));
  }
}
