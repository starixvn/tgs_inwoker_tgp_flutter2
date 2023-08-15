import 'dart:ui';
import 'package:api/entity/station_letter.dart';
import 'package:api/entity/vip.dart';
import 'package:api/extension/format.dart';
import 'package:api/network/event_result.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/memo/memo_dialog.dart';
import 'package:tgp_flutter2/ui/memo/reply_dialog.dart';
import 'package:tgp_flutter2/ui/vip/vipT14.dart';
import 'package:tgp_flutter2/ui/vip/vip_view_model.dart';

import '../../custom/custom_text_form_field.dart';
import '../report/account_report_view.dart';
import 'memo_item.dart';
import 'memo_view_model.dart';

class Inbox extends StatefulWidget {
  final MemoViewModel vm;

  Inbox({required this.vm});

  @override
  _InboxState createState() => _InboxState();
}

class _InboxState extends BaseState<Inbox> {
  @override
  void initState() {
    widget.vm.getStationLetterList();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          decoration:
              EnvironmentConfig.template_version == 14 ? BoxDecoration() : BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.auto)),
          padding: EdgeInsets.all(15.auto),
          margin: EnvironmentConfig.template_version == 14 ? EdgeInsets.zero : EdgeInsets.all(10.auto),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Text(
                        getTranslatedText("memo_subject"),
                        style: TextStyle(color: _getTextColor(), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 0,
                    child: Container(
                      child: Text(
                        getTranslatedText("memo_date"),
                        style: TextStyle(color: _getTextColor(), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: context.screenHeight * 0.72,
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: ClampingScrollPhysics(),
                  children: List.generate((widget.vm.stationLetterList?.length ?? 0), (index) {
                    StationLetter? letter = widget.vm.stationLetterList?[index];
                    return InkWell(
                      onTap: () {
                        if (!(letter?.haveRead ?? true)) widget.vm.readStationLetter(letter?.id ?? "");
                        widget.vm.getStationLetterDetails(letter?.id ?? "").then((_) {
                          print("111");
                          _showDialog(widget.vm.stationLetterList![index]);
                        });
                      },
                      child: MemoItem(
                        title: letter?.subject ?? "",
                        date: Format().reversedDateFormat(letter?.sentOn ?? ""),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getTextColor() => EnvironmentConfig.template_version == 14 ? Colors.white : Colors.black;

  _showDialog(StationLetter letter) {
    showDialog(
      context: context,
      builder: (BuildContext context) => MemoDialog(
        title: letter.subject,
        sender: letter.sender,
        sentOn: letter.sentOn,
        content: letter.content,
        onReplyClick: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => ReplyDialog(
              title: letter.subject,
              onSentClick: (String content) async {
                widget.vm.replyStationLetter(letter.id! ,content);
              },
            ),
          );
        },
      ),
    );
  }
}
