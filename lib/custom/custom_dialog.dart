import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText1, buttonText2;
  final Function onClick, onClick2;

  CustomDialog({
    this.title,
    this.description,
    this.buttonText1,
    this.buttonText2,
    this.onClick,
    this.onClick2,
  });

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
            color: CustomColor.theme_text_color2,
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
              title == null
                  ? Container()
                  : Container(
                      padding: EdgeInsets.only(bottom: 13.auto, left: 10.auto),
                      alignment: Alignment.topLeft,
                      child: Text(
                        title,
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
                  description,
                  style: TextStyle(
                    fontSize: 13.auto,
                    color: Colors.black54,
                  ),
                  textAlign: title==null?TextAlign.center: TextAlign.start,
                ),
              ),
              buttonText2 == null
                  ? _buildDoneButton(context)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [_buildDoneButton(context), _buildBackButton(context)],
                    )
            ],
          ),
        ),
      ],
    );
  }

  _buildDoneButton(BuildContext context) => ColorButton(
        onClick: () => this.onClick(),
        title: buttonText1,
        /*text: Text(
          buttonText1,
          textAlign: TextAlign.center,
          style: TextStyle(color: CustomColor.theme_text_color2),
        ),*/
        isEnabled: true,
        radius: 45.auto,
        width: context.screenWidth / 3.5,
        height: context.screenHeight / 18,
      );

  _buildBackButton(BuildContext context) => OutlineBorderButton(
        onClick: () => this.onClick2(),
        title: buttonText2,
        isEnabled: true,
        width: context.screenWidth / 3.5,
        height: context.screenHeight / 18,
        fontSize: 13.auto,
        color: CustomColor.theme_text_color2,
      );
}
