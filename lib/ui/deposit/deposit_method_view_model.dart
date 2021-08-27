import 'package:api/api.dart';
import 'package:api/entity/payment.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class DepositMethodViewModel extends BaseViewModel {
  final depositRepo = BankRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();
  final Map<String, List<Payment>> depositMethodList;

  DepositMethodViewModel(this.depositMethodList);

  @override
  List<BaseRepository> get repoList => [];
  var getManualDepositIdApiState,
      getDepositOrderApiState,
      getLeepayOrderApiState,
      primePayDepositOrderApiState,
      applePayDepositOrderApiState,
      getUmPayDepositOrderApiState,
      getExchangeRateApiState;
  List<Payment> paymentList;
  var depositOrder, orderNo, exchangeRate;

  filterMethod(String method) async {
    paymentList = depositMethodList[method];
    notifyListeners();
  }

  getManualDepositId(String account, String amount, String paymentId, String promotionId) async {
    setLoading();
    getManualDepositIdApiState = await depositRepo.getManualDepositId(account, amount, paymentId, promotionId);
    if (getManualDepositIdApiState.isSuccess) {
      orderNo = getManualDepositIdApiState.result;
      getManualDepositOrder(orderNo);
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

  leePayDepositOrder(String amount, String paymentId, String promotionId) async {
    setLoading();
    getLeepayOrderApiState = await depositRepo.leePayDepositOrder(amount, paymentId, promotionId);
    setLoading(false);
    return getLeepayOrderApiState;
  }

  primePayDepositOrder(String amount, String paymentId, String promotionId) async {
    setLoading();
    primePayDepositOrderApiState = await depositRepo.primePayDepositOrder(amount, paymentId, promotionId);
    setLoading(false);
    return primePayDepositOrderApiState;
  }

  applePayDepositOrder(String amount, String paymentId, String promotionId, String transName) async {
    setLoading();
    applePayDepositOrderApiState = await depositRepo.applePayDepositOrder(amount, paymentId, promotionId, transName);
    setLoading(false);
    return applePayDepositOrderApiState;
  }

  umPayDepositOrder(String amount, String paymentId, String promotionId, bool isCrypto) async {
    /*setLoading();
    if (isCrypto)
      getUmPayDepositOrderApiState = await depositRepo.umPayCryptoDepositOrder(amount, paymentId, promotionId);
    else
      getUmPayDepositOrderApiState = await depositRepo.umPayBankDepositOrder(amount, paymentId, promotionId);
    setLoading(false);
    return getUmPayDepositOrderApiState;*/
  }

  getExchangeRate(String paymentId, bool isUmPay) async {
    /*setLoading();
    if (!isUmPay)
      getExchangeRateApiState = await depositRepo.getLeePayExchangeRate(paymentId);
    else
      getExchangeRateApiState = await depositRepo.getUmPayExchangeRate(paymentId);
    if (getExchangeRateApiState.isSuccess) {
      if (!isUmPay)
        exchangeRate = getExchangeRateApiState.result.buyPrice;
      else
        exchangeRate = getExchangeRateApiState.result.rate.toString();
    }
    setLoading(false);
    return getExchangeRateApiState;*/
  }
}
