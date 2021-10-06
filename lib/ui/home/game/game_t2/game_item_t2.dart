import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class GameItemT2 extends StatefulWidget {
  final ScrollController controller;
  final List<dynamic> gameProviderList;
  final Function(GameProvider2) onGameClick;
  final GameType currGameType;

  GameItemT2({Key key, this.gameProviderList, this.onGameClick, this.currGameType, this.controller}) : super(key: key);

  @override
  GameItemT2State createState() => GameItemT2State();
}

class GameItemT2State extends BaseState<GameItemT2> {
  double _imageRatio = 750 / 330;
  double _containerPaddingRight = 5.auto;
  double _listViewPaddingRight = 5.auto;
  double _itemPaddingRight = 5.auto;
  double _itemPaddingLeft = (8.5).auto;
  double _itemPaddingTop = (12.5).auto;
  double _itemPaddingBottom = (5).auto;

  double get _itemWidth =>
      context.size.width - _containerPaddingRight - _listViewPaddingRight - _itemPaddingRight - _itemPaddingLeft;

  double get itemHeight => _itemWidth * (1 / _imageRatio) + _itemPaddingTop + _itemPaddingBottom;
  ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
        //decoration: BoxDecoration(color: CustomColor.very_light_pink_four, borderRadius: BorderRadius.circular(5.auto)),
        child: ListView(
      controller: widget.controller,
      children: widget.gameProviderList
          .map((item) => Container(
              padding: EdgeInsets.only(
                  left: _itemPaddingLeft, right: _itemPaddingRight, top: _itemPaddingTop, bottom: _itemPaddingBottom),
              child: _buildImageLayout(item)))
          .toList(),
    ));
  }

  _getImagePath(GameProvider2 gameProvider) {
    var gameType = gameProvider.gameType.getImagePath();
    var gamePlatformCode = gameProvider.code.toLowerCase();
    var imagePath = "images/game/T2/${gameType}_${gamePlatformCode}.png";
    return imagePath;
  }

  _buildImageLayout(GameProvider2 gameProvider) => GestureDetector(
        onTap: () {
          if (gameProvider.status != 0) {
          } else
            widget.onGameClick(gameProvider);
        },
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: _imageRatio,
              child: gameProvider.status != 0
                  ? ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.black,
                        BlendMode.saturation,
                      ),
                      child: _buildImage(gameProvider))
                  : _buildImage(gameProvider),
            ),
            Positioned(
              bottom: context.screenWidth / 30,
              left: context.screenWidth / 12,
              child: Container(
                width: 74.auto,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration:
                    BoxDecoration(image: DecorationImage(image: AssetImage("images/game/T2/btn_start_game.png"))),
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: AutoSizeText(
                    getTranslatedText("start_game"),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    minFontSize: 5,
                    maxFontSize: 11,
                    stepGranularity: 1,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: gameProvider.status != 0,
              child: AspectRatio(
                aspectRatio: _imageRatio,
                child: Container(
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.4)),
                  child: Center(
                    child: Text(getTranslatedText("maintenance"),
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.auto)),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  _buildImage(GameProvider2 gameProvider) => Container(
      alignment: Alignment.center,
      child: Image.asset(
        _getImagePath(gameProvider),
        fit: BoxFit.cover,
      ));
}
