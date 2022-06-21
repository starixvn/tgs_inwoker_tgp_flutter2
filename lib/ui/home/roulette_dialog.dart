import 'dart:async';
import 'dart:ui';
import 'package:api/entity/user_profile.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/fortune_wheel/core/core.dart';
import 'package:tgp_flutter2/custom/fortune_wheel/wheel/wheel.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:api/entity/campaign_details.dart';

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
  final selected = BehaviorSubject<int>();
  var isRoulettePlayed;
  final StreamController _dividerController = StreamController<int>();

  @override
  void initState() {
    isRoulettePlayed = widget.isPlayed;
    // if (widget.campaign != null && widget.campaign!.length < 8) {
    //   // to fix fortune item length in 8
    //   for (var i = widget.campaign!.length; i < 8; i++) {
    //     widget.campaign!.add(new CampaignDetails("", "", 0));
    //   }
    // }
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: Stack(
                          children: [
                            Center(
                              child:
                              FortuneWheel(
                                selected: selected.stream,
                                //duration: Duration(seconds: 3),
                                items: List.generate(
                                  widget.campaign?.length ?? 0,
                                  (index) => FortuneItem(
                                    child: RotatedBox(
                                      quarterTurns: 1,
                                      child: Text(
                                        widget.campaign?[index].title ?? "",
                                      ),
                                    ),
                                    style: FortuneItemStyle(
                                      color: Colors.transparent,
                                      borderColor: Colors.transparent,
                                      textAlign: TextAlign.center,
                                      textStyle: TextStyle(
                                        color: CustomColor.black,
                                        fontWeight: FontWeight.w900,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                                onAnimationStart: () {
                                  //widget.getRouletteResult();
                                  _controller.forward();
                                },
                                onAnimationEnd: () {
                                  WidgetsBinding.instance!.addPostFrameCallback((_) {
                                    _controller.reset();
                                  });
                                  setState(() {
                                    isRoulettePlayed = true;
                                  });
                                },
                              ),
                            ),
                            Center(
                              child: InkWell(
                                onTap: () {
                                  if (widget.userProfile == null) {
                                    navigateToLogin();
                                  } else if (widget.userProfile?.phone?.isEmpty ?? false) {
                                    navigateToPhoneVerification();
                                  } else {
                                    setState(() {
                                      // math.Random r = math.Random();
                                      // int number = Fortune.randomInt(0, items.length);
                                      // double probability = items[number];
                                      selected.add(Fortune.randomInt(0, widget.campaign?.length ?? 0));
                                    });
                                  }
                                },
                                child: Image.asset(
                                  'images/roulette/roulette_start.png',
                                  width: 80,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCloseDialogButton(0),
              ],
            ),
          ],
        ),
      );

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
