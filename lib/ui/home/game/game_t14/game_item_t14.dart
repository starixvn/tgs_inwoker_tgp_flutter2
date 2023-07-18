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

class GameItemT14 extends StatefulWidget {
  final ScrollController? controller;
  final List<dynamic>? gameProviderList;
  final Function(GameProvider2)? onGameClick;
  final Key key;
  final EnvFeaturesConfig? config;
  final GameViewModel vm;

  GameItemT14(
    this.key, {
    this.gameProviderList,
    this.onGameClick,
    this.controller,
    this.config,
    required this.vm,
  });

  @override
  GameItemT14State createState() => GameItemT14State();
}

class GameItemT14State extends BaseState<GameItemT14> {
  double _imageRatio = 1;
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
      child: GridView.count(
        padding: EdgeInsets.all(10.auto),
        crossAxisCount: 3,
        childAspectRatio: _imageRatio,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
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
                    borderRadius: BorderRadius.circular(300),
                    child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.black,
                          BlendMode.saturation,
                        ),
                        child: _buildImage(gameProvider)),
                  )
                : _buildImage(gameProvider),
          ),
        ],
      ),
    );
  }
  _buildImage(GameProvider2 gameProvider) => Container(
        alignment: Alignment.center,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(300),
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
