import 'package:api/api.dart';
import 'package:api/entity/bank_card.dart';
import 'package:api/entity/payment.dart';
import 'package:api/entity/withdrawal_info.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class WithdrawViewModel extends BaseViewModel {
  final bankRepo = BankRepository.getSingleton();
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [];
  var getBankCardListApiState, withdrawApiState, getTurnoverAmountApiState, getWithdrawalInfoListApiState;
  var bankCardList, turnover;
  List<WithdrawalInfo>? withdrawList;

  get wallet => userRepo.wallet;

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get config => contentRepo.featuresConfig;

  getBankCardList() async {
    setLoading();
    getBankCardListApiState = await bankRepo.getBankCardList();
    if (getBankCardListApiState.isSuccess) {
      bankCardList = getBankCardListApiState.result;
      await getWithdrawalInfoList();
      withdrawList!.forEach((withdraw) {
        bankCardList!.forEach((bankCard) {
          if(withdraw.channelId == bankCard.paymentChannelId)
            bankCard.transferLimit = withdraw.transferLimit;
        });
      });
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
      turnover = (getTurnoverAmountApiState.result).toDouble();
    }
    setLoading(false);
    return getTurnoverAmountApiState;
  }

  getWithdrawalInfoList() async {
    setLoading();
    getWithdrawalInfoListApiState = await bankRepo.getWithdrawalInfoList();
    if (getWithdrawalInfoListApiState.isSuccess) {
      withdrawList = getWithdrawalInfoListApiState.result;
    }
    setLoading(false);
    return getWithdrawalInfoListApiState;
  }
}
