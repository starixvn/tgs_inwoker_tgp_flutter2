import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/entity/game.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/home/game/game_web_view.dart';

class ChildGameSuggestion extends StatefulWidget {
  final bool isVisible;
  final List<Game> recommendList;

  ChildGameSuggestion({this.isVisible, this.recommendList});

  @override
  _ChildGameSuggestionState createState() => _ChildGameSuggestionState();
}

class _ChildGameSuggestionState extends BaseState<ChildGameSuggestion> {
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isVisible,
      child: Container(
        width: context.screenWidth,
        margin: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 5.auto),
        padding: EdgeInsets.all(10.auto),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.auto), color: Colors.white),
        child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            childAspectRatio: 96.6 / 25,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: List.generate(
                widget.recommendList.length,
                (index) => Container(
                      height: (12.5).auto,
                      width: 50.auto,
                      child: _buildSearchSuggestionItem(widget.recommendList[index]),
                    ))),
      ),
    );
  }

  _buildSearchSuggestionItem(Game game) => InkWell(
        onTap: () => _navigateToGameWeb(game),
        child: Container(
          height: 5.auto,
          width: 50.auto,
          padding: EdgeInsets.symmetric(horizontal: 5.auto),
          decoration: BoxDecoration(
              color: CustomColor.theme_button_color,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Center(
            child: AutoSizeText(
              game.name,
              style: TextStyle(color: CustomColor.theme_text_grey_color, fontSize: 15),
              minFontSize: 10,
              stepGranularity: 1,
            ),
          ),
        ),
      );

  _navigateToGameWeb(Game game) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => GameWeb(gamePlatformCode: game.gamePlatformCode, gameId: game.id,)));
    });
  }
}
