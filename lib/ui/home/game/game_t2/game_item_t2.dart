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

  GameItemT2({Key key,this.gameProviderList, this.onGameClick,this.currGameType, this.controller}): super(key: key);

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

double get _itemWidth =>  context.size.width-_containerPaddingRight-_listViewPaddingRight-_itemPaddingRight-_itemPaddingLeft;
double get itemHeight => _itemWidth*(1/_imageRatio)+_itemPaddingTop+_itemPaddingBottom;
ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      //decoration: BoxDecoration(color: CustomColor.very_light_pink_four, borderRadius: BorderRadius.circular(5.auto)),
      child: ListView(
        controller: widget.controller,
        children: widget.gameProviderList
            .map((item) => Container(
            padding: EdgeInsets.only(left: _itemPaddingLeft, right:_itemPaddingRight, top: _itemPaddingTop, bottom: _itemPaddingBottom),
            child: GestureDetector(onTap: () => widget.onGameClick(item), child: _buildImage(item))))
            .toList(),
      )
    );
  }

  _getImagePath(GameProvider2 gameProvider) {
    var gameType = gameProvider.gameType.getImagePath();
    var gamePlatformCode = gameProvider.code.toLowerCase();
    var imagePath = "images/game/T2/${gameType}_${gamePlatformCode}.png";
    return imagePath;
  }

  _buildImage(GameProvider2 gameProvider) =>Stack(
    children: [
      AspectRatio(
        aspectRatio: _imageRatio,
        child: Container(
          // color: Colors.blue,
            alignment: Alignment.center,
            child: Image.asset(
              _getImagePath(gameProvider),
              fit: BoxFit.cover,
            )),
      ),
      Positioned(
        bottom: context.screenWidth / 30,
        left: context.screenWidth / 12,
        child: Container(
          width: 74.auto,
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 5.auto, bottom: 5.auto),
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage("images/game/T2/btn_start_game.png"))),
          child: Text(
            getTranslatedText("start_game"),
            style: TextStyle(
              fontSize: 10.auto,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      )
    ],
  );
}
