import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';
import 'package:api/entity/game.dart';
import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:api/localizations/language_provider.dart';
import 'package:api/network/event_result.dart';
import 'package:api/api.dart';
import 'package:collection/collection.dart';

class GameViewModel extends BaseViewModel {
  final contentRepo = ContentRepository.getSingleton();
  final userRepo = UserRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [contentRepo];
  var getGameApiState;
  var getGameUrlApiState,
      getGameProviderListApiState,
      getLobbyGameUrlApiState,
      getFavouriteGameApiState,
      setFavouriteGameApiState,
      deleteFavouriteGameApiState;
  List<Game>? _gameList, filteredGameList;
  Map<String, List<Game>> gameListMap = new Map<String, List<Game>>();
  int mCategory = 0;
  String? mPlatform, mSearchQuery = "";
  GameType? mGameType;
  var url, lobbyUrl;
  List<GameProvider2>? platformList;
  List<List<GameProvider2>>? gameProviderList;
  List<GameType> gameTypeList = [
    GameType.Sportsbook,
    // GameType.ESports,
    GameType.LiveDealerLobby,
    GameType.CardGameLobby,
    GameType.Fishing,
    GameType.LotteryLobby,
    GameType.Slot,
    GameType.EGame,
  ];
  var _context;
  Map<GameType, List<GameProvider2>>? gameTypeMap = new Map<GameType, List<GameProvider2>>();
  bool isGamePlatformInactive = false;

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get recommendGameList => _getRecommendGameList();

  getGameProviderList({bool isRefresh = false}) async {
    if (contentRepo.gameProviderList == null || isRefresh) {
      setLoading();
      getGameProviderListApiState = await contentRepo.getGameProviderList();
    }
    if (contentRepo.gameProviderList == null) return;

    List<GameProvider2> list = [];
    contentRepo.gameProviderList!.forEach((e) {
      e.gameTypes.forEach((element) {
        if (!(element == GameType.VirtualSports || element == GameType.VirtualSportsLobby)) {
          list.add(GameProvider2(element, e.code, e.name, e.description, e.status));
        }
      });
    });
    gameProviderList = gameTypeList
        .map(
          (type) => list.where((element) => element.gameType == type).toList(),
        )
        .toList();
    gameTypeMap = (groupBy(list, (obj) => obj.gameType));
    print("222");
    setLoading(false);
    return getGameProviderListApiState;
  }

  getGameList(String gamePlatformCode, GameType gameType) async {
    setLoading();
    var apiState = await contentRepo.getGameList(gamePlatformCode, gameType);
    if (apiState.isSuccess) {
      if (apiState.result!.isEmpty) {
        getGameApiState = apiState;
        await getPlatformList(gameType);
        isGamePlatformInactive = true;
        mPlatform = "ALL";
        await filter(gamePlatformCode: mPlatform!);
      } else {
        gameListMap[gamePlatformCode] = apiState.result!;
        if (gameType == GameType.Slot || gameType == GameType.EGame || gameType == GameType.Fishing)
          await _getFavoriteGame(gameType).then((_apiState) {
            if (_apiState.result.isNotEmpty) {
              getGameApiState = _apiState;
            } else {
              getGameApiState = apiState;
            }
          });
      }
    }
    setLoading(false);
    return getGameApiState;
  }

  getGameUrl(String gamePlatformCode, int gameId, String _lobbyUrl) async {
    setLoading();
    getGameUrlApiState = await contentRepo.getGameUrl(gamePlatformCode, gameId, _lobbyUrl);
    if (getGameUrlApiState.isSuccess) {
      url = getGameUrlApiState.result.url;
    }
    setLoading(false);
    return getGameUrlApiState;
  }

  getLobbyGameUrl(String gamePlatformCode, GameType gameType, String _lobbyUrl) async {
    setLoading();
    getLobbyGameUrlApiState = await contentRepo.getLobbyGameUrl(gamePlatformCode, gameType, _lobbyUrl);
    if (getLobbyGameUrlApiState.isSuccess) {
      lobbyUrl = getLobbyGameUrlApiState.result.url;
    }
    setLoading(false);
    return getLobbyGameUrlApiState;
  }

