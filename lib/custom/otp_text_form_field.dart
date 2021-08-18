import 'dart:async';

import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

import 'outline_border_button.dart';

class OtpTextFormField extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final Function getOtpCode;
  final Function onCountDownEnd;
  final bool isEnabled;
  final bool isCountdown;

  OtpTextFormField(
      {Key key,
      this.hintText,
      this.onChanged,
      this.controller,
      this.textInputAction,
      this.getOtpCode,
      this.isEnabled,
      this.isCountdown,
      this.onCountDownEnd})
      : super(key: key);

  @override
  _OtpTextFormFieldState createState() => _OtpTextFormFieldState();
}


class _OtpTextFormFieldState extends BaseState<OtpTextFormField> {
  Timer _timer;
  int _start = 0;
  static const int _duration = 5;

  Widget build(BuildContext context) {

    return Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 5,
        //margin:EdgeInsets.only(top:15.auto,),
        child: Container(
          margin: EdgeInsets.only(top: 15.auto, bottom: 15.auto, left: 15.auto, right: 10.auto),
          //EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Row(
            children: [
              Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Container(
                  width: context.screenWidth - 140.auto,
                  alignment: Alignment.topLeft,
                  child: Text(
                    getTranslatedText("otp"),
                    style: TextStyle(color: Colors.black, fontSize: 9.auto),
                    textAlign: TextAlign.start,
                  ),
                ),
                Container(
                  width: context.screenWidth - 140.auto,
                  child: TextFormField(
                    autofocus: false,
                    onChanged: (value) => widget.onChanged(value),
                    controller: widget.controller,
                    keyboardType: TextInputType.text,
                    textInputAction: widget.textInputAction,
                    style: TextStyle(color: CustomColor.theme_value_text_color, fontSize: 13.auto),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: widget.hintText,
                      hintStyle:
                          TextStyle(color: CustomColor.very_light_pink_two, fontSize: 13.auto),
                    ),
                    enabled: widget.isEnabled,
                  ),
                ),
              ]),
              OutlineBorderButton(
                  title: widget.isCountdown ? "${getTranslatedText("retry_otp")} (${_start}s)" : getTranslatedText("request_otp"),
                  onClick: () => widget.isEnabled && !widget.isCountdown ? widget.getOtpCode():null,
                  width: 86.auto,
                  height: 29.auto,
                  color: CustomColor.theme_bar_gradient_2,
                  fontSize: 11.auto
                  //fontSize: 11.auto,
                  )
            ],
          ),
        ));
  }

  @override
  void didUpdateWidget(covariant OtpTextFormField oldWidget) {
    if(oldWidget.isCountdown != widget.isCountdown) {
      if (widget.isCountdown && (_timer == null || !_timer.isActive)) {
        startTimer();
      } else {
        if (_timer != null)
          _timer.cancel();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  void startTimer() {
    _start = _duration;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            widget.onCountDownEnd();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    print("disposedisposedisposedispose");
    _timer.cancel();
    super.dispose();
  }

}
