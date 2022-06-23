import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:tgp_flutter2/environment_config.dart';
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
import 'package:url_launcher/url_launcher.dart';

class GameT1 extends StatefulWidget {
  final GameViewModel? vm;
  final Function? onRefreshHomePage;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;

  GameT1({this.vm, this.onRefreshHomePage, this.onPauseBgMusic, this.onResumeBgMusic});

  @override
  _GameT1State createState() => _GameT1State();
}

class _GameT1State extends BaseState<GameT1> {
  var _controller = ScrollController();
  var currentTabIndex = 0, currentGameType = GameType.Sportsbook, currentGamePlatformCode;
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
                            elevation: 5,
                            child: ListView(
                              // padding: EdgeInsets.only(bottom: 10.auto),
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
                        ),
                        Container(
                          width: context.screenWidth - (100.auto),
                          child: GameItemT1(
                            gameViewItem,
                            controller: _controller,
                            gameProviderList: _vm.gameProviderList,
                            onGameClick: (game) => _onGameClick(game),
                            config: _vm.config,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
        });
  }

  _getGameTypeMap() {
    /*if (currentGameType == GameType.Sportsbook)
      return ([_vm.gameTypeMap![GameType.ESports], _vm.gameTypeMap![GameType.Sportsbook]].expand((x) => x!).toList());
    else*/
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
                color: (tabIndex == currentTabIndex && EnvironmentConfig.brandName == "PB" ||
                        tabIndex != currentTabIndex && EnvironmentConfig.brandName != "PB")
                    //only PB, selected game tab color is grey, not selected game tab is button color
                    ? CustomColor.theme_text_grey_color
                    : CustomColor.theme_button_color,
              ) /* ImageIcon(
                  AssetImage("images/game_tab/t1/ic_${gameType.getImagePath()}.png"),
                  size: 28.auto,
                  color:
                      currentGameType == gameType ? CustomColor.theme_button_color : CustomColor.theme_text_grey_color,
                ),*/
                  ), //Image.asset("images/game_tab/ic_$imagePath.png")),
              AutoSizeText(
                gameType.getName(context, _vm.config?.menuItemShootFish ?? false),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: (tabIndex == currentTabIndex && EnvironmentConfig.brandName == "PB" ||
                          tabIndex != currentTabIndex && EnvironmentConfig.brandName != "PB")
                      ? CustomColor.theme_text_grey_color
                      : CustomColor.theme_button_color,
                ),
                minFontSize: 2,
                maxFontSize: 13,
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
        index = _vm.gameProviderList!.where((i) => i.length > 0).toList().length - 1;
      }
    });
    setState(() {
      currentTabIndex = index; //1
    });
  }

  _onGameClick(GameProvider2 gameProvider) {
    if (_vm.userProfile == null) {
      showPreLoginDialog();
    } else {
      setState(() {
        currentGameType = gameProvider.gameType!;
        currentGamePlatformCode = gameProvider.code;
      });
      _navigate();
    }
  }

  _navigate() async {
    if (_isSWGame() || _isSGGame())
      await _vm.getLobbyGameUrl(currentGamePlatformCode!, currentGameType, EnvironmentConfig.url);
    else if (_isTcgGame()) {
      await _vm.getGameList(currentGamePlatformCode, currentGameType);
      await _vm.getGameUrl(
          currentGamePlatformCode, _vm.gameListMap[currentGamePlatformCode]!.first.id!, EnvironmentConfig.url);
    } else if (_isChildGame()) {
      //navigate to child game
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChildGame(
                    gamePlatformCode: currentGamePlatformCode,
                    gameType: currentGameType,
                    onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                    onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null)));
      });
    } else if (currentGameType == GameType.Lottery || currentGameType == GameType.LotteryLobby) {
      //only tcg will need to get gamelist
      await _vm.getGameList(currentGamePlatformCode, currentGameType);
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        if (widget.onPauseBgMusic != null) widget.onPauseBgMusic!();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GameWeb(
                      gamePlatformCode: currentGamePlatformCode,
                      gameType: currentGameType,
                      gameId: _vm.gameListMap[currentGamePlatformCode]!.first.id,
                      onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                      onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                    )));
      });
    } else {
      //navigate to game web
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        if (widget.onPauseBgMusic != null) widget.onPauseBgMusic!();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GameWeb(
                      gamePlatformCode: currentGamePlatformCode,
                      gameType: currentGameType,
                      onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                      onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                    )));
      });
    }
  }

  _isTcgGame() =>
      currentGamePlatformCode == "TCG_SEA" ||
      currentGamePlatformCode == "TCG_LOTTO" ||
      currentGamePlatformCode == "TCG_LOTTO_VN";

  _isSWGame() => (currentGamePlatformCode == "SW" && currentGameType == GameType.LiveDealerLobby);

  _isSGGame() => currentGamePlatformCode == "SG";

  _isChildGame() => (currentGameType == GameType.Slot ||
      currentGameType == GameType.EGame ||
      currentGameType == GameType.Fishing ||
      currentGameType == GameType.VirtualSports);

  _handleApiState() {
    handleApiState(_vm.getGameProviderListApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getGameApiState, onSuccess: () {});

    handleApiState(_vm.getLobbyGameUrlApiState, onSuccess: () {
      if (_vm.url == null)
        _navigateToMaintenance();
      else if (_isSWGame() || _isSGGame() || _isTcgGame())
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          launch(_vm.url!);
        });
    }, onError: (_) {
      _navigateToMaintenance();
    });

    handleApiState(_vm.getGameUrlApiState, onSuccess: () {
      if (_vm.url == null)
        _navigateToMaintenance();
      else if (_isSWGame() || _isSGGame() || _isTcgGame())
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          launch(_vm.url!);
        });
    }, onError: (_) {
      _navigateToMaintenance();
    });
  }

  _navigateToMaintenance() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (_isSWGame() || _isSGGame() || _isTcgGame())
        Navigator.of(context).pushNamed(RoutePath.maintenance);
      else
        Navigator.of(context).pushReplacementNamed(RoutePath.maintenance);
    });
  }
}
