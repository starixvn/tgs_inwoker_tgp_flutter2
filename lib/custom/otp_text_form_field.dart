import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
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
  final bool isVisible;

  OtpTextFormField(
      {
      required this.hintText,
      required this.onChanged,
      required this.controller,
      required this.textInputAction,
      required this.getOtpCode,
      required this.isEnabled,
      required this.isCountdown,
      required this.onCountDownEnd,
      this.isVisible = true,})
      ;

  @override
  _OtpTextFormFieldState createState() => _OtpTextFormFieldState();
}

class _OtpTextFormFieldState extends BaseState<OtpTextFormField> {
  Timer? _timer;
  int _start = 0;
  static const int _duration = 5;

  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isVisible,
      child: Container(
        margin: EdgeInsets.only(top: 15.auto, left: 10.auto, right: 10.auto),
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                getTranslatedText("otp"),
                style: TextStyle(color: CustomColor.theme_text_black_white_color, fontSize: 12.auto),
                textAlign: TextAlign.start,
              ),
            ),
            Opacity(
              opacity: widget.isEnabled ? 1 : 0.4,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 5,
                        margin: EdgeInsets.only(top: 8.auto, bottom: 8.auto, right: 10.auto),
                        child: Container(
                          height: 40.auto,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 10.auto),
                          child: TextFormField(
                            autofocus: false,
                            onChanged: (value) => widget.onChanged(value),
                            controller: widget.controller,
                            keyboardType: TextInputType.text,
                            textInputAction: widget.textInputAction,
                            style: TextStyle(color: CustomColor.theme_text_black_color, fontSize: 13.auto),
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
                    ),
                  ),
                  Expanded(flex: 1, child: _buildButton()),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildButton() => TextButton(
        onPressed: () => widget.isEnabled && !widget.isCountdown ? widget.getOtpCode() : null,
        style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.all(8)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular((5.8).auto),
              side: BorderSide(color: Colors.transparent),
            )),
            backgroundColor: MaterialStateProperty.all(
                widget.isCountdown ? CustomColor.theme_grey_button_color : CustomColor.theme_button_color),
            minimumSize: MaterialStateProperty.all(Size(100, 40.auto))),
        child: widget.isCountdown
            ? Container(
                width: 100,
                padding: EdgeInsets.only(left: 5.auto),
                alignment: Alignment.centerLeft,
                child: AutoSizeText.rich(
                  TextSpan(style: TextStyle(fontSize: 12.auto, fontWeight: FontWeight.bold), children: [
                    TextSpan(text: _start.toString(), style: TextStyle(color: Color(0xffFFDD00))),
                    TextSpan(text: " s", style: TextStyle(color: Colors.white))
                  ]),
                  minFontSize: 8,
                  maxFontSize: 15,
                  maxLines: 1,
                  stepGranularity: 1,
                  textAlign: TextAlign.left,
                ),
              )
            : AutoSizeText(
                getTranslatedText("request_otp"),
                style: TextStyle(color: Colors.white),
                minFontSize: 8,
                maxFontSize: 15,
                stepGranularity: 1,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
      );

  @override
  void didUpdateWidget(covariant OtpTextFormField oldWidget) {
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
