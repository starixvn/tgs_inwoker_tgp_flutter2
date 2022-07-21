import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tgp_flutter2/ui/Wheel/fortune_wheel_child.dart';

class WheelSlice extends StatelessWidget {
  WheelSlice({required this.index, required this.size, required this.fortuneWheelChildren});

  final int index;
  final double size;
  final List<FortuneWheelChild> fortuneWheelChildren;

  @override
  Widget build(BuildContext context) {
    int childCount = fortuneWheelChildren.length;
    double pieceAngle = (index / childCount * pi * 2);
    double pieceWidth = childCount == 2 ? size : sin(pi / childCount) * size / 2;
    double pieceHeight = size / 2;

    return Stack(
      children: [ _getSliceForeground(pieceAngle, pieceWidth, pieceHeight)],
    );
  }

  Widget _getSliceForeground(double pieceAngle, double pieceWidth, double pieceHeight) {
    double centerOffset = (pi / fortuneWheelChildren.length);
    double leftRotationOffset = (-pi / 2);

    return Transform.rotate(
      angle: leftRotationOffset + pieceAngle + centerOffset,
      alignment: Alignment.center,
      child: Stack(
        children: [
          Positioned(
            top: size / 2,
            left: size / 2 - pieceWidth / 2,
            child: Container(
              padding: EdgeInsets.all(size / fortuneWheelChildren.length / 4),
              height: pieceHeight,
              width: pieceWidth,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Transform.rotate(
                    angle: (() {
                      var angle = -pieceAngle - leftRotationOffset * 2;
                      //rotating text angle
                      if (index == 0)
                        return angle -1.58;
                      else
                        return angle + (index - 1.45);
                    }()), //,
                    child: fortuneWheelChildren[index].foreground),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
