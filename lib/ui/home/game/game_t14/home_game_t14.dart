import 'package:api/entity/game.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:signalr_netcore/json_hub_protocol.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/home/game/game_t1/game_item_t1.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';

import '../../../../provider/provider_widget.dart';
import 'game_suggest_t14.dart';

class HomeGameT14 extends StatefulWidget {
  final GameViewModel vm;
  final Function onRefreshHomePage;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final ValueChanged<GameProvider2> onGameClick;

  HomeGameT14({
    required this.vm,
    required this.onRefreshHomePage,
    this.onPauseBgMusic,
    this.onResumeBgMusic,
    required this.onGameClick,
  });

  @override
  _HomeGameT14State createState() => _HomeGameT14State();
}

class _HomeGameT14State extends BaseState<HomeGameT14> {
  var _controller = ScrollController();
  var currentTabIndex = 0, currentGameType, currentGamePlatformCode;
  var gameName;
  GlobalKey<GameItemT1State> gameViewItem = GlobalKey();
  String currGamePlatformCode = "";

  @override
  void initState() {
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
    await widget.vm.getGameProviderList(isRefresh: true);
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
    return (widget.vm.filteredGameList?.isEmpty ?? true)
        ? buildProgressDialog(widget.vm.brandLogoUrl)
        : ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(10),
            physics: ClampingScrollPhysics(),
            children: [
              GameSuggestT14(vm: widget.vm, titleType: 'Top Games'),
              GameSuggestT14(vm: widget.vm, titleType: 'Recommend For You'),
              GameSuggestT14(vm: widget.vm, titleType: 'New Games'),
            ],
            // SliverList(
            //   delegate: SliverChildListDelegate(
            //
            //   ),
            // shrinkWrap: true,
            //  physics: ClampingScrollPhysics(),
            // children: [
            //   GameSuggestT14(vm: widget.vm, titleType: 'Top Games'),
            //   GameSuggestT14(vm: widget.vm, titleType: 'Recommend For You'),
            //   GameSuggestT14(vm: widget.vm, titleType: 'New Games'),
            // ],
          );
    // });
    // }
  }
}
