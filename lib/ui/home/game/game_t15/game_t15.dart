import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/home/game/game_t1/game_item_t1.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';

import 'game_item_t15.dart';

class GameT15 extends StatefulWidget {
  final GameViewModel vm;
  final Function onRefreshHomePage;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final ValueChanged<GameProvider2> onGameClick;

  GameT15({
    required this.vm,
    required this.onRefreshHomePage,
    this.onPauseBgMusic,
    this.onResumeBgMusic,
    required this.onGameClick,
  });

  @override
  _GameT15State createState() => _GameT15State();
}

class _GameT15State extends BaseState<GameT15> {
  var _controller = ScrollController();
  var currentTabIndex = 0, currentGameType, currentGamePlatformCode;
  var gameName;
  GlobalKey<GameItemT1State> gameViewItem = GlobalKey();

  @override
  void initState() {
    currentGameType = widget.vm.gameTypeList.first;
    _controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.vm.gameProviderList == null
        ? buildProgressDialog(widget.vm.brandLogoUrl)
        : Expanded(
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Container(
                    // width: 65.auto,
                    margin: EdgeInsets.only(right: 5.auto, left: 5.auto),
                    child: ListView(
                      // padding: EdgeInsets.only(bottom: 10.auto),
                      children:
                      List.generate(widget.vm.gameTypeList.length, (index) {
                        var gameType = widget.vm.gameTypeList[index];
                        if (index == 0)
                          return _buildTopGameTab(index, gameType);
                        else if (index + 1 == widget.vm.gameTypeList.length)
                          return _buildBottomGameTab(index, gameType);
                        else
                          return _buildMiddleGameTab(index, gameType);
                      }),
                    ),
                  )),

                  Container(
                    width: context.screenWidth - (90.auto),
                    child: GameItemT15(
                      gameViewItem,
                      controller: _controller,
                      gameProviderList: _getGameTypeMap(),
                      onGameClick: (game) => widget.onGameClick(game),
                      config: widget.vm.config,
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

  _buildTopGameTab(int tabIndex, GameType gameType) => Container(
        // decoration: BoxDecoration(
        //   color: Colors.transparent,
        //   borderRadius: BorderRadius.only(
        //     topLeft: Radius.circular(5),
        //     topRight: Radius.circular(5),
        //   ),
        // ),
        child: _buildGameTab(tabIndex, gameType),
      );

  _buildBottomGameTab(int tabIndex, GameType gameType) => Container(
        // decoration: BoxDecoration(
        //   color: Colors.transparent,
        //   borderRadius: BorderRadius.only(
        //     bottomLeft: Radius.circular(5),
        //     bottomRight: Radius.circular(5),
        //   ),
        // ),
        margin: EdgeInsets.only(top: 7.auto, bottom: 10.auto),//EdgeInsets.only(bottom: 20.auto),
        child: _buildGameTab(tabIndex, gameType),
      );

  _buildMiddleGameTab(int tabIndex, GameType gameType) => Container(
    // width: 40,
    //     decoration: BoxDecoration(color: Colors.transparent),
        margin: EdgeInsets.only(top: 7.auto),
        child: _buildGameTab(tabIndex, gameType),
      );

  _buildGameTab(int tabIndex, GameType gameType) {
    return
      InkWell(
      onTap: () {
        _onTabClick(tabIndex, gameType);
      },
      child: Container(
        height: (90 * (36 / 74 )),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/game/T15/${tabIndex == currentTabIndex ? "gametype-selected" : "gametype"}.png'),
              fit: BoxFit.fill,
            ),
            // shape: BoxShape.circle,
          ),
          padding: EdgeInsets.only(top: 0.auto, left: 5.auto, right: 0.auto),
          child: Row(
            children: [
              Container(
                width: 18.auto,
                margin: EdgeInsets.only(right: 2.5.auto),
                child: Image.asset(
                          "images/game_tab/t15/${gameType.getImagePath()}${tabIndex == currentTabIndex ? "-selected" : ""}.png",
                        width: 18.auto,
                        height: 18.auto,
                        // color: (tabIndex == currentTabIndex &&
                        //             EnvironmentConfig.brandName == "PB" ||
                        //         tabIndex != currentTabIndex &&
                        //             EnvironmentConfig.brandName != "PB")
                        //     //only PB, selected game tab color is grey, not selected game tab is button color
                        //     ? CustomColor.theme_text_grey_color
                        //     : CustomColor.theme_button_color,
                      )
              ),
              Expanded(child: AutoSizeText(
                gameType.getName(
                    context, widget.vm.config?.menuItemShootFish ?? false),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: (tabIndex == currentTabIndex)
                      ? Color(0xff9aa4c2)
                      : Colors.white,
                  fontWeight: FontWeight.bold
                ),
                minFontSize: 2,
                maxFontSize: 12,
                stepGranularity: 1,
                maxLines: 2,
              ),)
            ],
          )),
    );
  }

  _onTabClick(int tabIndex, GameType gameType) {
    // var itemHeight = gameViewItem.currentState!.itemHeight;
    // var des = 0.0;
    //
    // widget.vm.gameProviderList!.asMap().forEach((i, element) {
    //   if (tabIndex > i) {
    //     des += itemHeight * widget.vm.gameProviderList![i].length;
    //   }
    // });
    setState(() {
      currentGameType = gameType == GameType.VirtualSports ? GameType.Sportsbook : gameType;
      _controller.animateTo(0, duration: Duration(milliseconds: 250), curve: Curves.linear);
       currentTabIndex = tabIndex;
      // _controller.animateTo(des,
      //     curve: Curves.linear, duration: Duration(milliseconds: 250));
    });
  }

  _scrollListener() {
    var scrollTab = gameViewItem.currentState!.itemHeight;
    var des = 0.0;
    var index = 0;

    widget.vm.gameProviderList!.asMap().forEach((i, element) {
      if (_controller.offset >= des) {
        des += scrollTab * widget.vm.gameProviderList![i].length;
        index = i;
      } else if (_controller.offset >= _controller.position.maxScrollExtent) {
        index = widget.vm.gameProviderList!
                .where((i) => i.length > 0)
                .toList()
                .length -
            1;
      }
    });
    setState(() {
      currentTabIndex = index; //1
    });
  }
}
