import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';

//import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:tgp_flutter2/custom/leave_game_dialog.dart';
import 'package:api/entity/game_type.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';

class GameWeb extends StatefulWidget {
  final int? gameId;
  final String? gamePlatformCode;
  final GameType? gameType;
  final Function? onResumeBgMusic;
  final Function? onPauseBgMusic;

  GameWeb({
    this.gameId,
    this.gameType,
    this.gamePlatformCode,
    this.onResumeBgMusic,
    this.onPauseBgMusic,
  });

  @override
  _GameWebState createState() => _GameWebState();
}

class _GameWebState extends BaseState<GameWeb> {
  var _vm = GameViewModel();
  InAppWebViewController? _webViewController;
  var isLoading = false;
  String? url, lobbyUrl;
  var prefs;

  @override
  void initState() {
    lobbyUrl = EnvironmentConfig.url;

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.gameType == null || widget.gameId == 1800001 || widget.gameId == 1800002 || widget.gameId == 1800003)
        _vm.getGameUrl(widget.gamePlatformCode!, widget.gameId!, lobbyUrl!);
      else
        _vm.getLobbyGameUrl(widget.gamePlatformCode!, widget.gameType!, lobbyUrl!);
    });
    /*if (isHabaPPGamePlatform()) {
      webviewPlugin.onUrlChanged.listen((String url) {
        if (url == lobbyUrl) {
          _displayDialog();
        }
      });
    }*/
    if (widget.onPauseBgMusic != null) widget.onPauseBgMusic!();
    _getSharedPrefs();
    super.initState();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //handle full screen web view
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
              body: isLoading || url == null ? buildProgressDialog(_vm.brandLogoUrl) : _buildWebView(),
            );
          }),
    );
  }

  _buildAppBar() => CustomAppBar(
        title: getTranslatedText("game"),
        widget: Container(
          margin: EdgeInsets.all(5.auto),
          alignment: Alignment.center,
          child: IconButton(
            icon: Image.asset("images/ic_refresh.png"),
            onPressed: () {
              _loadWebView();
            },
          ),
        ),
        onPop: () {
          if (widget.onResumeBgMusic != null) widget.onResumeBgMusic!();
          Navigator.pop(context);
        },
      );

  /*AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          getTranslatedText("game"),
          style: TextStyle(fontSize: 20.auto),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => _displayDialog(),
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(10.auto),
            alignment: Alignment.center,
            child: IconButton(
              icon: Image.asset("images/ic_refresh.png"),
              onPressed: () {
                _loadWebView();
              },
            ),
          ),
        ],
      );*/

  _getSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  _buildWebView() {
    var apiUrl = EnvironmentConfig.url + "api/game/bc";
    return /* isHabaPPGamePlatform()
        ? WebviewScaffold(
            url: _getValidUrl(_vm.url!),
            withZoom: false,
            withLocalStorage: true,
            withJavascript: true,
            useWideViewPort: true,
            hidden: true,
          )
        : */
        InAppWebView(
      initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(javaScriptEnabled: true, useShouldOverrideUrlLoading: true),
          android: AndroidInAppWebViewOptions(
            useWideViewPort: true,
            domStorageEnabled: true,
            mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          ),
          ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true)),
      onWebViewCreated: (InAppWebViewController controller) {
        _webViewController = controller;
        _webViewController!.loadUrl(
            urlRequest: widget.gamePlatformCode == "BC"
                ? //bet construct only
                URLRequest(url: Uri.parse(apiUrl), headers: {
                    "Authentication": "bearer " + prefs.getString("auth_token")!,
                    "token": prefs.getString("token")!
                  })
                : URLRequest(url: Uri.parse(_getValidUrl(_vm.url!))));
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

  _getValidUrl(String? url) {
    if (url != null) {
      if ((url.contains("https://") || url.contains("http://"))) {
        return url;
      } else {
        return "https:" + url;
      }
    }
  }

  _displayDialog() {
    // if (isHabaPPGamePlatform()) webviewPlugin.close();
    showDialog(
      context: context,
      builder: (BuildContext context) => LeaveGameDialog(),
    );
  }

  _loadWebView() {
    isLoading = true;
    if (widget.gameType == null || widget.gameId == 1800001 || widget.gameId == 1800002 || widget.gameId == 1800003)
      _vm.getGameUrl(widget.gamePlatformCode!, widget.gameId!, lobbyUrl!);
    else
      _vm.getLobbyGameUrl(widget.gamePlatformCode!, widget.gameType!, lobbyUrl!);
  }

  isHabaPPGamePlatform() {
    return widget.gamePlatformCode == "PP" || widget.gamePlatformCode == "HABA";
  }

  _handleApiState() {
    handleApiState(_vm.getGameUrlApiState, isAutoHideLoading: false, onSuccess: () {
      if (isLoading) {
        isLoading = !isLoading;
      }
      if (_vm.url == null) _navigateToMaintenance();
      url = _vm.url;
    }, onError: (_) {
      _navigateToMaintenance();
    });
    handleApiState(_vm.getLobbyGameUrlApiState, isAutoHideLoading: false, onSuccess: () {
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
