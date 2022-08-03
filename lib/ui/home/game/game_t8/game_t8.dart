import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/home/game/game_t1/game_item_t1.dart';
import 'package:tgp_flutter2/ui/home/game/game_t8/game_item_t8.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';

class GameT8 extends StatefulWidget {
  final GameViewModel vm;
  final Function onRefreshHomePage;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final ValueChanged<GameProvider2> onGameClick;

  GameT8({
    required this.vm,
    required this.onRefreshHomePage,
    this.onPauseBgMusic,
    this.onResumeBgMusic,
    required this.onGameClick,
  });

  @override
  _GameT8State createState() => _GameT8State();
}

class _GameT8State extends BaseState<GameT8> {
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
              margin: EdgeInsets.only(left: 10.auto, right: 10.auto),
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    //padding: EdgeInsets.only(bottom: 20.auto),
                    height: 135.auto,
                    margin: EdgeInsets.only(right: 5.auto),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 5.auto, horizontal: 15.auto),
                    child: GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        physics: NeverScrollableScrollPhysics(),
                        children: List.generate(
                            widget.vm.gameTypeList.length,
                            (index) => Container(
                                  child: _buildGameTab(index, widget.vm.gameTypeList[index]),
                                ))),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      height: context.screenHeight / 2 - 77.auto,
                      child: GameItemT8(
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
    // var bgImage = tabIndex == currentTabIndex ? "btn_home_game_category_selected_bg" : "btn_home_game_category_bg";
    return InkWell(
      onTap: () {
        _onTabClick(tabIndex, gameType);
      },
      child: Container(
          padding: EdgeInsets.only(top: 5.auto),
          decoration: tabIndex == currentTabIndex
              ? BoxDecoration(
                  color: Color(0xff8CA6F1),
                  borderRadius: BorderRadius.circular(5),
                )
              : BoxDecoration(),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  child: SvgPicture.asset(
                "images/game_tab/t8/ic_${gameType.getImagePath()}.svg",
                matchTextDirection: true,
                height: 20.auto,
                color: tabIndex == currentTabIndex ? Colors.white : Color(0xffA0A3B2),
              )),
              AutoSizeText(
                gameType.getName(context, widget.vm.config?.menuItemShootFish ?? false),
                textAlign: TextAlign.center,
                style: TextStyle(color: tabIndex == currentTabIndex ? Colors.white : Color(0xffA0A3B2)),
                minFontSize: 2,
                maxFontSize: 13,
                stepGranularity: 1,
                maxLines: 2,
              ),
            ],
          )),
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
