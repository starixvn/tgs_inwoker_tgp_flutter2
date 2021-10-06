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

  get balance => userRepo.wallet.main;

  get brandLogoUrl => contentRepo.brandLogo.mobileUrl;

  bool isNotLogin = false, isExpired = false;
  var getBasicInfoApiState, getAnnouncementApiState, getApiErrorLocalizationApiState;
  Announcement announcement;
  double gameBalance = 0.0, totalBalance;

  resumeIfNeed() async {
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
      print("Authorization: " + prefs.getString("auth_token"));
    } else
      isNotLogin = true;
    setLoading(false);
    notifyListeners();
  }

  markIsNotLogin() {
    isNotLogin = false;
  }

  getAnnouncement() async {
    setLoading();
    getAnnouncementApiState = await contentRepo.getAnnouncement();
    if (getAnnouncementApiState.isSuccess) {
      announcement = getAnnouncementApiState.result.first;
    }
    setLoading(false);
    return getAnnouncementApiState;
  }

  getApiError() async {
    await userRepo.getApiErrorLocalization();
  }

  _computeTotalBalance() async {
    if (contentRepo.gameProviderList == null) contentRepo.getGameProviderList();
    var gameList = contentRepo.gameProviderList.where((element) => element.transferWallet == true);

    var task = <Future>[];
    gameList.forEach((game) {
      task.add(_getGameWalletBalance(game));
    });
    await Future.wait(task);
    totalBalance = balance + gameBalance;
    notifyListeners();
  }

  _getGameWalletBalance(GameProvider game) async {
    var state = await walletRepo.getGameWallet(game.code);
    if (state.isSuccess) {
      gameBalance += state.result.balance;
    }
    notifyListeners();
  }
}
