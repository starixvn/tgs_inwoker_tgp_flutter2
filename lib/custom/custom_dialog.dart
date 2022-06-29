import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';

class CustomDialog extends StatefulWidget {
  final String? title, description, buttonText1;
  final String? buttonText2;
  final Function onClick;
  final Function? onClick2;
  final int popIndex;

  CustomDialog({
    this.title,
    required this.description,
    required this.buttonText1,
    this.buttonText2,
    required this.onClick,
    this.onClick2,
    this.popIndex = 1,
  });

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends BaseState<CustomDialog> {
  var isButtonClicked = false, isButton2Clicked = false;

  @override
  void dispose() {
    if (!isButton2Clicked && !isButtonClicked) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        if (widget.popIndex == 1)
          widget.onClick();
        else if (widget.popIndex == 2) widget.onClick2!();
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
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            vertical: context.screenHeight / 30,
            horizontal: context.screenWidth / 20,
          ),
          decoration: new BoxDecoration(
            color: Colors.white,
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
            children: <Widget>[
              widget.title == null
                  ? Container()
                  : Container(
                      padding: EdgeInsets.only(bottom: 13.auto, left: 10.auto),
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.title!,
                        style: TextStyle(
                          fontSize: 18.auto,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
              Container(
                width: context.screenWidth,
                padding: EdgeInsets.only(bottom: 20.auto, left: 10.auto, right: 10.auto),
                child: Text(
                  widget.description!,
                  style: TextStyle(
                    fontSize: 13.auto,
                    color: Colors.black54,
                  ),
                  textAlign: widget.title == null ? TextAlign.center : TextAlign.start,
                ),
              ),
              widget.buttonText2 == null
                  ? _buildDoneButton(context)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(flex: 1, child: _buildDoneButton(context)),
                        Container(
                          width: 10.auto,
                        ),
                        Expanded(flex: 1, child: _buildBackButton(context))
                      ],
                    )
            ],
          ),
        ),
      ],
    );
  }

  _buildDoneButton(BuildContext context) => ColorButton(
        onClick: () {
          setState(() {
            isButtonClicked = true;
          });
          widget.onClick();
        },
        title: widget.buttonText1!,
        isEnabled: true,
        radius: 45.auto,
        width: context.screenWidth / 3.5,
        height: context.screenHeight / 18,
      );

  _buildBackButton(BuildContext context) => OutlineBorderButton(
        onClick: () {
          setState(() {
            isButton2Clicked = true;
          });
          widget.onClick2!();
        },
        title: widget.buttonText2!,
        isEnabled: true,
        width: context.screenWidth / 3.5,
        height: context.screenHeight / 18,
        fontSize: 13.auto,
        color: CustomColor.theme_text_black_color,
        radius: 45.auto,
      );
}
