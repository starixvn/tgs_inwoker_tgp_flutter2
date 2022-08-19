import 'dart:ui';

import 'package:api/entity/env_features_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';

class GameItemT11 extends StatefulWidget {
  final ScrollController? controller;
  final List<dynamic>? gameProviderList;
  final Function(GameProvider2)? onGameClick;
  final Key key;
  final EnvFeaturesConfig? config;
  final GameViewModel vm;

  GameItemT11(
    this.key, {
    this.gameProviderList,
    this.onGameClick,
    this.controller,
    this.config,
    required this.vm,
  });

  @override
  GameItemT11State createState() => GameItemT11State();
}

class GameItemT11State extends BaseState<GameItemT11> {
  double _imageRatio = 710 / 320;
  double _containerPaddingRight = 5.auto;
  double _listViewPaddingRight = 5.auto;
  double _itemPaddingRight = 0; //5.auto;
  double _itemPaddingLeft = 0; //(8.5).auto;
  double _itemPaddingTop = 0;
  double _itemPaddingBottom = 0;

  double get _itemWidth => context.size!.width - _listViewPaddingRight - _itemPaddingRight - _itemPaddingLeft;

  double get itemHeight => _itemWidth * (1 / _imageRatio) + _itemPaddingTop + _itemPaddingBottom;

  //ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(bottom: 15.auto),
        children: (widget.gameProviderList ?? [])
                .map((item) => Container(
                      margin: EdgeInsets.only(top: 15.auto),
                      child: _buildImageLayout(item),
                    ))
                .toList(),

      ),
    );
  }

  _buildImageLayout(GameProvider2 gameProvider) {
    //var gamePlatformCode = gameProvider.code?.toLowerCase();

    return InkWell(
      onTap: () {
        if (gameProvider.status != 0) {
        } else
          widget.onGameClick!(gameProvider);
      },
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
                        child: _buildImage(gameProvider)),
                  )
                : _buildImage(gameProvider),
          ),
          Positioned(
            bottom: context.screenWidth / 15,
            left: context.screenWidth / 6,
            child: Column(
              children: [
                gameProvider.status != 0
                    ? ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.black,
                          BlendMode.saturation,
                        ),
                        child: _buildStartGameButton())
                    : _buildStartGameButton(),
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
                  borderRadius: BorderRadius.circular(10),
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
    );
  }

  _buildStartGameButton() => Container(
        width: 74.auto,
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 5.auto, bottom: 5.auto),
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage("images/game/T11/button.png"))),
        child: Text(
          getTranslatedText("start_game"),
          style: TextStyle(
            fontSize: 10.auto,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  _buildImage(GameProvider2 gameProvider) => Container(
        alignment: Alignment.center,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
              placeholder: (context, url) => Container(
                    width: context.screenWidth,
                    height: context.screenHeight,
                    color: gameProvider.status != 0 ? Colors.transparent : CustomColor.very_light_pink_four,
                    child: Center(
                      child: SizedBox(
                        height: 50.0,
                        width: 50.0,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(CustomColor.theme_button_color),
                        ),
                      ),
                    ),
                  ),
              imageUrl: getImagePath(gameProvider),
              errorWidget: (context, url, error) {
                print(url);
                return Container(
                  color: CustomColor.very_light_pink_four,
                );
              },
              //handling error
              fit: BoxFit.fill),
        ),
      );
}
