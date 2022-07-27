import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/home/game/game_t3/game_item_t3.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
        children: [_buildGameImageGridView()],
      ),
    );
  }

  getLanguage() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var languageCode = _prefs.getString("LANGUAGE_CODE") ?? EnvironmentConfig.default_lang;
    imageLanguageCode = (languageCode.contains("th")) ? languageCode : "en-US";
  }

  _buildGameImageGridView() {
    return Container(
      // height: 260.auto,
      margin: EdgeInsets.only(top: 8.auto, bottom: 10.auto),
      child: StaggeredGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 15.auto,
        crossAxisSpacing: 15.auto,
        children: List.generate(
          widget.vm.gameListT3!.length,
          (index) => InkWell(
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
                        bottom: (widget.vm.gameListT3![index] == GameType.Sportsbook ||
                                widget.vm.gameListT3![index] == GameType.LiveDealerLobby)
                            ? 7.auto
                            : 20.auto,
                        left: (widget.vm.gameListT3![index] == GameType.Sportsbook ||
                                widget.vm.gameListT3![index] == GameType.LiveDealerLobby)
                            ? context.screenWidth / 3.8
                            : 70.auto,
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
                        ),
                      ),
                    ],
                  ),
          ),
        ),
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
