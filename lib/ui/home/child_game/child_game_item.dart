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

class ChildGameItem extends StatefulWidget {
  final bool? isFavourite;
  final Game? game;
  final bool isDisabled;
  final GameViewModel? vm;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;

  ChildGameItem({
    this.isFavourite,
    this.game,
    this.isDisabled = false,
    this.vm,
    this.onPauseBgMusic,
    this.onResumeBgMusic,
  });

  @override
  _ChildGameItemState createState() => _ChildGameItemState();
}

class _ChildGameItemState extends BaseState<ChildGameItem> {
  var languageCode;
  var platformList;

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
      onTap:
          (widget.isDisabled) ? () {} : () => _navigateToGameWeb(widget.game!),
      child: Container(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Column(
            children: [
              Stack(
                children: [
                  Column(children: [
                    _buildImage(),
                    _buildImageTitleAndFavouriteIcon(),
                  ]),
                  _buildPlatformText()
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildImage() {
    return AspectRatio(
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
    );
  }

  _getImageUrl() {
    var gameName = _getGameName();
    if (gameName == "FishingYiLuFa")
      return EnvironmentConfig.slotGameUrl +
          "${(widget.game?.gamePlatformCode ?? "").toUpperCase()}/zh-CN/$gameName.jpg";
    else
      return EnvironmentConfig.slotGameUrl +
          "${(widget.game?.gamePlatformCode ?? "").toUpperCase()}/${languageCode ?? "en-US"}/$gameName.jpg";
  }

  _getGameName() {
    /*if (((getCurrentLanguage().apiCode == "zh-CN" || getCurrentLanguage().apiCode == "zh-TW") &&
        (widget.game.gamePlatformCode == "HABA" || widget.game.gamePlatformCode == "PP")) ||
        widget.game.gamePlatformCode == "SW"|| widget.game.type == GameType.Fishing )*/
    return widget.game!.code;
    /*else
      return widget.game.code.replaceAll(RegExp("_"), "");*/
  }

  _buildImageTitleAndFavouriteIcon() {
    return /*Expanded(
      flex: 1,
      child:*/
        Container(
      height: 32.auto,
      decoration: BoxDecoration(
          color: CustomColor.theme_button_color,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5),
          )),
      padding: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 7.auto),
      child: Row(
        children: [
          Expanded(
            flex: 9,
            child: Container(
              margin: EdgeInsets.only(right: 3.auto),
              child: AutoSizeText(
                widget.game?.name ?? "",
                style: TextStyle(color: Colors.white),
                minFontSize: 3,
                stepGranularity: 1,
                maxLines: 1,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                //ProgressDialog.show(context, widget.vm!.brandLogoUrl);
                widget.game!.isFavourite!
                    ? widget.vm!.deleteFavoriteGame(widget.game!)
                    : widget.vm!.setFavoriteGame(widget.game!);
              },
              child: Image.asset(
                widget.game!.isFavourite!
                    ? "images/child_game/ic_favorite_selected.png"
                    : "images/child_game/ic_favorite.png",
                width: 15.auto,
                height: 15.auto,
              ),
            ),
          )
        ],
      ),
    );
  }

  String returnGameName(gameCode) {
    return platformList
            ?.singleWhere((element) => element.code == gameCode)
            .name ??
        gameCode;
  }

  _buildPlatformText() => Positioned(
        top: context.screenWidth / 2.45,
        child: Container(
          margin: EdgeInsets.only(left: 10.auto, top: 5.auto),
          padding: EdgeInsets.symmetric(vertical: 5.auto, horizontal: 15.auto),
          decoration: BoxDecoration(
              color: CustomColor.black,
              borderRadius: BorderRadius.circular(15.0)),
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
                    onPauseBgMusic: () => (widget.onPauseBgMusic != null)
                        ? widget.onPauseBgMusic!()
                        : null,
                    onResumeBgMusic: () => (widget.onResumeBgMusic != null)
                        ? widget.onResumeBgMusic!()
                        : null,
                  )));
    });
  }
}
