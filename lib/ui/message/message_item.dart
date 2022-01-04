import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:api/entity/message.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

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
        setState(() {
          show = !show;
        });
        widget.onReadMessage(widget.message.id);
      },
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        elevation: 5,
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
    visible: !(widget.message.isRead ?? true),
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
              (widget.message.localization?.subject) ?? widget.message.subject ?? "",
              style: TextStyle(fontSize: 15.auto),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5.auto),
              child: Text(
                widget.message.createdOn == null ? "" : Format().dateTimezoneFormat(widget.message.createdOn!),
                style: TextStyle(fontSize: 11.auto, color: CustomColor.grey),
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
              parseHtmlString(widget.message.localization?.content?? ""),
              //overflow: TextOverflow.ellipsis,
              maxLines: 1,
              //softWrap: false,
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 13.auto, color: CustomColor.grey),
            ),
          ),
        ],
      );
}
