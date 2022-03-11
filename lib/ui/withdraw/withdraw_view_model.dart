import 'package:api/api.dart';
import 'package:api/entity/bank_card.dart';
import 'package:api/entity/payment.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class WithdrawViewModel extends BaseViewModel {
  final bankRepo = BankRepository.getSingleton();
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [];
  var getBankCardListApiState, withdrawApiState, getTurnoverAmountApiState, getPaymentApiState;
  var bankCardList, turnover;
  List<Payment>? paymentList;

  get wallet => userRepo.wallet;

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get config => contentRepo.featuresConfig;

  getBankCardList() async {
    setLoading();
    getBankCardListApiState = await bankRepo.getBankCardList();
    if (getBankCardListApiState.isSuccess) {
      bankCardList = getBankCardListApiState.result;
      await getPayment();
      paymentList!.forEach((payment) {
        bankCardList!.forEach((bankCard) {
          if(payment.channelId == bankCard.paymentChannelId)
            bankCard.transferLimit = payment.transferLimit;
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

  getPayment() async {
    setLoading();
    getPaymentApiState = await bankRepo.getPayment();
    if (getPaymentApiState.isSuccess) {
      paymentList = getPaymentApiState.result;
    }
    setLoading(false);
    return getPaymentApiState;
  }
}
