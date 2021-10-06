import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class WithdrawViewModel extends BaseViewModel {
  final bankRepo = BankRepository.getSingleton();
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [];
  var getBankCardListApiState, withdrawApiState, getTurnoverAmountApiState;
  var bankCardList, turnover;

  get wallet => userRepo.wallet;

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  getBankCardList() async {
    setLoading();
    getBankCardListApiState = await bankRepo.getBankCardList();
    if (getBankCardListApiState.isSuccess) {
      bankCardList = getBankCardListApiState.result;
    }
    setLoading(false);
    return getBankCardListApiState;
  }

  withdraw(int amount, String bankInfoId, String payPassword) async {
    setLoading();
    var status = await bankRepo.withdraw(amount, bankInfoId, payPassword);
    if (status.isSuccess) {
      withdrawApiState = await userRepo.getWalletBalance();
    } else
      withdrawApiState = status;
    setLoading(false);
    return withdrawApiState;
  }

  getTurnoverAmount() async {
    setLoading();
    getTurnoverAmountApiState = await bankRepo.getTurnoverAmount();
    if (getTurnoverAmountApiState.isSuccess) {
      turnover = getTurnoverAmountApiState.result;
    }
    setLoading(false);
    return getTurnoverAmountApiState;
  }
}
