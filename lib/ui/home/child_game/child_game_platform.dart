import 'dart:convert';
import 'dart:ui';

import 'package:api/entity/game_type.dart';
import 'package:flutter/material.dart';
import 'package:api/entity/game.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/home/child_game/child_game_platform_tab_bar_view.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';

class ChildGamePlatform extends StatefulWidget {
  final List<GameProvider2>? platformList;
  final List<Game>? gameList;
  final bool isSearching;
  final Function(String)? onFilterPlatform;
  final String? initialPlatformCode;
  final GameViewModel? vm;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;

  ChildGamePlatform(
      {this.platformList,
      this.gameList,
      this.isSearching = false,
      this.onFilterPlatform,
      this.initialPlatformCode,
      this.vm,
      this.onPauseBgMusic,
      this.onResumeBgMusic});

  @override
  _ChildGamePlatformState createState() => _ChildGamePlatformState();
}

class _ChildGamePlatformState extends BaseState<ChildGamePlatform> with SingleTickerProviderStateMixin {
  var _platformTabController;
  var platformTabIndex = 0;
  List<Map<String, String>> _platformTabList = [
    {"name": "all", "code": "ALL"}
  ];

  @override
  void initState() {
    initData();
    super.initState();
  }

  initData() {
    List<Map<String, String>> list = [
      {"name": "all", "code": "ALL"}
    ];
    widget.platformList!.asMap().forEach((index, value) {
      list.add({"name": value.name ?? "", "code": value.code ?? ""});
      if (value.code == widget.initialPlatformCode) {
        platformTabIndex = index + 1;
      }
    });
    _platformTabList = list;
    _platformTabController = TabController(length: list.length, vsync: this, initialIndex: platformTabIndex);
  }

  Widget build(BuildContext context) {
    return Column(children: [
      if (widget.platformList?.first.gameType != GameType.VirtualSports) _buildPlatformTabBar(),
      Expanded(
          child: ChildGamePlatformTabBarView(
        gameList: widget.gameList,
        isDisabled: widget.isSearching,
        vm: widget.vm,
        onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
        onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
      )),
    ]);
  }

  _buildPlatformTabBar() => Container(
        padding: EdgeInsets.symmetric(vertical: 5.auto, horizontal: 5.auto),
        constraints: BoxConstraints(maxHeight: 35.auto),
        color: CustomColor.theme_grey_button_color,
        width: context.screenWidth,
        child: TabBar(
          controller: _platformTabController,
          isScrollable: true,
          unselectedLabelColor: CustomColor.theme_text_grey_color,
          labelColor: CustomColor.theme_button_color,
          indicatorWeight: 3,
          onTap: (index) {
            setState(() {
              platformTabIndex = index;
            });
            widget.onFilterPlatform!((_platformTabList[index]["code"])!);
          },
          indicator: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: CustomColor.theme_button_color),
              borderRadius: BorderRadius.circular(15.auto),
            ),
          ),
          unselectedLabelStyle: TextStyle(color: CustomColor.theme_grey_button_color),
          tabs: _platformTabList.map((item) {
            return Tab(
              child: Text(item["code"] == "ALL" ? getTranslatedText((item["name"])!) : item["name"],
                  style: TextStyle(fontFamily: 'PingFang', fontSize: 14.auto, color: Colors.white)),
            );
          }).toList(),
        ),
      );
}
