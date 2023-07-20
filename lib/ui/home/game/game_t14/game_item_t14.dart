import 'dart:ui';

import 'package:api/entity/env_features_config.dart';
import 'package:api/entity/game.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:api/extension/list_extension.dart';

import '../../../../environment_config.dart';
import '../game_web_view.dart';

class GameItemT14 extends StatefulWidget {
  final bool? isFavourite;
  final Game? game;
  final bool isDisabled;
  final GameViewModel? vm;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;

  GameItemT14({
    this.isFavourite,
    this.game,
    this.isDisabled = false,
    this.vm,
    this.onPauseBgMusic,
    this.onResumeBgMusic,
  });

  @override
  GameItemT14State createState() => GameItemT14State();
}

class GameItemT14State extends BaseState<GameItemT14> {
  // double _imageRatio = 1;
  // double _containerPaddingRight = 5.auto;
  // double _listViewPaddingRight = 5.auto;
  // double _itemPaddingRight = 0; //5.auto;
  // double _itemPaddingLeft = 0; //(8.5).auto;
  // double _itemPaddingTop = 0;
  // double _itemPaddingBottom = 0;
  //
  // double get _itemWidth => context.size!.width - _listViewPaddingRight - _itemPaddingRight - _itemPaddingLeft;
  //
  // double get itemHeight => _itemWidth * (1 / _imageRatio) + _itemPaddingTop + _itemPaddingBottom;

  //ScrollController? controller;

  var languageCode;
  List? platformList;

  @override
  void initState() {
    _initData();
    super.initState();
  }

  _initData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    platformList = widget.vm?.platformList ?? [];

    var code = _prefs.getString("LANGUAGE_CODE");
    setState(() {
      if (code == "zh-TW" || code == "zh-CN")
        languageCode = "zh-CN";
      else
        languageCode = "en-US";
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (widget.isDisabled) ? () {} : () {
        if (widget.vm?.userProfile == null) {
          showPreLoginDialog();
        } else
          _navigateToGameWeb(widget.game!);
      },
      child: Container(
        child: Column(
          children: [
            Expanded(
              flex: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(300),
                child: _buildImage(),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.only(right: 3.auto),
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    widget.game?.name ?? "",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                // AutoSizeText(
                //   widget.game?.name ?? "",
                //   style: TextStyle(color: Colors.white),
                //   minFontSize: 10,
                //   stepGranularity: 1,
                //   maxLines: 1,
                // ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              flex: 1,
              child: Wrap(
                children: [
                  InkWell(
                    onTap: () {
                      if (widget.vm?.userProfile == null) {
                        showPreLoginDialog();
                      }
                      else
                        (widget.game?.isFavourite ?? false) ? widget.vm!.deleteFavoriteGame(widget.game!) : widget.vm!.setFavoriteGame(widget.game!);
                    },
                    child: Image.asset(
                      (widget.game?.isFavourite ?? false) ? "images/child_game/T14/ic_favorite_selected.png" : "images/child_game/T14/ic_favorite.png",
                      width: 15.auto,
                      height: 15.auto,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text("Collect", style: TextStyle(color: Colors.white))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildImage() {
    return AspectRatio(
      aspectRatio: 1,
      child: CachedNetworkImage(
          placeholder: (context, url) =>
              Container(
                color: CustomColor.very_light_pink_two,
              ),
          imageUrl: _getImageUrl(),
          //handling error
          errorWidget: (_, __, ___) =>
              Container(
                color: CustomColor.very_light_pink_two,
              ),
          fit: BoxFit.fill),
    );
  }

  _getImageUrl() {
    var gameName = _getGameName();
    if (gameName == "FishingYiLuFa")
      return EnvironmentConfig.slotGameUrl + "${(widget.game?.gamePlatformCode ?? "").toUpperCase()}/zh-CN/$gameName.jpg";
    else
      return EnvironmentConfig.slotGameUrl + "${(widget.game?.gamePlatformCode ?? "").toUpperCase()}/${languageCode ?? "en-US"}/$gameName.jpg";
  }

  _getGameName() {
    return widget.game!.code;
  }

  String returnGameName(gameCode) {
    return platformList
        ?.singleWhereOrNull((element) => element.code == gameCode)
        ?.name ?? gameCode;
  }

  _buildPlatformText() =>
      Container(
        margin: EdgeInsets.only(left: 10.auto, top: 5.auto),
        padding: EdgeInsets.symmetric(vertical: 5.auto, horizontal: 15.auto),
        decoration: BoxDecoration(color: CustomColor.black, borderRadius: BorderRadius.circular(15.0)),
        child: Text(
          returnGameName(widget.game!.gamePlatformCode),
          style: TextStyle(color: Colors.white, fontSize: 9.auto),
        ),
      );

  _navigateToGameWeb(Game game) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onPauseBgMusic != null) widget.onPauseBgMusic!();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  GameWeb(
                    gamePlatformCode: game.gamePlatformCode,
                    gameId: game.id,
                    onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                    onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                  )));
    });
  }
}
