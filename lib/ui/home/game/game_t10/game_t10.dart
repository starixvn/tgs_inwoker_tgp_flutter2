import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/home/game/game_t1/game_item_t1.dart';
import 'package:tgp_flutter2/ui/home/game/game_t10/game_item_t10.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';

class GameT10 extends StatefulWidget {
  final GameViewModel vm;
  final Function onRefreshHomePage;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final ValueChanged<GameProvider2> onGameClick;

  GameT10({
    required this.vm,
    required this.onRefreshHomePage,
    this.onPauseBgMusic,
    this.onResumeBgMusic,
    required this.onGameClick,
  });

  @override
  _GameT10State createState() => _GameT10State();
}

class _GameT10State extends BaseState<GameT10> {
  var _controller = ScrollController();
  var currentTabIndex = 0, currentGameType, currentGamePlatformCode;
  var gameName;
  GlobalKey<GameItemT1State> gameViewItem = GlobalKey();

  @override
  void initState() {
    //_controller.addListener(_scrollListener);
    currentGameType = widget.vm.gameTypeList.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.vm.gameProviderList == null
        ? buildProgressDialog(widget.vm.brandLogoUrl)
        : Expanded(
            child: Container(
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40.auto,
                    margin: EdgeInsets.symmetric(horizontal: 5.auto),
                    decoration: BoxDecoration(
                      color: CustomColor.theme_button_color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: List.generate(
                            widget.vm.gameTypeList.length,
                            (index) => Container(
                                  padding: const EdgeInsets.all(5),
                                  child: _buildGameTab(index, widget.vm.gameTypeList[index]),
                                ))),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      height: context.screenHeight,
                      margin: EdgeInsets.only(left: 10.auto, right: 10.auto),
                      child: GameItemT10(
                        gameViewItem,
                        controller: _controller,
                        gameProviderList: _getGameTypeMap(),
                        onGameClick: (game) => widget.onGameClick(game),
                        config: widget.vm.config,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  _getGameTypeMap() {
    return widget.vm.gameTypeMap![currentGameType];
  }

  _buildGameTab(int tabIndex, GameType gameType) {
    return InkWell(
      onTap: () {
        _onTabClick(tabIndex, gameType);
      },
      child: Container(
        height: 27.auto,
        padding: EdgeInsets.only(top: (context.screenHeight/100), bottom: (context.screenHeight/100), left: 15, right: 15),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                  color: tabIndex == currentTabIndex ? Color(0xffebde1d) : Colors.transparent,
                  width: 3,
                ))),
        alignment: Alignment.center,
        child: AutoSizeText(
          gameType.getName(context, widget.vm.config?.menuItemShootFish ?? false),
          textAlign: TextAlign.center,
          style: TextStyle(color: tabIndex == currentTabIndex ? Color(0xffebde1d) : Colors.white),
          minFontSize: 8,
          maxFontSize: 13,
          stepGranularity: 1,
          maxLines: 2,
        ),
      ),
    );
  }

  _onTabClick(int tabIndex, GameType gameType) {
    setState(() {
      currentGameType = gameType == GameType.VirtualSports ? GameType.Sportsbook : gameType;
      currentTabIndex = tabIndex;
      _controller.animateTo(0, duration: Duration(milliseconds: 250), curve: Curves.linear);
    });
  }
}
