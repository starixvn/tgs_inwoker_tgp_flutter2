import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/tab_button.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/ui/message/announcement_item.dart';
import 'package:tgp_flutter2/ui/message/message_view_model.dart';

import 'message_item.dart';

class AnnouncementContent extends StatefulWidget {
  final MessageViewModel vm;
  final ScrollController controller;
  
  AnnouncementContent({
    this.vm,this.controller
  });
  @override
  _AnnouncementContentState createState() => _AnnouncementContentState();
}

class _AnnouncementContentState extends BaseState<AnnouncementContent> {
  var isEditing = false, isSelected = false, isLoading = false;

  Widget build(BuildContext context) {
    return ListView(controller: widget.controller, padding: EdgeInsets.all(10.0), children: [
      Column(
        children: List.generate(widget.vm.messageList.length, (index) {
          return AnnouncementItem(
            announcement: widget.vm.messageList[index],
            onReadMessage: (id) {
              widget.vm.readMessage([id]); //call api silently
            },
          );
        }),
      ),
      Visibility(
          visible: widget.vm.endRecord ? false : isLoading,
          child: Container(alignment: Alignment.center, child: CircularProgressIndicator())),
      Visibility(
          visible: widget.vm.endRecord && widget.vm.messageList.isNotEmpty,
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 10.auto, top: 10.auto),
            child: Text(
              getTranslatedText("no_more"),
              style: TextStyle(fontSize: 12.auto, color: CustomColor.grey),
            ),
          ))
    ]);
  }
}
