import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:tgp_flutter2/custom/leave_game_dialog.dart';
import 'package:api/entity/game_type.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';

class GameWeb extends StatefulWidget {
  final int gameId;
  final String gamePlatformCode;
  final GameType gameType;

  GameWeb({Key key, this.gameId, this.gameType, this.gamePlatformCode}) : super(key: key);

  @override
  _GameWebState createState() => _GameWebState();
}


class _GameWebState extends BaseState<GameWeb> {
  var _vm = GameViewModel();

  InAppWebViewController _webViewController;

  //WebViewController _webViewController;
  var isLoading = false;
  String url, lobbyUrl;
  FlutterWebviewPlugin webviewPlugin = FlutterWebviewPlugin();

  @override
  void initState() {
    lobbyUrl =
        "http://gci.aggdemo.com:81/forwardGame.do?params=4DJlwdGL1cWclbwxZFKgtr6rJmU8Mqe0y4VXswlHs8uWLV/LAwtfY9/SYLWTh/MBrOQNAdd/nZiuIaXx1/ZDX71ziYHXpHj9WeekhidF60CbLBd9VFlD9EYcWQOX7ALM/w3Ww5Yy86wEsd/IgnUTGwU7vX+3btJezXPCNriz+iYgg9d9jU6yEAXdEN0H7L/tkDdt8IWJGjAqQ2334aF5vlPc2f7DCzM7&key=8dc57f4377fc86da1d0d9e47495993e0";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.gameType == null)
        _vm.getGameUrl(widget.gamePlatformCode, widget.gameId, lobbyUrl);
      else
        _vm.getLobbyGameUrl(widget.gamePlatformCode, widget.gameType, lobbyUrl);
    });
    if (isHabaPPGamePlatform()) {
      webviewPlugin.onUrlChanged.listen((String url) {
        if (url == lobbyUrl) {
          _displayDialog();
        }
      });
    }
    super.initState();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _displayDialog(),
      child: ProviderWidget<GameViewModel>(
          model: _vm,
          builder: (ctx, vm, _) {
            _handleApiState();
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: CustomColor.theme_bg_color,
              appBar: _buildAppBar(),
              body: isLoading || url == null ? buildProgressDialog() : _buildWebView(),
            );
          }),
    );
  }

  _buildAppBar() => AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: gradientDecoration,
        ),
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
      );

  _buildWebView() {
    return isHabaPPGamePlatform()
        ? WebviewScaffold(
            url: _getValidUrl(url),
            withZoom: false,
            withLocalStorage: true,
            withJavascript: true,
            useWideViewPort: true,
            hidden: true,
          )
        : InAppWebView(
            initialUrl: _getValidUrl(url),
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                    debuggingEnabled: true, javaScriptEnabled: true, useShouldOverrideUrlLoading: true),
                android: AndroidInAppWebViewOptions(
                  useWideViewPort: true,
                  mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                )),
            onWebViewCreated: (InAppWebViewController controller) {
              _webViewController = controller;
              _webViewController.loadUrl(url: _getValidUrl(url));
            },
            onExitFullscreen: (InAppWebViewController controller) {
              Navigator.pop(
                context,
              );
            },
            onLoadStart: (InAppWebViewController controller, String url) {
              //ProgressDialog.show(context);
            },
            onLoadStop: (InAppWebViewController controller, String url) async {
              // ProgressDialog.hide();
            },
            shouldOverrideUrlLoading: (controller, shouldOverrideUrlLoadingRequest) async {
              if (shouldOverrideUrlLoadingRequest.url == lobbyUrl) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => LeaveGameDialog(),
                );
                return ShouldOverrideUrlLoadingAction.CANCEL;
              } else {
                return ShouldOverrideUrlLoadingAction.ALLOW;
              }
            },
          );
  }

  _getValidUrl(String url) {
    if (url != null) {
      if ((url.contains("https://") || url.contains("http://"))) {
        return url;
      } else {
        return "https:" + url;
      }
    }
  }

  _displayDialog() {
    if (isHabaPPGamePlatform()) webviewPlugin.close();
    showDialog(
      context: context,
      builder: (BuildContext context) => LeaveGameDialog(),
    );
  }

  _loadWebView() {
    isLoading = true;
    if (widget.gameType == null)
      _vm.getGameUrl(widget.gamePlatformCode, widget.gameId, lobbyUrl);
    else
      _vm.getLobbyGameUrl(widget.gamePlatformCode, widget.gameType, lobbyUrl);
  }

  isHabaPPGamePlatform() {
    return widget.gamePlatformCode == "PP" || widget.gamePlatformCode == "HABA";
  }

  _handleApiState() {
    handleApiState(_vm.getGameUrlApiState, isAutoHideLoading: false, onSuccess: () {
      if (isLoading) {
        isLoading = !isLoading;
      }
      url = _vm.url;
    });
    handleApiState(_vm.getLobbyGameUrlApiState, isAutoHideLoading: false, onSuccess: () {
      if (isLoading) {
        isLoading = !isLoading;
      }
      url = _vm.lobbyUrl;
    });
  }
}
