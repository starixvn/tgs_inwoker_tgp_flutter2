import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:api/entity/status.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/transaction/transaction_date_item.dart';
import 'package:tgp_flutter2/ui/transaction/transaction_filter_button_item.dart';
import 'package:tgp_flutter2/ui/transaction/transaction_header_item.dart';
import 'package:tgp_flutter2/ui/transaction/transaction_view_model.dart';

class BaseTransaction extends StatefulWidget {
  final List<String> transactionHeaderList;
  final Widget getPickerBox;
  final int filterIndex;
  final int expandedHeight;
  final TransactionViewModel vm;
  final Function(bool, Status) getTransaction;
  final Function(int) setIndex;
  final ScrollController scrollController;
  final RefreshController refreshController;
  final List list;
  final List displayItemList;
  final bool isUploadButton;

  BaseTransaction(
      {Key key,
      this.transactionHeaderList,
      this.getPickerBox,
      this.filterIndex,
      this.expandedHeight,
      this.vm,
      this.getTransaction,
      this.setIndex,
      this.scrollController,
      this.refreshController,
      this.list,
      this.displayItemList,
      this.isUploadButton})
      : super(key: key);

  @override
  BaseTransactionState createState() => BaseTransactionState();
}

class BaseTransactionState extends BaseState<BaseTransaction> {
  Widget build(BuildContext context) {
    return Container(
      height: context.screenHeight,
      color: CustomColor.theme_bg_color,
      child: ScrollConfiguration(
          behavior: MyBehavior(),
          child: SmartRefresher(
              controller: widget.refreshController,
              enablePullDown: true,
              onRefresh: () {
                widget.getTransaction(false, null);
                widget.refreshController.refreshCompleted();
              },
              child: widget.list == null
                  ? buildProgressDialog(widget.vm.brandLogoUrl)
                  : CustomScrollView(
                controller: widget.scrollController,
                slivers: [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    pinned: true,
                    floating: false,
                    expandedHeight: widget.expandedHeight.auto,
                    backgroundColor: CustomColor.theme_bg_color,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Column(children: [
                        _getCalendarItem(),
                        TransactionFilterButtonItem(
                          index: widget.filterIndex,
                          onTextChanged: (value) => _onDateFilter(value),
                        ),
                        widget.getPickerBox
                      ]),
                    ),
                    bottom: PreferredSize(
                      preferredSize: Size.zero,
                      child: Center(
                        child: TransactionHeaderItem(
                          headerList: widget.transactionHeaderList,
                          isUploadButton: widget.isUploadButton,
                        ),
                      ),
                    ),
                    toolbarHeight: 40.auto,
                    elevation: 0,
                  ),
                  _buildTransactionItem()
                ],
              ))),
    );
  }

  _buildTransactionItem() => SliverPadding(
    padding: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 5.auto),
    sliver: SliverList(
      delegate: SliverChildListDelegate(
        widget.list?.length == 0
            ? List.generate(
            1,
                (index) =>  Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 10.auto, right: 10.auto),
                  height: 150.auto,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.white
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10.auto),
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 75.auto,
                          height: 75.auto,
                          child: Image.asset("images/transaction/ic_no_record.png")),
                      Text(getTranslatedText("no_record"))
                    ],
                  ),
                ))
            : widget.displayItemList,
      ),
    ),
  );

  _getCalendarItem() => Container(
    padding: EdgeInsets.all(10.auto),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TransactionDateItem(
          date: widget.vm.pStartDate,
          title: getTranslatedText("start_time"),
          onDateChanged: (value) {
            _onCalendarClick(value, true);
          },
        ),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 20.auto),
          width: 5.auto,
          height: 1,
          color: CustomColor.grey,
        ),
        TransactionDateItem(
          date: widget.vm.pEndDate,
          title: getTranslatedText("end_time"),
          onDateChanged: (value) {
            _onCalendarClick(value, false);
          },
        ),
      ],
    ),
  );

  _onCalendarClick(DateTime date, bool isStartDate) {
    if (isStartDate) {
      widget.vm.setDate(startDate: date);
    } else {
      if (date.isBefore(widget.vm.pStartDate)) {
        CustomToast.show(getTranslatedText("transaction_after_start_date"));
        return;
      } else
        widget.vm.setDate(endDate: date);
    }
    _onDateFilter(-1);
  }

  _onDateFilter(int index) {
    var currentDate = DateTime.now();
    switch (index) {
      case 0: //today
        widget.vm.setDate(
            startDate: DateTime(currentDate.year, currentDate.month, currentDate.day, 0, 0, 0, 0, 0),
            endDate: currentDate);
        break;
      case 1: //week
        widget.vm.setDate(
            startDate: DateTime(currentDate.year, currentDate.month, currentDate.day - 7), endDate: currentDate);
        break;
      case 2: //month
        widget.vm.setDate(
            startDate: DateTime(currentDate.year, currentDate.month - 1, currentDate.day), endDate: currentDate);
        break;
      case -1: //click from calendar
        break;
      default:
        widget.vm.setDate();
        break;
    }
    widget.getTransaction(false, null);
    widget.setIndex(index);
  }
}
