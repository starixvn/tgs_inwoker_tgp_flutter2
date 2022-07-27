import 'package:api/entity/env_features_config.dart';
import 'package:api/entity/game_provider.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/home/child_game/child_game.dart';
import 'package:tgp_flutter2/ui/home/game/game_t3/game_item_t3.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/game/game_web_view.dart';
import 'package:url_launcher/url_launcher.dart';

class GameT4 extends StatefulWidget {
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final GameViewModel vm;
  final Function? onRefreshHomePage;
  final ValueChanged<GameProvider2> onGameClick;

  GameT4({
    this.onResumeBgMusic,
    this.onPauseBgMusic,
    required this.vm,
    this.onRefreshHomePage,
    required this.onGameClick,
  });

  @override
  _GameT3State createState() => _GameT3State();
}

class _GameT3State extends BaseState<GameT4> {
  var gameName;
  late GameViewModel _vm;
  double _imageRatio = 750 / 330;
  var imageLanguageCode;

  @override
  void initState() {
    _vm = widget.vm;
    _vm.getGameProviderList(isRefresh: true);
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
    var languageCode =
        _prefs.getString("LANGUAGE_CODE") ?? EnvironmentConfig.default_lang;
    imageLanguageCode = (languageCode.contains("th")) ? languageCode : "en-US";
  }

  _buildGameImageGridView() {
    return Container(
      height: 400.auto,
      margin: EdgeInsets.only(top: 8.auto, bottom: 10.auto),
      child: StaggeredGrid.count(
        crossAxisCount: 3,
        mainAxisSpacing: 15.auto,
        crossAxisSpacing: 15.auto,
        children: List.generate(_vm.gameListT3!.length, (index) {
          return InkWell(
            onTap: () =>
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GameItemT3(
                              gamePlatformCode: "",
                              gameType: _vm.gameListT3![index],
                              index: index,
                              onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                              onResumeBgMusic: () =>
                              (widget.onResumeBgMusic != null)
                                  ? widget.onResumeBgMusic!()
                                  : null,
                              onGameClick: (gameProvider) => widget.onGameClick(gameProvider),
                              vm: _vm,
                            ))),
            child: (_vm.config?.homePageAnimated ?? false)
                ? Image.asset(
              _getFullGameTabImagePath(
                  _vm.gameListT3![index].getImagePath()),
            )
                : Column(
              children: [
                Image.asset(
                  _getFullGameTabImagePath(
                      _vm.gameListT3![index].getImagePath()),
                ),
                Container(
                  width: 70.auto,
                  height: 40.auto,
                  alignment: Alignment.center,
                  child: AutoSizeText(
                    _vm.gameListT3![index].getName(
                        context, _vm.config?.menuItemShootFish ?? false),
                    maxFontSize: 23,
                    minFontSize: 10,
                    stepGranularity: 1,
                    style: TextStyle(
                        color: CustomColor.theme_text_black_white_color,
                        fontWeight: FontWeight.bold,
                        fontSize: 23.auto),
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  _getFullGameTabImagePath(String path) {
    if (_vm.config?.homePageAnimated ?? false)
      return "images/game_tab/t4/$imageLanguageCode/$path.gif";
    else
      return "images/game_tab/t4/$path.png";
  }
}
