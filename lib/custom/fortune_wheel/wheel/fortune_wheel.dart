part of 'wheel.dart';

Offset _calculateWheelOffset(BoxConstraints constraints, TextDirection textDirection) {
  final smallerSide = getSmallerSide(constraints);
  var offsetX = constraints.maxWidth / 2;
  if (textDirection == TextDirection.rtl) {
    offsetX = offsetX * -1 + smallerSide / 2;
  }
  return Offset(offsetX, constraints.maxHeight / 2);
}

double _calculateSliceAngle(int index, int itemCount) {
  final anglePerChild = 2 * _math.pi / itemCount;
  final childAngle = anglePerChild * index;
  // first slice starts at 90 degrees, if 0 degrees is at the top.
  // The angle offset puts the center of the first slice at the top.
  final angleOffset = -(_math.pi / 2 + anglePerChild / 2);
  return childAngle + angleOffset;
}

double _calculateAlignmentOffset(Alignment alignment) {
  if (alignment == Alignment.topRight) {
    return _math.pi * 0.25;
  }

  if (alignment == Alignment.centerRight) {
    return _math.pi * 0.5;
  }

  if (alignment == Alignment.bottomRight) {
    return _math.pi * 0.75;
  }

  if (alignment == Alignment.bottomCenter) {
    return _math.pi;
  }

  if (alignment == Alignment.bottomLeft) {
    return _math.pi * 1.25;
  }

  if (alignment == Alignment.centerLeft) {
    return _math.pi * 1.5;
  }

  if (alignment == Alignment.topLeft) {
    return _math.pi * 1.75;
  }

  return 0;
}

class _WheelData {
  final BoxConstraints constraints;
  final int itemCount;
  final TextDirection textDirection;

  late final double smallerSide = getSmallerSide(constraints);
  late final double largerSide = getLargerSide(constraints);
  late final double sideDifference = largerSide - smallerSide;
  late final Offset offset = _calculateWheelOffset(constraints, textDirection);
  late final Offset dOffset = Offset(
    (constraints.maxHeight - smallerSide) / 2,
    (constraints.maxWidth - smallerSide) / 2,
  );
  late final double diameter = smallerSide;
  late final double radius = diameter / 2;
  late final double itemAngle = 2 * _math.pi / itemCount;

  _WheelData({
    required this.constraints,
    required this.itemCount,
    required this.textDirection,
  });
}

/// A fortune wheel visualizes a (random) selection process as a spinning wheel
/// divided into uniformly sized slices, which correspond to the number of
/// [items].
///
/// ![](https://raw.githubusercontent.com/kevlatus/flutter_fortune_wheel/main/images/img-wheel-256.png?sanitize=true)
///
/// See also:
///  * [FortuneBar], which provides an alternative visualization
///  * [FortuneWidget()], which automatically chooses a fitting widget
///  * [Fortune.randomItem], which helps selecting random items from a list
///  * [Fortune.randomDuration], which helps choosing a random duration
class FortuneWheel extends HookWidget implements FortuneWidget {
  //static const StyleStrategy kDefaultStyleStrategy = AlternatingStyleStrategy();

  /// {@macro flutter_fortune_wheel.FortuneWidget.items}
  final List<FortuneItem> items;

  /// {@macro flutter_fortune_wheel.FortuneWidget.selected}
  final Stream<int> selected;

  /// {@macro flutter_fortune_wheel.FortuneWidget.rotationCount}
  //final int rotationCount = 100;

  /// {@macro flutter_fortune_wheel.FortuneWidget.duration}
  //final Duration duration = Duration(seconds: 3);

  /// {@macro flutter_fortune_wheel.FortuneWidget.animationType}
  //final Curve curve;

  /// {@macro flutter_fortune_wheel.FortuneWidget.onAnimationStart}
  final VoidCallback? onAnimationStart;

  /// {@macro flutter_fortune_wheel.FortuneWidget.onAnimationEnd}
  final VoidCallback? onAnimationEnd;

  /// {@macro flutter_fortune_wheel.FortuneWidget.styleStrategy}
  // final StyleStrategy styleStrategy;

  /// {@macro flutter_fortune_wheel.FortuneWidget.animateFirst}
  final bool animateFirst = false;

  /// {@macro flutter_fortune_wheel.FortuneWidget.physics}
  // final PanPhysics physics;

  /// {@macro flutter_fortune_wheel.FortuneWidget.onFling}
  // final VoidCallback? onFling;

