import 'dart:ui';

import 'package:api/entity/env_features_config.dart';
import 'package:api/localizations/language_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class GameItemT10 extends StatefulWidget {
  final ScrollController? controller;
  final List<dynamic>? gameProviderList;
  final Function(GameProvider2)? onGameClick;
  final Key key;
  final EnvFeaturesConfig? config;

  GameItemT10(this.key,
      {this.gameProviderList, this.onGameClick, this.controller, this.config});

  @override
  GameItemT10State createState() => GameItemT10State();
}

class GameItemT10State extends BaseState<GameItemT10> {
  double _imageRatio = 356 / 184;
  double _containerPaddingRight = 5.auto;
  double _listViewPaddingRight = 5.auto;
  double _itemPaddingRight = 0; //5.auto;
  double _itemPaddingLeft = 0; //(8.5).auto;
  double _itemPaddingTop = 0;
  double _itemPaddingBottom = 0;

  double get _itemWidth =>
      context.size!.width -
      _listViewPaddingRight -
      _itemPaddingRight -
      _itemPaddingLeft;

  double get itemHeight =>
      _itemWidth * (1 / _imageRatio) + _itemPaddingTop + _itemPaddingBottom;

  //ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.count(
          controller: widget.controller,
          padding: EdgeInsets.only(top: 5.auto),
          crossAxisCount: 2,
          shrinkWrap: true,
          childAspectRatio: _imageRatio,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          children: (widget.gameProviderList ?? [])
              /*.expand((element) => element)
          .toList()*/
              .map((item) => Container(child: _buildImageLayout(item)))
              .toList()),
    );
  }

  _getImagePath(GameProvider2 gameProvider) {
    var imagePath;
    var gameType = gameProvider.gameType?.getImagePath();
    var gamePlatformCode = gameProvider.code?.toLowerCase();
    var fullPath = "${gameType}_${gamePlatformCode}";
    imagePath = "images/game/T10/${gameType}-$gamePlatformCode.png";
    return imagePath;
  }

  _isNeedHandleLanguage(String path) {
    switch (path) {
      case "sports-saba":
      case "sports-imes":
      case "fish-jdb":
      case "slot-jdb":
        return true;
      default:
        return false;
    }
  }

  _buildImageLayout(GameProvider2 gameProvider) {
    var gamePlatformCode = gameProvider.code?.toLowerCase();
    return GestureDetector(
      onTap: () {
        if (gameProvider.status != 0) {
        } else
          widget.onGameClick!(gameProvider);
      },
      child: Container(
        alignment: Alignment.center,
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: _imageRatio,
              child: gameProvider.status != 0
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.black,
                          BlendMode.saturation,
                        ),
                        child: _buildImage(gameProvider),
                      ),
                    )
                  : _buildImage(gameProvider),
            ),
            /*Positioned(
              bottom: context.screenWidth / 50,
              left: context.screenWidth / 13,
              child: Column(
                children: [
                  _isSportsHideLogo(gamePlatformCode)
                      ? Container(
                          width: 74.auto,
                          margin: EdgeInsets.only(bottom: 15.auto),
                          child: Text(
                            getTranslatedText("sports_$gamePlatformCode"),
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Container(),
                  Container(
                    width: 74.auto,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration:
                        BoxDecoration(image: DecorationImage(image: AssetImage("images/game/T2/btn-start-game.jpg"))),
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: AutoSizeText(
                        getTranslatedText("start_game"),
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        minFontSize: 5,
                        maxFontSize: 8,
                        stepGranularity: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),*/
            Visibility(
              visible: gameProvider.status != 0,
              child: AspectRatio(
                aspectRatio: _imageRatio,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Text(getTranslatedText("maintenance"),
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.auto)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildImage(GameProvider2 gameProvider) => ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          alignment: Alignment.center,
          child: Image.asset(
            _getImagePath(gameProvider),
            fit: BoxFit.cover,
          ),
        ),
      );

  _isSportsHideLogo(String? gamePlatformCode) =>
      (widget.config?.sportsHideLogo ?? false) &&
      (gamePlatformCode == "wgfm" || gamePlatformCode == "wgvia");
}
