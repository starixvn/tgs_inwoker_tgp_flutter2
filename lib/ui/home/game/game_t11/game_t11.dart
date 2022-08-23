import 'package:api/entity/game.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/home/game/game_t11/game_item_t11.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/jackpot/jackpot.dart';

class GameT11 extends StatefulWidget {
  final GameViewModel vm;
  final Function onRefreshHomePage;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final ValueChanged<GameProvider2> onGameClick;
  final ValueChanged<bool> onClickGameTab;
  final ValueChanged<Game> onClickChildGame;

  GameT11({
    required this.vm,
    required this.onRefreshHomePage,
    this.onPauseBgMusic,
    this.onResumeBgMusic,
    required this.onGameClick,
    required this.onClickGameTab,
    required this.onClickChildGame,
  });

  @override
  _GameT11State createState() => _GameT11State();
}

class _GameT11State extends BaseState<GameT11> {
  var _controller = ScrollController();
  var currentTabIndex, currentGameType, currentGamePlatformCode;
  var gameName;
  GlobalKey<GameItemT11State> gameViewItem = GlobalKey();
  var isDisplayGameView = false;

  @override
  void initState() {
    //_controller.addListener(_scrollListener);
    currentGameType = widget.vm.gameTypeList.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: widget.vm.gameProviderList == null
          ? buildProgressDialog(widget.vm.brandLogoUrl)
          : Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 62.auto,
                    margin: EdgeInsets.symmetric(horizontal: 5.auto),
                    decoration: BoxDecoration(
                      color: CustomColor.theme_button_color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: List.generate(
                            widget.vm.gameTypeList.length,
                            (index) => Container(
                                  padding: const EdgeInsets.all(5),
                                  child: _buildGameTab(index, widget.vm.gameTypeList[index]),
                                ))),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    height: context.screenHeight,
                    width: context.screenWidth,
                    margin: EdgeInsets.only(left: 10.auto, right: 10.auto),
                    child: isDisplayGameView
                        ? GameItemT11(
                            gameViewItem,
                            controller: _controller,
                            gameProviderList: _getGameTypeMap(),
                            onGameClick: (game) => widget.onGameClick(game),
                            config: widget.vm.config,
                            vm: widget.vm,
                          )
                        : Jackpot(vm: widget.vm, onClickChildGame: (game) => widget.onClickChildGame(game)),
                  ),
                ),
              ],
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
          padding: EdgeInsets.only(left: 10.auto, right: 10.auto),
          child: Column(
            children: [
              Expanded(
                flex: 8,
                child: Container(
                  child: Image.asset(
                    "images/game_tab/t11/ic_${gameType.getImagePath()}.gif",
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Opacity(
                  opacity: currentTabIndex == tabIndex ? 1 : 0.5,
                  child: AutoSizeText(
                    gameType.getName(context, widget.vm.config?.menuItemShootFish ?? false),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                    minFontSize: 8,
                    maxFontSize: 13,
                    stepGranularity: 1,
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          )),
    );
  }

  _onTabClick(int tabIndex, GameType gameType) {
    widget.onClickGameTab(true);
    setState(() {
      isDisplayGameView = true;
      currentGameType = gameType == GameType.VirtualSports ? GameType.Sportsbook : gameType;
      currentTabIndex = tabIndex;
      //_controller.animateTo(0, duration: Duration(milliseconds: 250), curve: Curves.linear);
    });
  }
}
