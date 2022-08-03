import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/home/child_game/child_game.dart';
import 'package:tgp_flutter2/ui/home/game/game_t1/game_item_t1.dart';
import 'package:tgp_flutter2/ui/home/game/game_t9/game_item_t9.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/game/game_web_view.dart';
import 'package:url_launcher/url_launcher.dart';

class GameT9 extends StatefulWidget {
  final GameViewModel vm;
  final Function onRefreshHomePage;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final ValueChanged<GameProvider2> onGameClick;

  GameT9({
    required this.vm,
    required this.onRefreshHomePage,
    this.onPauseBgMusic,
    this.onResumeBgMusic,
    required this.onGameClick,
  });

  @override
  _GameT9State createState() => _GameT9State();
}

class _GameT9State extends BaseState<GameT9> {
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
                    height: (widget.vm.config?.t9CustomHome ?? false) ? 95.auto : 135.auto,
                    margin: EdgeInsets.only(right: 5.auto),
                    decoration: (widget.vm.config?.t9CustomHome ?? false)
                        ? BoxDecoration()
                        : BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                    padding: EdgeInsets.symmetric(
                        vertical: 5.auto, horizontal: (widget.vm.config?.t9CustomHome ?? false) ? 0 : 15.auto),
                    child: GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        childAspectRatio: (widget.vm.config?.t9CustomHome ?? false) ? 2 : 1.2,
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
                      child: GameItemT9(
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
      child: (widget.vm.config?.t9CustomHome ?? false)
          ? Container(
              decoration: tabIndex == currentTabIndex
                  ? BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xffCFB98F), Color(0xffEFE6C7)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          stops: [0, 0.5]),
                      borderRadius: BorderRadius.circular(10),
                    )
                  : BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      padding: EdgeInsets.only(right: 5.auto),
                      child: SvgPicture.asset(
                        "images/game_tab/t8/ic_${gameType.getImagePath()}.svg",
                        matchTextDirection: true,
                        height: 20.auto,
                        color: tabIndex == currentTabIndex ? Color(0xffC59C6A) : Color(0xff8490B0),
                      )), //Image.asset("images/game_tab/ic_$imagePath.png")),
                  AutoSizeText(
                    gameType.getName(context, widget.vm.config?.menuItemShootFish ?? false),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tabIndex == currentTabIndex ? Colors.white : Color(0xff8490B0)),
                    minFontSize: 2,
                    maxFontSize: 13,
                    stepGranularity: 1,
                    maxLines: 2,
                  ),
                ],
              ))
          : Container(
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
                  )), //Image.asset("images/game_tab/ic_$imagePath.png")),
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
