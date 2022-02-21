import 'dart:io';

import 'package:api/api.dart';
import 'package:api/entity/bank_type.dart';
import 'package:api/entity/payment.dart';
import 'package:api/entity/promotion.dart';
import 'package:collection/collection.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class DepositViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final depositRepo = BankRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [];
  var getPaymentApiState, uploadDepositImageApiState, getPlayerPromotionListApiState;
  Map<String, Map<BankType, List<Payment>>>? paymentCodeList;
  List<Payment>? paymentList;
  var manualDepositOrder;
  List<Promotion>? promotionList;
  List<Map<String, String>> displayPromotionList = [
    /*{"name": "promotion_picker_hint", "id": "-1"}*/
  ];
  var rows = 20;

  get wallet => userRepo.wallet;

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get config => contentRepo.featuresConfig;

  getPayment() async {
    setLoading();
    getPaymentApiState = await depositRepo.getPayment();
    if (getPaymentApiState.isSuccess) {
      List<Payment> list = getPaymentApiState.result;
      //list.sort((a, b) => a.order.compareTo(b.order));
      paymentCodeList = groupBy(list, (Payment obj) => obj.paymentCode)
          .map((key, value) => MapEntry(key!, groupBy(value, (obj) => obj.bankType!)));
    }
    setLoading(false);
    return getPaymentApiState;
  }

  uploadDepositImage(File imageFile, String id) async {
    setLoading();
    uploadDepositImageApiState = await depositRepo.uploadDepositImage(imageFile, id);
    if (uploadDepositImageApiState.isSuccess) {}
    setLoading(false);
    return uploadDepositImageApiState;
  }

  getPlayerPromotionList(int page) async {
    setLoading();
    getPlayerPromotionListApiState = await contentRepo.getPromotionList(page, rows, false, false, userProfile == null);
    if (getPlayerPromotionListApiState.isSuccess) {
      List<Promotion> list = getPlayerPromotionListApiState.result.items;
      list.forEach((value) {
        if (value.promotionType == "FirstDeposit" ||
            value.promotionType == "DailySecondDeposit" ||
            value.promotionType == "DailyFirstDeposit")
          displayPromotionList.add({
            "name": ((value.localization?.name?.isNotEmpty ?? false) ? value.localization?.name : value.name) ?? "",
            "id": value.id ?? ""
          });
      });
      setLoading(false);
      return getPlayerPromotionListApiState;
    }
  }
}
