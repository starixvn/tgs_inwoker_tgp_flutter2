import 'dart:math';

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
  var getBankCardListApiState,
      withdrawApiState,
      getTurnoverAmountApiState,
      getWithdrawalInfoListApiState;
  var turnover;
  List<WithdrawalInfo>? withdrawList;
  List<BankCard>? bankCardList;

  get wallet => userRepo.wallet;

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get config => contentRepo.featuresConfig;

  getBankCardList() async {
    setLoading();
    getBankCardListApiState = await bankRepo.getBankCardList();
    if (getBankCardListApiState.isSuccess) {
      bankCardList = getBankCardListApiState.result;
      _getTransferLimit();
    }
    setLoading(false);
    return getBankCardListApiState;
  }

  withdraw(
      int amount, String bankInfoId, String payPassword, String? note) async {
    setLoading();
    var status = await bankRepo.withdraw(amount, bankInfoId, payPassword, note);
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

  _getTransferLimit() async {
    await getWithdrawalInfoList();
    bankCardList!.forEach((bankCard) {
      List<double> minList = [], maxList = [];
      withdrawList!.forEach((withdraw) {
        if (withdraw.channelId == bankCard.paymentChannelId) {
          bankCard.transferLimit = withdraw.transferLimit;
          minList.add(withdraw.transferLimit?.from ?? 0);
          maxList.add(withdraw.transferLimit?.to ?? 0);
          bankCard.transferLimit?.from = minList.reduce(min);
          bankCard.transferLimit?.to = maxList.reduce(max);
          bankCard.fees = withdraw.fees ?? 0;
        }
      });
    });
  }
}
