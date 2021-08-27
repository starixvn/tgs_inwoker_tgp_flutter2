import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/home/child_game/child_game.dart';
import 'package:tgp_flutter2/ui/home/game/game_t2/game_item_t2.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/game/game_web_view.dart';

class GameT2 extends StatefulWidget {
  GameT2();

  @override
  _GameT2State createState() => _GameT2State();
}

class _GameT2State extends BaseState<GameT2> {
  var _controller = ScrollController();
  var currentTabIndex = 0, currentGameType = GameType.ESports;
  var _vm = GameViewModel();
  var gameName;

  @override
  void initState() {
    //_controller.addListener(_scrollListener);
    _vm.getGameProviderList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<GameViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return _vm.gameProviderList == null
              ? buildProgressDialog()
              : Expanded(
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
                                gameProviderList: _vm.gameTypeMap[currentGameType],
                                onGameClick: (game) => _onGameClick(game),

                              ),
                            ))
                      ],
                    ),
                  ),
                );
        });
  }

  _buildTopGameTab(int tabIndex, GameType gameType) => Container(
        decoration: BoxDecoration(
          color: CustomColor.theme_text_color2,
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

  _buildGameTab(int tabIndex,GameType gameType) {
    // var bgImage = tabIndex == currentTabIndex ? "btn_home_game_category_selected_bg" : "btn_home_game_category_bg";
    return InkWell(
      onTap: () {
        setState(() {
          currentGameType = gameType;
          _controller.animateTo(0,
                duration:Duration(milliseconds: 250), curve: Curves.linear);

        });
      },
      child: Container(
          padding: EdgeInsets.only(top: 20.auto, left: 10.auto, right: 10.auto),
          child: Column(
            children: [
              Container(
                child: ImageIcon(
                  AssetImage("images/game_tab/ic_${gameType.getImagePath()}.png"),
                  size: 28.auto,
                  color: currentGameType == gameType ? CustomColor.theme_button_color : CustomColor.theme_text_color,
                ),
              ), //Image.asset("images/game_tab/ic_$imagePath.png")),
              Container(
                child: Text(
                  gameType.getName(context),
                  style: TextStyle(
                      color:
                      currentGameType == gameType ? CustomColor.theme_button_color : CustomColor.theme_text_color),
                ),
              )
            ],
          )),
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
        ),
      );
    } else
      _navigate(gameProvider.code, gameProvider.gameType);
  }

  navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(RoutePath.login);
    });
  }

  _navigate(String gamePlatformCode, GameType gameType) async {
    if (gameType == GameType.Slot || gameType == GameType.EGame || gameType == GameType.Fishing) {
      //navigate to child game
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChildGame(
                      gamePlatformCode: gamePlatformCode,
                      gameType: gameType,
                    )));
      });
    } else {
      //navigate to game web
      /*ProgressDialog.show(context);
      await _vm.getGameList(gamePlatformCode, gameType);
      ProgressDialog.hide();*/
      WidgetsBinding.instance.addPostFrameCallback((_) {
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
