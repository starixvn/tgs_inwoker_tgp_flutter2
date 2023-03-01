import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';

class CustomerServiceWebView extends StatefulWidget {
  final String? url;
  final String? brandLogoUrl;

  CustomerServiceWebView({this.url, this.brandLogoUrl});

  @override
  _CustomerServiceWebViewState createState() => _CustomerServiceWebViewState();
}

class _CustomerServiceWebViewState extends BaseState<CustomerServiceWebView> {
  InAppWebViewController? _webViewController;

  // var url = EnvironmentConfig.csUrl;
//  CustomerServiceViewModel _vm = CustomerServiceViewModel();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        title: getTranslatedText("customer_service") == "customer_service"
            ? "Customer Service"
            : getTranslatedText("customer_service"),
      ),
      body: widget.url == null
          ? buildProgressDialog(widget.brandLogoUrl!)
          : InAppWebView(
              initialUrlRequest: URLRequest(url: Uri.parse(widget.url!)),
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
                _webViewController!.loadUrl(urlRequest: URLRequest(url: Uri.parse(widget.url!)));
              },
              androidOnPermissionRequest:
                  (InAppWebViewController controller, String origin, List<String> resources) async {
                await Permission.camera.request();
                return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
              }),
    );
  }
}
