import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';

class CountdownTimer extends AnimatedWidget {
  CountdownTimer({Key key, this.animation}) : super(key: key, listenable: animation);
  final Animation<int> animation;

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);

    String timerText =
        "${clockTimer.inHours.toString()} 时 "
        "${clockTimer.inMinutes.remainder(60).toString()} 分 "
        "${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')} 秒";

    return Text(
      "$timerText",
      style: TextStyle(
        fontSize: 13.auto,
        color: Colors.red
      ),
    );
  }
}