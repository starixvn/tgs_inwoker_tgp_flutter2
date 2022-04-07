import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
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
import 'package:tgp_flutter2/ui/home/game/game_t2/game_item_t2.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/game/game_web_view.dart';
import 'package:url_launcher/url_launcher.dart';

class GameT2 extends StatefulWidget {
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final GameViewModel? vm;
  final Function? onRefreshHomePage;

  GameT2({
    this.onResumeBgMusic,
    this.onPauseBgMusic,
    this.vm,
    this.onRefreshHomePage,
  });

  @override
  _GameT2State createState() => _GameT2State();
}

class _GameT2State extends BaseState<GameT2> {
  var _controller = ScrollController();
  var currentTabIndex = 0, currentGameType = GameType.Sportsbook;
  late GameViewModel _vm;

  var gameName;
  GlobalKey<GameItemT2State> gameViewItem = GlobalKey();

  @override
  void initState() {
    _vm = widget.vm!;
    //_vm.getGameProviderList();
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
              : /*Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 10.auto, right: 10.auto),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Container(
                              //padding: EdgeInsets.only(bottom: 20.auto),
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
                            )),
                        Expanded(
                            flex: 3,
                            child: Container(
                              child: GameItemT2(
                                controller: _controller,
                                currGameType: currentGameType,
                                gameProviderList: _getGameTypeMap(),
                                onGameClick: (game) => _onGameClick(game),
                                config: _vm.config,
                              ),
                            ))
                      ],
                    ),
                  ),
                )*/
              Expanded(
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
                              children: List.generate(_vm.gameTypeList.length, (index) {
                                return Container(
                                  margin: EdgeInsets.only(top: 8.auto),
                                  child: _buildGameTab(index, _vm.gameTypeList[index]),
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
                            gameProviderList: _vm.gameProviderList,
                            onGameClick: (game) => _onGameClick(game),
                            config: _vm.config,
                          ),
                        )
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
        setState(() {
          _onTabClick(tabIndex);
          //currentGameType = gameType;
          //_controller.animateTo(0, duration: Duration(milliseconds: 250), curve: Curves.linear);
        });
      },
      child: /*Container(
          padding: EdgeInsets.only(top: 20.auto, left: 10.auto, right: 10.auto),
          child: Column(
            children: [
              Container(
                child: ImageIcon(
                  AssetImage("images/game_tab/t2/ic_${gameType.getImagePath()}.png"),
                  size: 28.auto,
                  color:
                      currentGameType == gameType ? CustomColor.theme_button_color : CustomColor.theme_text_grey_color,
                ),
              ), //Image.asset("images/game_tab/ic_$imagePath.png")),
              AutoSizeText(
                gameType.getName(context, _vm.config?.menuItemShootFish ?? false),
                style: TextStyle(
                    color: currentGameType == gameType
                        ? CustomColor.theme_button_color
                        : CustomColor.theme_text_grey_color),
                minFontSize: 2,
                stepGranularity: 1,
                maxLines: 1,
              ),
            ],
          ))*/
          Container(
        width: (62.5).auto,
        height: (33.5).auto,
        decoration: BoxDecoration(
            color: tabIndex == currentTabIndex ? CustomColor.theme_button_color : CustomColor.very_light_pink_four,
            border: Border.all(color: tabIndex == currentTabIndex ? Colors.black : CustomColor.very_light_pink_two),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        // tabIndex == currentTabIndex ? gameTabGradientDecoration : gameTabColorDecoration,
        padding: EdgeInsets.all(3.auto),
        child: Center(
            child: Container(
          width: (62.5).auto,
          child: AutoSizeText(
            gameType.getName(context, _vm.config?.menuItemShootFish ?? false),
            style: TextStyle(
                color: tabIndex == currentTabIndex ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
            minFontSize: 2,
            maxFontSize: 13,
            stepGranularity: 1,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        )),
      ),
    );
  }

  _onGameClick(GameProvider2 gameProvider) {
    if (_vm.userProfile == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          title: getTranslatedText("login_hint"),
          description: getTranslatedText("login_dialog_des"),
          buttonText1: getTranslatedText("login_or_signup"),
          buttonText2: getTranslatedText("got_it"),
          onClick: this.navigateToLogin,
          onClick2: () {
            Navigator.pop(context);
          },
          popIndex: 2,
        ),
      );
    } else
      _navigate(gameProvider.code, gameProvider.gameType);
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

  navigateToLogin() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(RoutePath.login);
    });
  }

  _navigate(String? gamePlatformCode, GameType? gameType) async {
    // if (_isSWGame(gamePlatformCode, gameType)) {
    if (_isSWGame(gamePlatformCode, gameType) || _isSGGame(gamePlatformCode))
      await _vm.getLobbyGameUrl(gamePlatformCode!, gameType!, EnvironmentConfig.url);
    else if (_isTcgGame(gamePlatformCode)) {
      await _vm.getGameList(gamePlatformCode, gameType);
      await _vm.getGameUrl(gamePlatformCode!, _vm.gameListMap[gamePlatformCode]!.first.id!, EnvironmentConfig.url);
      // }
      /*WidgetsBinding.instance!.addPostFrameCallback((_) {
        launch(_vm.url!);
      });*/
    } else if (gameType == GameType.Slot || gameType == GameType.EGame || gameType == GameType.Fishing) {
      //navigate to child game
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChildGame(
                      gamePlatformCode: gamePlatformCode,
                      gameType: gameType,
                      onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                      onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                    )));
      });
    } else if (gameType == GameType.Lottery || gameType == GameType.LotteryLobby) {
      //only tcg will need to get gamelist
      await _vm.getGameList(gamePlatformCode, gameType);
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        if (widget.onPauseBgMusic != null) widget.onPauseBgMusic!();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GameWeb(
                      gamePlatformCode: gamePlatformCode,
                      gameType: gameType,
                      gameId: _vm.gameListMap[gamePlatformCode]!.first.id,
                      onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                      onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                    )));
      });
    } else {
      //navigate to game web
      if (widget.onPauseBgMusic != null) widget.onPauseBgMusic!();
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GameWeb(
                      gamePlatformCode: gamePlatformCode,
                      gameType: gameType,
                      onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                      onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                    )));
      });
    }
  }

  _isTcgGame(String? gamePlatformCode) =>
      gamePlatformCode == "TCG_SEA" || gamePlatformCode == "TCG_LOTTO" || gamePlatformCode == "TCG_LOTTO_VN";

  _isSWGame(String? gamePlatformCode, GameType? gameType) =>
      (gamePlatformCode == "SW" && gameType == GameType.LiveDealerLobby);

  _isSGGame(String? gamePlatformCode) => gamePlatformCode == "SG";

  _handleApiState() {
    handleApiState(_vm.getGameProviderListApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getGameApiState, onSuccess: () {});

    handleApiState(_vm.getLobbyGameUrlApiState, onSuccess: () {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        launch(_vm.url!);
      });
    }, onError: (_) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.of(context).pushNamed(RoutePath.maintenance);
      });
    });

    handleApiState(_vm.getGameUrlApiState, onSuccess: () {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        launch(_vm.url!);
      });
    }, onError: (_) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.of(context).pushNamed(RoutePath.maintenance);
      });
    });
  }
}
