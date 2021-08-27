

import 'package:api/api.dart';
import 'package:api/entity/account_transaction.dart';
import 'package:api/entity/bet_transaction.dart';
import 'package:api/entity/status.dart';
import 'package:api/entity/transfer_transaction.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class TransactionViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();
  final depositRepo = BankRepository.getSingleton();
  var getTransactionApiState, getGameProviderApiState, getAccountTransactionApiState, getWithdrawTransactionApiState, getTransferTransactionApiState, getDepositOrderApiState;
  var page = 1, rows = 10;
  var pStartDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0, 0, 0),
      pEndDate = DateTime.now();
  List<BetTransaction> betTransactionList;
  List<AccountTransaction> accountTransactionList, withdrawTransactionList;
  List<TransferTransaction> transferTransactionList;
  var endRecord = false;
  var statusList = Status.values;
  var pStatus = Status.All;
  var paymentId;

  get gameProviderList => contentRepo.gameProviderList;
  get wallet => userRepo.wallet;

  @override
  List<BaseRepository> get repoList => [userRepo, contentRepo];

  getTransaction({bool isLoadMore = false}) async {
    setLoading();

    if (isLoadMore) {
      if (page * rows < getTransactionApiState.result.totalCount) {
        page++;
      } else
        return;
    } else {
      page = 1;
      getTransactionApiState = null;
      betTransactionList = null;
    }
    getTransactionApiState =
        await userRepo.getTransaction(pStartDate, pEndDate, page, rows /*, orderBy, isDesc, sortBy, showAll*/);

    List<BetTransaction> list = [];
    if (getTransactionApiState.isSuccess) {
      list = getTransactionApiState.result.items;
      if (betTransactionList == null) betTransactionList = [];

      betTransactionList.addAll(list);
      endRecord = betTransactionList.length >= getTransactionApiState.result.totalCount ? true : false;
      notifyListeners();
    }
    setLoading(false);
    return getTransactionApiState;
  }

  getAccountTransaction({bool isLoadMore = false, Status status}) async {
    setLoading();

    if (isLoadMore) {
      if (page * rows < getAccountTransactionApiState.result.totalCount) {
        page++;
      } else
        return;
    } else {
      page = 1;
      getAccountTransactionApiState = null;
      accountTransactionList = null;
    }

    if (status != null) pStatus = status;
    getAccountTransactionApiState = await userRepo.getAccountTransaction(pStartDate, pEndDate, page, rows, pStatus);

    List<AccountTransaction> list = [];
    if (getAccountTransactionApiState.isSuccess) {
      list = getAccountTransactionApiState.result.items;
      if (accountTransactionList == null) accountTransactionList = [];

      accountTransactionList.addAll(list);
      endRecord = accountTransactionList.length >= getAccountTransactionApiState.result.totalCount ? true : false;
      notifyListeners();
    }
    setLoading(false);
    return getAccountTransactionApiState;
  }

  getWithdrawTransaction({bool isLoadMore = false, Status status}) async {
    setLoading();

    if (isLoadMore) {
      if (page * rows < getWithdrawTransactionApiState.result.totalCount) {
        page++;
      } else
        return;
    } else {
      page = 1;
      getWithdrawTransactionApiState = null;
      withdrawTransactionList = null;
    }
    if (status != null) pStatus = status;
    getWithdrawTransactionApiState = await userRepo.getWithdrawTransaction(pStartDate, pEndDate, page, rows, pStatus);

    List<AccountTransaction> list = [];
    if (getWithdrawTransactionApiState.isSuccess) {
      list = getWithdrawTransactionApiState.result.items;
      if (withdrawTransactionList == null) withdrawTransactionList = [];

      withdrawTransactionList.addAll(list);
      endRecord = withdrawTransactionList.length >= getWithdrawTransactionApiState.result.totalCount ? true : false;
      notifyListeners();
    }
    setLoading(false);
    return getWithdrawTransactionApiState;
  }

  getTransferTransaction({bool isLoadMore = false}) async {
    setLoading();

    if (isLoadMore) {
      if (page * rows < getTransferTransactionApiState.result.totalCount) {
        page++;
      } else
        return;
    } else {
      page = 1;
      getTransferTransactionApiState = null;
      transferTransactionList = null;
    }
    getTransferTransactionApiState = await userRepo.getTransferTransaction(pStartDate, pEndDate, page, rows);

    List<TransferTransaction> list = [];
    if (getTransferTransactionApiState.isSuccess) {
      list = getTransferTransactionApiState.result.items;
      if (transferTransactionList == null) transferTransactionList = [];

      transferTransactionList.addAll(list);
      endRecord = transferTransactionList.length >= getTransferTransactionApiState.result.totalCount ? true : false;
      notifyListeners();
    }
    setLoading(false);
    return getTransferTransactionApiState;
  }


  setDate({DateTime startDate, endDate}) {
    if (startDate != null) pStartDate = startDate;
    if (endDate != null) {
      if(endDate == pStartDate) pEndDate = DateTime(endDate.year, endDate.month, endDate.day,23,59,59,59,59);
      else pEndDate = endDate;
    }
      notifyListeners();
  }

  getManualDepositOrder(String id) async {
    setLoading();
    getDepositOrderApiState = await depositRepo.getManualDepositOrder(id);
    if (getDepositOrderApiState.isSuccess) {
      paymentId =id;
    }
    setLoading(false);
    return getDepositOrderApiState;
  }
}
