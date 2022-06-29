import 'package:api/entity/env_features_config.dart';
import 'package:api/entity/game_provider.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/home/child_game/child_game.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/game/game_web_view.dart';
import 'package:url_launcher/url_launcher.dart';

class GameItemT3 extends StatefulWidget {
  final String? gamePlatformCode;
  final GameType? gameType;
  final int? index;
  final EnvFeaturesConfig? config;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;

  GameItemT3(
      {this.gamePlatformCode, this.gameType, this.index, this.config, this.onPauseBgMusic, this.onResumeBgMusic});

  @override
  _GameItemT3State createState() => _GameItemT3State();
}

class _GameItemT3State extends BaseState<GameItemT3> {
  var _vm = GameViewModel();
  var gameName;

  double _imageRatio = 750 / 330;

  @override
  void initState() {
    _vm.getGameProviderList(isRefresh: true);
    super.initState();
  }

  List<dynamic>? _getGameTypeMap() {
    if (_vm.gameTypeMap?.isEmpty ?? true)
      return null;
    else
      return _vm.gameTypeMap![widget.gameType]!;
  }

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<GameViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return ScrollConfiguration(
              behavior: MyBehavior(),
              child: CustomScaffold(
                  appBar: CustomAppBar(
                    title: getTranslatedText(widget.gameType!.getName(context, false)),
                    isPassTrueWhenPop: true,
                  ),
                  body: _getGameTypeMap() == null
                      ? buildProgressDialog(_vm.brandLogoUrl)
                      : ListView(
                          padding: EdgeInsets.only(bottom: 15.auto),
                          children: _getGameTypeMap()!
                              .map((item) => Container(
                                  margin: EdgeInsets.only(top: 15.auto, left: 15.auto, right: 15.auto),
                                  child: _buildImageLayout(item)))
                              .toList())));
        });
  }

  _getImagePath(GameProvider2 gameProvider) {
    var gameType = gameProvider.gameType?.getImagePath();
    var gamePlatformCode = gameProvider.code?.toLowerCase();
    //var imagePath = "images/game/T3/${gameType}_${gamePlatformCode}.png";
    var imagePath;
    if (_isSportsHideLogo(gamePlatformCode))
      imagePath = "images/game/T3/$gameType-$gamePlatformCode-hkjp.jpg";
    else
      imagePath = "images/game/T3/${gameType == "" ? "sports" : gameType}-$gamePlatformCode.jpg";
    return imagePath;
  }

  _buildImageLayout(GameProvider2 gameProvider) {
    var gamePlatformCode = gameProvider.code?.toLowerCase();

    return InkWell(
      onTap: () {
        if (gameProvider.status != 0) {
        } else
          _onGameClick(gameProvider);
      },
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: _imageRatio,
            child: gameProvider.status != 0
                ? ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black,
                      BlendMode.saturation,
                    ),
                    child: _buildImage(gameProvider))
                : _buildImage(gameProvider),
          ),
          Positioned(
            bottom: context.screenWidth / 15,
            left: context.screenWidth / 6,
            child: Column(
              children: [
                (_isSportsHideLogo(gamePlatformCode))
                    ? Container(
                        width: 74.auto,
                        margin: EdgeInsets.only(bottom: 15.auto),
                        child: Text(
                          getTranslatedText("sports_$gamePlatformCode"),
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Container(),
                gameProvider.status != 0
                    ? ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.black,
                          BlendMode.saturation,
                        ),
                        child: _buildStartGameButton())
                    : _buildStartGameButton(),
              ],
            ),
          ),
          Visibility(
            visible: gameProvider.status != 0,
            child: AspectRatio(
              aspectRatio: _imageRatio,
              child: Container(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.4)),
                child: Center(
                  child: Text(getTranslatedText("maintenance"),
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.auto)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildStartGameButton() => Container(
        width: 74.auto,
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 5.auto, bottom: 5.auto),
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage("images/game/T3/btn-start-game.jpg"))),
        child: Text(
          getTranslatedText("start_game"),
          style: TextStyle(
            fontSize: 10.auto,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  _buildImage(GameProvider2 gameProvider) => ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
          alignment: Alignment.center,
          child: Image.asset(
            _getImagePath(gameProvider),
            fit: BoxFit.cover,
          )));

  _onGameClick(GameProvider2 gameProvider) {
    if (_vm.userProfile == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          title: getTranslatedText("login_hint"),
          description: getTranslatedText("login_dialog_des"),
          buttonText1: getTranslatedText("login_or_signup"),
          buttonText2: getTranslatedText("got_it"),
          onClick: this.navigateToLogin,
          onClick2: () {
            Navigator.pop(context);
          },
          popIndex: 2,
        ),
      );
    } else
      _navigate(gameProvider.code, gameProvider.gameType);
  }

  _navigate(String? gamePlatformCode, GameType? gameType) async {
    // if (_isSWGame(gamePlatformCode, gameType)) {
    if (_isSWGame(gamePlatformCode, gameType) || _isSGGame(gamePlatformCode))
      await _vm.getLobbyGameUrl(gamePlatformCode!, gameType!, EnvironmentConfig.url);
    else if (_isTcgGame(gamePlatformCode)) {
      await _vm.getGameList(gamePlatformCode, gameType);
      await _vm.getGameUrl(gamePlatformCode!, _vm.gameListMap[gamePlatformCode]!.first.id!, EnvironmentConfig.url);
      // }
      /*WidgetsBinding.instance!.addPostFrameCallback((_) {
        launch(_vm.url!);
      });*/
    } else if (gameType == GameType.Slot || gameType == GameType.EGame || gameType == GameType.Fishing) {
      //navigate to child game
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChildGame(
                      gamePlatformCode: gamePlatformCode,
                      gameType: gameType,
                      onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                      onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                    )));
      });
    } else if (gameType == GameType.Lottery || gameType == GameType.LotteryLobby) {
      //only tcg will need to get gamelist
      await _vm.getGameList(gamePlatformCode, gameType);
      if (widget.onPauseBgMusic != null) widget.onPauseBgMusic!();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GameWeb(
                    gamePlatformCode: gamePlatformCode,
                    gameType: gameType,
                    gameId: _vm.gameListMap[gamePlatformCode]!.first.id,
                    onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                    onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                  )));
    } else {
      //navigate to game web
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        if (widget.onPauseBgMusic != null) widget.onPauseBgMusic!();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GameWeb(
                      gamePlatformCode: gamePlatformCode,
                      gameType: gameType,
                      onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                      onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                    )));
      });
    }
  }

  navigateToLogin() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(RoutePath.login);
    });
  }

  _isSportsHideLogo(String? gamePlatformCode) =>
      (widget.config?.sportsHideLogo ?? false) && (gamePlatformCode == "wgfm" || gamePlatformCode == "wgvia");

  _isTcgGame(String? gamePlatformCode) =>
      gamePlatformCode == "TCG_SEA" || gamePlatformCode == "TCG_LOTTO" || gamePlatformCode == "TCG_LOTTO_VN";

  _isSWGame(String? gamePlatformCode, GameType? gameType) =>
      (gamePlatformCode == "SW" && gameType == GameType.LiveDealerLobby);

  _isSGGame(String? gamePlatformCode) => gamePlatformCode == "SG";

  _handleApiState() {
    handleApiState(_vm.getGameProviderListApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getGameApiState, onSuccess: () {});

    handleApiState(_vm.getLobbyGameUrlApiState, onSuccess: () {
      if (_vm.url == null)
        _navigateToMaintenance();
      else
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          launch(_vm.url!);
        });
    }, onError: (_) {
      _navigateToMaintenance();
    });

    handleApiState(_vm.getGameUrlApiState, onSuccess: () {
      if (_vm.url == null)
        _navigateToMaintenance();
      else
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          launch(_vm.url!);
        });
    }, onError: (_) {
      _navigateToMaintenance();
    });
  }

  _navigateToMaintenance() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(RoutePath.maintenance);
    });
  }
}
