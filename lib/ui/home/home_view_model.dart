import 'package:api/entity/home_banner.dart';
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

  @override
  List<BaseRepository> get repoList => [userRepo, contentRepo];

  get userProfile => userRepo.userProfile;

  get balance => userRepo.wallet?.main;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  bool isNotLogin = false, isExpired = false;
  var getBasicInfoApiState, getAnnouncementApiState, getApiErrorLocalizationApiState, getBannerApiState;
  String? announcement;
  double? gameBalance;
  double? totalBalance;
  List<HomeBanner>? bannerList;
  Announcement? firstAnnouncement;

  /*resumeIfNeed() async {
    setLoading();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    if (token != null) {
      print(token);
      await userRepo.getBasicInfo();
      await userRepo.getWalletBalance();
      await _computeTotalBalance();
      if (userProfile == null) isExpired = true;
      print("Token: " + token);
      print("Authorization: " + prefs.getString("auth_token")!);
    } else
      isNotLogin = true;
    setLoading(false);
    notifyListeners();
  }*/

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
    notifyListeners();
  }

  _getGameWalletBalance(GameProvider game) async {
    var state = await walletRepo.getGameWallet(game.code);
    if (state.isSuccess) {
      gameBalance = (gameBalance ?? 0.0) + state.result!.balance;
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

  getTotalBalance() async {
    setLoading();
    await userRepo.getWalletBalance();
    await _computeTotalBalance();
    setLoading(false);
    notifyListeners();
  }
}
