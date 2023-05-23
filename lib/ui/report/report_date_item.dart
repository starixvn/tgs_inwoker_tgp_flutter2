import 'package:flutter/material.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class ReportDateItem extends StatefulWidget {
  final DateTime date;
  final String title;
  final ValueChanged<DateTime> onDateChanged;

  const ReportDateItem({required this.date, required this.title, required this.onDateChanged});

  @override
  _ReportDateItemState createState() => _ReportDateItemState();
}

class _ReportDateItemState extends BaseState<ReportDateItem> {
  var date;

  Widget build(BuildContext context) {
    date = widget.date;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 2,
            height: 20.auto,
            color: CustomColor.theme_button_color,
            margin: EdgeInsets.symmetric(horizontal: 10.auto),
          ),
          Text(
            widget.title,
            style: TextStyle(fontSize: 10.auto, color: CustomColor.theme_text_black_white_color),
          )
        ]),
        InkWell(
          onTap: () => _showDatePicker(context),
          child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5,
              child: Container(
                width: context.screenWidth / 2 - 45.auto,
                padding: EdgeInsets.all(10.auto),
                child: Text(
                  Format().dateFormat(date),
                  style: TextStyle(
                    color: EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode ? CustomColor.theme_bg_color : CustomColor.theme_button_color,
                    fontSize: 13.auto,
                  ),
                  textAlign: TextAlign.center,
                ),
              )),
        )
      ],
    );
  }

  _showDatePicker(BuildContext context) async {
    var currentDate = DateTime.now();
    final DateTime? dateTime = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: currentDate);

    if (dateTime == null) {
      setState(() {
        widget.onDateChanged(date);
      });
    } else {
      widget.onDateChanged(dateTime);
      setState(() {
        date = dateTime;
      });
    }
  }
}
