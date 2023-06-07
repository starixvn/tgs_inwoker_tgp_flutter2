import 'dart:async';

import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

import '../../../environment_config.dart';

class LoginOtpInputView extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final Function getOtpCode;
  final Function onCountDownEnd;
  final bool isEnabled;
  final bool isCountdown;

  LoginOtpInputView(
      {required this.hintText,
      required this.onChanged,
      required this.controller,
      required this.textInputAction,
      required this.getOtpCode,
      required this.isEnabled,
      required this.isCountdown,
      required this.onCountDownEnd});

  @override
  _LoginOtpInputViewState createState() => _LoginOtpInputViewState();
}

class _LoginOtpInputViewState extends BaseState<LoginOtpInputView> {
  Timer? _timer;
  int _start = 0;
  static const int _duration = 60;

  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 40.auto,
            margin: EdgeInsets.only(right: 5.auto),
            padding: EdgeInsets.symmetric(horizontal: 10.auto),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: CustomColor.black, width: 1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: TextFormField(
              autofocus: false,
              onChanged: (value) => widget.onChanged(value),
              controller: widget.controller,
              keyboardType: TextInputType.text,
              textInputAction: widget.textInputAction,
              style: TextStyle(color: CustomColor.black, fontSize: 13.auto),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: TextStyle(color: CustomColor.very_light_pink_two, fontSize: 13.auto),
              ),
              enabled: widget.isEnabled,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: ColorButton(
            title: widget.isCountdown ? "${getTranslatedText("retry_otp")} (${_start}s)" : getTranslatedText("request_otp"),
            onClick: () => widget.isEnabled && !widget.isCountdown ? widget.getOtpCode() : null,
            width: 86.auto,
            height: 40.auto,
            isEnabled: widget.isEnabled,
            radius: 2.9,
            //fontSize: 11.auto,
          ),
        )
      ],
    );
  }

  @override
  void didUpdateWidget(covariant LoginOtpInputView oldWidget) {
    if (oldWidget.isCountdown != widget.isCountdown) {
      if (widget.isCountdown && (_timer == null || !_timer!.isActive)) {
        startTimer();
      } else {
        if (_timer != null) _timer!.cancel();
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
    _timer!.cancel();
    super.dispose();
  }
}
