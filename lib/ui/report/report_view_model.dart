import 'package:api/api.dart';
import 'package:api/entity/account_report.dart';
import 'package:api/entity/bet_report.dart';
import 'package:api/entity/promotion_report.dart';
import 'package:api/entity/status.dart';
import 'package:api/entity/transfer_report.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class ReportViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();
  final depositRepo = BankRepository.getSingleton();
  var getReportApiState,
      getGameProviderApiState,
      getAccountReportApiState,
      getWithdrawReportApiState,
      getTransferReportApiState,
      getDepositOrderApiState,
      getPromotionReportApiState;
  var page = 1, rows = 10;
  var pStartDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0, 0, 0),
      pEndDate = DateTime.now();
  List<BetReport>? betReportList;
  List<AccountReport>? accountReportList, withdrawReportList;
  List<TransferReport>? transferReportList;
  List<PromotionReport>? promotionReportList;
  var endRecord = false;
  var statusList = Status.values;
  var pStatus = Status.All;
  var paymentId;

  get gameProviderList => contentRepo.gameProviderList;

  get wallet => userRepo.wallet;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  @override
  List<BaseRepository> get repoList => [userRepo, contentRepo];

  getReport({bool isLoadMore = false}) async {
    setLoading();

    if (isLoadMore) {
      if (page * rows < getReportApiState.result.totalCount) {
        page++;
      } else
        return;
    } else {
      page = 1;
      getReportApiState = null;
      betReportList = null;
    }
    getReportApiState =
        await userRepo.getReport(pStartDate, pEndDate, page, rows /*, orderBy, isDesc, sortBy, showAll*/);

    List<BetReport> list = [];
    if (getReportApiState.isSuccess) {
      list = getReportApiState.result.items;
      if (betReportList == null) betReportList = [];

      betReportList!.addAll(list);
      endRecord = betReportList!.length >= getReportApiState.result.totalCount ? true : false;
      notifyListeners();
    }
    setLoading(false);
    return getReportApiState;
  }

  getAccountReport({bool isLoadMore = false, Status? status = Status.All}) async {
    setLoading();

    if (isLoadMore) {
      if (page * rows < getAccountReportApiState.result.totalCount) {
        page++;
      } else
        return;
    } else {
      page = 1;
      getAccountReportApiState = null;
      accountReportList = null;
    }

    if (status != null) pStatus = status;
    getAccountReportApiState = await userRepo.getAccountReport(pStartDate, pEndDate, page, rows, pStatus);

    List<AccountReport> list = [];
    if (getAccountReportApiState.isSuccess) {
      list = getAccountReportApiState.result.items;
      if (accountReportList == null) accountReportList = [];

      accountReportList!.addAll(list);
      endRecord = accountReportList!.length >= getAccountReportApiState.result.totalCount ? true : false;
      notifyListeners();
    }
    setLoading(false);
    return getAccountReportApiState;
  }

  getWithdrawReport({bool isLoadMore = false, Status? status = Status.All}) async {
    setLoading();

    if (isLoadMore) {
      if (page * rows < getWithdrawReportApiState.result.totalCount) {
        page++;
      } else
        return;
    } else {
      page = 1;
      getWithdrawReportApiState = null;
      withdrawReportList = null;
    }
    if (status != null) pStatus = status;
    getWithdrawReportApiState = await userRepo.getWithdrawReport(pStartDate, pEndDate, page, rows, pStatus);

    List<AccountReport> list = [];
    if (getWithdrawReportApiState.isSuccess) {
      list = getWithdrawReportApiState.result.items;
      if (withdrawReportList == null) withdrawReportList = [];

      withdrawReportList!.addAll(list);
      endRecord = withdrawReportList!.length >= getWithdrawReportApiState.result.totalCount ? true : false;
      notifyListeners();
    }
    setLoading(false);
    return getWithdrawReportApiState;
  }

  getTransferReport({bool isLoadMore = false}) async {
    setLoading();

    if (isLoadMore) {
      if (page * rows < getTransferReportApiState.result.totalCount) {
        page++;
      } else
        return;
    } else {
      page = 1;
      getTransferReportApiState = null;
      transferReportList = null;
    }
    getTransferReportApiState = await userRepo.getTransferReport(pStartDate, pEndDate, page, rows);

    List<TransferReport> list = [];
    if (getTransferReportApiState.isSuccess) {
      list = getTransferReportApiState.result.items;
      if (transferReportList == null) transferReportList = [];

      transferReportList!.addAll(list);
      endRecord = transferReportList!.length >= getTransferReportApiState.result.totalCount ? true : false;
      notifyListeners();
    }
    setLoading(false);
    return getTransferReportApiState;
  }

  setDate({DateTime? startDate,  DateTime? endDate}) {
    if (startDate != null) pStartDate = startDate;
    if (endDate != null) {
      if (endDate == pStartDate)
        pEndDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 59, 59);
      else
        pEndDate = endDate;
    }
    notifyListeners();
  }

  getManualDepositOrder(String id) async {
    setLoading();
    getDepositOrderApiState = await depositRepo.getManualDepositOrder(id);
    if (getDepositOrderApiState.isSuccess) {
      paymentId = id;
    }
    setLoading(false);
    return getDepositOrderApiState;
  }


  getPromotionReport({bool isLoadMore = false}) async {
    setLoading();

    if (isLoadMore) {
      if (page * rows < getPromotionReportApiState.result.totalCount) {
        page++;
      } else
        return;
    } else {
      page = 1;
      getPromotionReportApiState = null;
      promotionReportList = null;
    }
    getPromotionReportApiState = await userRepo.getPromotionReport(pStartDate, pEndDate, page, rows);

    List<PromotionReport> list = [];
    if (getPromotionReportApiState.isSuccess) {
      list = getPromotionReportApiState.result.items;
      if (promotionReportList == null) promotionReportList = [];

      promotionReportList!.addAll(list);
      endRecord =
      ((promotionReportList?.length ??0) >= (getPromotionReportApiState.result.totalCount ?? 0)) ? true : false;
      notifyListeners();
    }
    setLoading(false);
    return getPromotionReportApiState;
  }
}
