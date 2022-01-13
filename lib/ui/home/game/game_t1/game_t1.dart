import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/home/child_game/child_game.dart';
import 'package:tgp_flutter2/ui/home/game/game_t1/game_item_t1.dart';
import 'package:tgp_flutter2/ui/home/game/game_t2/game_item_t2.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/game/game_web_view.dart';

class GameT1 extends StatefulWidget {
  final GameViewModel? vm;
  final Function? onRefreshHomePage;

  GameT1({this.vm, this.onRefreshHomePage});

  @override
  _GameT1State createState() => _GameT1State();
}

class _GameT1State extends BaseState<GameT1> {
  var _controller = ScrollController();
  var currentTabIndex = 0, currentGameType = GameType.Sportsbook;
  var gameName;
  GlobalKey<GameItemT1State> gameViewItem = GlobalKey();
  late GameViewModel _vm;

  @override
  void initState() {
    _vm = widget.vm!;
    _controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<GameViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return _vm.gameProviderList == null
              ? buildProgressDialog(_vm.brandLogoUrl)
              : Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 10.auto, right: 10.auto),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          //padding: EdgeInsets.only(bottom: 20.auto),
                          width: 75.auto,
                          margin: EdgeInsets.only(right: 5.auto),
                          child: ListView(
                            padding: EdgeInsets.only(bottom: 10.auto),
                            children: List.generate(_vm.gameTypeList.length, (index) {
                              var gameType = _vm.gameTypeList[index];
                              if (index == 0)
                                return _buildTopGameTab(index, gameType);
                              else if (index + 1 == _vm.gameTypeList.length)
                                return _buildBottomGameTab(index, gameType);
                              else
                                return _buildMiddleGameTab(index, gameType);
                            }),
                          ),
                        ),
                        Container(
                          width: context.screenWidth - (120.auto),
                          child: GameItemT1(
                            gameViewItem,
                            controller: _controller,
                            gameProviderList: _vm.gameProviderList,
                            onGameClick: (game) => _onGameClick(game),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
        });
  }

  _getGameTypeMap() {
    if (currentGameType == GameType.Sportsbook)
      return ([_vm.gameTypeMap![GameType.ESports], _vm.gameTypeMap![GameType.Sportsbook]].expand((x) => x!).toList());
    else
      return _vm.gameTypeMap![currentGameType];
  }

  _buildTopGameTab(int tabIndex, GameType gameType) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
          ),
        ),
        child: _buildGameTab(tabIndex, gameType),
      );

  _buildBottomGameTab(int tabIndex, GameType gameType) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5),
          ),
        ),
        padding: EdgeInsets.only(bottom: 20.auto),
        child: _buildGameTab(tabIndex, gameType),
      );

  _buildMiddleGameTab(int tabIndex, GameType gameType) => Container(
        decoration: BoxDecoration(color: Colors.white),
        child: _buildGameTab(tabIndex, gameType),
      );

  _buildGameTab(int tabIndex, GameType gameType) {
    // var bgImage = tabIndex == currentTabIndex ? "btn_home_game_category_selected_bg" : "btn_home_game_category_bg";
    return InkWell(
      onTap: () {
        _onTabClick(tabIndex);
      },
      child: Container(
          padding: EdgeInsets.only(top: 20.auto, left: 10.auto, right: 10.auto),
          child: Column(
            children: [
              Container(
                  child: SvgPicture.asset(
                // images/game_tab/t1/ic_eGame.svg
                "images/game_tab/t1/ic_${gameType.getImagePath()}.svg",
                matchTextDirection: true,
                width: 28.auto,
                height: 28.auto,
                color: tabIndex == currentTabIndex ? CustomColor.theme_button_color : CustomColor.theme_text_grey_color,
              ) /* ImageIcon(
                  AssetImage("images/game_tab/t1/ic_${gameType.getImagePath()}.png"),
                  size: 28.auto,
                  color:
                      currentGameType == gameType ? CustomColor.theme_button_color : CustomColor.theme_text_grey_color,
                ),*/
                  ), //Image.asset("images/game_tab/ic_$imagePath.png")),
              AutoSizeText(
                gameType.getName(context, _vm.config?.menuItemShootFish ?? false),
                style: TextStyle(
                    color: tabIndex == currentTabIndex
                        ? CustomColor.theme_button_color
                        : CustomColor.theme_text_grey_color),
                minFontSize: 2,
                stepGranularity: 1,
                maxLines: 1,
              ),
            ],
          )),
    );
  }

  _onTabClick(int tabIndex) {
    var itemHeight = gameViewItem.currentState!.itemHeight;
    var des = 0.0;

    _vm.gameProviderList!.asMap().forEach((i, element) {
      if (tabIndex > i) {
        des += itemHeight * _vm.gameProviderList![i].length;
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

    _vm.gameProviderList!.asMap().forEach((i, element) {
      if (_controller.offset >= des) {
        des += scrollTab * _vm.gameProviderList![i].length;
        index = i;
      } else if (_controller.offset >= _controller.position.maxScrollExtent) {
        index = _vm.gameProviderList!.length - 1;
      }
    });
    setState(() {
      currentTabIndex = index; //1
    });
  }

  _onGameClick(GameProvider2 gameProvider) {
    if (_vm.userProfile == null) {
      showPreLoginDialog();
    } else
      _navigate(gameProvider.code, gameProvider.gameType);
  }

  _navigate(String? gamePlatformCode, GameType? gameType) async {
    if (gameType == GameType.Slot || gameType == GameType.EGame || gameType == GameType.Fishing) {
      //navigate to child game
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChildGame(
                      gamePlatformCode: gamePlatformCode,
                      gameType: gameType,
                    )));
      });
    } else if (gameType == GameType.Lottery || gameType == GameType.LotteryLobby) {
      //only tcg will need to get gamelist
      await _vm.getGameList(gamePlatformCode, gameType);
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GameWeb(
                      gamePlatformCode: gamePlatformCode,
                      gameType: gameType,
                      gameId: _vm.gameListMap[gamePlatformCode]!.first.id,
                    )));
      });
    } else {
      //navigate to game web
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => GameWeb(gamePlatformCode: gamePlatformCode, gameType: gameType)));
      });
    }
  }

  _handleApiState() {
    handleApiState(_vm.getGameProviderListApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getGameApiState, onSuccess: () {});
  }
}
