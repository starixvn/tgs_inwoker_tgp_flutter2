import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:tgp_flutter2/custom/round_check_box.dart';
import 'package:api/entity/message.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/message/message_action_dialog.dart';

class MessageDetails extends StatefulWidget {
  final Message message;

  MessageDetails({this.message});

  @override
  _MessageDetailsState createState() => _MessageDetailsState();
}

class _MessageDetailsState extends BaseState<MessageDetails> {
  var isSelected;

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: gradientDecoration,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          getTranslatedText("message_center"),
          style: TextStyle(fontSize: 16.auto),
        ),
        /*actions: [
          InkWell(
            onTap: () => _showActionDialog(),
            child: Container(
              margin: EdgeInsets.only(right: 10.auto),
              alignment: Alignment.center,
              width: 23.auto,
              child: Image.asset("images/message/ic_message_action.png"),
            ),
          ),
        ],*/
      ),
      body: Container(
          margin: EdgeInsets.all(20.auto),
          padding: EdgeInsets.symmetric(
            vertical: 20.auto,
          ),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10.0))),
          child: ListView(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.auto),
                child: Text(
                  widget.message.subject,
                  style: TextStyle(fontSize: 15.auto, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.auto, vertical: 5.auto),
                child: Text(
                  Format().dateFormat(DateTime.parse(widget.message.createdOn)),
                  style: TextStyle(fontSize: 11.auto, color: CustomColor.grey),
                ),
              ),
              Divider(
                thickness: (1.0).auto,
                color: CustomColor.very_light_pink_four,
              ),
              Container(margin: EdgeInsets.symmetric(horizontal: 20.auto), child: Html(data: widget.message.content))
            ],
          )),
    );
  }

  /*_showActionDialog() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return MessageActionDialog();
        });
  }*/
}
