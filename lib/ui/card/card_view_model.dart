import 'package:api/api.dart';
import 'package:api/entity/bank_card.dart';
import 'package:api/entity/bank_type.dart';
import 'package:api/entity/payment.dart';
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

  get userProfile => userRepo.userProfile;

  var getBankCardListApiState,
      getWithdrawalInfoListApiState,
      addBankCardApiState,
      getDepositInfoListApiState,
      deleteBankCardApiState;
  Map<BankType, List> bankTypeList = new Map<BankType, List>();

  List? withdrawalInfoList, depositInfoList;
  BankType? pBankType;
  WithdrawalInfo? pWithdrawalInfo;
  Payment? pDepositInfo;
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

  getDepositInfoList() async {
    setLoading();
    getDepositInfoListApiState = await bankRepo.getPayment();
    if (getDepositInfoListApiState.isSuccess) {
      List<Payment> list = getDepositInfoListApiState.result;

      bankTypeList = groupBy(list, (obj) => obj.bankType!);
    }
    setLoading(false);
    return getDepositInfoListApiState;
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

  onSelectedBankType(BankType? bankType, fromDeposit) async {
    await fromDeposit ? getDepositInfoList() : getWithdrawalInfoList();
    if (bankType == null && pBankType == null) {
      if (config.addCardHideCertainField ?? false)
        pBankType = BankType.BANK;
      else
        pBankType = bankTypeList.keys.first;
    } else
      pBankType = bankType;

    if (fromDeposit) {
      depositInfoList = (bankTypeList[pBankType])!;
    } else {
      withdrawalInfoList = (bankTypeList[pBankType])!;
    }

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

  onSelectedDepositInfo({Payment? depositInfo}) async {
    if (bankTypeList.isEmpty) await getDepositInfoList();
    if (depositInfo == null)
      pDepositInfo = depositInfoList!.first;
    else
      pDepositInfo = depositInfo;
    notifyListeners();
  }

  onSelectedBankName({String? bankName, fromDeposit}) async {
    await fromDeposit ? getDepositInfoList() : getWithdrawalInfoList();
    if (bankName == null)
      pBankName = bankNameList.first;
    else
      pBankName = bankName;
    notifyListeners();
  }

  addBankCard(
      {String? address,
      bankAccount,
      bankName,
      name,
      bankBranch,
      phone,
      realName,
      bool isIdrRegister = false}) async {
    setLoading();
    var state = await bankRepo.addBankCard(
      pWithdrawalInfo!.channelId,
      pBankType!,
      address: address,
      bankAccount: bankAccount,
      bankName: bankName,
      bankBranch: bankBranch,
      name: name,
      phone: phone,
      realName: realName,
      isRegister: isIdrRegister,
    );
    //get bank card list if navigate from profile
    if (state.isSuccess) {
      if (config?.navigateToAddCard ?? false) getBankCardList();
      if (config?.idrRegisterCustomFlow ?? false)
        addBankCardApiState = await userRepo.getBasicInfo();
      else
        addBankCardApiState = state;
    } else
      addBankCardApiState = state;
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
