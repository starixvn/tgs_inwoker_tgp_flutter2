import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:api/entity/message.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/message/message_dialog.dart';

import '../../environment_config.dart';
import '../../globalUtil/GlobalValueUtil.dart';

class MessageItem extends StatefulWidget {
  final Message message;
  final Function(String?) onReadMessage;

  MessageItem({
    required this.message,
    required this.onReadMessage,
  });

  @override
  _MessageItemState createState() => _MessageItemState();
}

class _MessageItemState extends BaseState<MessageItem> {
  var show = false;

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (EnvironmentConfig.template_version == 14) {
          //show dialog
          showDialog(
              context: context,
              builder: (BuildContext context) => MessageDialog(
                    messageList: [
                      _getMessageSubject(),
                      widget.message.createdOn == null ? "" : Format().dateTimezoneFormat(widget.message.createdOn!),
                      _getMessageContent(),
                    ],
                  ));
        } else {
          setState(() {
            show = !show;
          });
        }
        widget.onReadMessage(widget.message.id);
      },
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        elevation: 5,
        color: EnvironmentConfig.template_version == 14 ? Color(0xff202137) : Colors.white,
        child: Container(
            padding: EdgeInsets.all(15.auto),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_messageDot(), _messageTitle()],
                ),
                show
                    ? Container(
                        child: _messageContent(),
                      )
                    : Container()
              ],
            )),
      ),
    );
  }

  _messageDot() => Visibility(
        visible: !(widget.message.isRead ?? true) && EnvironmentConfig.template_version != 14,
        child: Container(
          width: 8.auto,
          height: 8.auto,
          margin: EdgeInsets.only(top: 7.auto, right: 10.auto),
          decoration: BoxDecoration(color: CustomColor.theme_button_color, shape: BoxShape.circle),
        ),
      );

  _messageTitle() => Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getMessageSubject(),
              style: TextStyle(
                  fontSize: (EnvironmentConfig.template_version == 14 ? 14 : 15).auto,
                  color: EnvironmentConfig.template_version == 14 ? Colors.white : Colors.black),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5.auto),
              child: Text(
                widget.message.createdOn == null ? "" : Format().dateTimezoneFormat(widget.message.createdOn!),
                style: TextStyle(fontSize: (EnvironmentConfig.template_version == 14 ? 14 : 11).auto, color: CustomColor.grey),
              ),
            ),
          ],
        ),
      );

  _messageContent() => Column(
        children: [
          Divider(
            thickness: (1.0).auto,
            color: CustomColor.very_light_pink_four,
          ),
          Container(
            width: context.screenWidth,
            child: Text(
              GlobalValueUtil.parseHtmlString(_getMessageContent()),
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 13.auto, color: CustomColor.grey),
            ),
          ),
        ],
      );

  _getMessageSubject() {
    if ((widget.message.localization?.subject?.isNotEmpty) ?? false)
      return widget.message.localization?.subject;
    else
      return widget.message.subject ?? "";
  }

  _getMessageContent() {
    if (widget.message.localization?.content?.isNotEmpty ?? false)
      return widget.message.localization?.content;
    else
      return widget.message.content ?? "";
  }
}
