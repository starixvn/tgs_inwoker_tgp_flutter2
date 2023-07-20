import 'dart:ui';

import 'package:api/entity/game_provider2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:api/entity/game_type.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/GlobalValueUtil.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/home/game/game_t14/game_item_t14.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';

class ChildGameT14 extends StatefulWidget {
  final String? gamePlatformCode;
  final GameType? gameType;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final GameViewModel vm;

  ChildGameT14({this.gamePlatformCode, this.gameType, this.onPauseBgMusic, this.onResumeBgMusic, required this.vm});

  @override
  _ChildGameT14State createState() => _ChildGameT14State();
}

class _ChildGameT14State extends BaseState<ChildGameT14> with SingleTickerProviderStateMixin {
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
  late GameViewModel _vm;
  var searchController = TextEditingController();
  var _focusNode = FocusNode();
  var isSearching = false, isVisibleSuggestionList = false, isInitLoading = true;
  var currGamePlatformCode;

  @override
  void initState() {
    _vm = widget.vm;
    _groupTabController = TabController(length: _groupTabList.length, vsync: this, initialIndex: _groupTabIndex);
    _focusNode.addListener(_onFocusNodeListener);
    currGamePlatformCode = (widget.vm.platformList ?? []).first.code ?? "";
    GlobalValueUtil.pausesong();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Container(
      // subtract bottom navigation bar height
      height: context.screenHeight - context.screenWidth / 6,
      color: Color(0xff000325),
      child: _buildWidget(),
    );
    // });
  }

  _buildWidget() {
    if (_vm.filteredGameList == null || _vm.gameProviderList == null)
      return buildProgressDialog(_vm.brandLogoUrl);
    else {
      // List<Game> gamelist = (widget.vm.filteredGameList ?? []).take(10).toList();
      return ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(10.auto),
        physics: BouncingScrollPhysics(),
        children: [
          Container(
            height: context.screenHeight / 23,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: double.infinity,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(color: Color(0xff1f213a), borderRadius: BorderRadius.all(Radius.circular(25))),
                    child: TextFormField(
                      autofocus: false,
                      onChanged: (value) {
                        _vm.filter(context: context, searchQuery: searchController.text);
                      },
                      controller: searchController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(color: Colors.white, fontSize: 13.auto),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: "Search bar",
                        hintStyle: TextStyle(color: Colors.white, fontSize: 13.auto),
                      ), /*Text("Search bar", style: TextStyle(color: Colors.white)*/
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(color: Color(0xff1f213a), borderRadius: BorderRadius.all(Radius.circular(25))),
                    padding: EdgeInsets.all(10),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<GameProvider2>(
                        isExpanded: true,
                        isDense: true,
                        hint: Container(child: Text(currGamePlatformCode == null ? "Providers" : currGamePlatformCode, style: TextStyle(color: Colors.white))),
                        items: (widget.vm.platformList ?? []).map((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(
                              value.code ?? "",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (GameProvider2? value) {
                          setState(() {
                            currGamePlatformCode = value?.code ?? "";
                          });
                          _vm.filter(context: context, gamePlatformCode: currGamePlatformCode);
                        },
                        style: TextStyle(
                          color: CustomColor.theme_title_text_color,
                        ),
                        dropdownStyleData: DropdownStyleData(
                            maxHeight: context.screenHeight * 0.6,
                            width: (context.screenWidth / 2) - 10,
                            offset: const Offset(-10, -15),
                            decoration: BoxDecoration(color: Color(0xff1f213a))),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 165.5 / 198,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: List.generate((widget.vm.filteredGameList ?? []).length, (index) {
                return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: GameItemT14(
                      game: (widget.vm.filteredGameList ?? [])[index],
                      //isFavourite: true,
                      isDisabled: false,
                      vm: widget.vm,
                      onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                      onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                    ));
              }),
            ),
          ),
        ],
      );
    }
  }

  _buildChildGameT14() => ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: _groupTabList.map((item) {
          return Container(
            width: context.screenWidth / 4.5,
            child: Text(getTranslatedText(item),
                style: TextStyle(
                  fontFamily: 'PingFang',
                  fontSize: 14.auto,
                )),
          );
        }).toList(),

        // if (widget.gameType != GameType.VirtualSports)
        //   Container(
        //     constraints: BoxConstraints(maxHeight: 35.auto),
        //     width: context.screenWidth,
        //     child: TabBar(
        //       controller: _groupTabController,
        //       isScrollable: true,
        //       unselectedLabelColor: CustomColor.theme_text_grey_white_color,
        //       labelColor: CustomColor.theme_button_color,
        //       indicatorColor: CustomColor.theme_button_color,
        //       indicatorWeight: 3,
        //       onTap: (index) {
        //         setState(() {
        //           _groupTabIndex = index;
        //         });
        //         _vm.filter(category: index);
        //       },
        //       unselectedLabelStyle: TextStyle(color: CustomColor.grey),
        //       tabs: _groupTabList.map((item) {
        //         return Tab(
        //           child: Text(getTranslatedText(item),
        //               style: TextStyle(
        //                 fontFamily: 'PingFang',
        //                 fontSize: 14.auto,
        //               )),
        //         );
        //       }).toList(),
        //     ),
        //     ),
        //   Expanded(
        //     child: ChildGameT14Platform(
        //       platformList: _vm.platformList,
        //       gameList: _vm.filteredGameList,
        //       isSearching: isSearching,
        //       onFilterPlatform: (code) {
        //         _vm.filter(gamePlatformCode: code);
        //       },
        //       initialPlatformCode: widget.gamePlatformCode!,
        //       vm: _vm,
        //       onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
        //       onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
        //     ),
        //   ),
        // ],
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
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
              ],
            ),
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
          _vm.filter(context: context, searchQuery: "");
        },
        child: Container(
          padding: EdgeInsets.only(right: 8.auto),
          alignment: Alignment.center,
          child: Text(
            getTranslatedText("cancel"),
            style: TextStyle(
              color: CustomColor.theme_app_bar_text_color,
            ),
          ),
        ),
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
              color: CustomColor.theme_app_bar_text_color,
            ),
          ),
        );
      } else {
        // if not in searching mode and search controller text is not empty
        return InkWell(
          onTap: () {
            _vm.filter(context: context, searchQuery: "");
          },
          child: Container(
            padding: EdgeInsets.only(right: 8.auto),
            alignment: Alignment.center,
            child: Text(
              getTranslatedText("cancel_search"),
              style: TextStyle(
                color: CustomColor.theme_app_bar_text_color,
              ),
            ),
          ),
        );
      }
    }
  }

  _onFocusNodeListener() {
    if (!_focusNode.hasFocus) {
      isSearching = false;
      isVisibleSuggestionList = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
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
