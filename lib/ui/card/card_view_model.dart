import 'package:api/api.dart';
import 'package:api/entity/bank_card.dart';
import 'package:api/entity/bank_type.dart';
import 'package:api/entity/withdrawal_info.dart';
import 'package:flutter/material.dart';
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

  get config => contentRepo.featuresConfig;

  get bankCardList => bankRepo.bankCardList;

  var getBankCardListApiState, getWithdrawalInfoListApiState, addBankCardApiState, deleteBankCardApiState;
  Map<BankType, List<WithdrawalInfo>> bankTypeList = new Map<BankType, List<WithdrawalInfo>>();
  List? withdrawalInfoList;
  BankType? pBankType;
  WithdrawalInfo? pWithdrawalInfo;
  String? pBankName;
  List<String> bankNameList = [
    "bank_KKR",
    "bank_SCB",
    "bank_KTB",
    "bank_BBL",
    "bank_GSB",
    "bank_TTB",
    "bank_KrungSri",
    "bank_BAAC",
    "bank_UOB",
    "bank_CIMB",
    "bank_KKP",
    "bank_GH",
  ];

  getBankCardList() async {
    setLoading();
    getBankCardListApiState = await bankRepo.getBankCardList();
    setLoading(false);
    return getBankCardListApiState;
  }

  getWithdrawalInfoList() async {
    setLoading();
    getWithdrawalInfoListApiState = await bankRepo.getWithdrawalInfoList();
    if (getWithdrawalInfoListApiState.isSuccess) {
      List<WithdrawalInfo> list = getWithdrawalInfoListApiState.result;
      //if (!config.addCardDisplayFPS) (list).removeWhere((e) => e.bankType == BankType.FPS);
      bankTypeList = groupBy(list, (obj) => obj.bankType!);
    }
    setLoading(false);
    return getWithdrawalInfoListApiState;
  }

  onSelectedBankType(BankType? bankType) async {
    if (bankTypeList.isEmpty) await getWithdrawalInfoList();
    if (bankType == null && pBankType == null)
      pBankType = bankTypeList.keys.first;
    else
      pBankType = bankType;
    withdrawalInfoList = (bankTypeList[pBankType])!;
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

  onSelectedBankName({String? bankName}) async {
    if (bankTypeList.isEmpty) await getWithdrawalInfoList();
    if (bankName == null)
      pBankName = bankNameList.first;
    else
      pBankName = bankName;
    notifyListeners();
  }

  addBankCard({String? address, bankAccount, bankName, name, bankBranch, phone, realName}) async {
    setLoading();
    addBankCardApiState = await bankRepo.addBankCard(pWithdrawalInfo!.channelId, pBankType!,
        address: address,
        bankAccount: bankAccount,
        bankName: bankName,
        bankBranch: bankBranch,
        name: name,
        phone: phone,
        realName: realName);
    //get bank card list if navigate from profile
    if (addBankCardApiState.isSuccess && config?.navigateToAddCard) getBankCardList();
    setLoading(false);
    return addBankCardApiState;
  }

  deleteBankCard(String? bankInfoId) async {
    setLoading();
    deleteBankCardApiState = await bankRepo.deleteBankCard(bankInfoId);
    getBankCardList(); //incase failed, had to get back the deleted card
    setLoading(false);
    return deleteBankCardApiState;
  }
}
