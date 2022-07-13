import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';

class GameItemT3 extends StatefulWidget {
  final String? gamePlatformCode;
  final GameType? gameType;
  final int? index;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final ValueChanged<GameProvider2> onGameClick;
  final GameViewModel vm;

  GameItemT3({
    this.gamePlatformCode,
    this.gameType,
    this.index,
    this.onPauseBgMusic,
    this.onResumeBgMusic,
    required this.onGameClick,
    required this.vm,
  });

  @override
  _GameItemT3State createState() => _GameItemT3State();
}

class _GameItemT3State extends BaseState<GameItemT3> {
  var gameName;

  double _imageRatio = 750 / 330;

  @override
  void initState() {
    widget.vm.getGameProviderList(isRefresh: true);
    super.initState();
  }

  List<dynamic>? _getGameTypeMap() {
    if (widget.vm.gameTypeMap?.isEmpty ?? true)
      return null;
    else
      return widget.vm.gameTypeMap![widget.gameType]!;
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
        behavior: MyBehavior(),
        child: CustomScaffold(
            appBar: CustomAppBar(
              title: getTranslatedText(widget.gameType!.getName(context, false)),
              isPassTrueWhenPop: true,
            ),
            body: _getGameTypeMap() == null
                ? buildProgressDialog(widget.vm.brandLogoUrl)
                : ListView(
                    padding: EdgeInsets.only(bottom: 15.auto),
                    children: _getGameTypeMap()!
                        .map((item) => Container(
                            margin: EdgeInsets.only(top: 15.auto, left: 15.auto, right: 15.auto),
                            child: _buildImageLayout(item)))
                        .toList())));
  }

  _buildImageLayout(GameProvider2 gameProvider) {
    var gamePlatformCode = gameProvider.code?.toLowerCase();

    return InkWell(
      onTap: () {
        if (gameProvider.status != 0) {
        } else
          widget.onGameClick(gameProvider);
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
                (_isSportsHideLogo(gamePlatformCode))
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
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.4)),
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
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage("images/game/T3/btn-start-game.jpg"))),
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

  _isSportsHideLogo(String? gamePlatformCode) =>
      (widget.vm.config?.sportsHideLogo ?? false) && (gamePlatformCode == "wgfm" || gamePlatformCode == "wgvia");
}
