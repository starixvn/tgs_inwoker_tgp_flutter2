import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/home/child_game/child_game.dart';
import 'package:tgp_flutter2/ui/home/game/game_t1/game_item_t1.dart';
import 'package:tgp_flutter2/ui/home/game/game_t10/game_item_t10.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/game/game_web_view.dart';
import 'package:url_launcher/url_launcher.dart';

class GameT10 extends StatefulWidget {
  final GameViewModel? vm;
  final Function? onRefreshHomePage;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;

  GameT10(
      {this.vm,
      this.onRefreshHomePage,
      this.onPauseBgMusic,
      this.onResumeBgMusic});

  @override
  _GameT10State createState() => _GameT10State();
}

class _GameT10State extends BaseState<GameT10> {
  var _controller = ScrollController();
  var currentTabIndex = 0,
      currentGameType = GameType.Sportsbook,
      currentGamePlatformCode;
  var gameName;
  GlobalKey<GameItemT1State> gameViewItem = GlobalKey();
  late GameViewModel _vm;

  @override
  void initState() {
    _vm = widget.vm!;
    //_controller.addListener(_scrollListener);
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
                    child: Column(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 40.auto,
                          margin: EdgeInsets.only(right: 5.auto),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: List.generate(
                                  _vm.gameTypeList.length,
                                  (index) => Container(
                                        padding: const EdgeInsets.all(5),
                                        child: _buildGameTab(
                                            index, _vm.gameTypeList[index]),
                                      ))),
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(
                            height: context.screenHeight,
                            margin:
                                EdgeInsets.only(left: 10.auto, right: 10.auto),
                            child: GameItemT10(
                              gameViewItem,
                              controller: _controller,
                              gameProviderList: _getGameTypeMap(),
                              onGameClick: (game) => _onGameClick(game),
                              config: _vm.config,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
        });
  }

  _getGameTypeMap() {
    return _vm.gameTypeMap![currentGameType];
  }

  _buildGameTab(int tabIndex, GameType gameType) {
    // var bgImage = tabIndex == currentTabIndex ? "btn_home_game_category_selected_bg" : "btn_home_game_category_bg";
    return InkWell(
      onTap: () {
        _onTabClick(tabIndex, gameType);
      },
      child: Container(
          padding:
              const EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15),
          decoration: tabIndex == currentTabIndex
              ? BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/game/T10/button.png'),
                    fit: BoxFit.fill,
                  ),
                )
              : BoxDecoration(),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AutoSizeText(
                gameType.getName(
                    context, _vm.config?.menuItemShootFish ?? false),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: tabIndex == currentTabIndex
                        ? Colors.white
                        : Color(0xffA0A3B2)),
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
    /*var itemHeight = gameViewItem.currentState!.itemHeight;
    var des = 0.0;

    _vm.gameProviderList!.asMap().forEach((i, element) {
      if (tabIndex > i) {
        des += itemHeight * _vm.gameProviderList![i].length;
      }
    });*/
    setState(() {
      currentGameType = gameType;
      currentTabIndex = tabIndex;
      _controller.animateTo(0,
          duration: Duration(milliseconds: 250), curve: Curves.linear);
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
      await _vm.getLobbyGameUrl(
          currentGamePlatformCode!, currentGameType, EnvironmentConfig.url);
    else if (_isTcgGame()) {
      await _vm.getGameList(currentGamePlatformCode, currentGameType);
      await _vm.getGameUrl(
          currentGamePlatformCode,
          _vm.gameListMap[currentGamePlatformCode]!.first.id!,
          EnvironmentConfig.url);
    } else if (_isChildGame()) {
      //navigate to child game
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChildGame(
                    gamePlatformCode: currentGamePlatformCode,
                    gameType: currentGameType,
                    onResumeBgMusic: () => (widget.onResumeBgMusic != null)
                        ? widget.onResumeBgMusic!()
                        : null,
                    onPauseBgMusic: () => (widget.onPauseBgMusic != null)
                        ? widget.onPauseBgMusic!()
                        : null)));
      });
    } else if (currentGameType == GameType.Lottery ||
        currentGameType == GameType.LotteryLobby) {
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
                      gameId:
                          _vm.gameListMap[currentGamePlatformCode]!.first.id,
                      onPauseBgMusic: () => (widget.onPauseBgMusic != null)
                          ? widget.onPauseBgMusic!()
                          : null,
                      onResumeBgMusic: () => (widget.onResumeBgMusic != null)
                          ? widget.onResumeBgMusic!()
                          : null,
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
                      onPauseBgMusic: () => (widget.onPauseBgMusic != null)
                          ? widget.onPauseBgMusic!()
                          : null,
                      onResumeBgMusic: () => (widget.onResumeBgMusic != null)
                          ? widget.onResumeBgMusic!()
                          : null,
                    )));
      });
    }
  }

  _isTcgGame() =>
      currentGamePlatformCode == "TCG_SEA" ||
      currentGamePlatformCode == "TCG_LOTTO" ||
      currentGamePlatformCode == "TCG_LOTTO_VN";

  _isSWGame() => (currentGamePlatformCode == "SW" &&
      currentGameType == GameType.LiveDealerLobby);

  _isSGGame() => currentGamePlatformCode == "SG";

  _isChildGame() => (currentGameType == GameType.Slot ||
      currentGameType == GameType.EGame ||
      currentGameType == GameType.Fishing);

  _handleApiState() {
    handleApiState(_vm.getGameProviderListApiState,
        isAutoHideLoading: false, onSuccess: () {});
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
