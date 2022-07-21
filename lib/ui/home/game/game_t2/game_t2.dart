import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/home/game/game_t2/game_item_t2.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';

class GameT2 extends StatefulWidget {
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final GameViewModel vm;
  final Function onRefreshHomePage;
  final ValueChanged<GameProvider2> onGameClick;

  GameT2({
    required this.onResumeBgMusic,
    required this.onPauseBgMusic,
    required this.vm,
    required this.onRefreshHomePage,
    required this.onGameClick,
  });

  @override
  _GameT2State createState() => _GameT2State();
}

class _GameT2State extends BaseState<GameT2> {
  var _controller = ScrollController();
  var currentTabIndex = 0, currentGameType = GameType.Sportsbook, currentGamePlatformCode;

  var gameName;
  GlobalKey<GameItemT2State> gameViewItem = GlobalKey();

  @override
  void initState() {
    //widget.vm.getGameProviderList();
    _controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.vm.gameProviderList == null
        ? buildProgressDialog(widget.vm.brandLogoUrl)
        : Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 10.auto, right: 10.auto, bottom: 5.auto),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.fitHeight,
                    child: Container(
                      margin: EdgeInsets.only(right: 10.auto, bottom: 5.auto),
                      child: Column(
                        children: List.generate(widget.vm.gameTypeList.length, (index) {
                          return Container(
                            margin: EdgeInsets.only(top: 8.auto),
                            child: _buildGameTab(index, widget.vm.gameTypeList[index]),
                          );
                        }),
                      ),
                    ),
                  ),
                  Container(
                    child: GameItemT2(
                      gameViewItem,
                      controller: _controller,
                      currGameType: currentGameType,
                      gameProviderList: widget.vm.gameProviderList,
                      onGameClick: (game) => widget.onGameClick(game),
                      config: widget.vm.config,
                    ),
                  )
                ],
              ),
            ),
          );
  }

  _buildGameTab(int tabIndex, GameType gameType) {
    return InkWell(
      onTap: () {
        setState(() {
          _onTabClick(tabIndex);
        });
      },
      child: Container(
        width: (62.5).auto,
        height: (33.5).auto,
        decoration: BoxDecoration(
            color: tabIndex == currentTabIndex ? CustomColor.theme_button_color : CustomColor.very_light_pink_four,
            border: Border.all(color: tabIndex == currentTabIndex ? Colors.black : CustomColor.very_light_pink_two),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        padding: EdgeInsets.all(3.auto),
        child: Center(
          child: Container(
            width: (62.5).auto,
            child: AutoSizeText(
              gameType.getName(context, widget.vm.config?.menuItemShootFish ?? false),
              style: TextStyle(
                  color: tabIndex == currentTabIndex ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
              minFontSize: 2,
              maxFontSize: 13,
              stepGranularity: 1,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  _onTabClick(int tabIndex) {
    var itemHeight = gameViewItem.currentState!.itemHeight;
    var des = 0.0;

    widget.vm.gameProviderList!.asMap().forEach((i, element) {
      if (tabIndex > i) {
        des += itemHeight * widget.vm.gameProviderList![i].length;
      }
    });
    setState(() {
      //  currentTabIndex = tabIndex;
      _controller.animateTo(des, curve: Curves.linear, duration: Duration(milliseconds: 250));
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
        index = widget.vm.gameProviderList!.length - 1;
      }
    });
    setState(() {
      currentTabIndex = index; //1
    });
  }
}
