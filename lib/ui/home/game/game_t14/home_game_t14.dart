import 'package:api/NotificationServices/NotificationServiceName.dart';
import 'package:api/NotificationServices/notification_center.dart';
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
    NotificationCenter().subscribe(NotificationServiceName().gameNeededLoadData, (bool value) {
      if (value) {
        widget.vm.slotGameListByTagMap.clear();
        _initData();
      }
    });
    super.initState();
  }

  _initData() async {
    await widget.vm.getGameProviderList(isRefresh: true);
    await widget.vm.getPlatformList(GameType.Slot);
    await widget.vm.getSlotHotGameList();
  }

  @override
  Widget build(BuildContext context) {
    // return ProviderWidget<GameViewModel>(
    //     model: widget.vm,
    //     builder: (ctx, vm, _) {
    return (widget.vm.slotGameListByTagMap.isEmpty)
        ? Center(child: buildProgressDialog(widget.vm.brandLogoUrl))
        : ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(10),
            physics: ClampingScrollPhysics(),
            children: [
              GameSuggestT14(vm: widget.vm, titleType: getTranslatedText("top_games"), tag: "hot"),
              SizedBox(height: 10),
              GameSuggestT14(vm: widget.vm, titleType: getTranslatedText("recommend_for_you"), tag: "recommend"),
              SizedBox(height: 10),
              GameSuggestT14(vm: widget.vm, titleType: getTranslatedText("new_games"), tag: "new"),
            ],
          );
    // });
    // }
  }
}
