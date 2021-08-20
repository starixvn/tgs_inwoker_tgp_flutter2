import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:api/entity/message.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class AnnouncementItem extends StatefulWidget {
  final Message announcement;
  final Function(String) onReadMessage;

  AnnouncementItem({
    this.announcement,
    this.onReadMessage,
  });

  @override
  _AnnouncementItemState createState() => _AnnouncementItemState();
}

class _AnnouncementItemState extends BaseState<AnnouncementItem> {
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
       // widget.onReadMessage(widget.announcement.id);
      },
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        elevation: 5,
        /*Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: show
              ? BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))
              : BorderRadius.circular(10.auto),
        ),
        margin: EdgeInsets.only(
          bottom: 10.auto,
        )*/
        child: Column(
          children: [
            _announcementTitle(),
            show
                ? Container(
                    child: _messageContent(),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  _announcementTitle() => Container(
        color: show ? CustomColor.theme_button_color : Colors.white,
        padding: EdgeInsets.symmetric(vertical: 10.auto, horizontal: 15.auto),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                margin: EdgeInsets.only(right: 20.auto),
                padding: EdgeInsets.symmetric(vertical: 5.auto, horizontal: 15.auto),
                decoration: BoxDecoration(
                  color: show ? Colors.white : CustomColor.theme_button_color,
                  borderRadius: BorderRadius.circular(5.auto),
                ),
                child: Text(
                  "银行",
                  style: TextStyle(fontSize: 8.auto, color: show ? CustomColor.theme_button_color : Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.announcement.subject,
                    style: TextStyle(fontSize: 13.auto, color: show ? Colors.white : CustomColor.theme_text_color),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 2.auto),
                    child: Text(
                      Format().dateFormat(DateTime.parse(widget.announcement.createdOn)),
                      style: TextStyle(fontSize: 13.auto, color: show ? Colors.white : CustomColor.theme_text_color),
                    ),
                  ),
                ],
              ),
            ),
            show
                ? Container()
                : Expanded(
                    flex: 1,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: CustomColor.grey,
                    ),
                  )
          ],
        ),
      );

  _messageContent() => Container(
        color: CustomColor.light_button_color,
        padding: EdgeInsets.symmetric(vertical: 10.auto, horizontal: 15.auto),
        child: Column(
          children: [
            Container(
              width: context.screenWidth,
              child: Text(
                parseHtmlString(widget.announcement.localization?.content ?? widget.announcement.content),
                //overflow: TextOverflow.ellipsis,
                maxLines: 1,
                //softWrap: false,
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 13.auto, color: CustomColor.grey),
              ),
            ),
          ],
        ),
      );
}
