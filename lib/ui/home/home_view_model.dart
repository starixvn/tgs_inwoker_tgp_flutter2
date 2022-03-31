import 'package:api/entity/home_banner.dart';
import 'package:api/entity/promotion.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';
import 'package:api/entity/announcement.dart';
import 'package:api/entity/game.dart';
import 'package:api/entity/game_provider.dart';
import 'package:api/entity/game_type.dart';
import 'package:api/network/event_result.dart';
import 'package:api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();
  final walletRepo = WalletRepository.getSingleton();
  final bankRepo = BankRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [userRepo, contentRepo];

  get userProfile => userRepo.userProfile;

  get balance => userRepo.wallet?.main;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get config => contentRepo.featuresConfig;

  get wallet => userRepo.wallet;

  bool isNotLogin = false, isExpired = false;
  var getBasicInfoApiState,
      getAnnouncementApiState,
      getApiErrorLocalizationApiState,
      getBannerApiState,
      logoutApiState,
      getBrandCommunicationApiState,
      getBankCardListApiState,
      getPromotionListApiState;
  String? announcement;
  double? gameBalance;
  double? totalBalance;
  List<HomeBanner>? bannerList;
  Announcement? firstAnnouncement;
  String? phone;
  int? page;
  int rows = 10;
  bool endRecord = false;
  List<Promotion>? promotionList;

  markIsNotLogin() {
    isNotLogin = false;
  }

  getAnnouncement() async {
    setLoading();
    getAnnouncementApiState = await contentRepo.getAnnouncement();
    if (getAnnouncementApiState.isSuccess) {
      List<Announcement> _list = getAnnouncementApiState.result;
      if (_list.isEmpty)
        announcement = "";
      else {
        firstAnnouncement = _list.first;
        announcement = _getAnnouncementContent(_list.first);
        if (_list.length != 1) {
          for (var i = 1; i < _list.length; i++) {
            announcement = announcement! + " " + _getAnnouncementContent(_list[i]);
          }
        }
      }
    }
    setLoading(false);
    return getAnnouncementApiState;
  }

  _getAnnouncementContent(Announcement text) {
    if (text.localization?.content?.isNotEmpty ?? false)
      return text.localization!.content;
    else if (text.content?.isNotEmpty ?? false)
      return text.content;
    else
      return "";
  }

  getApiError() async {
    await userRepo.getApiErrorLocalization();
  }

  _computeTotalBalance() async {
    if (contentRepo.gameProviderList == null) contentRepo.getGameProviderList();
    var gameList = contentRepo.gameProviderList!.where((element) => element.transferWallet == true);

    var task = <Future>[];
    gameList.forEach((game) {
      task.add(_getGameWalletBalance(game));
    });
    await Future.wait(task);
    totalBalance = (balance ?? 0.0) + (gameBalance ?? 0.0);
    wallet?.totalBalance = totalBalance;
    notifyListeners();
  }

  _getGameWalletBalance(GameProvider game) async {
    var state = await walletRepo.getGameWallet(game.code);
    if (state.isSuccess) {
      gameBalance = (gameBalance ?? 0.0) + state.result!.balance!;
    }
    notifyListeners();
  }

  getBanner() async {
    setLoading();
    getBannerApiState = await contentRepo.getBanner();
    if (getBannerApiState.isSuccess) {
      bannerList = getBannerApiState.result;
    }
    setLoading(false);
    return getBannerApiState;
  }

  getUserInfo() async {
    setLoading();
    getBasicInfoApiState = await userRepo.getBasicInfo();
    setLoading(false);
    return getBasicInfoApiState;
  }

  _getTotalBalance() async {
    setLoading();
    await userRepo.getWalletBalance();
    await _computeTotalBalance();
    setLoading(false);
    notifyListeners();
  }

  logout() async {
    setLoading();
    logoutApiState = await userRepo.logout();
    setLoading(false);
    return logoutApiState;
  }

  getBrandCommunication() async {
    setLoading();
    getBrandCommunicationApiState = await userRepo.getBrandCommunication();
    if (getBrandCommunicationApiState.isSuccess) {
      if (getBrandCommunicationApiState.result.isNotEmpty ?? false)
        phone = getBrandCommunicationApiState.result?.first.phone;
    }
    setLoading(false);
    return getBrandCommunicationApiState;
  }

  _getBankCardList() async {
    setLoading();
    getBankCardListApiState = await bankRepo.getBankCardList();
    setLoading(false);
    return getBankCardListApiState;
  }

  getUserDetails() {
    //if (userProfile != null) {
    _getTotalBalance();
    _getBankCardList();
  }

  getPromotionList({isLoadMore = false}) async {
    setLoading();

    if (isLoadMore) {
      if (page! * rows < getPromotionListApiState.result.totalCount)
        page = page! + 1;
      else
        return;
    } else
      page = 1;

    //if (userProfile == null)
    getPromotionListApiState = await contentRepo.getPromotionList(page!, rows, true, true, userProfile == null);
    // else
    //   getPromotionListApiState = await contentRepo.getPlayerPromotionList(page, rows, true, true);
    List<Promotion> list = [];
    if (getPromotionListApiState.isSuccess) {
      list = getPromotionListApiState.result.items;
      if (promotionList == null) promotionList = [];
      if (list.isNotEmpty) promotionList!.addAll(list);
      endRecord = promotionList!.length >= getPromotionListApiState.result.totalCount ? true : false;
    } else
      promotionList = [];
    setLoading(false);
    return getPromotionListApiState;
  }
}
