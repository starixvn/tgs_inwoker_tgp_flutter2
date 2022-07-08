import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/home/game/game_t3/game_item_t3.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';

class GameT3 extends StatefulWidget {
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final GameViewModel vm;
  final Function onRefreshHomePage;
  final ValueChanged<GameProvider2> onGameClick;

  GameT3({
    required this.vm,
    required this.onRefreshHomePage,
    this.onPauseBgMusic,
    this.onResumeBgMusic,
    required this.onGameClick,
  });

  @override
  _GameT3State createState() => _GameT3State();
}

class _GameT3State extends BaseState<GameT3> {
  var gameName;
  double _imageRatio = 750 / 330;
  var imageLanguageCode;

  @override
  void initState() {
    widget.vm.getGameProviderList(isRefresh: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: ListView(
        children: [_buildImageRow(), _buildGameImageGridView()],
      ),
    );
  }

  getLanguage() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var languageCode = _prefs.getString("LANGUAGE_CODE") ?? EnvironmentConfig.default_lang;
    imageLanguageCode = (languageCode.contains("th")) ? languageCode : "en-US";
  }

  _buildImageRow() {
    getLanguage();
    return Container(
      height: 180.auto,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(widget.vm.gameRowListT3!.length, (index) {
            return InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GameItemT3(
                              gamePlatformCode: "",
                              gameType: widget.vm.gameRowListT3![index],
                              index: index,
                              onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                              onResumeBgMusic: () =>
                                  (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                              onGameClick: (gameProvider) => widget.onGameClick(gameProvider),
                          vm: widget.vm,
                            ))),
                child: Container(
                  width: context.screenWidth / 2 - 15.auto,
                  child: (widget.vm.config?.homePageAnimated ?? false)
                      ? Image.asset(
                          _getFullGameTabImagePath(widget.vm.gameRowListT3![index].getImagePath()),
                        )
                      : Stack(
                          children: [
                            Image.asset("images/home/${widget.vm.gameRowListT3![index].getImagePath()}.png"),
                            Positioned(
                              bottom: 7.auto,
                              right: 10.auto,
                              child: Container(
                                width: 80.auto,
                                height: 90.auto,
                                alignment: Alignment.bottomCenter,
                                child: AutoSizeText(
                                  // gameType.getName(context, widget.vm.config?.menuItemShootFish ?? false),
                                  widget.vm.gameRowListT3![index]
                                      .getName(context, widget.vm.config?.menuItemShootFish ?? false),
                                  maxFontSize: 23,
                                  minFontSize: 10,
                                  stepGranularity: 1,
                                  style: TextStyle(color: CustomColor.theme_text_black_white_color, fontSize: 23),
                                ),
                              ),
                            ),
                          ],
                        ),
                ));
          })),
    );
  }

  _buildGameImageGridView() {
    return Container(
      height: 260.auto,
      margin: EdgeInsets.only(top: 8.auto, bottom: 10.auto),
      child: StaggeredGridView.countBuilder(
        crossAxisCount: 2,
        itemCount: widget.vm.gameListT3!.length,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) => InkWell(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GameItemT3(
                        gamePlatformCode: "",
                        gameType: widget.vm.gameListT3![index],
                        index: index,
                        onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                        onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                        onGameClick: (gameProvider) => widget.onGameClick(gameProvider),
                    vm: widget.vm,
                      ))),
          child: (widget.vm.config?.homePageAnimated ?? false)
              ? Image.asset(
                  _getFullGameTabImagePath(widget.vm.gameListT3![index].getImagePath()),
                )
              : Stack(
                  children: [
                    Image.asset(
                      _getFullGameTabImagePath(widget.vm.gameListT3![index].getImagePath()),
                    ),
                    Positioned(
                        bottom: 20.auto,
                        left: 60.auto,
                        child: Container(
                          width: 70.auto,
                          height: 40.auto,
                          alignment: Alignment.bottomLeft,
                          child: AutoSizeText(
                            widget.vm.gameListT3![index].getName(context, widget.vm.config?.menuItemShootFish ?? false),
                            maxFontSize: 23,
                            minFontSize: 10,
                            stepGranularity: 1,
                            style: TextStyle(color: CustomColor.theme_text_black_white_color, fontSize: 23.auto),
                          ),
                        )),
                  ],
                ),
        ),
        staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
        mainAxisSpacing: 15.auto,
        crossAxisSpacing: 15.auto,
      ),
    );
  }

  _getFullGameTabImagePath(String path) {
    if (widget.vm.config?.homePageAnimated ?? false)
      return "images/game_tab/t3/$imageLanguageCode/$path.gif";
    else
      return "images/game_tab/t3/$path.png";
  }
}
