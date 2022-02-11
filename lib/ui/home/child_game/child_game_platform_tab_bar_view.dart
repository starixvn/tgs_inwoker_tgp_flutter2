import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:api/entity/game.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/home/child_game/child_game_item.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';

class ChildGamePlatformTabBarView extends StatefulWidget {
  final List<Game>? gameList;
  final Function? onClick;
  final bool isDisabled;
  final GameViewModel? vm;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;

  ChildGamePlatformTabBarView(
      {@required this.gameList,
      this.onClick,
      this.isDisabled = false,
      this.vm,
      this.onPauseBgMusic,
      this.onResumeBgMusic});

  @override
  _ChildGamePlatformTabBarViewState createState() => _ChildGamePlatformTabBarViewState();
}

class _ChildGamePlatformTabBarViewState extends BaseState<ChildGamePlatformTabBarView> {
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.
      all(10.auto),
      crossAxisCount: 2,
      childAspectRatio: 165.5 / 198,
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: List.generate(widget.gameList!.length, (index) {
        return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ChildGameItem(
              game: widget.gameList![index],
              //isFavourite: true,
              isDisabled: widget.isDisabled,
              vm: widget.vm,
              onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
              onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
            ));
      }),
    );
  }
}
