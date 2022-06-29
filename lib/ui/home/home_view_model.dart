import 'package:api/entity/home_banner.dart';
import 'package:api/entity/main_dialog_content.dart';
import 'package:api/entity/marquees.dart';
import 'package:api/entity/promotion.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';
import 'package:api/entity/game_provider.dart';
import 'package:api/api.dart';
import 'package:api/extension/list_extension.dart';
import 'package:api/entity/campaign_details.dart';

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
      getPromotionListApiState,
      getTodayRouletteResultApiState,
      getRouletteApiState;
  String? announcement;
  double? gameBalance;
  double? totalBalance;
  List<HomeBanner>? bannerList;
  MainDialogContent? marqueeDialog;
  String? phone;
  int? page;
  int rows = 10;
  bool endRecord = false;
  List<Promotion>? promotionList;
  bool isRoulettePlayed = false;
  List<CampaignDetails>? campaign;
  Promotion? roulettePromo;
  int? rotatedResultId;

  markIsNotLogin() {
    isNotLogin = false;
  }

  getAnnouncement() async {
    setLoading();
    getAnnouncementApiState = await contentRepo.getAnnouncement();
    if (getAnnouncementApiState.isSuccess) {
      List<Marquees> _list = getAnnouncementApiState.result.marquees;
      marqueeDialog = ((getAnnouncementApiState.result.main) as List<MainDialogContent>).firstOrNull;
      if (_list.isEmpty)
        announcement = "";
      else {
        _list.asMap().forEach((index, element) {
          if (index == 0)
            announcement = _getAnnouncementContent(element);
          else
            announcement = announcement! + " " + _getAnnouncementContent(element);
        });
      }
    }
    setLoading(false);
    return getAnnouncementApiState;
  }

  _getAnnouncementContent(Marquees text) {
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
    isRoulettePlayed = false;
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

  getPromotionList() async {
    setLoading();
    getPromotionListApiState = await contentRepo.getPromotionList();
    if (getPromotionListApiState.isSuccess) {
      promotionList = getPromotionListApiState.result;
      roulettePromo = promotionList?.singleWhere((element) => element.promotionType == "Roulette");
      campaign = roulettePromo?.campaignDetails?.items ?? [];
    } else
      promotionList = [];
    setLoading(false);
    return getPromotionListApiState;
  }

  getRouletteTodayResult() async {
    setLoading();
    getTodayRouletteResultApiState = await contentRepo.getRouletteTodayResult(roulettePromo?.id ?? "");
    if (getTodayRouletteResultApiState.isSuccess) {
      isRoulettePlayed = getTodayRouletteResultApiState.result.id != null;

    }
    setLoading(false);
    return getTodayRouletteResultApiState;
  }

  getRouletteResult() async {
    setLoading();
    getRouletteApiState = await contentRepo.getRouletteResult(roulettePromo?.id ?? "");
    if (getRouletteApiState.isSuccess) {
      getRouletteTodayResult();
      rotatedResultId = getRouletteApiState.result.itemIndex;
    }
    setLoading(false);
    return getRouletteApiState;
  }
}
