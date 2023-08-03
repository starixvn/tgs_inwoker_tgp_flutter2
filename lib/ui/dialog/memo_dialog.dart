import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';

class MemoDialog extends StatefulWidget {
  final String title, sender, date, content;
  final Function onClick;

  MemoDialog({
    required this.onClick,
    required this.title,
    required this.sender,
    required this.date,
    required this.content,
  });

  @override
  _MemoDialogState createState() => _MemoDialogState();
}

class _MemoDialogState extends BaseState<MemoDialog> {
  var isButtonClicked = false;

  @override
  void dispose() {
    if (!isButtonClicked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onClick();
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
          color: Colors.white),
      child: _buildContent(),
    );
  }

  _buildContent() => Column(
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: CustomColor.theme_text_black_color,
              fontSize: 17.auto,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.title,
            style: TextStyle(
              color: CustomColor.theme_text_black_color,
              fontSize: 10.auto,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
}
