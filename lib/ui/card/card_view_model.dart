import 'package:api/api.dart';
import 'package:api/entity/bank_type.dart';
import 'package:api/entity/withdrawal_info.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';
import 'package:collection/collection.dart';

class CardViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();
  final bankRepo = BankRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [
        userRepo,
        contentRepo,
      ];

  get wallet => userRepo.wallet;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  var getBankCardListApiState, getWithdrawalInfoListApiState, addBankCardApiState, deleteBankCardApiState;
  Map<BankType, List<WithdrawalInfo>> bankTypeList = new Map<BankType, List<WithdrawalInfo>>();
  List? bankCardList, withdrawalInfoList;
  BankType pBankType = BankType.THIRD_PARTY;
  WithdrawalInfo? pWithdrawalInfo;

  getBankCardList() async {
    setLoading();
    getBankCardListApiState = await bankRepo.getBankCardList();
    if (getBankCardListApiState.isSuccess) {
      bankCardList = getBankCardListApiState.result;
    }
    setLoading(false);
    return getBankCardListApiState;
  }

  getWithdrawalInfoList() async {
    setLoading();
    getWithdrawalInfoListApiState = await bankRepo.getWithdrawalInfoList();
    if (getWithdrawalInfoListApiState.isSuccess) {
      List<WithdrawalInfo> list = getWithdrawalInfoListApiState.result;
      bankTypeList = groupBy(list, (obj) => obj.bankType);
    }
    setLoading(false);
    return getWithdrawalInfoListApiState;
  }

  onSelectedBankType(BankType bankType) async {
    if (bankTypeList.isEmpty) await getWithdrawalInfoList();
    pBankType = bankType;
    withdrawalInfoList = (bankTypeList[bankType])!;
    notifyListeners();
  }

  onSelectedWithdrawalInfo({WithdrawalInfo? withdrawalInfo}) async {
    if (bankTypeList.isEmpty) await getWithdrawalInfoList();
    if (withdrawalInfo == null)
      pWithdrawalInfo = withdrawalInfoList!.first;
    else
      pWithdrawalInfo = withdrawalInfo;
    notifyListeners();
  }

  addBankCard({
    String? address,
    String? bankAccount,
    String? bankName,
    String? name,
    String? bankBranch,
    String? phone,
    String? realName,
  }) async {
    setLoading();
    addBankCardApiState = await bankRepo.addBankCard(
      pWithdrawalInfo!.channelId,
      pBankType,
      address: address,
      bankAccount: bankAccount,
      bankName: bankName,
      bankBranch: bankBranch,
      name: name,
      phone: phone,
      realName: realName,
    );
    setLoading(false);
    return addBankCardApiState;
  }

  deleteBankCard(String bankInfoId) async {
    setLoading();
    deleteBankCardApiState = await bankRepo.deleteBankCard(bankInfoId);
    getBankCardList(); //incase failed, had to get back the deleted card
    setLoading(false);
    return deleteBankCardApiState;
  }
}
