import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tgp_flutter2/ui/Wheel/wheel_slice.dart';
import 'fortune_wheel_child.dart';

export 'fortune_wheel_child.dart';

class FortuneWheel<T> extends StatefulWidget {
  FortuneWheel({
    required this.children,
    required this.size,
  }) : assert(children.length > 1, 'List with at least two elements must be given');

  final List<FortuneWheelChild<T>> children;
  final double size;

  @override
  _FortuneWheelState createState() => _FortuneWheelState();
}

class _FortuneWheelState extends State<FortuneWheel> with SingleTickerProviderStateMixin {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
       // widget.size = min(constraints.maxHeight, constraints.maxWidth);
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: _getWheelContent(),
        );
      }),
    );
  }

  _getWheelContent() {
    return _getSlices();
  }

  Widget _getSlices() {
    double fourthCircleAngle = pi / 2;
    double pieceAngle = pi * 2 / widget.children.length;

    return Stack(
      children: [
        for (int index = 0; index < widget.children.length; index++)
          Transform.rotate(
            angle: (-fourthCircleAngle) - (pieceAngle / 2),
            child: WheelSlice(index: index, size: widget.size, fortuneWheelChildren: widget.children),
          ),
      ],
    );
  }
}
