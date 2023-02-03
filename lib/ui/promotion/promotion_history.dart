import 'package:api/entity/campaign_details.dart';
import 'package:api/entity/roulette_history_record.dart';
import 'package:api/entity/roulette_prize.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:api/extension/format.dart';

class PromotionHistory extends StatefulWidget {
  final List<RouletteHistoryRecord>? historyList;
  final RoulettePrize? prize;

  PromotionHistory({
    required this.historyList,
    required this.prize,
  });

  @override
  _PromotionHistoryState createState() => _PromotionHistoryState();
}

class _PromotionHistoryState extends BaseState<PromotionHistory> {
  Widget build(BuildContext context) {
    return Container(
        child: ListView(
          padding: EdgeInsets.all(8.auto),
          children: [
            Row(
              children: [
                Expanded(
                    flex: 4,
                    child: Text(
                      getTranslatedText("winning_id"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.auto,
                      ),
                    )),
                SizedBox(width: 5.auto),
                Expanded(
                    flex: 2,
                    child: Text(
                      getTranslatedText("date_time"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.auto,
                      ),
                    )),
                SizedBox(width: 5.auto),
                Expanded(
                    flex: 2,
                    child: Text(
                      getTranslatedText("winning_content"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.auto,
                      ),
                    )),
              ],
            ),
            widget.historyList == null
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: widget.historyList!.length,
                    itemBuilder: (context, index) {
                      return _buildHistoryItem(widget.historyList![index]);
                    }),
          ],
        ),

    );
  }

  _buildHistoryItem(RouletteHistoryRecord item) => Container(
    margin: EdgeInsets.only(top: 5.auto),
    child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(item.id ?? "", style: TextStyle(fontSize: 10.auto)),
            ),
            SizedBox(width: 5.auto),
            Expanded(
                flex: 2,
                child: Text((Format().dateTimeFormat2(item.createdOn)), style: TextStyle(fontSize: 10.auto))),
            SizedBox(width: 5.auto),
            Expanded(
              flex: 2,
              child:
                  Text(widget.prize?.rouletteItems?[item.itemIndex ?? 0].title ?? "", style: TextStyle(fontSize: 10.auto)),
            ),
          ],
        ),
  );
}
