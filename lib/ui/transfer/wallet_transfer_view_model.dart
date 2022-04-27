import 'package:api/api.dart';
import 'package:api/entity/wallet.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class WalletTransferViewModel extends BaseViewModel {
  final contentRepo = ContentRepository.getSingleton();
  final walletRepo = WalletRepository.getSingleton();
  final userRepo = UserRepository.getSingleton();

  List<Wallet> walletList = List.empty();

  WalletTransferViewModel() {
    walletList = contentRepo.gameProviderList!
        .where((element) => element.transferWallet == true)
        .map((e) => Wallet(e.code, e.name))
        .toList()
      ..insert(0, Wallet("-1", "main_wallet", isMainWallet: true));
  }

  get userMainWalletBalance =>
      walletList.singleWhere((element) => element.isMainWallet).balance;

  get gameWalletList => walletList
      .where((element) => !element.isMainWallet && element.balance != null)
      .toList();

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get mainWallet => userRepo.wallet;

  @override
  List<BaseRepository> get repoList => [contentRepo];
  var transferAllToMainWalletApiState,
      transferWalletApiState,
      getWalletApiState,
      getAutoTransferApiState,
      setAutoTransferApiState,
      withdrawFromAllBrandState;
  bool isFetchingBalance = false, autoTransferValue = false;

  transferWallet(String? gpCode, int transferAmount, bool isFundOut) async {
    setLoading();
    transferWalletApiState =
        await walletRepo.fundTransfer(gpCode, transferAmount, isFundOut);
    if (transferWalletApiState.isSuccess) {
      getAllWallet();
    }
    setLoading(false);
  }

  _getGameWalletBalance(Wallet wallet) async {
    wallet.balance = null;
    if (wallet.isMainWallet) {
      await userRepo.getWalletBalance();
      wallet.balance = userRepo.wallet!.main;
    } else {
      var state = await walletRepo.getGameWallet(wallet.gpCode);
      if (state.isSuccess) {
        wallet.balance = state.result?.balance ?? 0.0;
      } else {
        wallet.balance = null;
        walletList.removeWhere((element) => element.gpCode == wallet.gpCode);
      }
    }
    notifyListeners();
  }

  getAllWallet() async {
    isFetchingBalance = true;
    notifyListeners();
    var task = <Future>[];
    walletList.forEach((wallet) {
      task.add(_getGameWalletBalance(wallet));
    });
    await Future.wait(task);
    isFetchingBalance = false;
    if (hasListeners) notifyListeners();
  }

  getAutoTransferValue() async {
    setLoading();
    getAutoTransferApiState = await userRepo.getAutoTransferValue();
    if (getAutoTransferApiState.isSuccess) {
      autoTransferValue = getAutoTransferApiState.result;
    }
    setLoading(false);
    return getAutoTransferApiState;
  }

  setAutoTransferValue() async {
    setLoading();
    setAutoTransferApiState = await userRepo.setAutoTransferValue();
    if (setAutoTransferApiState.isSuccess) {
      autoTransferValue = !autoTransferValue;
    }
    setLoading(false);
    return setAutoTransferApiState;
  }

  performWithdrawFromAllBrand() async {
    setLoading();
    withdrawFromAllBrandState = await walletRepo.withdrawAllFund();
    if (withdrawFromAllBrandState.isSuccess) {
      getAllWallet();
    }
    setLoading(false);

    return withdrawFromAllBrandState;
  }
}
