import 'package:api/entity/home_banner.dart';
import 'package:api/entity/main_dialog_content.dart';
import 'package:api/entity/marquees.dart';
import 'package:api/entity/promotion.dart';
import 'package:api/entity/wallet.dart';
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

  get bankCardList => bankRepo.bankCardList;

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
      getRouletteApiState,
      getRoulettePlayCountState,
      // new addition
      getTodayDepositRouletteResultApiState,
      getDepositRouletteApiState;
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
  bool isDepositRoulettePlayed = false;
  var campaign, depositcampaign;
  Promotion? roulettePromo;
  var depositRoulettePromo;
  int? rotatedResultId, depositRotatedResultId;
  List<Wallet> walletList = List.empty();
  var userMainWalletBalance, gameWalletList;

  var rouletteCount = [];

  markIsNotLogin() {
    isNotLogin = false;
  }

  getAnnouncement() async {
    setLoading();
    getAnnouncementApiState = await contentRepo.getAnnouncement();
    if (getAnnouncementApiState.isSuccess) {
      List<Marquees> _list = getAnnouncementApiState.result.marquees;
      marqueeDialog =
          ((getAnnouncementApiState.result.main) as List<MainDialogContent>)
              .firstOrNull;
      if (_list.isEmpty)
        announcement = "";
      else {
        _list.asMap().forEach((index, element) {
          if (index == 0)
            announcement = _getAnnouncementContent(element);
          else
            announcement =
                announcement! + " " + _getAnnouncementContent(element);
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
    if (contentRepo.gameProviderList == null)
      await contentRepo.getGameProviderList();
    walletList = contentRepo.gameProvider2List!
        .where((element) => element.transferWallet == true)
        .map((e) => Wallet(e.code, e.name, e.gameType))
        .toList()
      ..insert(0, Wallet("-1", "main_wallet", null, isMainWallet: true));
    var task = <Future>[];
    print(walletList);
    walletList.forEach((wallet) {
      task.add(_getGameWalletBalance(wallet));
    });
    await Future.wait(task);
    gameWalletList = walletList
        .where((element) => !element.isMainWallet && element.balance != null)
        .toList();
    totalBalance = (balance ?? 0.0) + (gameBalance ?? 0.0);
    wallet?.totalBalance = totalBalance;
    notifyListeners();
  }

  _getGameWalletBalance(Wallet wallet) async {
    wallet.balance = null;
    if (wallet.isMainWallet) {
      await userRepo.getWalletBalance();
      wallet.balance = userRepo.wallet?.main;
    } else {
      var state = await walletRepo.getGameWallet(wallet.gpCode);
      if (state.isSuccess) {
        wallet.balance = state.result?.balance ?? 0.0;
        gameBalance = (gameBalance ?? 0.0) + state.result!.balance!;
      } else {
        wallet.balance = null;
        walletList.removeWhere((element) => element.gpCode == wallet.gpCode);
      }
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
    // await userRepo.getWalletBalance();
    await _computeTotalBalance();
    setLoading(false);
    notifyListeners();
  }

  logout() async {
    setLoading();
    logoutApiState = await userRepo.logout();
    isRoulettePlayed = false;
    isDepositRoulettePlayed = false;
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

  getBankCardList() async {
    setLoading();
    getBankCardListApiState = await bankRepo.getBankCardList();
    setLoading(false);
    return getBankCardListApiState;
  }

  getUserDetails() async {
    //if (userProfile != null) {
    await _getTotalBalance();
  }

  getPromotionList() async {
    setLoading();
    getPromotionListApiState = await contentRepo.getPromotionList();

    if (getPromotionListApiState.isSuccess) {
      promotionList = getPromotionListApiState.result;
      roulettePromo = promotionList?.firstWhereOrNull(
        (element) => element.promotionType == "Roulette",
      );

      // depositRoulettePromo = promotionList?.firstWhereOrNull(
      //   (element) => element.promotionType == "DepositAccumulateRoulette",
      // );

      depositRoulettePromo = promotionList
          ?.where(
              (element) => element.promotionType == "DepositAccumulateRoulette")
          .toList();

      campaign = roulettePromo?.campaignDetails ?? [];
      depositcampaign = depositRoulettePromo?.campaignDetails ?? [];
    } else {
      promotionList = [];
    }
    setLoading(false);
    return getPromotionListApiState;
  }

  getRouletteTodayResult() async {
    setLoading();
    getTodayRouletteResultApiState =
        await contentRepo.getRouletteTodayResult(roulettePromo?.id ?? "");
    if (getTodayRouletteResultApiState.isSuccess) {
      isRoulettePlayed = getTodayRouletteResultApiState.result.id != null;
    }
    setLoading(false);
    return getTodayRouletteResultApiState;
  }

  getRouletteResult() async {
    setLoading();
    getRouletteApiState =
        await contentRepo.getRouletteResult(roulettePromo?.id ?? "");
    if (getRouletteApiState.isSuccess) {
      getRouletteTodayResult();
      rotatedResultId = getRouletteApiState.result.itemIndex;
    }
    setLoading(false);
    return getRouletteApiState;
  }

  getDepositRouletteTodayResult() async {
    setLoading();
    getTodayDepositRouletteResultApiState = await contentRepo
        .getDepositRouletteResult(depositRoulettePromo?.id ?? "");
    if (getTodayDepositRouletteResultApiState.isSuccess) {
      isDepositRoulettePlayed =
          getTodayDepositRouletteResultApiState.result.id != null;
    }
    setLoading(false);
    return getTodayRouletteResultApiState;
  }

  getDepositRouletteResult() async {
    setLoading();
    getDepositRouletteApiState = await contentRepo
        .getDepositRouletteResult(depositRoulettePromo?.id ?? "");
    if (getDepositRouletteApiState.isSuccess) {
      getDepositRouletteTodayResult();
      depositRotatedResultId = getDepositRouletteApiState.result.itemIndex;
    }
    setLoading(false);
    return getDepositRouletteApiState;
  }

  getRoulettePlayCount() async {
    setLoading();
    getRoulettePlayCountState = await contentRepo.getRouletteCount();
    if (getRoulettePlayCountState.isSuccess) {
      rouletteCount = getRoulettePlayCountState.result;
    }
    setLoading(false);
    return getRoulettePlayCountState;
  }
}
