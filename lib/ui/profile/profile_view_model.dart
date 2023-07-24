import 'package:api/entity/game_provider.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';
import 'package:api/api.dart';

import '../../globalUtil/GlobalValueUtil.dart';

class ProfileViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();
  final walletRepo = WalletRepository.getSingleton();
  final bankRepo = BankRepository.getSingleton();

  var logoutApiState, getWalletBalanceApiState, getAffiliateStatusState;
  double? gameBalance;
  double? totalBalance;
  bool haveAffiliate = false;

  @override
  List<BaseRepository> get repoList => [userRepo];

  get userProfile => userRepo.userProfile;

  get wallet => userRepo.wallet;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get config => contentRepo.featuresConfig;

  get bankCardList => bankRepo.bankCardList;

  String get announcement => GlobalValueUtil.removeMultiLine(GlobalValueUtil.parseHtmlString(contentRepo.announcementInStr));

  logout() async {
    setLoading();
    logoutApiState = await userRepo.logout();
    setLoading(false);
    return logoutApiState;
  }

  computeTotalBalance() async {
    if (contentRepo.gameProviderList == null) contentRepo.getGameProviderList();
    var gameList = contentRepo.gameProviderList?.where((element) => element.transferWallet == true) ?? [];

    var task = <Future>[];
    gameList.forEach((game) {
      task.add(_getGameWalletBalance(game));
    });
    await Future.wait(task);
    totalBalance = (wallet?.main ?? 0.0) + (gameBalance ?? 0.0);
    wallet?.totalBalance = totalBalance;
    GlobalValueUtil.updateTotalBalance(totalBalance ?? 0.0);
    notifyListeners();
  }

  _getGameWalletBalance(GameProvider game) async {
    var state = await walletRepo.getGameWallet(game.code);
    if (state.isSuccess) {
      gameBalance = (gameBalance ?? 0.0) + state.result!.balance!;
    }
    notifyListeners();
  }

  getAffiliateStatus() async {
    setLoading();
    getAffiliateStatusState = await contentRepo.getAffiliateStatus();
    if (getAffiliateStatusState.isSuccess) {
      haveAffiliate = getAffiliateStatusState.result.switchOn;
    }
    setLoading(false);
    notifyListeners();
    return getAffiliateStatusState;
  }
}
