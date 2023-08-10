import 'package:api/extension/format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';

class MemoDialog extends StatefulWidget {
  final String? title, sender, sentOn, content;
  final Function onReplyClick;

  MemoDialog({this.title, this.sender, this.sentOn, this.content, required this.onReplyClick});

  @override
  _MemoDialogState createState() => _MemoDialogState();
}

class _MemoDialogState extends BaseState<MemoDialog> {
  @override
  void dispose() {
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
      padding: EdgeInsets.symmetric(
        vertical: context.screenHeight / 90,
        horizontal: context.screenWidth / 20,
      ),
      decoration: new BoxDecoration(
        color: EnvironmentConfig.template_version == 14 ? CustomColor.theme_bar_gradient_1 : Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the card compact
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.centerRight,
            child: _buildCloseDialogButton(),
          ),
          Text(
            widget.title ?? "",
            style: TextStyle(color: _getTextColor(), fontSize: 17.auto, fontWeight: FontWeight.bold),
          ),
          Wrap(
            children: [
              Text(
                "${widget.sender} - ",
                style: TextStyle(color: _getTextColor(), fontSize: 10),
              ),
              Text(
                "${Format().dateFormat(DateTime.parse(widget.sentOn ?? ""))} - ",
                style: TextStyle(color: _getTextColor(), fontSize: 10),
              ),
              Text(
                _calculateDaysDifference(),
                style: TextStyle(color: _getTextColor(), fontSize: 10),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text("${widget.content ?? " "}"),
          ),
          Row(
            children: [
              Expanded(flex: 1, child: Container()),
              Expanded(
                flex: 0,
                child: ColorButton(
                  title: "回复",
                  onClick: () => widget.onReplyClick(),
                  isEnabled: true,
                  width: 60.auto,
                  height: 17,
                  fontSize: 14,
                  radius: 5,
                  padding: 4,
                  textColor: /*_isDarkMode() || EnvironmentConfig.light_mode || EnvironmentConfig.template_version == 14 ?*/
                  Colors.white /*: CustomColor.theme_app_bar_color*/,
                  color: /*EnvironmentConfig.template_version == 3 ||
                            EnvironmentConfig.template_version == 4 ||
                            EnvironmentConfig.template_version == 10 ||
                            EnvironmentConfig.template_version == 14 ||
                            _isDarkMode() ||
                            EnvironmentConfig.light_mode
                            ? */
                  CustomColor.theme_button_color /* : Colors.white*/,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  _buildCloseDialogButton() =>
      InkWell(
        onTap: () => Navigator.pop(context),
        child: Icon(
          Icons.close,
          color: Colors.black,
          size: 20,
        ),
      );

  Color _getTextColor() => EnvironmentConfig.template_version == 14 ? Colors.white : Colors.black;

  String _calculateDaysDifference() {
    DateTime currentDate = DateTime.now();
    DateTime givenDate = DateTime.parse(widget.sentOn ?? "");

    Duration difference = givenDate.difference(currentDate);
    int daysDifference = difference.inDays.abs();

    return "$daysDifference天前";
  }
}
