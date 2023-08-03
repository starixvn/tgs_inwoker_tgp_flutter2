import 'package:api/entity/vip.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import '../vip_view_model.dart';

class TableBody extends StatefulWidget {
  final ScrollController scrollController;
  final VipViewModel vm;

  TableBody({
    required this.scrollController,
    required this.vm,
  });

  @override
  _TableBodyState createState() => _TableBodyState();
}

class _TableBodyState extends State<TableBody> {
  late LinkedScrollControllerGroup _controllers;
  late ScrollController _firstColumnController;
  late ScrollController _restColumnsController;
  List list = [
    "levelKeepAccumulateBetAmount",
    "levelKeepAccumulateDeposit",
    "levelUpAccumulateBetAmount",
    "levelUpAccumulateDeposit",
    "birthdayBenefit",
    "promotionBenefit",
    "quarterlyBenefit",
    "cardGameRebate",
    "lotteryRebate",
    "slotRebate",
    "sportsRebate",
    "virtualSportsRebate",
  ];

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _firstColumnController = _controllers.addAndGet();
    _restColumnsController = _controllers.addAndGet();
  }

  @override
  void dispose() {
    _firstColumnController.dispose();
    _restColumnsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: ListView(
            controller: _firstColumnController,
            physics: ClampingScrollPhysics(),
            children: List.generate(9, (index) {
              return Container(
                width: 120,
                height: 120,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    SvgPicture.asset(
                      "images/vip/T14/vip0${index + 1}.svg",
                      width: 65,
                      height: 65,
                    ),
                    Text(
                      "VIP${index + 1}",
                      style: TextStyle(color: Colors.white, fontSize: 14.auto),
                    )
                  ],
                ),
              );
            }),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              width: list.length * 120,
              child: ListView(
                controller: _restColumnsController,
                physics: const ClampingScrollPhysics(),
                children: List.generate(9, (y) {
                  return Row(
                    children: List.generate(list.length, (x) {
                      return Container(
                          width: 120,
                          height: 120,
                          alignment: Alignment.center,
                        child: Text(
                          "${_getContentList(y)[x]}",
                          style: TextStyle(color: Colors.white, fontSize: 14.auto),
                        ),
                      );
                        //MultiplicationTableCell(value: "4444");
                    }),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<String> _getContentList(int index) {
    Vip? vip = widget.vm.vipMap[index+1];


    return [
      _getAmount(vip?.levelKeepAccumulateBetAmount),
      _getAmount(vip?.levelKeepAccumulateDeposit),
      _getAmount(vip?.levelUpAccumulateBetAmount),
      _getAmount(vip?.levelUpAccumulateDeposit),
      _getAmount(vip?.birthBenefit),
      _getAmount(vip?.promotionBenefit),
      _getAmount(vip?.quarterlyBenefit),
      _getRebateAmount(vip?.cardGameRebate),
      _getRebateAmount(vip?.liveDealerRebate),
      _getRebateAmount(vip?.lotteryRebate),
      _getRebateAmount(vip?.slotRebate),
      _getRebateAmount(vip?.sportsRebate),
      _getRebateAmount(vip?.virtualSportsRebate)
    ];
  }

  String _getAmount(double? amount) => Format().currencyFormat((amount ?? 0).toInt());

  String _getRebateAmount(double? amount) => "${((amount ?? 0).toInt().toString())}";
}
