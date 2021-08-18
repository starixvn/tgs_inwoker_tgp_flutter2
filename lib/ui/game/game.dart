import 'package:api/entity/game_provider.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/game/game_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class Game extends StatefulWidget {
  final String gamePlatformCode;
  final GameType gameType;
  final int index;

  Game({this.gamePlatformCode, this.gameType, this.index});

  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends BaseState<Game> {
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
                  appBar: CustomAppBar(),
                  body: _vm.gameTypeMap[widget.gameType] == null
                      ? buildProgressDialog()
                      : ListView(
                          padding: EdgeInsets.only(bottom: 15.auto),
                          children: _vm.gameTypeMap[widget.gameType]
                              .map((item) => Container(
                                  margin: EdgeInsets.only(top: 15.auto, left: 15.auto, right: 15.auto),
                                  child: GestureDetector(onTap: () => {}, child: _buildImage(item))))
                              .toList())));
        });
  }

  _getImagePath(GameProvider2 gameProvider) {
    var gameType = gameProvider.gameType.getImagePath();
    var gamePlatformCode = gameProvider.code.toLowerCase();
    var imagePath = "images/game/${gameType}_${gamePlatformCode}.png";
    return imagePath;
  }

  _buildImage(GameProvider2 gameProvider) => /*Stack(
        children: [*/
          AspectRatio(
            aspectRatio: 750/330,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      _getImagePath(gameProvider),
                      fit: BoxFit.cover,
                    ))),
          )
         /* Positioned(
            bottom: context.screenWidth / 30,
            left: context.screenWidth / 12,
            child: Container(
              width: 74.auto,
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 5.auto, bottom: 5.auto),
              decoration: BoxDecoration(image: DecorationImage(image: AssetImage("images/game/btn_start_game.png"))),
              child: Text(
                "START GAME",
                //getTranslatedText("start_game"),
                style: TextStyle(
                  fontSize: 10.auto,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      )*/;
}
