import 'dart:ui';

import 'package:api/entity/env_features_config.dart';
import 'package:api/entity/game_type.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

class GameItemT10 extends StatefulWidget {
  final ScrollController? controller;
  final List<dynamic>? gameProviderList;
  final Function(GameProvider2)? onGameClick;
  final Key key;
  final EnvFeaturesConfig? config;

  GameItemT10(this.key, {this.gameProviderList, this.onGameClick, this.controller, this.config});

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

  double get _itemWidth => context.size!.width - _listViewPaddingRight - _itemPaddingRight - _itemPaddingLeft;

  double get itemHeight => _itemWidth * (1 / _imageRatio) + _itemPaddingTop + _itemPaddingBottom;

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
                    child: Text(getTranslatedText("maintenance"), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.auto)),
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
        alignment: Alignment.center,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              CachedNetworkImage(
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
              if (gameProvider.gameType == GameType.Slot)
                Positioned(
                  left: 0,
                  top: context.screenHeight / 70,
                  child: Container(
                    width: context.screenWidth / 4.5,
                    child: Text(
                      gameProvider.name ?? "",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );

  _isSportsHideLogo(String? gamePlatformCode) => (widget.config?.sportsHideLogo ?? false) && (gamePlatformCode == "wgfm" || gamePlatformCode == "wgvia");
}
