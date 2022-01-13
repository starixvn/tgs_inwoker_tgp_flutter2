import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:api/entity/game_type.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/home/child_game/child_game_platform.dart';
import 'package:tgp_flutter2/ui/home/child_game/child_game_suggestion.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';

class ChildGame extends StatefulWidget {
  final String? gamePlatformCode;
  final GameType? gameType;

  ChildGame({this.gamePlatformCode, this.gameType});

  @override
  _ChildGameState createState() => _ChildGameState();
}

class _ChildGameState extends BaseState<ChildGame> with SingleTickerProviderStateMixin {
  var _groupTabController;
  var _groupTabIndex = 0;
  var _groupTabList = [
    "all_game",
    "new_game",
    "hot_game",
    "favorite_game"
    /*"收藏游戏",
    "捕鱼游戏",
    "历史游戏"*/
  ];
  var _vm = GameViewModel();
  var searchController = TextEditingController();
  var _focusNode = FocusNode();
  var isSearching = false, isVisibleSuggestionList = false, isInitLoading = true;
  var currGamePlatformCode;

  @override
  void initState() {
    _groupTabController = TabController(length: _groupTabList.length, vsync: this, initialIndex: _groupTabIndex);
    _focusNode.addListener(_onFocusNodeListener);
    currGamePlatformCode = widget.gamePlatformCode;
    _initData();
    super.initState();
  }

  _initData() async {
    await _vm.getGameProviderList();
    _vm.getPlatformList(widget.gameType!);
    _vm.filter(context: context, gamePlatformCode: widget.gamePlatformCode!, gameType: widget.gameType!);
  }

  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: ProviderWidget<GameViewModel>(
          model: _vm,
          builder: (ctx, vm, _) {
            _handleApiState();
            return Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: CustomColor.theme_bg_color,
                appBar: _buildAppBar(),
                body: _buildWidget());
          }),
    );
  }

  _buildAppBar() => AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: CustomColor.theme_app_bar_color,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: isSearching
            ? _buildSearchTextField()
            : Text(
                _getAppTitle(),
                style: TextStyle(fontSize: 16.auto),
              ),
        actions: [_getAction()],
      );

  _buildWidget() {
    if (_vm.filteredGameList == null || _vm.gameProviderList == null)
      return buildProgressDialog(_vm.brandLogoUrl);
    else {
      return Stack(
        children: [
          _buildChildGame(),
          _buildOverlay(),
          Visibility(
            visible: _vm.recommendGameList.isNotEmpty && _vm.recommendGameList != null,
            child: ChildGameSuggestion(
              isVisible: isVisibleSuggestionList,
              recommendList: _vm.recommendGameList,
            ),
          )
        ],
      );
    }
  }

  _buildChildGame() => Column(
        children: [
          Container(
            constraints: BoxConstraints(maxHeight: 35.auto),
            width: context.screenWidth,
            child: TabBar(
              controller: _groupTabController,
              isScrollable: true,
              unselectedLabelColor: CustomColor.theme_text_grey_white_color,
              labelColor: CustomColor.theme_button_color,
              indicatorColor: CustomColor.theme_button_color,
              indicatorWeight: 3,
              onTap: (index) {
                setState(() {
                  _groupTabIndex = index;
                });
                _vm.filter(category: index);
              },
              unselectedLabelStyle: TextStyle(color: CustomColor.grey),
              tabs: _groupTabList.map((item) {
                return Tab(
                  child: Text(getTranslatedText(item),
                      style: TextStyle(fontFamily: 'PingFang', fontSize: 14.auto,)),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ChildGamePlatform(
              platformList: _vm.platformList,
              gameList: _vm.filteredGameList,
              isSearching: isSearching,
              onFilterPlatform: (code) {
                _vm.filter(gamePlatformCode: code);
              },
              initialPlatformCode: widget.gamePlatformCode!,
              vm: _vm,
            ),
          ),
        ],
      );

  _buildOverlay() => Visibility(
        visible: isSearching,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.black54, BlendMode.srcOut),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      );

  _buildSearchTextField() => Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 5,
      //margin:EdgeInsets.only(top:15.auto,),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Container(
                width: 110.auto,
                padding: EdgeInsets.symmetric(horizontal: 10.auto),
                child: TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: getTranslatedText("search_keyword"),
                    hintStyle: TextStyle(color: CustomColor.very_light_pink_two, fontSize: 13.auto),
                  ),
                  focusNode: _focusNode,
                  autofocus: true,
                  onChanged: (value) => _onTextChange(),
                ),
              ),
            ]),
            Icon(
              Icons.search,
              color: CustomColor.theme_button_color,
            )
          ],
        ),
      ));

  _getAppTitle() {
    if (widget.gameType != null) {
      return widget.gameType!.getName(context, _vm.config?.menuItemShootFish ?? false);
    }
  }

  _getAction() {
    if (isSearching) {
      //if in searching mode
      return InkWell(
        onTap: () {
          setState(() {
            isSearching = false;
            isVisibleSuggestionList = false;
            searchController.text = "";
          });
          _vm.filter(searchQuery: "");
        },
        child: Container(padding: EdgeInsets.only(right: 8.auto), alignment: Alignment.center, child: Text("取消")),
      );
    } else {
      if (_vm.mSearchQuery?.isEmpty ?? false) {
        // if not in searching mode and search controller text is empty
        return InkWell(
          onTap: () {
            setState(() {
              isSearching = true;
              isVisibleSuggestionList = true;
            });
          },
          child: Container(
            padding: EdgeInsets.only(right: 8.auto),
            child: Icon(
              Icons.search,
            ),
          ),
        );
      } else {
        // if not in searching mode and search controller text is not empty
        return InkWell(
          onTap: () {
            _vm.filter(searchQuery: "");
          },
          child: Container(padding: EdgeInsets.only(right: 8.auto), alignment: Alignment.center, child: Text("取消搜索")),
        );
      }
    }
  }

  _onFocusNodeListener() {
    if (!_focusNode.hasFocus) {
      isSearching = false;
      isVisibleSuggestionList = false;
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        searchController.text = "";
      });
    }
  }

  _onTextChange() {
    if (searchController.text.isNotEmpty) {
      setState(() {
        isVisibleSuggestionList = false;
      });
      _vm.filter(searchQuery: searchController.text);
    }
  }

  _handleApiState() {
    handleApiState(_vm.getGameApiState, isAutoHideLoading: false, onSuccess: () {
      if (_vm.isGamePlatformInactive) {
        currGamePlatformCode = "ALL";
        _vm.filter(gamePlatformCode: currGamePlatformCode);
        _vm.setGamePlatformInactiveFalse();
        CustomToast.show(getTranslatedText("game_platform_inactive"));
      }
    });
    handleApiState(_vm.getGameProviderListApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getFavouriteGameApiState, isAutoHideLoading: !isInitLoading, onSuccess: () {
      if (isInitLoading) isInitLoading = !isInitLoading;
    });
    handleApiState(_vm.setFavouriteGameApiState, onSuccess: () {});
    handleApiState(_vm.deleteFavouriteGameApiState, onSuccess: () {});
  }
}
