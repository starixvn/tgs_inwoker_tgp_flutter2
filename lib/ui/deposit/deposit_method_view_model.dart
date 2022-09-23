import 'package:api/api.dart';
import 'package:api/entity/bank_type.dart';
import 'package:api/entity/payment.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';
import 'dart:io';

class DepositMethodViewModel extends BaseViewModel {
  final depositRepo = BankRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();
  final bankRepo = BankRepository.getSingleton();
  final userRepo = UserRepository.getSingleton();
  final Map<BankType, List<Payment>>? depositMethodList;

  DepositMethodViewModel(this.depositMethodList);

  @override
  List<BaseRepository> get repoList => [];
  var getManualDepositIdApiState,
      getDepositOrderApiState,
      getLeepayOrderApiState,
      primePayDepositOrderApiState,
      applePayDepositOrderApiState,
      getUmPayDepositOrderApiState,
      getExchangeRateApiState,
      maticPayDepositOrderApiState,
      help2PayDepositOrderApiState,
      getHelp2PayHtmlTextApiState,
      skyPayDepositOrderApiState,
      uploadDepositImageApiState,
      zeroNineNinePayDepositOrderApiState,
      malakiPayDepositOrderApiState,
      depositOrderApiState;
  List<Payment>? paymentList;
  var depositOrder, orderNo, exchangeRate;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get config => contentRepo.featuresConfig;

  get bankCardList => bankRepo.bankCardList;

  get userProfile => userRepo.userProfile;

  filterMethod(BankType bankType) async {
    paymentList = depositMethodList![bankType];
    notifyListeners();
  }

  getManualDepositId(
      BankType bankType,
      String account,
      String amount,
      String? paymentId,
      String? promotionId,
      File? imageFile,
      String? name,
      String? note) async {
    setLoading();
    getManualDepositIdApiState = await depositRepo.getManualDepositId(
        account, amount, paymentId, promotionId, name, bankType.getJson, note);
    if (getManualDepositIdApiState.isSuccess) {
      orderNo = getManualDepositIdApiState.result;
      if (config.deposit_DualPage ?? false)
        getManualDepositOrder(orderNo);
      else
        uploadDepositImage(imageFile!, orderNo);
    }
    setLoading(false);
    return getManualDepositIdApiState;
  }

  getManualDepositOrder(String id) async {
    setLoading();
    getDepositOrderApiState = await depositRepo.getManualDepositOrder(id);
    if (getDepositOrderApiState.isSuccess) {
      depositOrder = getDepositOrderApiState.result;
    }
    setLoading(false);
    return getDepositOrderApiState;
  }

  leePayDepositOrder(
      String amount, String? paymentId, String? promotionId) async {
    setLoading();
    getLeepayOrderApiState =
        await depositRepo.leePayDepositOrder(amount, paymentId, promotionId);
    setLoading(false);
    return getLeepayOrderApiState;
  }

  primePayDepositOrder(
      String amount, String? paymentId, String? promotionId) async {
    setLoading();
    primePayDepositOrderApiState =
        await depositRepo.primePayDepositOrder(amount, paymentId, promotionId);
    setLoading(false);
    return primePayDepositOrderApiState;
  }

  applePayDepositOrder(String amount, String? paymentId, String? promotionId,
      String transName) async {
    setLoading();
    applePayDepositOrderApiState = await depositRepo.applePayDepositOrder(
        amount, paymentId, promotionId, transName);
    setLoading(false);
    return applePayDepositOrderApiState;
  }

  umPayDepositOrder(String amount, String? paymentId, String? promotionId,
      bool isCrypto) async {
    setLoading();
    if (isCrypto)
      getUmPayDepositOrderApiState = await depositRepo.umPayCryptoDepositOrder(
          amount, paymentId, promotionId);
    else
      getUmPayDepositOrderApiState = await depositRepo.umPayBankDepositOrder(
          amount, paymentId, promotionId);
    setLoading(false);
    return getUmPayDepositOrderApiState;
  }

  getExchangeRate(String? paymentId, bool isUmPay) async {
    setLoading();
    if (!isUmPay)
      getExchangeRateApiState =
          await depositRepo.getLeePayExchangeRate(paymentId);
    else
      getExchangeRateApiState =
          await depositRepo.getUmPayExchangeRate(paymentId);
    if (getExchangeRateApiState.isSuccess) {
      print(getExchangeRateApiState.result);
      if (!isUmPay)
        exchangeRate =
            getExchangeRateApiState.result.buyPrice.replaceAll(',', '.');
      else {
        exchangeRate = getExchangeRateApiState.result;
      }
    }
    setLoading(false);
    return getExchangeRateApiState;
  }

  maticPayDepositOrder(
      String amount, String? paymentId, String? promotionId) async {
    setLoading();
    maticPayDepositOrderApiState =
        await depositRepo.maticPayDepositOrder(amount, paymentId, promotionId);
    setLoading(false);
    return maticPayDepositOrderApiState;
  }

  help2PayDepositOrder(
      String amount, String? paymentId, String? promotionId) async {
    setLoading();
    help2PayDepositOrderApiState =
        await depositRepo.help2PayDepositOrder(amount, paymentId, promotionId);
    setLoading(false);
    return help2PayDepositOrderApiState;
  }

  getHelp2PayHtmlText(String url) async {
    setLoading();
    getHelp2PayHtmlTextApiState =
        await depositRepo.getHelp2PayHtmlText(url.substring(1));
    setLoading(false);
    return getHelp2PayHtmlTextApiState;
  }

  skyPayDepositOrder(
      String amount, String? paymentId, String? promotionId) async {
    setLoading();
    skyPayDepositOrderApiState =
        await depositRepo.skyPayDepositOrder(amount, paymentId, promotionId);
    setLoading(false);
    return skyPayDepositOrderApiState;
  }

  zeroNineNinePayDepositOrder(
      String amount, String? paymentId, String? promotionId) async {
    setLoading();
    zeroNineNinePayDepositOrderApiState = await depositRepo
        .zeroNineNinePayDepositOrder(amount, paymentId, promotionId);
    setLoading(false);
    return zeroNineNinePayDepositOrderApiState;
  }

  malakiPayDepositOrder(String amount, String? paymentId, String? promotionId,
      String? type) async {
    setLoading();
    malakiPayDepositOrderApiState = await depositRepo.malakiPayDepositOrder(
        amount, paymentId, promotionId, type);
    setLoading(false);
    return malakiPayDepositOrderApiState;
  }

  performDepositOrder(String amount, String? paymentId, String? promotionId,
      String? type, String? paymentcode) async {
    setLoading();
    depositOrderApiState = await depositRepo.performDeposit(
        amount, paymentId, promotionId, type, paymentcode);
    setLoading(false);
    return depositOrderApiState;
  }

  uploadDepositImage(File imageFile, String id) async {
    setLoading();
    uploadDepositImageApiState =
        await depositRepo.uploadDepositImage(imageFile, id);
    if (uploadDepositImageApiState.isSuccess) {}
    setLoading(false);
    return uploadDepositImageApiState;
  }
}
