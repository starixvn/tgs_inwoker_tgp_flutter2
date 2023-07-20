import 'package:api/entity/game.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/home/game/game_t11/game_item_t11.dart';
import 'package:tgp_flutter2/ui/home/game/game_t14/game_item_t14.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/jackpot/jackpot.dart';

import '../../../../my_behavior.dart';
import '../../../../provider/provider_widget.dart';
import '../../../../route_path.dart';

class GameT14 extends StatefulWidget {
  final GameViewModel vm;
  final Function onRefreshHomePage;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final ValueChanged<GameProvider2> onGameClick;
  final ValueChanged<bool> onClickGameTab;
  final ValueChanged<Game> onClickChildGame;
  final GameType currGameType;

  GameT14({
    required this.vm,
    required this.onRefreshHomePage,
    this.onPauseBgMusic,
    this.onResumeBgMusic,
    required this.onGameClick,
    required this.onClickGameTab,
    required this.onClickChildGame,
    required this.currGameType,
  });

  @override
  _GameT14State createState() => _GameT14State();
}

class _GameT14State extends BaseState<GameT14> {
  var _controller = ScrollController();
  var currentTabIndex, currentGamePlatformCode;
  var gameName;
  GlobalKey<GameItemT11State> gameViewItem = GlobalKey();
  var isDisplayGameView = false;
  String currGamePlatformCode = "";
  double _imageRatio = 1;
  double _containerPaddingRight = 5.auto;
  double _listViewPaddingRight = 5.auto;
  double _itemPaddingRight = 0; //5.auto;
  double _itemPaddingLeft = 0; //(8.5).auto;
  double _itemPaddingTop = 0;
  double _itemPaddingBottom = 0;

  double get _itemWidth => context.size!.width - _listViewPaddingRight - _itemPaddingRight - _itemPaddingLeft;

  double get itemHeight => _itemWidth * (1 / _imageRatio) + _itemPaddingTop + _itemPaddingBottom;

  @override
  void initState() {
    //_controller.addListener(_scrollListener);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff000325),
      child: ScrollConfiguration(
        behavior: MyBehavior(),
        child: GridView.count(
          padding: EdgeInsets.all(10.auto),
          crossAxisCount: 3,
          childAspectRatio: _imageRatio,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: (_getGameTypeMap() ?? [])
              .map((item) => Container(
                    margin: EdgeInsets.only(top: 15.auto),
                    child: _buildImageLayout(item),
                  ))
              .toList(),
        ),
      ),
    );
  }

  _buildImageLayout(GameProvider2 gameProvider) {
    return InkWell(
      onTap: () {
        if (gameProvider.status != 0) {
        } else
          widget.onGameClick!(gameProvider);
      },
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: _imageRatio,
            child: gameProvider.status != 0
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(300),
                    child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.black,
                          BlendMode.saturation,
                        ),
                        child: _buildImage(gameProvider)),
                  )
                : _buildImage(gameProvider),
          ),
        ],
      ),
    );
  }

  _buildImage(GameProvider2 gameProvider) => Container(
        alignment: Alignment.center,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(300),
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

  _getGameTypeMap() {
    return widget.vm.gameTypeMap![widget.currGameType];
  }

  _handleApiState() {
    handleApiState(widget.vm.getGameProviderListApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(widget.vm.getGameApiState, onSuccess: () {});

    handleApiState(widget.vm.getLobbyGameUrlApiState, onSuccess: () {
      if (widget.vm.url == null) _navigateToMaintenance();
      // else if (_isSWGame() || _isSGGame() || _isTcgGame())
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     launch(widget.vm.url!);
      //   });
    }, onError: (_) {
      _navigateToMaintenance();
    });

    handleApiState(widget.vm.getGameUrlApiState, onSuccess: () {
      if (widget.vm.url == null) _navigateToMaintenance();
      // else if (_isSWGame() || _isSGGame() || _isTcgGame())
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     launch(widget.vm.url!);
      //   });
    }, onError: (_) {
      _navigateToMaintenance();
    });
  }

  _navigateToMaintenance() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if (_isSWGame() || _isSGGame() || _isTcgGame())
      //   Navigator.of(context).pushNamed(RoutePath.maintenance);
      // else
      Navigator.of(context).pushReplacementNamed(RoutePath.maintenance);
    });
  }
}
