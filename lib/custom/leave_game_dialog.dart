import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';

import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';

class LeaveGameDialog extends StatefulWidget {
  @override
  _LeaveGameDialogState createState() => _LeaveGameDialogState();
}

class _LeaveGameDialogState extends BaseState<LeaveGameDialog> {
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
      child: Wrap(
        children: [
          Stack(
            children: [
              Container(child: Image.asset("images/child_game/leave_game_bg.png")),
              Positioned(
                top: context.screenWidth / 6,
                left: context.screenWidth / 8,
                child: Text(
                  getTranslatedText("confirm_leave_game"),
                  style: TextStyle(fontSize: 13.5.auto, color: Colors.white),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildLeaveButton(),
              VerticalDivider(
                color: CustomColor.grey_five,
                width: 0.5,
              ),
              _buildContinuePlayingButton()
            ],
          )
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
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5.auto))),
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
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.only(bottomRight: Radius.circular(5.auto))),
            child: Text(
              getTranslatedText("play_a_while"),
              style: TextStyle(color: CustomColor.faded_red, fontSize: 11.5.auto),
            ),
          ),
        ),
      );
}
