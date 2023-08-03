import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class ReportFilterButtonItem extends StatefulWidget {
  final int index;
  final ValueChanged<int> onTextChanged;

  const ReportFilterButtonItem({required this.index, required this.onTextChanged});

  @override
  _ReportFilterButtonItemState createState() => _ReportFilterButtonItemState();
}

class _ReportFilterButtonItemState extends BaseState<ReportFilterButtonItem> {
  var currentFilterIndex = 0;
  var filterTabList = [
    {"id": "0", "text": "today"},
    {"id": "1", "text": "one_week"},
    {"id": "2", "text": "one_month"},
  ];

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.auto, horizontal: 20.auto),
      child: EnvironmentConfig.template_version == 14
          ? Container(
              width: context.screenWidth,
              child: Wrap(
                spacing: 10.auto, // Adjust the spacing between tabs
                runSpacing: 10.auto, // Adjust the spacing between rows of tabs
                alignment: WrapAlignment.start,
                children: List.generate(filterTabList.length, (index) {
                  return Container(
                    child: _buildFilterButtonT14(index, (filterTabList[index]["text"])!),
                  );
                }),
              ),
            )
          : Row(
              children: List.generate(filterTabList.length, (index) {
                return Container(
                  child: _buildFilterButton(index, (filterTabList[index]["text"])!),
                );
              }),
            ),
    );
  }

  _buildFilterButton(int index, String text) => Expanded(
        flex: 1,
        child: InkWell(
          onTap: () {
            widget.onTextChanged(index);
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Text(
            getTranslatedText(text),
            style: TextStyle(
                fontSize: widget.index == index ? 15.auto : 12.auto,
                color: widget.index == index ? CustomColor.theme_button_color : CustomColor.theme_text_black_white_color),
            textAlign: TextAlign.center,
          ),
        ),
      );

  _buildFilterButtonT14(int index, String text) => InkWell(
        onTap: () {
          widget.onTextChanged(index);
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.auto, horizontal: 15.auto),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: index == widget.index ? CustomColor.tab_selected_color : CustomColor.tab_unselected_color,
          ),
          child: Text(
            getTranslatedText(text),
            style: TextStyle(fontSize: 14.auto, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
}
