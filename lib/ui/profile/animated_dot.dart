
import 'package:flutter/material.dart';

import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class AnimatedDot extends StatefulWidget {
  final double size;
  final Color color;

  AnimatedDot({Key key, this.size = 10, this.color})
      : super(key: key);

  @override
  _AnimatedDotState createState() => _AnimatedDotState();
}

class _AnimatedDotState extends BaseState<AnimatedDot> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation scaleAnimation;
  int bounceCount = 0;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
    scaleAnimation = Tween(begin: 1.0, end: 1.2)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _controller.reverse();
            } else if (status == AnimationStatus.dismissed) {
              bounceCount++;
              if (bounceCount >= 2) {
                bounceCount = 0;
                Future.delayed(Duration(milliseconds: 3000), () {
                  if (_controller != null) _controller.forward(from: 0.0);
                });
              } else {
                _controller.forward(from: 0.0);
              }
            }
          });

    super.initState();
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller = null;
    scaleAnimation = null;
    super.dispose();
  }

  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      alignment: Alignment.center,
      child: Container(
        width: widget.size.auto,
        height: widget.size.auto,
        decoration: BoxDecoration(color: widget.color?? CustomColor.theme_button_color, shape: BoxShape.circle),
      ),
    );
  }
}
