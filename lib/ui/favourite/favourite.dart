import 'dart:ui';
import 'package:api/entity/game.dart';
import 'package:api/entity/game_type.dart';
import 'package:api/entity/vip.dart';
import 'package:api/extension/format.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';

import '../home/game/game_t14/game_item_t14.dart';

class Favourite extends StatefulWidget {
  @override
  _FavouriteState createState() => _FavouriteState();
}

class _FavouriteState extends BaseState<Favourite> {
  GameViewModel _vm = GameViewModel();
  List<GameType> gameTypeList = [GameType.Fishing, GameType.Slot, GameType.EGame];
  List<Game> favouriteGameList = [];

  @override
  void initState() {
    _initData();
    super.initState();
  }

  _initData() async {
    await _vm.getGameProviderList(isRefresh: true);

    gameTypeList.forEach((gameType) async {
      await _vm.getPlatformList(gameType);
      await _vm.filter(category: 3, gamePlatformCode: "ALL", gameType: gameType);
    });
  }

  Widget build(BuildContext context) {
    return ProviderWidget<GameViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return CustomScaffold(
              appBar: _buildAppBar(),
              body: (() {
                if (_vm.favouriteGameList == null)
                  return buildProgressDialog(_vm.brandLogoUrl);
                else if (_vm.favouriteGameList?.isEmpty ?? true) return _buildEmptyFavouriteList();
                return Container(
                  height: context.screenHeight,
                  child: ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 15.auto, left: 5.auto, right: 5.auto),
                        child: GridView.count(
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          // scrollDirection: Axis.horizontal,
                          children: List.generate(
                            _vm.favouriteGameList!.length,
                            (index) {
                              return GameItemT14(
                                game: (_vm.favouriteGameList ?? [])[index],
                                //isFavourite: true,
                                isDisabled: false,
                                vm: _vm,
                                onPauseBgMusic: () {},
                                onResumeBgMusic: () {},
                                isHideFavourite: true,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }()));
        });
  }

  _buildAppBar() => CustomAppBar(
        title: getTranslatedText("my_favorite"),
      );

  _buildEmptyFavouriteList() => Container(
        width: context.screenWidth,
        height: context.screenHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "images/child_game/no_favorite.svg",
              width: 100.auto,
              height: 100.auto,
            ),
            SizedBox(height: 10.auto),
            Text(
              getTranslatedText("no_favorite_hint"),
              style: TextStyle(fontSize: 10.auto, color: Colors.white),
            ),
            SizedBox(height: 10.auto),
            Text(
              getTranslatedText("no_favorite_hint2"),
              style: TextStyle(fontSize: 10.auto, color: Colors.white),
            ),
          ],
        ),
      );

  _handleApiState() {
    handleApiState(_vm.getFavouriteGameApiState, isAutoHideLoading: false, isSplashScreen: true, onSuccess: () {});
    handleApiState(_vm.getGameApiState, isAutoHideLoading: false, isSplashScreen: true, onSuccess: () {});
  }
}
