import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/leave_game_dialog.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';

class WebGameView extends StatefulWidget {
  final String? gameProvider;

  WebGameView({
    this.gameProvider,
  });

  @override
  _GameWebState createState() => _GameWebState();
}

class _GameWebState extends BaseState<WebGameView> {
  var _vm = GameViewModel();
  InAppWebViewController? _webViewController;
  var isLoading = false;
  String? url, lobbyUrl;
  var prefs;

  @override
  void initState() {
    lobbyUrl = EnvironmentConfig.url;
    _getSharedPrefs();
    super.initState();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _webViewController!.goBack();
        _webViewController!.goBack();
        return true;
      },
      child: ProviderWidget<GameViewModel>(
          model: _vm,
          builder: (ctx, vm, _) {
            _handleApiState();
            return CustomScaffold(
              appBar: _buildAppBar(),
              body: _buildWebView(),
            );
          }),
    );
  }

  _buildAppBar() => CustomAppBar(
        title: getTranslatedText("game"),
        widget: Container(
          margin: EdgeInsets.all(5.auto),
          alignment: Alignment.center,
        ),
        onPop: () {
          Navigator.pop(context);
        },
      );

  _getSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  _buildWebView() {
    var apiUrl = EnvironmentConfig.url + "api/game/" + widget.gameProvider!;
    return InAppWebView(
      initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true, useShouldOverrideUrlLoading: true),
          android: AndroidInAppWebViewOptions(
            useWideViewPort: true,
            domStorageEnabled: true,
            mixedContentMode:
                AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          ),
          ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true)),
      onWebViewCreated: (InAppWebViewController controller) {
        _webViewController = controller;
        _webViewController!.loadUrl(
            urlRequest: URLRequest(url: Uri.parse(apiUrl), headers: {
          "Authentication": "bearer " + prefs.getString("auth_token")!,
          "token": prefs.getString("token")!
        }));
      },
      onExitFullscreen: (InAppWebViewController controller) {
        Navigator.pop(
          context,
        );
      },
      onLoadStart: (controller, url) {},
      onLoadStop: (controller, url) async {},
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        var uri = navigationAction.request.url;
        if (uri == Uri.parse(lobbyUrl!)) {
          showDialog(
            context: context,
            builder: (BuildContext context) => LeaveGameDialog(),
          );
          return NavigationActionPolicy.CANCEL;
        } else {
          return NavigationActionPolicy.ALLOW;
        }
      },
    );
  }

  _handleApiState() {
    handleApiState(_vm.getGameUrlApiState, isAutoHideLoading: false,
        onSuccess: () {
      if (isLoading) {
        isLoading = !isLoading;
      }
      if (_vm.url == null) _navigateToMaintenance();
      url = _vm.url;
    }, onError: (_) {
      _navigateToMaintenance();
    });
    handleApiState(_vm.getLobbyGameUrlApiState, isAutoHideLoading: false,
        onSuccess: () {
      if (isLoading) {
        isLoading = !isLoading;
      }
      if (_vm.url == null) _navigateToMaintenance();
      url = _vm.url;
    }, onError: (_) {
      _navigateToMaintenance();
    });
  }

  _navigateToMaintenance() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(RoutePath.maintenance);
    });
  }
}
