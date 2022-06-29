import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:api/entity/user_profile.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/fortune_wheel/core/core.dart';
// import 'package:tgp_flutter2/custom/fortune_wheel/wheel/wheel.dart';
import 'package:tgp_flutter2/route_path.dart';
// import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:api/entity/campaign_details.dart';
import 'package:tgp_flutter2/ui/Wheel/controller/fortune_wheel_controller.dart';
// import 'package:flutter_spinning_wheel/flutter_spinning_wheel.dart';
// import 'package:flutter_spinwheel/flutter_spinwheel.dart';
// import 'package:tgp_flutter2/ui/home/QuarterCircle.dart';
import 'package:tgp_flutter2/ui/Wheel/fortune_wheel.dart';

class RouletteDialog extends StatefulWidget {
  final Function onTapCloseIcon;
  final UserProfile? userProfile;
  final bool isPlayed;
  final Function getRouletteResult;
  final List<CampaignDetails>? campaign;

  RouletteDialog(
      {required this.onTapCloseIcon,
      this.isPlayed = false,
      this.userProfile,
      required this.getRouletteResult,
      this.campaign});

  @override
  _RouletteDialogState createState() => _RouletteDialogState();
}

class _RouletteDialogState extends BaseState<RouletteDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // late AnimationController _controller2;
  final selected = BehaviorSubject<int>();
  var isRoulettePlayed;
  int selectedValue = 0;
  final StreamController _dividerController = StreamController<int>();
  double _generateRandomAngle() => Random().nextDouble() * pi * 2;
  final _wheelNotifier = StreamController<double>();
  double _generateRandomVelocity() => (Random().nextDouble() * 6000) + 2000;
  late int select;
  Paint customPaint = Paint();
  var currentSelectValue = 0.0;
  var isClick = false;
  FortuneWheelController<int> fortuneWheelController = FortuneWheelController();
  late Animation animationOpenClose;
  late CurvedAnimation _animation;
  var pieValue = 0.00;

  @override
  void initState() {
    isRoulettePlayed = widget.isPlayed;
    // if (widget.campaign != null && widget.campaign!.length < 8) {
    //   // to fix fortune item length in 8
    //   for (var i = widget.campaign!.length; i < 8; i++) {
    //     widget.campaign!.add(new CampaignDetails("", "", 0));
    //   }
    // }
    select = 0;
    customPaint.color = Colors.transparent;
    customPaint.strokeWidth = 0;
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )
      ..repeat()
      ..addListener(() {
        var a = double.parse(((_controller.value * 2.0 * pi)).toStringAsFixed(2));
        var b = double.parse((currentSelectValue).toStringAsFixed(2));
        if (a == b && isClick) {
          _controller.stop();
        }
      });
    _animation = new CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    )..addStatusListener((AnimationStatus status) {
        print("whatisstatus now?? : ${status}");
        if (status == AnimationStatus.completed) print('completed');
      });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    selected.close();
    _dividerController.close();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      backgroundColor: Colors.transparent,
      child: isRoulettePlayed ? _buildIsPlayedRouletteText() : _buildRoulette(),
    );
  }

  List<FortuneWheelChild<int>> totalList() {
    List<FortuneWheelChild<int>> list = [];
    if (widget.campaign == null) {
      list = [FortuneWheelChild(foreground: Text(""), value: 1), FortuneWheelChild(foreground: Text(""), value: 1)];
    } else {
      for (var i = 0; i < widget.campaign!.length; i++) {
        list.add(FortuneWheelChild(foreground: Text(widget.campaign?[i].title ?? ""), value: 1));
      }
    }
    return list;
  }

  _buildRoulette() => Container(
      padding: EdgeInsets.symmetric(
        vertical: context.screenHeight / 30,
        horizontal: context.screenWidth / 20,
      ),
      decoration: BoxDecoration(
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
      child: Stack(
        children: [
          // Column(
          // children: [
          AnimatedBuilder(
            animation: /* selectedValue != 0 ? _controller2 : */ _animation,
            builder: (BuildContext _, child) {
              return Transform.rotate(
                angle: /*selectedValue != 0
                    ? ((_controller.value * 2.0 * pi)) * selectedValue
                    : */
                    /*isClick ? currentSelectValue :  (((1 / 6) * selectedValue) * 2.0 * pi) +*/
                    _controller.value * 2.0 * pi,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        Center(
                          child: Image.asset('images/roulette/roulette.png'),
                        ),
                        Center(
                          child: SizedBox(
                              width: 280,
                              height: 280,
                              child: FortuneWheel<int>(
                                controller: fortuneWheelController,
                                children: totalList(),
                              )),
                          //   Container(
                          // height: 280 / 6,
                          // child: ListView.builder(
                          //     itemCount: 1,
                          //     primary: false,
                          //     physics: NeverScrollableScrollPhysics(),
                          //     itemBuilder: (context, index) => Container(
                          //           height: 280 / 6,
                          //           width: 280 / 6,
                          //           child: QuarterCircle(
                          //             circleAlignment: CircleAlignment.bottomLeft,
                          //             key: Key("1"),
                          //           ),
                          //         )

                          // Container(
                          //     height: 280,
                          //     width: 280,
                          //     child: Center(
                          //       child: Spinwheel(
                          //         size: 280,
                          //         items: choices[index][0] is String ? choices[index].cast<String>() : null,
                          //         select: select,
                          //         autoPlay: false,
                          //         hideOthers: false,
                          //         shouldDrawBorder: false,
                          //         wheelPaint: customPaint,
                          //         shouldDrawDividers: false,
                          //         wheelOrientation: pi / 4,
                          //         rotationDuration: 250,
                          //         shouldDrawCenterPiece: false,
                          //         onChanged: (val) {
                          //           if (this.mounted)
                          //             setState(() {
                          //               answers[index] = val;
                          //             });
                          //         },
                          //       ),
                          //     ))
                          // ),
                          // )
                        ),

                        // Column(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     SizedBox(
                        //       width: 280,
                        //       height: 280,
                        //       child: Stack(
                        //         children: [
                        //           Center(
                        //             child: SpinningWheel(
                        //               Image.asset('images/roulette/roulette.png'),
                        //               width: 310,
                        //               height: 310,
                        //               initialSpinAngle: _generateRandomAngle(),
                        //               spinResistance: 0.5,
                        //               canInteractWhileSpinning: false,
                        //               dividers: 6,
                        //               onUpdate: _dividerController.add,
                        //               onEnd: _dividerController.add,
                        //               shouldStartOrStop: _wheelNotifier.stream,
                        //             ),
                        //           ),
                        // SizedBox(height: 30),
                        // StreamBuilder(
                        //   stream: _dividerController.stream,
                        //   builder: (context, snapshot) =>
                        //       snapshot.hasData ? RouletteScore(int.parse(snapshot.data.toString())) : Container(),
                        // ),
                        // SizedBox(height: 30),
                        // new RaisedButton(
                        //   child: new Text("Start"),
                        //   onPressed: () =>
                        //       _wheelNotifier.sink.add(_generateRandomVelocity()),
                        // ),

                        // FortuneWheel(
                        //   selected: selected.stream,
                        //   //duration: Duration(seconds: 3),
                        //   items: List.generate(
                        //     widget.campaign?.length ?? 0,
                        //     (index) => FortuneItem(
                        //       child: RotatedBox(
                        //         quarterTurns: 1,
                        //         child: Text(
                        //           widget.campaign?[index].title ?? "",
                        //         ),
                        //       ),
                        //       style: FortuneItemStyle(
                        //         color: Colors.transparent,
                        //         borderColor: Colors.transparent,
                        //         textAlign: TextAlign.center,
                        //         textStyle: TextStyle(
                        //           color: CustomColor.black,
                        //           fontWeight: FontWeight.w900,
                        //           height: 1.0,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        //   onAnimationStart: () {
                        //     //widget.getRouletteResult();
                        //     _controller.forward();
                        //     _wheelNotifier.sink.add(_generateRandomVelocity());
                        //   },
                        //   onAnimationEnd: () {
                        //     WidgetsBinding.instance!.addPostFrameCallback((_) {
                        //       _controller.reset();
                        //     });
                        //     setState(() {
                        //       isRoulettePlayed = true;
                        //     });
                        //   },
                        // ),

                        //         ],
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // ),
                        // _buildCloseDialogButton(0),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          // ],
          // ),
          Positioned(
            top: (280 / 2) - 40,
            left: (280 / 2) - 30,
            child: Center(
              child: InkWell(
                onTap: () {
                  if (widget.userProfile == null) {
                    navigateToLogin();
                  } else if (widget.userProfile?.phone?.isEmpty ?? false) {
                    navigateToPhoneVerification();
                  } else {
                    setState(() {
                      // _controller.value = 4;
                      // math.Random r = math.Random();
                      // int number = Fortune.randomInt(0, items.length);
                      // double probability = items[number];
                      selectedValue = 2;
                      currentSelectValue = ((1 / 6) * selectedValue) * 2.0 * pi;
                      isClick = true;
                      print("currentpiValue2: ${double.parse(((_controller.value * 2.0 * pi)).toStringAsFixed(2))}");
                      print("currentpiValue3: ${(double.parse((currentSelectValue).toStringAsFixed(2)))}");
                      // selected.add(Fortune.randomInt(0, widget.campaign?.length ?? 0));
                    });
                  }
                },
                child: Image.asset(
                  'images/roulette/roulette_start.png',
                  width: 80,
                  height: 80,
                ),
              ),
            ),
          )
        ],
      ));

  _buildIsPlayedRouletteText() => Container(
        height: context.screenWidth / 2,
        width: context.screenWidth,
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
            image: DecorationImage(
              image: AssetImage("images/roulette/roulette_bg2.png"),
              fit: BoxFit.fill,
            )),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getTranslatedText("roulette_is_played_text_1"),
                    style: TextStyle(color: Colors.black, fontSize: 25.auto),
                  ),
                  Text(
                    getTranslatedText("roulette_is_played_text_2"),
                    style: TextStyle(color: Colors.black, fontSize: 20.auto),
                  ),
                  InkWell(
                    onTap: () => navigateToPromo(),
                    child: Text(
                      getTranslatedText("roulette_is_played_text_3"),
                      style: TextStyle(color: Colors.red, fontSize: 12.auto),
                    ),
                  )
                ],
              ),
            ),
            _buildCloseDialogButton(13.auto),
          ],
        ),
      );

  _buildCloseDialogButton(double position) => Positioned(
        top: position,
        right: position,
        child: InkWell(
          onTap: () => widget.onTapCloseIcon(),
          child: Container(
            height: 25,
            width: 25,
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100), border: Border.all(width: 2, color: Colors.black)),
            child: Icon(
              Icons.close,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
      );

  navigateToPromo() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(RoutePath.promotion);
    });
  }

  navigateToLogin() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(RoutePath.login);
    });
  }

  navigateToPhoneVerification() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(RoutePath.phoneVerification);
    });
  }
}

class RouletteScore extends StatelessWidget {
  final int selected;

  final Map<int, String> labels = {
    1: '1000\$',
    2: '400\$',
    3: '800\$',
    4: '7000\$',
    5: '5000\$',
    6: '300\$',
    // 7: '2000\$',
    // 8: '100\$',
  };

  RouletteScore(this.selected);

  @override
  Widget build(BuildContext context) {
    return Text('${labels[selected]}', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 24.0));
  }
}
