import 'dart:ui';

import 'package:api/entity/env_features_config.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';

class GameItemT8Dark extends StatefulWidget {
  final ScrollController? controller;
  final List<dynamic>? gameProviderList;
  final Function(GameProvider2)? onGameClick;
  final Key key;
  final EnvFeaturesConfig? config;

  GameItemT8Dark(this.key, {this.gameProviderList, this.onGameClick, this.controller, this.config});

  @override
  GameItemT8DarkState createState() => GameItemT8DarkState();
}

class GameItemT8DarkState extends BaseState<GameItemT8Dark> {
  double _imageRatio = 750 / 330;
  double _containerPaddingRight = 5.auto;
  double _listViewPaddingRight = 5.auto;
  double _itemPaddingRight = 0; //5.auto;
  double _itemPaddingLeft = 0; //(8.5).auto;
  double _itemPaddingTop = (12.5).auto;
  double _itemPaddingBottom = (5).auto;

  double get _itemWidth => context.size!.width - _listViewPaddingRight - _itemPaddingRight - _itemPaddingLeft;

  double get itemHeight => _itemWidth * (1 / _imageRatio) + _itemPaddingTop + _itemPaddingBottom;

  //ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      //padding: EdgeInsets.only(),
      //decoration: BoxDecoration(color: CustomColor.very_light_pink_four, borderRadius: BorderRadius.circular(5.auto)),
      child: ListView(
          padding: EdgeInsets.only(right: _listViewPaddingRight),
          controller: widget.controller,
          children: (widget.gameProviderList ?? [])
              /*.expand((element) => element)
              .toList()*/
              .map((item) => Container(
                  padding: EdgeInsets.only(
                      left: _itemPaddingLeft,
                      right: _itemPaddingRight,
                      top: _itemPaddingTop,
                      bottom: _itemPaddingBottom),
                  child: _buildImageLayout(item)))
              .toList()),
    );
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
            Positioned(
              bottom: context.screenWidth / 50,
              left: context.screenWidth / 7,
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
                        BoxDecoration(image: DecorationImage(image: AssetImage("images/game/T8/btn-start-game.jpg"))),
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
            ),
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
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.auto)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildImage(GameProvider2 gameProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.auto),
          border: Border.all(color: Color(0xffFEFFA1)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.auto),
          child: Image.asset(
            getImagePath(gameProvider),
            fit: BoxFit.cover,
          ),
        ),
      );

  _isSportsHideLogo(String? gamePlatformCode) =>
      (widget.config?.sportsHideLogo ?? false) && (gamePlatformCode == "wgfm" || gamePlatformCode == "wgvia");
}
