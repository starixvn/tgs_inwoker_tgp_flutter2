import 'dart:ui';

import 'package:api/entity/env_features_config.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class GameItemT15 extends StatefulWidget {
  final ScrollController? controller;
  final List<dynamic>? gameProviderList;
  final Function(GameProvider2)? onGameClick;
  final Key key;
  final EnvFeaturesConfig? config;

  GameItemT15(
      this.key, {
        this.gameProviderList,
        this.onGameClick,
        this.controller,
        this.config,
      });

  @override
  GameItemT15State createState() => GameItemT15State();
}

class GameItemT15State extends BaseState<GameItemT15> {
  double _imageRatio = 391 / 391;
  double _containerPaddingRight = 5.auto;
  double _listViewPaddingRight = 0;
  double _itemPaddingRight = 5.auto;
  double _itemPaddingLeft = (8.5).auto;
  double _itemPaddingTop = 0;
  double _itemPaddingBottom = (5).auto;

  double get _itemWidth =>
      context.size!.width -
          _listViewPaddingRight -
          _itemPaddingRight -
          _itemPaddingLeft;

  double get itemHeight =>
      _itemWidth * (1 / _imageRatio) +
          _itemPaddingTop +
          _itemPaddingBottom +
          6.5;

  //ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.count(
          controller: widget.controller,
          padding: EdgeInsets.only(right: 5.auto, left: 2.5.auto, bottom: 5.auto),
          crossAxisCount: 2,
          shrinkWrap: true,
          childAspectRatio: _imageRatio,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: (widget.gameProviderList ?? [])
          /*.expand((element) => element)
          .toList()*/
              .map((item) => Container(child: _buildImageLayout(item)))
              .toList()),
    );
    //   Container(
    //   padding: EdgeInsets.only(),
    //   decoration: BoxDecoration(
    //       color: CustomColor.very_light_pink_four,
    //       borderRadius: BorderRadius.circular(5.auto)),
    //   child: ListView(
    //       padding: EdgeInsets.only(right: _listViewPaddingRight),
    //       controller: widget.controller,
    //       children: (widget.gameProviderList ?? [])
    //           .expand((element) => element)
    //           .toList()
    //           .map((item) => Container(
    //           padding: EdgeInsets.only(
    //               top: _itemPaddingTop, bottom: _itemPaddingBottom),
    //           child: _buildImageLayout(item)))
    //           .toList()),
    // );
  }

  // _buildImageLayout(GameProvider2 gameProvider) {
  //   var gamePlatformCode = gameProvider.code?.toLowerCase();
  //   return GestureDetector(
  //     onTap: () {
  //       if (gameProvider.status != 0) {
  //       } else
  //         widget.onGameClick!(gameProvider);
  //     },
  //     child: Stack(
  //       children: [
  //         AspectRatio(
  //           aspectRatio: _imageRatio,
  //           child: gameProvider.status != 0
  //               ? ClipRRect(
  //             borderRadius: BorderRadius.circular(5),
  //             child: ColorFiltered(
  //                 colorFilter: ColorFilter.mode(
  //                   Colors.black,
  //                   BlendMode.saturation,
  //                 ),
  //                 child: _buildImage(gameProvider)),
  //           )
  //               : _buildImage(gameProvider),
  //         ),
  //         Positioned(
  //           bottom: context.screenWidth / 50,
  //           left: context.screenWidth / 13,
  //           child: Column(
  //             children: [
  //               _isSportsHideLogo(gamePlatformCode)
  //                   ? Container(
  //                 width: 74.auto,
  //                 margin: EdgeInsets.only(bottom: 15.auto),
  //                 child: Text(
  //                   getTranslatedText("sports_$gamePlatformCode"),
  //                   style: TextStyle(
  //                       color: Colors.white, fontWeight: FontWeight.bold),
  //                   textAlign: TextAlign.center,
  //                 ),
  //               )
  //                   : Container(),
  //               Container(
  //                 width: 74.auto,
  //                 alignment: Alignment.center,
  //                 padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  //                 decoration: BoxDecoration(
  //                     image: DecorationImage(
  //                         image:
  //                         AssetImage("images/game/T2/btn-start-game.jpg"))),
  //                 child: FittedBox(
  //                   fit: BoxFit.cover,
  //                   child: AutoSizeText(
  //                     getTranslatedText("start_game"),
  //                     style: TextStyle(
  //                         fontWeight: FontWeight.bold, color: Colors.white),
  //                     minFontSize: 5,
  //                     maxFontSize: 8,
  //                     stepGranularity: 1,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         Visibility(
  //           visible: gameProvider.status != 0,
  //           child: AspectRatio(
  //             aspectRatio: _imageRatio,
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 color: Colors.black.withOpacity(0.4),
  //                 borderRadius: BorderRadius.circular(5),
  //               ),
  //               child: Center(
  //                 child: Text(getTranslatedText("maintenance"),
  //                     style: TextStyle(
  //                         color: Colors.white,
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 18.auto)),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
    alignment: Alignment.center,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: CachedNetworkImage(
          placeholder: (context, url) => Container(
            width: context.screenWidth,
            height: context.screenHeight,
            color: gameProvider.status != 0
                ? Colors.transparent
                : CustomColor.very_light_pink_four,
            child: Center(
              child: SizedBox(
                height: 50.0,
                width: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      CustomColor.theme_button_color),
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

  _isSportsHideLogo(String? gamePlatformCode) =>
      (widget.config?.sportsHideLogo ?? false) &&
          (gamePlatformCode == "wgfm" || gamePlatformCode == "wgvia");
}
