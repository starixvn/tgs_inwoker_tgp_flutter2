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

class GameT1 extends StatefulWidget {
  final GameViewModel vm;
  final Function onRefreshHomePage;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final ValueChanged<GameProvider2> onGameClick;

  GameT1({
    required this.vm,
    required this.onRefreshHomePage,
    this.onPauseBgMusic,
    this.onResumeBgMusic,
    required this.onGameClick,
  });

  @override
  _GameT1State createState() => _GameT1State();
}

class _GameT1State extends BaseState<GameT1> {
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
                  Container(
                    width: 75.auto,
                    margin: EdgeInsets.only(right: 5.auto),
                    child: Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      color: EnvironmentConfig.dark_mode ? Colors.black : Colors.white,
                      elevation: 5,
                      child: ListView(
                        // padding: EdgeInsets.only(bottom: 10.auto),
                        children: List.generate(widget.vm.gameTypeList.length, (index) {
                          var gameType = widget.vm.gameTypeList[index];
                          if (index == 0)
                            return _buildTopGameTab(index, gameType);
                          else if (index + 1 == widget.vm.gameTypeList.length)
                            return _buildBottomGameTab(index, gameType);
                          else
                            return _buildMiddleGameTab(index, gameType);
                        }),
                      ),
                    ),
                  ),
                  Container(
                    width: context.screenWidth - (100.auto),
                    child: GameItemT1(
                      gameViewItem,
                      controller: _controller,
                      gameProviderList: widget.vm.gameProviderList,
                      onGameClick: (game) => widget.onGameClick(game),
                      config: widget.vm.config,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  _buildTopGameTab(int tabIndex, GameType gameType) => Container(
        decoration: BoxDecoration(
          color: EnvironmentConfig.dark_mode ? Colors.black : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
          ),
        ),
        child: _buildGameTab(tabIndex, gameType),
      );

  _buildBottomGameTab(int tabIndex, GameType gameType) => Container(
        decoration: BoxDecoration(
          color: EnvironmentConfig.dark_mode ? Colors.black : Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5),
          ),
        ),
        padding: EdgeInsets.only(bottom: 20.auto),
        child: _buildGameTab(tabIndex, gameType),
      );

  _buildMiddleGameTab(int tabIndex, GameType gameType) => Container(
        decoration: BoxDecoration(
          color: EnvironmentConfig.dark_mode ? Colors.black : Colors.white,
        ),
        child: _buildGameTab(tabIndex, gameType),
      );

  _buildGameTab(int tabIndex, GameType gameType) {
    return InkWell(
      onTap: () {
        _onTabClick(tabIndex);
      },
      child: Container(
          padding: EdgeInsets.only(top: 20.auto, left: 10.auto, right: 10.auto),
          child: Column(
            children: [
              Container(
                child: gameType == GameType.Fishing
                    //to fix fishing image will shake sometimes
                    ? Image.asset(
                        "images/game_tab/t1/ic_fish.png",
                        width: 28.auto,
                        height: 28.auto,
                        color: (/*tabIndex == currentTabIndex && EnvironmentConfig.brandName == "PB" ||*/
                                tabIndex != currentTabIndex/* && EnvironmentConfig.brandName != "PB"*/)
                            //only PB, selected game tab color is grey, not selected game tab is button color
                            ? CustomColor.theme_text_grey_color
                            : CustomColor.theme_button_color,
                      )
                    : SvgPicture.asset(
                        "images/game_tab/t1/ic_${gameType.getImagePath()}.svg",
                        width: 28.auto,
                        height: 28.auto,
                        color: (/*tabIndex == currentTabIndex && EnvironmentConfig.brandName == "PB" ||*/
                                tabIndex != currentTabIndex /*&& EnvironmentConfig.brandName != "PB"*/)
                            //only PB, selected game tab color is grey, not selected game tab is button color
                            ? CustomColor.theme_text_grey_color
                            : CustomColor.theme_button_color,
                      ),
              ),
              AutoSizeText(
                gameType.getName(context, widget.vm.config?.menuItemShootFish ?? false),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      (/*tabIndex == currentTabIndex && EnvironmentConfig.brandName == "PB" || */tabIndex != currentTabIndex/* && EnvironmentConfig.brandName != "PB"*/)
                          ? CustomColor.theme_text_grey_color
                          : CustomColor.theme_button_color,
                ),
                minFontSize: 2,
                maxFontSize: 12,
                stepGranularity: 1,
                maxLines: 2,
              ),
            ],
          )),
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
        index = widget.vm.gameProviderList!.where((i) => i.length > 0).toList().length - 1;
      }
    });
    setState(() {
      currentTabIndex = index; //1
    });
  }
}
