import 'package:api/extension/screen_apis.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/globalUtil/GlobalValueUtil.dart';

import '../../../base_state.dart';
import '../../../src/custom_color.dart';

class TableHead extends StatefulWidget {
  final ScrollController scrollController;

  TableHead({
    required this.scrollController,
  });

  @override
  TableHeadState createState() => TableHeadState();
}

class TableHeadState extends BaseState<TableHead> {
  @override
  Widget build(BuildContext context) {
    List<String> list = [
      getTranslatedText("levelKeepAccumulateBetAmount"),
      getTranslatedText("levelKeepAccumulateDeposit"),
      getTranslatedText("levelUpAccumulateBetAmount"),
      getTranslatedText("levelUpAccumulateDeposit"),
      getTranslatedText("birthdayBenefit"),
      getTranslatedText("promotionBenefit"),
      getTranslatedText("quarterlyBenefit"),
      getTranslatedText("cardGameRebate"),
      getTranslatedText("lotteryRebate"),
      getTranslatedText("slotRebate"),
      getTranslatedText("sportsRebate"),
      getTranslatedText("virtualSportsRebate"),
    ];

    double fontsize = GlobalValueUtil.calculateFontSizeForLongestString(list, 13.auto, 100);

    return SizedBox(
      height: 70,
      child: Row(
        children: [
          // MultiplicationTableCell(
          //   value: "1",
          // ),
          Container(
            height: 45,
            width: 120,
            decoration: BoxDecoration(
              color: CustomColor.theme_bar_gradient_1,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Text(
              getTranslatedText("vip_level"),
              style: TextStyle(color: Colors.white, fontSize: fontsize),
            ),
          ),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(vertical: 13),
              children: List.generate(list.length, (index) {
                return Container(
                  height: 45,
                  width: 120,
                  decoration: index == list.length - 1
                      ? BoxDecoration(
                          color: CustomColor.theme_bar_gradient_1,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        )
                      : BoxDecoration( color: CustomColor.theme_bar_gradient_1),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Text(
                    getTranslatedText(list[index]),
                    style: TextStyle(color: Colors.white, fontSize: fontsize),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
