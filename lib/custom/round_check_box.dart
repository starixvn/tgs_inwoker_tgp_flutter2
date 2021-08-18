import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class RoundCheckBox extends StatefulWidget{
  final bool isEdit;

  RoundCheckBox({Key key,
    this.isEdit
  }) : super(key: key);

  @override
  _RoundCheckBoxState createState() => _RoundCheckBoxState();
}

class _RoundCheckBoxState extends BaseState<RoundCheckBox> {
  Widget build(BuildContext context) {
    return  Container(
      child: widget.isEdit
          ? Container(
        width: 22,
        height: 22,
        child: Icon(
          Icons.check_circle,
          color: Colors.red,
        ),
      )
          : Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(
            Radius.circular(100),
          ),
          /*border: Border.all(
            width: 3,
            color: Colors.green,
          ),*/
        ),
        child: Icon(
          Icons.check_circle,
          size: 22.0,
          color: Colors.black,
        ),
      ),
    );
  }
}