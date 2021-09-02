import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';


class CustomerServiceWebView extends StatefulWidget {
  final String url;

  CustomerServiceWebView({
    Key key,
    this.url,
  }) : super(key: key);

  @override
  _CustomerServiceWebViewState createState() => _CustomerServiceWebViewState();
}

class _CustomerServiceWebViewState extends BaseState<CustomerServiceWebView> {
  InAppWebViewController _webViewController;
  var url = EnvironmentConfig.csUrl;
//  CustomerServiceViewModel _vm = CustomerServiceViewModel();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title:getTranslatedText("customer_service"),
      ),
      body: widget.url == null
          ? buildProgressDialog()
          : InAppWebView(
        initialUrl: widget.url,
        initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              debuggingEnabled: true,
              javaScriptEnabled: true,
            ),
            android: AndroidInAppWebViewOptions(
              useWideViewPort: true,
              mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
            )),
        onWebViewCreated: (InAppWebViewController controller) {
          _webViewController = controller;
          _webViewController.loadUrl(url: widget.url);
        },
        onLoadStart: (InAppWebViewController controller, String url) {
          ProgressDialog.show(context);
        },
        onLoadStop: (InAppWebViewController controller, String url) async {
          ProgressDialog.hide();
        },
      ),
    );
  }
}
