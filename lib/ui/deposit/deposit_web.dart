import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
//import 'package:webview_flutter/webview_flutter.dart';

class DepositWeb extends StatefulWidget {
  final String? url;
  final String? brandLogoUrl;

  DepositWeb({

    this.url,
    this.brandLogoUrl
  }) ;

  @override
  _DepositWebState createState() => _DepositWebState();
}

class _DepositWebState extends BaseState<DepositWeb> {
  InAppWebViewController? _webViewController;

  Widget build(BuildContext context) {
    print("url=${widget.url}");
    return CustomScaffold(
        appBar: CustomAppBar(
          title: getTranslatedText("deposit"),
        ) ,
        body: InAppWebView(
          initialUrlRequest: URLRequest(url:Uri.parse(widget.url!)),
          //initialUrl: widget.url,
          initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                //debuggingEnabled: true,
                javaScriptEnabled: true,
              ),
              android: AndroidInAppWebViewOptions(
                useWideViewPort: true,
                mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              )),
          onWebViewCreated: (InAppWebViewController controller) {
            _webViewController = controller;
            _webViewController!.loadUrl(urlRequest: URLRequest(url:Uri.parse(widget.url!)),);
          },
          onLoadStart: ( controller,  url) {
            ProgressDialog.show(context, widget.brandLogoUrl);
          },
          onLoadStop: ( controller,  url) async {
            ProgressDialog.hide();
          },
        ));
  }
}
