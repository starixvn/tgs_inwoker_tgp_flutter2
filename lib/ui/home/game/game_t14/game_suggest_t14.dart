import 'package:api/entity/game.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/entity/game_type.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/home/game/game_t1/game_item_t1.dart';
import 'package:tgp_flutter2/ui/home/game/game_t14/game_item_t14.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';

import '../../../../custom/color_button.dart';

class GameSuggestT14 extends StatefulWidget {
  final GameViewModel vm;

  final String titleType;
  final String tag;

  GameSuggestT14({
    required this.vm,
    required this.titleType,
    required this.tag,
  });

  @override
  _GameSuggestT14State createState() => _GameSuggestT14State();
}

class _GameSuggestT14State extends BaseState<GameSuggestT14> {
  var currentTabIndex = 0, currentGameType, currentGamePlatformCode;
  var gameName;
  GlobalKey<GameItemT1State> gameViewItem = GlobalKey();

  @override
  void initState() {
    currentGameType = widget.vm.gameTypeList.first;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Game> gamelist = (widget.vm.slotGameListByTagMap[widget.tag] ?? []).take(9).toList();
    print(gamelist);
    return gamelist.isEmpty
        ? Container()
        : Column(
            children: [
              Container(
                child: Row(
                  children: [
                    Expanded(
                      flex: 0,
                      child: Icon(
                        Icons.star,
                        size: 20,
                        color: CustomColor.theme_button_color,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: Text(
                        widget.titleType,
                        style: TextStyle(color: CustomColor.theme_button_color, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
              GridView.count(
                padding: EdgeInsets.all(10.auto),
                crossAxisCount: 3,
                childAspectRatio: 2 / 3,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 20,
                children: List.generate(
                  gamelist.length,
                  (index) => GameItemT14(
                      game: gamelist[index],
                      //isFavourite: true,
                      isDisabled: false,
                      vm: widget.vm,
                      onPauseBgMusic: () {},
                      onResumeBgMusic: () {}),
                ),
              ),
              SizedBox(height: 10),
              ColorButton(title: getTranslatedText("see_more"), onClick: () {}, isEnabled: true),
              SizedBox(height: 20),
            ],
          );
  }
}
