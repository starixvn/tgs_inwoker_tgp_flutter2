import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/home/game/game_t1/game_item_t1.dart';
import 'package:tgp_flutter2/ui/home/game/game_t8_dark/game_item_t8_dark.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';

class GameT8Dark extends StatefulWidget {
  final GameViewModel vm;
  final Function onRefreshHomePage;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final ValueChanged<GameProvider2> onGameClick;

  GameT8Dark({
    required this.vm,
    required this.onRefreshHomePage,
     this.onPauseBgMusic,
     this.onResumeBgMusic,
    required this.onGameClick,
  });

  @override
  _GameT8DarkState createState() => _GameT8DarkState();
}

class _GameT8DarkState extends BaseState<GameT8Dark> {
  var _controller = ScrollController();
  var currentTabIndex = 0, currentGameType = GameType.Sportsbook, currentGamePlatformCode;
  var gameName;
  GlobalKey<GameItemT1State> gameViewItem = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.vm.gameProviderList == null
        ? buildProgressDialog(widget.vm.brandLogoUrl)
        : Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 10.auto, right: 10.auto),
        child: Column(
          children: [
            Container(
              height: 135.auto,
              margin: EdgeInsets.only(right: 5.auto),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color(0xffFEFFA1)),
                gradient: LinearGradient(
                    colors: [
                      Color(0xff080F21),
                      Colors.transparent.withOpacity(1.0),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: [0, 0.5]),
              ),
              padding: EdgeInsets.symmetric(vertical: 10.auto, horizontal: 15.auto),
              child: GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  physics: NeverScrollableScrollPhysics(),
                  children: List.generate(
                      widget.vm.gameTypeList.length,
                          (index) => Container(
                        child: _buildGameTab(index, widget.vm.gameTypeList[index]),
                      ))),
            ),
            Flexible(
              flex: 1,
              child: Container(
                height: context.screenHeight / 2 - 77.auto,
                child: GameItemT8Dark(
                  gameViewItem,
                  controller: _controller,
                  gameProviderList: _getGameTypeMap(),
                  onGameClick: (game) => widget.onGameClick(game),
                  config: widget.vm.config,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getGameTypeMap() {
    return widget.vm.gameTypeMap![currentGameType];
  }

  _buildGameTab(int tabIndex, GameType gameType) {
    // var bgImage = tabIndex == currentTabIndex ? "btn_home_game_category_selected_bg" : "btn_home_game_category_bg";
    return InkWell(
      onTap: () {
        _onTabClick(tabIndex, gameType);
      },
      child: Container(
        padding: EdgeInsets.only(top: 5.auto),
        decoration: tabIndex == currentTabIndex
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color(0xffFEFFA1)),
                gradient: LinearGradient(
                    colors: [
                      Color(0xff152C62), Color(0xff071842),

                      // Colors.transparent.withOpacity(1.0),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    stops: [0, 0.8]),
              )
            : BoxDecoration(),
        alignment: Alignment.center,
        child: ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: tabIndex == currentTabIndex
                  ? [
                      Color(0xffFEFFA1),
                      Color(0xffE9A60B),
                    ]
                  : [
                      Colors.white,
                      Colors.white,
                    ],
            ).createShader(bounds);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //tabIndex == currentTabIndex
              SvgPicture.asset(
                "images/game_tab/t8/ic_${gameType.getImagePath()}.svg",
                matchTextDirection: true,
                height: 20.auto,
                color: Colors.white,
              ), //Image.asset("images/game_tab/ic_$imagePath.png")),
              AutoSizeText(
                gameType.getName(context, widget.vm.config?.menuItemShootFish ?? false),
                textAlign: TextAlign.center,
                minFontSize: 2,
                maxFontSize: 13,
                stepGranularity: 1,
                maxLines: 2,
              ),
            ],
          ),
          blendMode: BlendMode.srcATop,
        ),
      ),
    );
  }

  _onTabClick(int tabIndex, GameType gameType) {
    setState(() {
      currentGameType = gameType == GameType.VirtualSports ? GameType.Sportsbook : gameType;
      currentTabIndex = tabIndex;
      _controller.animateTo(0, duration: Duration(milliseconds: 250), curve: Curves.linear);
    });
  }
}
