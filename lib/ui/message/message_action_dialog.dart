import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:api/entity/game_provider.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class MessageActionDialog extends StatefulWidget {
  MessageActionDialog({
    Key key,
  }) : super(key: key);

  @override
  _MessageActionDialogState createState() => _MessageActionDialogState();
}

class _MessageActionDialogState extends BaseState<MessageActionDialog> {
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10.auto, right: 10.auto, bottom: 10.auto),
      child: Wrap(children: [
        /*ColorButton(
            text: Text(
              getTranslatedText("delete"),
              style: TextStyle(fontSize: 17.2.auto, color: Colors.red),
            ),
            onClick: () {},
            isEnabled: true,
            color: Colors.white,
            radius: 11.6.auto),*/
        ColorButton(
            title: getTranslatedText("cancel"),

            onClick: () {
              Navigator.pop(
                context,
              );
            },
            isEnabled: true,
            color: CustomColor.theme_text_grey_color,
            radius: 11.6.auto),
      ]),
    );
  }
}
