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
import 'package:tgp_flutter2/environment_config.dart';

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
      deleteFavouriteGameApiState,
      getBetConstructHtmlApiState;
  List<Game>? _gameList, filteredGameList;
  Map<String, List<Game>> gameListMap = new Map<String, List<Game>>();
  int mCategory = 0;
  String? mPlatform, mSearchQuery = "";
  GameType? mGameType;
  String? url, lobbyUrl;
  List<GameProvider2>? platformList;
  List<List<GameProvider2>>? gameProviderList;
  List<GameType> gameTypeList = [];
  List<GameType> _gameTypeList = [
    GameType.Sportsbook,
    GameType.ESports,
    GameType.LiveDealerLobby,
    GameType.CardGameLobby,
    GameType.Fishing,
    GameType.LotteryLobby,
    GameType.Slot,
    GameType.EGame,
  ];
  List<GameType> nonExistGameTypeList = [];
  var _gameListT3 = [
    GameType.Sportsbook,
    GameType.LiveDealerLobby,
    GameType.ESports,
    GameType.Slot,
    GameType.Fishing,
    GameType.LotteryLobby,
    GameType.EGame,
    GameType.CardGameLobby,
  ];
  var _pbGamelist = [
    GameType.Slot,
    GameType.LiveDealerLobby,
    GameType.Sportsbook,
    GameType.ESports,
    GameType.EGame,
    GameType.Fishing,
    GameType.CardGameLobby,
    GameType.LotteryLobby,
  ];
  var balanceGameTypeList = [
    GameType.ESports,
    GameType.Sportsbook,
    GameType.LiveDealerLobby,
    GameType.CardGameLobby,
    GameType.LotteryLobby,
    GameType.Slot,
    GameType.EGame,
    GameType.Fishing
  ];
  var _pb3Gamelist = [
    GameType.Slot,
    GameType.LiveDealerLobby,
    GameType.Sportsbook,
    GameType.EGame,
    GameType.Fishing,
    GameType.ESports,
  ];

  List<GameType>? gameListT3;

  var JILITF_slot = [
    "Super_Ace",
    "Golden_Empire",
    "Fortune_Gems",
    "Money_Coming",
    "Boxing_King",
    "Crazy777",
    "Mega_Ace",
    "Charge_Buffalo",
    "Ali_Baba",
    "Bonus_Bingo",
  ];

  var RTTF_slot = [
    "Masquerade",
    "10001_Nights",
    "Aztec_Spins",
    "777_Strike",
    "Jewel_Scarabs",
    "Zeus_Lightning_Power_Reels",
    "Cash_Ultimate",
    "Thor's_Vengeance",
    "Golden_Leprechaun_Megaways",
    "Dragon's_Luck_Deluxe",
  ];

  var JDB_slot = [
    "TrumpCard",
    "MayaGoldCrazy",
    "TreasureBowl",
    "Blossom_of_Wealth",
    "Kong",
    "SuperNiubiDeluxe",
    "Mjolnir",
    "Moneybags_Man_2",
    "OpenSesameII",
    "Fortune_Treasure",
  ];

  var JILITF_fish = [
    "Mega_Fishing",
    "Jackpot_Fishing",
    "Dinosaur_Tycoon",
    "Happy_Fishing",
    "Bombing_Fishing",
    "All-star_Fishing",
    "Boom_Legend",
    "Royal_Fishing",
    "Dragon_Fortune",
  ];

  var JDB_fish = [
    "Cai Shen_Fishing",
    "Fishing_YiLuFa",
    "Dragon_Fishing II",
    "Dragon_Master",
    "Dragon_Fishing",
    "Five_Dragons_Fishing",
    "Fishing_Disco",
  ];
  List<Game>? expandRecommendList;

  var _context;
  Map<GameType, List<GameProvider2>>? gameTypeMap = new Map<GameType, List<GameProvider2>>();
  bool isGamePlatformInactive = false;

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get recommendGameList => _getRecommendGameList();

  get config => contentRepo.featuresConfig;

  Map<String, List<Game>> jackpotRecommendGameList = new Map<String, List<Game>>();

  getGameProviderList({bool isRefresh = false}) async {
    if (contentRepo.gameProviderList == null || isRefresh) {
      setLoading();
      getGameProviderListApiState = await contentRepo.getGameProviderList();
    }
    if (contentRepo.gameProvider2List == null) return;
    List<GameProvider2> list = contentRepo.gameProvider2List!;
    gameTypeList = (() {
      if (EnvironmentConfig.brandName == "PB")
        return _pbGamelist;
      else if (EnvironmentConfig.brandName == "PB2" || EnvironmentConfig.brandName == "BUNNY")
        //to remove card game and lottery
        return _pbGamelist
          ..remove(GameType.CardGameLobby)
          ..remove(GameType.LotteryLobby);
      else if (EnvironmentConfig.brandName == "PB3")
        return _pb3Gamelist;
      else
        return _gameTypeList;
    }());
    //(EnvironmentConfig.brandName == "PB" || EnvironmentConfig.brandName == "PB2") ? _pbGamelist : _gameTypeList;
    gameProviderList = gameTypeList
        .map((type) => list
            .where((element) => (type == GameType.Sportsbook) //combine VirtualSports to VirtualSports
                ? (element.gameType == type || (element.gameType == GameType.VirtualSports && element.code == "PPTF"))
                : element.gameType == type)
            .toList())
        .toList();
    gameTypeMap = (groupBy(list, (obj) => obj.gameType!))
      ..forEach((key, value) {
        if (key == GameType.Sportsbook) {
          //combine VirtualSports to VirtualSports
          value.addAll(list.where((element) => (element.gameType == GameType.VirtualSports && element.code == "PPTF")));
        }
      });
    removeNonExistGameType();
    gameListT3 = _gameListT3;

    setLoading(false);
    return getGameProviderListApiState;
  }

  removeNonExistGameType() {
    //check which game type not exist in gameProviderList and remove it
    gameTypeList.forEach((element) {
      if (gameTypeMap?[element]?.isEmpty ?? true) {
        nonExistGameTypeList.add(element);
      }
    });
    nonExistGameTypeList.forEach((element) {
      //handle some showing empty game list, some will hide it
      if (EnvironmentConfig.template_version == 1) {
        gameTypeList.remove(element);
      }
      _gameListT3.remove(element);
    });
  }

  getGameList(String? gamePlatformCode, GameType? gameType, {bool isGettingRecommendList = false}) async {
    setLoading();
    var apiState = await contentRepo.getGameList(gamePlatformCode!, gameType!);
    if (apiState.isSuccess) {
      if (apiState.result!.isEmpty) {
        getGameApiState = apiState;
        if (!isGettingRecommendList) {
          await getPlatformList(gameType);
          isGamePlatformInactive = true;
          mPlatform = "ALL";
          await filter(gamePlatformCode: mPlatform!);
        }
      } else {
        gameListMap[gamePlatformCode] = apiState.result!;
        if (!isGettingRecommendList &&
            (gameType == GameType.Slot ||
                gameType == GameType.EGame ||
                gameType == GameType.Fishing ||
                gameType == GameType.VirtualSports))
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
    } else
      getGameUrlApiState = EventResult.maintenance();
    setLoading(false);
    return getGameUrlApiState;
  }

  getLobbyGameUrl(String gamePlatformCode, GameType gameType, String _lobbyUrl) async {
    setLoading();
    getLobbyGameUrlApiState = await contentRepo.getLobbyGameUrl(gamePlatformCode, gameType, _lobbyUrl);
    if (getLobbyGameUrlApiState.isSuccess) {
      url = getLobbyGameUrlApiState.result.url;
    } else
      getLobbyGameUrlApiState = EventResult.maintenance();
    setLoading(false);
    return getLobbyGameUrlApiState;
  }

  _getRecommendGameList() {
    if (_gameList != null)
      return _gameList!.where((element) => element.tag?.isRecommend == true).take(6).toList();
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
    if (gameType != null) mGameType = gameType;

    var platformGameList = await _filterPlatform();
    filteredGameList = _filterSearch(_filterCategory(platformGameList));
    print(filteredGameList);
    notifyListeners();
  }

  List<Game> _filterCategory(List<Game> gameList) {
    switch (mCategory) {
      case 0:
        //all game list
        return gameList;
      case 1:
        //new game list
        var list = gameList.where((element) => element.tag?.isNew == true).toList();
        return list;
      case 2:
        //hot game list
        var list = gameList.where((element) => element.tag?.isHot == true).toList();
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
      List<Game> _list = await _addGameList();
      return _list;
    } else {
      //if (gameListMap[mPlatform] == null) {
      return await getGameList(mPlatform!, mGameType!).then((apiState) {
        if (apiState.result?.isEmpty ?? true) {
          List<Game> list = [];
          return list;
        } else
          return gameListMap[mPlatform];
      });
    }
  }

  _addGameList() async {
    var task = <Future>[];
    platformList!.forEach((platform) {
      if (gameListMap[platform.code] == null) {
        task.add(getGameList(platform.code, mGameType));
      }
    });
    await Future.wait(task);
    return gameListMap.values.expand((element) => element).toList();
  }

  List<Game> _filterSearch(List<Game> gameList) {
    if (mSearchQuery?.isEmpty ?? true) {
      return gameList;
    } else {
      var list = gameList
          .where((element) => (element.name ?? "").toLowerCase().contains(mSearchQuery!.toLowerCase()))
          .toList();
      return list;
    }
  }

  getPlatformList(GameType gameType) {
    List<GameProvider2> list = gameProviderList!.expand((e) => e).toList();
    platformList = list.where((element) => element.gameType == gameType && element.status == 0).toList();
    notifyListeners();
  }

  _getFavoriteGame(GameType? gameType) async {
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

  getBetConstructHtml() async {
    setLoading();
    getBetConstructHtmlApiState = await contentRepo.getBetConstructHtml();
    if (getBetConstructHtmlApiState.isSuccess) {
      url = getBetConstructHtmlApiState.result;
    }
    setLoading(false);
    return getBetConstructHtmlApiState;
  }

  getJackpotRecommendList() async {
    var recommendList = [
      "JILITF",
      "RTTF",
      "JDB",
    ];
    var gameTypeList = [GameType.Slot, GameType.Fishing];
    expandRecommendList = [];
    gameTypeList.forEach((gametype) {
      recommendList.forEach((gpCode) async {
        jackpotRecommendGameList["${gpCode}_$gametype"] = await _addRecommendGameList(gpCode, gametype);
        (expandRecommendList ?? []).addAll(jackpotRecommendGameList["${gpCode}_$gametype"] ?? []);
        print(expandRecommendList);
      });
    });
    notifyListeners();
  }

  _addRecommendGameList(String gpCode, GameType type) async {
    List<Game> list = [];
    print("");
    await getGameList(gpCode, type, isGettingRecommendList: true);
    print(gameListMap[gpCode]);
    switch (gpCode) {
      case "JILITF":
        if (type == GameType.Slot) {
          JILITF_slot.forEach((name) {
            (gameListMap[gpCode] ?? []).forEach((element) {
              if (element.code == name) {
                list.add(element);
                print("got data");
              }
            });
          });
        } else {
          JILITF_fish.forEach((name) {
            (gameListMap[gpCode] ?? []).forEach((element) {
              if (element.code == name) {
                list.add(element);
                print("got data");
              }
            });
          });
        }
        break;
      case "RTTF":
        {
          RTTF_slot.forEach((name) {
            (gameListMap[gpCode] ?? []).forEach((element) {
              if (element.code == name) {
                list.add(element);
                print("got data");
              }
            });
          });
          break;
        }
      case "JDB":
        if (type == GameType.Slot) {
          JDB_slot.forEach((name) {
            (gameListMap[gpCode] ?? []).forEach((element) {
              if (element.code == name) {
                list.add(element);
                print("got data");
              }
            });
          });
        } else {
          JDB_fish.forEach((name) {
            (gameListMap[gpCode] ?? []).forEach((element) {
              if (element.code == name) {
                list.add(element);
                print("got data");
              }
            });
          });
        }
        break;
    }
    return list;
  }

  Game? randomGameData() {
    if ((expandRecommendList ?? []).isNotEmpty) {
      int result = Random().nextInt(expandRecommendList!.length);
      return expandRecommendList![result];
    } else {
      return null;
    }
  }

  clearFilteredGameList() {
    filteredGameList = null;
  }
}
