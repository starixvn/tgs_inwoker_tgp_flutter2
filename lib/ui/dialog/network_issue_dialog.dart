import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter/services.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';

class NetworkIssueDialog extends StatefulWidget {
  NetworkIssueDialog();

  @override
  _NetworkIssueDialogState createState() => _NetworkIssueDialogState();
}

class _NetworkIssueDialogState extends BaseState<NetworkIssueDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      backgroundColor: Colors.transparent,
      alignment: Alignment.center,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) => Wrap(
        children: [
          Container(
            padding: EdgeInsets.all(20.auto),
            decoration: new BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: ListView(
              shrinkWrap: true,
              children: [
                Image.asset(
                  "images/network_error.png",
                  height: context.screenHeight / 7,
                ),
                Text(
                  getTranslatedText("network_desc"),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.auto,
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.only(top: 10.auto),
                  child: ColorButton(
                    title: getTranslatedText("network_restart"),
                    onClick: () {
                      SystemNavigator.pop();
                    },
                    isEnabled: true,
                  ),
                )
              ],
            ),
          ),
        ],
      );
}