  /// The position to which the wheel aligns the selected value.
  ///
  /// Defaults to [Alignment.topCenter]
  final Alignment alignment;

  double _getAngle(double progress) {
    return 2 * _math.pi * 100 * progress;
  }

  /// {@template flutter_fortune_wheel.FortuneWheel}
  /// Creates a new [FortuneWheel] with the given [items], which is centered
  /// on the [selected] value.
  ///
  /// {@macro flutter_fortune_wheel.FortuneWidget.ctorArgs}.
  ///
  /// See also:
  ///  * [FortuneBar], which provides an alternative visualization.
  /// {@endtemplate}
  FortuneWheel({
    Key? key,
    required this.items,
    //this.rotationCount = FortuneWidget.kDefaultRotationCount,
    this.selected = const Stream<int>.empty(),
    // this.duration = FortuneWidget.kDefaultDuration,
    //this.curve = FortuneCurve.spin,
    // this.styleStrategy = kDefaultStyleStrategy,
    // this.animateFirst = true,
    this.onAnimationStart,
    this.onAnimationEnd,
    this.alignment = Alignment.topCenter,
    // PanPhysics? physics,
    // this.onFling,
  })  : //physics = physics ?? CircularPanPhysics(),
        assert(items.length > 1),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final rotateAnimCtrl = useAnimationController(duration: Duration(seconds: 3));
    final imageRotateAnimCtrl = useAnimationController(duration: Duration(seconds: 3));
    final rotateAnim = CurvedAnimation(parent: rotateAnimCtrl, curve: FortuneCurve.spin);
    final imageRotateAnim = CurvedAnimation(parent: rotateAnimCtrl, curve: FortuneCurve.spin);

    Future<void> animate() async {
      if (rotateAnimCtrl.isAnimating) {
        return;
      }

      await Future.microtask(() => onAnimationStart?.call());
      await rotateAnimCtrl.forward(from: 0);
      await imageRotateAnimCtrl.repeat(min: 100, max: 100, period: Duration(seconds: 3));
      await Future.microtask(() => onAnimationEnd?.call());
    }

    useEffect(() {
      if (animateFirst) animate();
      return null;
    }, []);

    final selectedIndex = useState<int>(0);

    useEffect(() {
      final subscription = selected.listen((event) {
        selectedIndex.value = event;
        animate();
      });
      return subscription.cancel;
    }, []);

    return PanAwareBuilder(
      behavior: HitTestBehavior.translucent,
      physics: CircularPanPhysics(),
      builder: (context, panState) {
        return Stack(
          children: [
            // RotationTransition(
            //   turns: imageRotateAnim,
            //   child: Center(
            //     child: Image.asset('images/roulette/roulette.png'),
            //   ),
            // ),
            AnimatedBuilder(
              animation: imageRotateAnimCtrl,
              builder: (BuildContext _, child) {
                return Transform.scale(
                  scale: imageRotateAnimCtrl.value,
                  child: Center(
                    child: Image.asset('images/roulette/roulette.png'),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: rotateAnim,
              builder: (context, _) {
                final size = MediaQuery.of(context).size;
                final meanSize = (size.width + size.height) / 2;
                final panFactor = 6 / meanSize;

                return LayoutBuilder(builder: (context, constraints) {
                  final wheelData = _WheelData(
                    constraints: constraints,
                    itemCount: items.length,
                    textDirection: Directionality.of(context),
                  );

                  final isAnimatingPanFactor = rotateAnimCtrl.isAnimating ? 0 : 1;
                  final selectedAngle = -2 * _math.pi * (selectedIndex.value / items.length);
                  final panAngle = panState.distance * panFactor * isAnimatingPanFactor;
                  final rotationAngle = _getAngle(rotateAnim.value);
                  final alignmentOffset = _calculateAlignmentOffset(alignment);

                  final transformedItems = [
                    for (var i = 0; i < items.length; i++)
                      TransformedFortuneItem(
                        item: items[i],
                        angle: selectedAngle +
                            panAngle +
                            rotationAngle +
                            alignmentOffset +
                            _calculateSliceAngle(i, items.length),
                        offset: wheelData.offset,
                      ),
                  ];

                  return SizedBox.expand(
                    child: _CircleSlices(
                      items: transformedItems,
                      wheelData: wheelData,
                      styleStrategy: AlternatingStyleStrategy(),
                    ),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }
}
