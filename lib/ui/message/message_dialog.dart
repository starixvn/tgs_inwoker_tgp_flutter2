import 'package:api/entity/message.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';

import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';

import '../../globalUtil/GlobalValueUtil.dart';

class MessageDialog extends StatefulWidget {
  final List<String> messageList;

  MessageDialog({
    required this.messageList,
  });

  @override
  _MessageDialogState createState() => _MessageDialogState();
}

class _MessageDialogState extends BaseState<MessageDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: Colors.transparent,
      child: dialogContent(),
    );
  }

  dialogContent() {
    return Container(
      decoration: BoxDecoration(color: Color(0xff202138), borderRadius: BorderRadius.all(Radius.circular(12.auto))),
      padding: EdgeInsets.all(20),
      child: ListView(
        // mainAxisSize: MainAxisSize.min,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Container(alignment: Alignment.center, child: Text(widget.messageList[0], style: TextStyle(fontSize: 30.auto, color: Colors.white))),
          SizedBox(height: 10),
          Container(alignment: Alignment.center, child: Text(widget.messageList[1], style: TextStyle(fontSize: 14.auto, color: Colors.grey))),
          SizedBox(height: 25),
          Container(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: new BoxConstraints(
                maxHeight: context.screenHeight/3,
              ),
              child: ListView(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                children:[
                  Text(GlobalValueUtil.parseHtmlString(widget.messageList[2]), style: TextStyle(fontSize: 15.auto, color: Colors.white)),
                ]
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildLeaveButton() => Expanded(
        flex: 1,
        child: InkWell(
          onTap: () {
            Navigator.pop(context, true);
            Navigator.pop(context, true);
          },
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(left: 22.5.auto),
            height: 35.auto,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5.auto))),
            child: Text(
              getTranslatedText("leave"),
              style: TextStyle(color: CustomColor.grey_five, fontSize: 11.5.auto),
            ),
          ),
        ),
      );

  _buildContinuePlayingButton() => Expanded(
        flex: 1,
        child: InkWell(
          onTap: () => Navigator.pop(
            context,
          ),
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(right: 17.5.auto),
            height: 35.auto,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(bottomRight: Radius.circular(5.auto))),
            child: Text(
              getTranslatedText("play_a_while"),
              style: TextStyle(color: CustomColor.faded_red, fontSize: 11.5.auto),
            ),
          ),
        ),
      );
}
