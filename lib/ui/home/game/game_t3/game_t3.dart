import 'package:api/entity/game_provider.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/home/child_game/child_game.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/game/game_web_view.dart';

class GameT3 extends StatefulWidget {
  final String gamePlatformCode;
  final GameType gameType;
  final int index;

  GameT3({this.gamePlatformCode, this.gameType, this.index});

  @override
  _GameT3State createState() => _GameT3State();
}

class _GameT3State extends BaseState<GameT3> {
  var _vm = GameViewModel();
  var gameName;

  /*double _imageRatio = 750 / 330;
  double _containerPaddingRight = 5.auto;
  double _listViewPaddingRight = 5.auto;
  double _itemPaddingRight = 5.auto;
  double _itemPaddingLeft = (8.5).auto;
  double _itemPaddingTop = (12.5).auto;
  double _itemPaddingBottom = (5).auto;

  double get _itemWidth =>
      context.size.width - _containerPaddingRight - _listViewPaddingRight - _itemPaddingRight - _itemPaddingLeft;

  double get itemHeight => _itemWidth * (1 / _imageRatio) + _itemPaddingTop + _itemPaddingBottom;*/

  @override
  void initState() {
    _vm.getGameProviderList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<GameViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          //_handleApiState();
          return ScrollConfiguration(
              behavior: MyBehavior(),
              child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor: CustomColor.theme_bg_color,
                  appBar: CustomAppBar(
                    title: getTranslatedText("game"),
                  ),
                  body: _vm.gameTypeMap[widget.gameType] == null
                      ? buildProgressDialog(_vm.brandLogoUrl)
                      : ListView(
                          padding: EdgeInsets.only(bottom: 15.auto),
                          children: _vm.gameTypeMap[widget.gameType]
                              .map((item) => Container(
                                  margin: EdgeInsets.only(top: 15.auto, left: 15.auto, right: 15.auto),
                                  child: GestureDetector(onTap: () => {_onGameClick(item)}, child: _buildImage(item))))
                              .toList())));
        });
  }

  _getImagePath(GameProvider2 gameProvider) {
    var gameType = gameProvider.gameType.getImagePath();
    var gamePlatformCode = gameProvider.code.toLowerCase();
    var imagePath = "images/game/T3/${gameType}_${gamePlatformCode}.png";
    return imagePath;
  }

  _buildImage(GameProvider2 gameProvider) => Stack(
    children: [
      AspectRatio(
            aspectRatio: 750 / 330,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      _getImagePath(gameProvider),
                      fit: BoxFit.cover,
                    ))),
          ),
      Positioned(
        bottom: context.screenWidth / 15,
        left: context.screenWidth /6,
        child: Container(
          width: 74.auto,
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 5.auto, bottom: 5.auto),
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage("images/game/T3/btn_start_game.png"))),
          child: Text(
            getTranslatedText("start_game"),
            style: TextStyle(
              fontSize: 10.auto,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      )
    ],
  );

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
      /*ProgressDialog.show(context, _vm.brandLogoUrl);
      await _vm.getGameList(gamePlatformCode, gameType);
      ProgressDialog.hide();*/
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => GameWeb(gamePlatformCode: gamePlatformCode, gameType: gameType)));
      });
    }
  }

  navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(RoutePath.login);
    });
  }

  _handleApiState() {
    handleApiState(_vm.getGameProviderListApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getGameApiState, onSuccess: () {});
  }
}
