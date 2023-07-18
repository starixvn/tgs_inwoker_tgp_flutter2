import 'dart:ui';

import 'package:api/entity/game_provider2.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:api/entity/game.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/game/game_web_view.dart';
import 'package:api/extension/list_extension.dart';

class GameSuggestItemT14 extends StatefulWidget {
  final bool? isFavourite;
  final Game? game;
  final bool isDisabled;
  final GameViewModel? vm;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;

  GameSuggestItemT14({
    this.isFavourite,
    this.game,
    this.isDisabled = false,
    this.vm,
    this.onPauseBgMusic,
    this.onResumeBgMusic,
  });

  @override
  _GameSuggestItemT14State createState() => _GameSuggestItemT14State();
}

class _GameSuggestItemT14State extends BaseState<GameSuggestItemT14> {
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

  Widget build(BuildContext context) {
    return InkWell(
      onTap: (widget.isDisabled) ? () {} : () => _navigateToGameWeb(widget.game!),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(300),
        ),
        child: Stack(
          children: [
            _buildImage(),
            // Positioned(
            //   right: 10,
            //   top: 10,
            //   child: InkWell(
            //     onTap: () {
            //       //ProgressDialog.show(context, widget.vm!.brandLogoUrl);
            //       widget.game!.isFavourite! ? widget.vm!.deleteFavoriteGame(widget.game!) : widget.vm!.setFavoriteGame(widget.game!);
            //     },
            //     child: Image.asset(
            //       widget.game!.isFavourite! ? "images/child_game/ic_favorite_selected.png" : "images/child_game/ic_favorite.png",
            //       width: 15.auto,
            //       height: 15.auto,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  _buildImage() {
    print(_getImageUrl());
    return ClipRRect(
      borderRadius: BorderRadius.circular(300),
      child: AspectRatio(
        aspectRatio: 1,
        child: CachedNetworkImage(
            placeholder: (context, url) => Container(
                  color: CustomColor.very_light_pink_two,
                ),
            imageUrl: _getImageUrl(),
            //handling error
            errorWidget: (_, __, ___) => Container(
                  color: CustomColor.very_light_pink_two,
                ),
            fit: BoxFit.fill),
      ),
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
    /*if (((getCurrentLanguage().apiCode == "zh-CN" || getCurrentLanguage().apiCode == "zh-TW") &&
        (widget.game.gamePlatformCode == "HABA" || widget.game.gamePlatformCode == "PP")) ||
        widget.game.gamePlatformCode == "SW"|| widget.game.type == GameType.Fishing )*/
    return widget.game!.code;
    /*else
      return widget.game.code.replaceAll(RegExp("_"), "");*/
  }

  String returnGameName(gameCode) {
    return platformList?.singleWhereOrNull((element) => element.code == gameCode)?.name ?? gameCode;
  }

  _buildPlatformText() => Positioned(
        top: context.screenWidth / 2.45,
        child: Container(
          margin: EdgeInsets.only(left: 10.auto, top: 5.auto),
          padding: EdgeInsets.symmetric(vertical: 5.auto, horizontal: 15.auto),
          decoration: BoxDecoration(color: CustomColor.black, borderRadius: BorderRadius.circular(15.0)),
          child: Text(
            returnGameName(widget.game!.gamePlatformCode),
            style: TextStyle(color: Colors.white, fontSize: 9.auto),
          ),
        ),
      );

  _navigateToGameWeb(Game game) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onPauseBgMusic != null) widget.onPauseBgMusic!();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GameWeb(
                    gamePlatformCode: game.gamePlatformCode,
                    gameId: game.id,
                    onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                    onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                  )));
    });
  }
}
