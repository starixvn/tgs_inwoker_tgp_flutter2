import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tgp_flutter2/custom/custom_picker.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:api/entity/status.dart';
import 'package:api/entity/transaction_cell_item_type.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/tab_button.dart';
import 'package:tgp_flutter2/custom/right_tool_tip_shape.dart';
import 'package:tgp_flutter2/custom/left_tool_tip_shape.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/transaction/transaction_cell_item.dart';
import 'package:tgp_flutter2/ui/transaction/transaction_date_item.dart';
import 'package:tgp_flutter2/ui/transaction/transaction_filter_button_item.dart';
import 'package:tgp_flutter2/ui/transaction/transaction_header_item.dart';
import 'package:tgp_flutter2/ui/transaction/transaction_view_model.dart';

class TransactionSilverAppBar extends StatefulWidget {
  final List<String> transactionHeaderList;
  final int filterIndex;
  final int expandedHeight;
  final TransactionViewModel vm;
  final Function(bool, int) getTransaction;
  final Function(int) setIndex;
  final ScrollController scrollController;
  final RefreshController refreshController;
  final List list;
  final List displayItemList;

  TransactionSilverAppBar(
      {Key key,
      this.transactionHeaderList,
      this.filterIndex,
      this.expandedHeight,
      this.vm,
      this.getTransaction,
      this.setIndex,
      this.scrollController,
      this.refreshController,
      this.list,
      this.displayItemList})
      : super(key: key);

  @override
  TransactionSilverAppBarState createState() => TransactionSilverAppBarState();
}

class TransactionSilverAppBarState extends BaseState<TransactionSilverAppBar> {
  var tab = [
    {"id": "0", "text": "未完成"},
    {"id": "1", "text": "已完成"}
  ];

  List dropDownList = [
    {"id": "0", "text": "全部"},
    {"id": "1", "text": "存款"},
    {"id": "2", "text": "提款"}
  ];
  var currentTabIndex = 0;

  Widget build(BuildContext context) {
    return Container(
      height: context.screenHeight,
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
                  ? buildProgressDialog()
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
                              Container(
                                padding: EdgeInsets.only(left: 10.auto, right: 10.auto),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      child: PopupMenuButton(
                                        child: _buildTypePopUpButton(),
                                        color: Colors.white,
                                        shape: LeftTooltipShape(),
                                        offset: Offset(-10, 20),
                                        padding: EdgeInsets.all(10),
                                        itemBuilder: (context) => List.generate(dropDownList.length, (index) {
                                          var _index = int.parse(dropDownList[index]["id"]);
                                          return PopupMenuItem<int>(
                                            value: _index,
                                            height: 35.auto,
                                            child: _buildPopUpMenuItem(context, index),
                                          );
                                        }),
                                        onSelected: (int index) {
                                          widget.getTransaction(false, null);
                                        },
                                      ),
                                    ),
                                    InkWell(
                                        onTap: () {},
                                        child: TabButton(
                                          text: tab[0]["text"],
                                          index: int.parse(tab[0]['id']),
                                          currentTabIndex: currentTabIndex,
                                          width: context.screenWidth / 4,
                                          height: 32.auto,
                                        )),
                                    InkWell(
                                        onTap: () {},
                                        child: TabButton(
                                          text: tab[1]["text"],
                                          index: int.parse(tab[1]['id']),
                                          currentTabIndex: currentTabIndex,
                                          width: context.screenWidth / 4,
                                          height: 32.auto,
                                        )),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                          bottom: PreferredSize(
                            preferredSize: Size.zero,
                            child: Center(
                              child: TransactionHeaderItem(
                                headerList: widget.transactionHeaderList,
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

  _buildTypePopUpButton() => Container(
        width: context.screenWidth / 4,
        height: 32.auto,
        padding: EdgeInsets.symmetric(horizontal: 10.auto),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 8,
              child: AutoSizeText(
                "选择类别",
                style: TextStyle(
                  color: CustomColor.theme_button_color,
                ),
                maxFontSize: 12,
                minFontSize: 8,
                maxLines: 1,
              ),
            ),
            Expanded(
              flex: 2,
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 18.0,
              ),
            )
          ],
        )
      );

  _buildPopUpMenuItem(BuildContext context, int index) {
    return Container(
      width: 50.auto,
      child: Column(
        children: [
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 1,
                child: SvgPicture.asset(
                  "images/transaction/check_box.svg",
                  height: 20.auto,
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(left: 10.auto),
                  child: Text(
                    dropDownList[index]["text"],
                    style: TextStyle(fontSize: 10.auto),
                    textAlign: TextAlign.start,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  _buildTransactionItem() => SliverPadding(
        padding: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 5.auto),
        sliver: SliverList(
          delegate: SliverChildListDelegate(
            widget.list?.length == 0
                ? List.generate(
                    1,
                    (index) => Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(left: 10.auto, right: 10.auto),
                          height: 94.auto,
                          color: Colors.white,
                          child: Text(
                            getTranslatedText("no_record"),
                            textAlign: TextAlign.center,
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
