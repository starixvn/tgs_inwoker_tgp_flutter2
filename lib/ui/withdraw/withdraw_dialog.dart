import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';

class WithdrawDialog extends StatelessWidget {
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
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "红利限额",
                  style: TextStyle(
                    fontSize: 18.auto,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _dialogText(),
              TextButton(
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(45.auto),
                    )),
                    minimumSize: MaterialStateProperty.all(Size(context.screenWidth / 3.5, context.screenHeight / 15))),
                onPressed: () => {Navigator.of(context).pop()},
                child: Ink(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xffebce91),
                          Color(0xffdcb370),
                          Color(0xffc59f62),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(45))),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: context.screenWidth / 3.5,
                      maxHeight: context.screenHeight / 15,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "确认",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _dialogText() => Container(
        child: Row(
          children: [
            Spacer(),
            Column(
              children: [
                Text(
                  "体育",
                  style: TextStyle(fontSize: 12.auto),
                ),
                Text(
                  "彩票",
                  style: TextStyle(fontSize: 12.auto),
                ),
                Text(
                  "真人",
                  style: TextStyle(fontSize: 12.auto),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "190550.00",
                  style: TextStyle(color: Colors.red, fontSize: 12.auto),
                ),
                Text(
                  "595.00",
                  style: TextStyle(color: Colors.red, fontSize: 12.auto),
                ),
                Text(
                  "0.00",
                  style: TextStyle(color: Colors.red, fontSize: 12.auto),
                ),
              ],
            ),
            Spacer(),
          ],
        ),
      );
}