  _getRecommendGameList() {
    if (_gameList != null)
      return _gameList!.where((element) => element.tag.isRecommend == true).take(6).toList();
    else
      return <Game>[];
  }

  filter(
      {BuildContext? context, int? category, String? searchQuery, String? gamePlatformCode, GameType? gameType}) async {
    if (context != null) _context = context;
    if (gamePlatformCode != null && gameType != null) {
      mGameType = gameType;
      mPlatform = gamePlatformCode;
      await getGameList(gamePlatformCode, gameType);
    }
    if (category != null) mCategory = category;
    if (gamePlatformCode != null) mPlatform = gamePlatformCode;
    if (searchQuery != null) mSearchQuery = searchQuery;

    var platformGameList = await _filterPlatform();
    filteredGameList = _filterSearch(_filterCategory(platformGameList));
    notifyListeners();
  }

  List<Game> _filterCategory(List<Game> gameList) {
    switch (mCategory) {
      case 0:
        //all game list
        return gameList;
      case 1:
        //new game list
        var list = gameList.where((element) => element.tag.isNew == true).toList();
        return list;
      case 2:
        //hot game list
        var list = gameList.where((element) => element.tag.isHot == true).toList();
        return list;
      case 3:
        //favorite game list
        var list = gameList.where((element) => element.isFavourite == true).toList();
        return list;
      default:
        return gameList;
    }
  }

  Future<List<Game>> _filterPlatform() async {
    if (mPlatform == "ALL") {
      //get all game list
      List<Game> _list = await _addGameList(_gameList!);
      return _list;
    } else {
      //if (gameListMap[mPlatform] == null) {
      return await getGameList(mPlatform!, mGameType!).then((apiState) {
        if (apiState.result.isEmpty) {
          List<Game> list = [];
          return list;
        } else
          return gameListMap[mPlatform];
      });
    }
  }

  _addGameList(List<Game> list) async {
    var task = <Future>[];
    platformList!.forEach((platform) {
      if (gameListMap[platform.code] == null) {
        task.add(getGameList(platform.code, mGameType!));
      }
    });
    await Future.wait(task);
    return gameListMap.values.expand((element) => element).toList();
  }

  List<Game> _filterSearch(List<Game> gameList) {
    if (mSearchQuery?.isEmpty ?? true) {
      return gameList;
    } else {
      var list = gameList.where((element) => element.name.toLowerCase().contains(mSearchQuery!.toLowerCase())).toList();
      return list;
    }
  }

  getPlatformList(GameType gameType) {
    List<GameProvider2> list = gameProviderList!.expand((e) => e).toList();
    platformList = list.where((element) => element.gameType == gameType).toList();
    notifyListeners();
  }

  _getFavoriteGame(GameType gameType) async {
    setLoading();
    getFavouriteGameApiState = await contentRepo.getFavoriteGame(gameType);
    if (getFavouriteGameApiState.isSuccess) {
      List list = getFavouriteGameApiState.result;
      gameListMap.values.forEach((gameList) => gameList.map((game) {
            game.isFavourite = false;
            list.forEach((id) {
              if (game.id == id) game.isFavourite = true;
            });
          }).toList());
    }
    setLoading(false);
    return getFavouriteGameApiState;
  }

  setFavoriteGame(Game game) async {
    setLoading();
    var _apiState = await contentRepo.setFavoriteGame(game.id);
    if (_apiState.isSuccess) {
      setFavouriteGameApiState = await _getFavoriteGame(game.type);
    } else
      setFavouriteGameApiState = _apiState;
    setLoading(false);
    return setFavouriteGameApiState;
  }

  deleteFavoriteGame(Game game) async {
    setLoading();
    var _apiState = await contentRepo.deleteFavoriteGame(game.id);
    if (_apiState.isSuccess) {
      deleteFavouriteGameApiState = await _getFavoriteGame(game.type);
    } else
      deleteFavouriteGameApiState = _apiState;
    setLoading(false);
    return deleteFavouriteGameApiState;
  }
  setGamePlatformInactiveFalse() {
    isGamePlatformInactive = false;
  }
}
