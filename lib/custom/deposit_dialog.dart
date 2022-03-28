import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';

class DepositDialog extends StatelessWidget {
  final String title, description, buttonText1;

  DepositDialog({
    required this.title,
    required this.description,
    required this.buttonText1,
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
    LineSplitter lineSplitter = LineSplitter();
    List<String> content = lineSplitter.convert(description);
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
              Container(
                padding: EdgeInsets.only(bottom: 13.auto, left: 10.auto),
                child: Text(title,
                    style: TextStyle(
                      fontSize: 20.auto,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center),
              ),
              (description.contains("\n"))
                  ? Container(
                      width: context.screenWidth,
                      padding: EdgeInsets.only(bottom: 20.auto, left: 10.auto, right: 10.auto),
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: 13.auto,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.only(bottom: 20.auto),
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: content.length,
                            itemBuilder: (_, index) {
                              print(index.toString() + content[index]);
                              return Container(
                                width: context.screenWidth,
                                margin: EdgeInsets.only(bottom: 5.auto),
                                child: Text(
                                  content[index],
                                  style: TextStyle(
                                    fontSize: 13.auto,
                                    color: Colors.black54,
                                  ),
                                  textAlign: index == 0 ? TextAlign.center : TextAlign.justify,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
              _buildDoneButton(context)
            ],
          ),
        ),
      ],
    );
  }

  _buildDoneButton(BuildContext context) => ColorButton(
        onClick: () => Navigator.pop(context),
        title: buttonText1,
        /*text: Text(
          buttonText1,
          textAlign: TextAlign.center,
          style: TextStyle(color: CustomColor.theme_text_grey_color),
        ),*/
        isEnabled: true,
        radius: 45.auto,
        width: context.screenWidth / 3.5,
        height: context.screenHeight / 18,
      );
}
