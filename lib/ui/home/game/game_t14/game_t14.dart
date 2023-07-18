import 'package:api/entity/game.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/home/game/game_t11/game_item_t11.dart';
import 'package:tgp_flutter2/ui/home/game/game_t14/game_item_t14.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/jackpot/jackpot.dart';

import '../../../../provider/provider_widget.dart';
import '../../../../route_path.dart';

class GameT14 extends StatefulWidget {
  final GameViewModel vm;
  final Function onRefreshHomePage;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final ValueChanged<GameProvider2> onGameClick;
  final ValueChanged<bool> onClickGameTab;
  final ValueChanged<Game> onClickChildGame;
  final GameType currGameType;

  GameT14({
    required this.vm,
    required this.onRefreshHomePage,
    this.onPauseBgMusic,
    this.onResumeBgMusic,
    required this.onGameClick,
    required this.onClickGameTab,
    required this.onClickChildGame,
    required this.currGameType,
  });

  @override
  _GameT14State createState() => _GameT14State();
}

class _GameT14State extends BaseState<GameT14> {
  var _controller = ScrollController();
  var currentTabIndex, currentGamePlatformCode;
  var gameName;
  GlobalKey<GameItemT11State> gameViewItem = GlobalKey();
  var isDisplayGameView = false;
  String currGamePlatformCode = "";

  @override
  void initState() {
    //_controller.addListener(_scrollListener);
    _initData();
    super.initState();
  }

  _initData() async {
    var task = <Future>[];
    // task.add(widget.vm.getPlatformList(GameType.Slot));
    // currGamePlatformCode = (widget.vm.platformList ?? []).first.code ?? "";
    // task.add(widget.vm.getGameList(currGamePlatformCode, GameType.Slot));
    //
    // task.add(widget.vm.filter(category: 0, gamePlatformCode: currGamePlatformCode, gameType: GameType.Slot));
    //
    // await Future.wait(task);
    //
    // print(widget.vm.filteredGameList);

    await widget.vm.getPlatformList(GameType.Slot);
    currGamePlatformCode = (widget.vm.platformList ?? []).first.code ?? "";
    await widget.vm.getGameList(currGamePlatformCode, GameType.Slot);
    await widget.vm.filter(category: 0, gamePlatformCode: currGamePlatformCode, gameType: GameType.Slot);
  }

  @override
  Widget build(BuildContext context) {
    // return ProviderWidget<GameViewModel>(
    //     model: widget.vm,
    //     builder: (ctx, vm, _) {
    //       _handleApiState();
    return /*widget.vm.gameProviderList == null
              ? buildProgressDialog(widget.vm.brandLogoUrl)
              :*/
        Container(
      // width: context.screenWidth,
      // height: context.screenHeight - context.screenWidth / 6,
      color: Color(0xff000325),
      child: GameItemT14(
        gameViewItem,
        controller: _controller,
        gameProviderList: _getGameTypeMap(),
        onGameClick: (game) => widget.onGameClick(game),
        config: widget.vm.config,
        vm: widget.vm,
      ),
    );
    // });
  }

  _getGameTypeMap() {
    return widget.vm.gameTypeMap![widget.currGameType];
  }

  _handleApiState() {
    handleApiState(widget.vm.getGameProviderListApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(widget.vm.getGameApiState, onSuccess: () {});

    handleApiState(widget.vm.getLobbyGameUrlApiState, onSuccess: () {
      if (widget.vm.url == null) _navigateToMaintenance();
      // else if (_isSWGame() || _isSGGame() || _isTcgGame())
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     launch(widget.vm.url!);
      //   });
    }, onError: (_) {
      _navigateToMaintenance();
    });

    handleApiState(widget.vm.getGameUrlApiState, onSuccess: () {
      if (widget.vm.url == null) _navigateToMaintenance();
      // else if (_isSWGame() || _isSGGame() || _isTcgGame())
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     launch(widget.vm.url!);
      //   });
    }, onError: (_) {
      _navigateToMaintenance();
    });
  }

  _navigateToMaintenance() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if (_isSWGame() || _isSGGame() || _isTcgGame())
      //   Navigator.of(context).pushNamed(RoutePath.maintenance);
      // else
      Navigator.of(context).pushReplacementNamed(RoutePath.maintenance);
    });
  }
}
