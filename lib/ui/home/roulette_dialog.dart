import 'dart:math';
import 'dart:ui';
import 'package:api/entity/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:api/entity/campaign_details.dart';
import 'package:tgp_flutter2/ui/Wheel/fortune_wheel.dart';
import 'package:tgp_flutter2/ui/home/home_view_model.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_main_details.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_terms_content.dart';

class RouletteDialog extends StatefulWidget {
  final Function onTapCloseIcon;
  final UserProfile? userProfile;
  final bool isPlayed;
  final List<CampaignDetails>? campaign;
  final HomeViewModel vm;

  RouletteDialog(
      {required this.onTapCloseIcon, this.isPlayed = false, this.userProfile, required this.vm, this.campaign});

  @override
  _RouletteDialogState createState() => _RouletteDialogState();
}

class _RouletteDialogState extends BaseState<RouletteDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int selectedValue = 0;
  var currentSelectValue = 0.0;
  var isClick = false;
  late CurvedAnimation _animation;
  var isDisplayReward = false, isExpandedColumn = false;
  var buttonIndex = 0;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1),
      vsync: this,
    );
    _animation = new CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
    super.initState();
  }

  void animate() {
    _controller
      ..repeat()
      ..addListener(() async {
        var a = double.parse(((_controller.value * 2.0 * pi)).toStringAsFixed(2));
        var b = double.parse((currentSelectValue).toStringAsFixed(2));
        if (a == b && isClick) {
          _controller.stop();
          setState(() {
            isDisplayReward = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      backgroundColor: Colors.transparent,
      child: (() {
        if (widget.isPlayed)
          return _buildIsPlayedRouletteText();
        else if (isDisplayReward)
          return _buildRewardText();
        else
          return _buildRoulette();
      }()),
    );
  }

  List<FortuneWheelChild<int>> totalList() {
    List<FortuneWheelChild<int>> list = [];
    if (widget.campaign == null) {
      list = [FortuneWheelChild(foreground: Text(""), value: 1), FortuneWheelChild(foreground: Text(""), value: 1)];
    } else {
      for (var i = 0; i < widget.campaign!.length; i++) {

        list.add(FortuneWheelChild(
          foreground: Text(
            widget.campaign?[i].title ?? "",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          value: 1,
        ));
      }
    }
    return list;
  }

  _buildRoulette() => Container(

      width: context.screenWidth,
      height: isExpandedColumn ? context.screenWidth / 1.2 + 200.auto : context.screenWidth / 1.2,
      decoration: BoxDecoration(
        // color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15),

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

          ListView(
            // mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: context.screenWidth,
                height: context.screenWidth / 1.2,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/roulette/roulette_bg.png"),
                    fit: BoxFit.cover,
                  ),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: isExpandedColumn ? Radius.zero : Radius.circular(15),
                    bottomRight: isExpandedColumn ? Radius.zero : Radius.circular(15),
                  ),
                ),
                padding: EdgeInsets.only(
                  top: context.screenWidth / 30,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 300,
                      height: 300,
                      child: Stack(
                        children: [
                          AnimatedBuilder(
                            animation: _animation,
                            builder: (BuildContext _, child) {
                              return Transform.rotate(
                                angle: _controller.value * 2.0 * pi,
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Image.asset(
                                        'images/roulette/roulette.png',
                                      ),
                                    ),
                                    Center(
                                      child: FortuneWheel<int>(
                                        children: totalList(),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Center(
                            child: InkWell(
                              onTap: () async {
                                if (widget.userProfile == null) {
                                  navigateToLogin();
                                } else if (widget.userProfile?.phone?.isEmpty ?? false) {
                                  navigateToPhoneVerification();
                                } else {
                                  animate();
                                  await widget.vm.getRouletteResult().then((_apiState) {
                                    if (_apiState.isSuccess) {
                                      setState(() {
                                        selectedValue = widget.vm.rotatedResultId ?? 0;
                                        currentSelectValue = ((1 / 6) * selectedValue) * 2.0 * pi;
                                        isClick = true;
                                      });
                                    } else {
                                      // for handling api return error
                                      _controller.reset();
                                    }
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
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildRoulettePromoButton(0, "roulette_promo_home"),
                        _buildRoulettePromoButton(1, "roulette_promo_content"),
                        _buildRoulettePromoButton(2, "roulette_promo_terms"),
                      ],
                    ),
                  ],
                ),

              ),
              _buildExpandedPromoContent(),
            ],
          ),
          _buildCloseDialogButton(10.auto),
        ],
      ));

  _buildRoulettePromoButton(int index, String title) => InkWell(
        onTap: () {
          setState(() {
            isExpandedColumn = true;
            buttonIndex = index;
          });
        },
        child: Container(
          width: 70.auto,
          height: 30.auto,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: buttonIndex == index ? Color(0xffc79f58) : Color(0xffece6d1).withOpacity(0.4),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Text(
            getTranslatedText(title),
            textAlign: TextAlign.center,
          ),
        ),
      );

  _buildRewardText() {
    return Container(
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
      padding: EdgeInsets.symmetric(horizontal: 10.auto),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  //  margin: EdgeInsets.symmetric(horizontal: 20.auto),
                  child: Text(
                    getTranslatedText("roulette_reward"),
                    style: TextStyle(color: Colors.black, fontSize: 25.auto),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  widget.campaign?[selectedValue].title ?? "lose",
                  style: TextStyle(color: Colors.black, fontSize: 20.auto),
                ),
              ],
            ),
          ),
          _buildCloseDialogButton(5.auto),
        ],
      ),
    );
  }

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

  _buildExpandedPromoContent() => Container(
        height: 200.auto,
        width: context.screenWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
          color: Color(0xfffffded),
        ),
        child: (() {
          switch (buttonIndex) {
            case 0:
              return PromotionMainDetails(promotion: widget.vm.roulettePromo);
            case 1:
              return PromotionTermsContent(
                  termsContent: ((widget.vm.roulettePromo?.localization?.content?.isNotEmpty ?? false)
                          ? widget.vm.roulettePromo?.localization?.content
                          : widget.vm.roulettePromo?.content ?? "") ??
                      "");
            case 2:
              return PromotionTermsContent(termsContent: widget.vm.roulettePromo?.terms ?? "");
            default:
              return Container();
          }
        }()),
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
