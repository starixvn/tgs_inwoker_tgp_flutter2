import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
//import 'package:webview_flutter/webview_flutter.dart';

class DepositWeb extends StatefulWidget {
  final String url;

  DepositWeb({
    Key key,
    this.url,
  }) : super(key: key);

  @override
  _DepositWebState createState() => _DepositWebState();
}

class _DepositWebState extends BaseState<DepositWeb> {
  InAppWebViewController _webViewController;

  Widget build(BuildContext context) {
    print("url=${widget.url}");
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: gradientDecoration,
          ),
          centerTitle: true,
          title: Text(
            getTranslatedText("deposit"),
            style: TextStyle(fontSize: 20.auto),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: InAppWebView(
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
        ));
  }
}
