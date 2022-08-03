import 'package:flutter/material.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/home/child_game/child_game.dart';
import 'package:tgp_flutter2/ui/home/game/game_T4/game_T4.dart';
import 'package:tgp_flutter2/ui/home/game/game_t1/game_item_t1.dart';
import 'package:tgp_flutter2/ui/home/game/game_t1/game_t1.dart';
import 'package:tgp_flutter2/ui/home/game/game_t10/game_t10.dart';
import 'package:tgp_flutter2/ui/home/game/game_t2/game_t2.dart';
import 'package:tgp_flutter2/ui/home/game/game_t3/game_t3.dart';
import 'package:tgp_flutter2/ui/home/game/game_t8/game_t8.dart';
import 'package:tgp_flutter2/ui/home/game/game_t9/game_t9.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/game/game_web_view.dart';
import 'package:url_launcher/url_launcher.dart';

class BaseGame extends StatefulWidget {
  final GameViewModel vm;
  final Function onRefreshHomePage;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;

  BaseGame({
    required this.vm,
    required this.onRefreshHomePage,
    this.onPauseBgMusic,
    this.onResumeBgMusic,
  });

  @override
  _BaseGameState createState() => _BaseGameState();
}

class _BaseGameState extends BaseState<BaseGame> {
  var currentTabIndex = 0, currentGameType, currentGamePlatformCode;
  var gameName;
  GlobalKey<GameItemT1State> gameViewItem = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<GameViewModel>(
        model: widget.vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return widget.vm.gameProviderList == null
              ? buildProgressDialog(widget.vm.brandLogoUrl)
              : _getGameTemplateView();
        });
  }

  _getGameTemplateView() {
    switch (EnvironmentConfig.template_version) {
      case 1:
        return GameT1(
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          vm: widget.vm,
          onRefreshHomePage: () => widget.onRefreshHomePage,
          onGameClick: (gameProvider) => _onGameClick(gameProvider),
        );
      case 2:
        return GameT2(
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          vm: widget.vm,
          onRefreshHomePage: () => widget.onRefreshHomePage,
          onGameClick: (gameProvider) => _onGameClick(gameProvider),
        );
      case 3:
        return GameT3(
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          vm: widget.vm,
          onRefreshHomePage: () => widget.onRefreshHomePage,
          onGameClick: (gameProvider) => _onGameClick(gameProvider),
        );
      case 4:
        return GameT4(
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          vm: widget.vm,
          onRefreshHomePage: () => widget.onRefreshHomePage,
          onGameClick: (gameProvider) => _onGameClick(gameProvider),
        );
      case 8:
        return GameT8(
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          vm: widget.vm,
          onRefreshHomePage: () => widget.onRefreshHomePage,
          onGameClick: (gameProvider) => _onGameClick(gameProvider),
        );
      case 9:
        return GameT9(
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          vm: widget.vm,
          onRefreshHomePage: () => widget.onRefreshHomePage,
          onGameClick: (gameProvider) => _onGameClick(gameProvider),
        );
      case 10:
        return GameT10(
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          vm: widget.vm,
          onRefreshHomePage: () => widget.onRefreshHomePage,
          onGameClick: (gameProvider) => _onGameClick(gameProvider),
        );
      default:
        return GameT1(
          onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
          onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
          vm: widget.vm,
          onRefreshHomePage: () => widget.onRefreshHomePage,
          onGameClick: (gameProvider) => _onGameClick(gameProvider),
        );
    }
  }

  _onGameClick(GameProvider2 gameProvider) {
    if (widget.vm.userProfile == null) {
      showPreLoginDialog();
    } else {
      setState(() {
        currentGameType = gameProvider.gameType!;
        currentGamePlatformCode = gameProvider.code;
      });
      _navigate();
    }
  }

  _navigate() async {
    if (_isSWGame() || _isSGGame())
      await widget.vm.getLobbyGameUrl(currentGamePlatformCode!, currentGameType, EnvironmentConfig.url);
    else if (_isTcgGame()) {
      await widget.vm.getGameList(currentGamePlatformCode, currentGameType);
      await widget.vm.getGameUrl(
          currentGamePlatformCode, widget.vm.gameListMap[currentGamePlatformCode]!.first.id!, EnvironmentConfig.url);
    } else if (_isChildGame()) {
      //navigate to child game
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChildGame(
                      gamePlatformCode: currentGamePlatformCode,
                      gameType: currentGameType,
                      onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                      onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                    )));
      });
    } else if (currentGameType == GameType.Lottery || currentGameType == GameType.LotteryLobby) {
      //only tcg will need to get gamelist
      await widget.vm.getGameList(currentGamePlatformCode, currentGameType);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.onPauseBgMusic != null) widget.onPauseBgMusic!();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GameWeb(
                      gamePlatformCode: currentGamePlatformCode,
                      gameType: currentGameType,
                      gameId: widget.vm.gameListMap[currentGamePlatformCode]!.first.id,
                      onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                      onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                    )));
      });
    } else {
      //navigate to game web
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.onPauseBgMusic != null) widget.onPauseBgMusic!();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GameWeb(
                      gamePlatformCode: currentGamePlatformCode,
                      gameType: currentGameType,
                      onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                      onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                    )));
      });
    }
  }

  _isTcgGame() =>
      currentGamePlatformCode == "TCG_SEA" ||
      currentGamePlatformCode == "TCG_LOTTO" ||
      currentGamePlatformCode == "TCG_LOTTO_VN";

  _isSWGame() => (currentGamePlatformCode == "SW" && currentGameType == GameType.LiveDealerLobby);

  _isSGGame() => currentGamePlatformCode == "SG";

  _isChildGame() => (currentGameType == GameType.Slot ||
      currentGameType == GameType.EGame ||
      currentGameType == GameType.Fishing ||
      currentGameType == GameType.VirtualSports);

  _handleApiState() {
    handleApiState(widget.vm.getGameProviderListApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(widget.vm.getGameApiState, onSuccess: () {});

    handleApiState(widget.vm.getLobbyGameUrlApiState, onSuccess: () {
      if (widget.vm.url == null)
        _navigateToMaintenance();
      else if (_isSWGame() || _isSGGame() || _isTcgGame())
        WidgetsBinding.instance.addPostFrameCallback((_) {
          launch(widget.vm.url!);
        });
    }, onError: (_) {
      _navigateToMaintenance();
    });

    handleApiState(widget.vm.getGameUrlApiState, onSuccess: () {
      if (widget.vm.url == null)
        _navigateToMaintenance();
      else if (_isSWGame() || _isSGGame() || _isTcgGame())
        WidgetsBinding.instance.addPostFrameCallback((_) {
          launch(widget.vm.url!);
        });
    }, onError: (_) {
      _navigateToMaintenance();
    });
  }

  _navigateToMaintenance() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isSWGame() || _isSGGame() || _isTcgGame())
        Navigator.of(context).pushNamed(RoutePath.maintenance);
      else
        Navigator.of(context).pushReplacementNamed(RoutePath.maintenance);
    });
  }
}
