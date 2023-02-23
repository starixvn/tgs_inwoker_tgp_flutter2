import 'dart:math';
import 'dart:ui';
import 'package:api/entity/promotion.dart';
import 'package:api/entity/promotion_roulette.dart';
import 'package:api/entity/roulette_history_record.dart';
import 'package:api/entity/roulette_prize.dart';
import 'package:api/entity/roulette_prize_details.dart';
import 'package:api/entity/user_profile.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:api/entity/campaign_details.dart';
import 'package:tgp_flutter2/ui/Wheel/fortune_wheel.dart';
import 'package:tgp_flutter2/ui/dialog/roulette_dialog.dart';
import 'package:tgp_flutter2/ui/home/home_view_model.dart';
import 'package:tgp_flutter2/ui/profile_info/phone/phone_verification.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_history.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_main_details.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_terms_content.dart';

class AnotherRouletteDialog extends StatefulWidget {
  final Function onTapCloseIcon;
  final UserProfile? userProfile;
  final bool isPlayed;
  final Promotion? contents;

  // final campaign;
  final HomeViewModel vm;
  final List<RouletteHistoryRecord>? rouletteHistoryList;
  final RoulettePrize? prize;
  final PromotionRoulette? promotionRoulette;

  AnotherRouletteDialog({
    required this.onTapCloseIcon,
    this.isPlayed = false,
    this.userProfile,
    required this.vm,
    this.contents,
    // this.campaign,
    this.rouletteHistoryList,
    this.prize,
    this.promotionRoulette,
  });

  @override
  _AnotherRouletteDialogState createState() => _AnotherRouletteDialogState();
}

class _AnotherRouletteDialogState extends BaseState<AnotherRouletteDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int selectedValue = 0;
  var currentSelectValue = 0.0;
  var isClick = false;
  late CurvedAnimation _animation;
  var isDisplayReward = false, isExpandedColumn = false;
  var buttonIndex = 0;
  var shownReward = false;
  var nomore = false;
  var preventClickMoreThanOnce = false;
  List<int> getSelectedPositionList = [];

  List<double> sectorRadians = [];
  double angle = 0;

  bool spinning = false;
  int spins = 0;

  late Animation<double> animation;

  @override
  void initState() {
    _initData();
    generateSectorRadians();
    // _controller = AnimationController(
    //   duration: const Duration(seconds: 1),
    //   vsync: this,
    // );
    // _animation = new CurvedAnimation(
    //   parent: _controller,
    //   curve: Curves.linear,
    // );

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600));

    Tween<double> tween = Tween(begin: 0, end: 1);

    CurvedAnimation curve = CurvedAnimation(parent: _controller, curve: Curves.decelerate);

    animation = tween.animate(curve);

    _controller.addListener(() {
      if (_controller.isCompleted) {
        if (!isDisplayReward) {
          setState(() {
            // to prevent reward dialog show more than once
            isDisplayReward = true;
          });
          _displayReward(context).then((value) {
            // spinning = false;
            isClick = false;
          });
        }
        Future.delayed(const Duration(seconds: 1), () {
          if (!shownReward) {
            shownReward = true;
          }
        });
      }
    });

    super.initState();
  }

  void generateSectorRadians() {
    if (widget.vm.prize != null &&
        widget.vm.prize!.rouletteItems != null &&
        widget.vm.prize!.rouletteItems!.length > 0) {
      //radian for 1 sector
      double sectorRadian = (2.0 * pi) / widget.vm.prize!.rouletteItems!.length;

      for (int i = 0; i < widget.vm.prize!.rouletteItems!.length; i++) {
        sectorRadians.add((i) * sectorRadian);
      }

      // descending list index except 0 for example [0,11,....,1]
      sectorRadians.sort((b, a) => a.compareTo(b));
      sectorRadians.removeWhere((item) => item == 0);
      sectorRadians.insert(0, 0.0);
    }
  }

  void spin() {
    double randomRadian = generateRandomRadianToSpinTo();
    angle = randomRadian;
    _controller.forward();
  }

  double generateRandomRadianToSpinTo() {
    return (2.0 * pi * widget.vm.prize!.rouletteItems!.length) + sectorRadians[selectedValue];
  }

  _initData() async {
    // await widget.vm.getDepositRouletteHistoryRecord(widget.promotionRoulette?.id ?? "");
  }

  // void animate() {
  //   _controller
  //     ..repeat()
  //     ..addListener(() async {
  //       var a = double.parse(((_controller.value * 2.0 * pi)).toStringAsFixed(2));
  //       var b = double.parse((currentSelectValue).toStringAsFixed(2));
  //       if (a == b && isClick) {
  //         _controller.stop();
  //         if (!isDisplayReward) {
  //           setState(() {
  //             // to prevent reward dialog show more than once
  //             isDisplayReward = true;
  //           });
  //           _displayReward(context).then((value) {
  //             isClick = false;
  //           });
  //         }
  //         Future.delayed(const Duration(seconds: 1), () {
  //           if (!shownReward) {
  //             shownReward = true;
  //           }
  //         });
  //       }
  //     });
  // }

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
        // if (widget.playcount == 0 || widget.playcount == null || nomore)
        //   return _buildIsPlayedRouletteText();
        // else
        return _buildRoulette();
      }()),
    );
  }

  _displayReward(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            content: _buildRewardText(),
          );
        });
  }

  List<FortuneWheelChild<int>> totalList() {
    List<FortuneWheelChild<int>> list = [];
    if (widget.vm.prize == null || widget.vm.prize!.rouletteItems == null) {
      list = [FortuneWheelChild(foreground: Text(""), value: 1), FortuneWheelChild(foreground: Text(""), value: 1)];
    } else {
      for (var i = 0; i < widget.vm.prize!.rouletteItems!.length; i++) {
        RoulettePrizeDetails createNewList = widget.vm.prize!.rouletteItems![i];
        if (getSelectedPositionList.length <= widget.vm.prize!.rouletteItems!.length) getSelectedPositionList.add(i);
        list.add(FortuneWheelChild(
          foreground: Text(
            //display title text
            createNewList.title ?? "",

            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: i % 2 == 0 ? Colors.black : Colors.white,
            ),
          ),
          value: 1,
        ));
      }
    }
    return list;
  }

  _buildRoulette() {
    var height = context.screenHeight / 3;
    int playCount = 0;
    for (int i = 0; i < widget.vm.rouletteCount.length; i++) {
      if (widget.vm.rouletteCount[i].id == widget.promotionRoulette?.id) {
        playCount = widget.promotionRoulette?.rouletteCount ?? 0;
      }
    }
    // int? playCount = widget.vm.rouletteCount.first.rouletteCount;
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
          width: context.screenWidth,
          height: isExpandedColumn ? height + 200.auto : height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
              bottomLeft: isExpandedColumn ? Radius.zero : Radius.circular(15),
              bottomRight: isExpandedColumn ? Radius.zero : Radius.circular(15),
            ),
            color: Colors.white,
          ),
          child: Stack(
            children: [
              ListView(
                shrinkWrap: true,
                primary: false,
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  Container(
                    width: context.screenWidth,
                    height: height,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("images/roulette/roulette_bg.png"),
                        fit: BoxFit.cover,
                      ),
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          // top:height/1.6,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          // bottom: -(height / 100),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            // color: Colors.green,
                            child: Image.asset(
                              "images/roulette/roulette_bottom.png",
                              height: (height / 3),
                              width: context.screenWidth / 2,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          bottom: height / 9.5,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 3.auto, horizontal: 50.auto),
                              decoration: BoxDecoration(color: Colors.black),
                              child: Text(
                                getTranslatedText("remaining_spin") +
                                    playCount.toString() +
                                    getTranslatedText("remaining_spin2"),
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.auto),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 10,
                              child: Stack(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(top: height / 30, bottom: 30),
                                    child: Stack(
                                      children: [
                                        AnimatedBuilder(
                                          animation: animation,
                                          builder: (BuildContext _, child) {
                                            return Transform.rotate(
                                              angle: _controller.value * angle,
                                              child: Stack(
                                                children: [
                                                  Center(
                                                    child: Image.asset(
                                                      'images/roulette/roulette12.png',
                                                      width: height - 20.auto,
                                                      height: height - 20.auto,
                                                    ),
                                                  ),
                                                  Center(
                                                    child: FortuneWheel<int>(
                                                      children: totalList(),
                                                      size: height - 45.auto,
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
                                              // if (preventClickMoreThanOnce) {
                                              // } else {
                                              //   _controller.reset();
                                              //   _controller.forward(from: 0.0);
                                              //
                                              //   Future.delayed(Duration(seconds: 1), () {
                                              //     setState(() {
                                              //       selectedValue = 1;
                                              //
                                              //       // //stored value for prize position
                                              //       // currentSelectValue = ((1 / getSelectedPositionList.length) *
                                              //       //         getSelectedPositionList[selectedValue]) *
                                              //       //     2.0 *
                                              //       //     pi;
                                              //       if (!isClick) spin();
                                              //       // spinning = true;
                                              //       isClick = true;
                                              //       isDisplayReward = false;
                                              //       preventClickMoreThanOnce = true;
                                              //     });
                                              //   });
                                              // }
                                              if (widget.userProfile == null) {
                                                navigateToLogin();
                                              } else if (preventClickMoreThanOnce) {
                                                // do nothing when it is true
                                              } else {
                                                _controller.forward(from: 0.0);
                                                setState(() {
                                                  preventClickMoreThanOnce = true;
                                                });
                                                await widget.vm
                                                    .getDepositRouletteResult(widget.promotionRoulette?.id ?? "")
                                                    .then((_apiState) {
                                                  shownReward = false;
                                                  if (_apiState.isSuccess) {
                                                    if (_apiState.result?.itemIndex == -1) {
                                                      setState(() {
                                                        nomore = true;
                                                      });
                                                    } else {
                                                      setState(() {
                                                        selectedValue = _apiState.result?.itemIndex ?? 0;

                                                        // //stored value for prize position
                                                        // currentSelectValue = ((1 / getSelectedPositionList.length) *
                                                        //         getSelectedPositionList[selectedValue]) *
                                                        //     2.0 *
                                                        //     pi;
                                                        if (!isClick) spin();
                                                        isClick = true;
                                                        isDisplayReward = false;
                                                        preventClickMoreThanOnce = true;
                                                      });
                                                    }
                                                  } else {
                                                    // for handling api return error
                                                    _controller.reset();
                                                  }
                                                });
                                              }
                                            },
                                            child: Image.asset(
                                              'images/roulette/roulette_start.png',
                                              width: height / 3.8,
                                              height: height / 3.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: playCount == 0 || playCount == null || nomore,
                                    child: Container(
                                      decoration: _buildGreyedOutBackground(),
                                      child: Center(
                                        child: Text(
                                          getTranslatedText("spin_run_out"),
                                          style: TextStyle(
                                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25.auto),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration: playCount == 0 || playCount == null || nomore
                                    ? _buildGreyedOutBackground()
                                    : BoxDecoration(),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildRoulettePromoButton(0, "roulette_promo_home"),
                                    _buildRoulettePromoButton(1, "roulette_promo_content"),
                                    _buildRoulettePromoButton(2, "roulette_promo_terms"),
                                    _buildRoulettePromoButton(3, "roulette_history"),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  isExpandedColumn ? _buildExpandedPromoContent() : Container(),
                ],
              ),
              _buildCloseDialogButton(10.auto),
            ],
          )),
    );
  }

  _buildRoulettePromoButton(int index, String title) => InkWell(
        onTap: () {
          setState(() {
            if (index == buttonIndex)
              isExpandedColumn = !isExpandedColumn;
            else
              isExpandedColumn = true;
            buttonIndex = index;
          });
        },
        child: Container(
          width: 50.auto,
          height: context.screenHeight / 2,
          alignment: Alignment.center,
          padding: EdgeInsets.all(3.auto),
          decoration: BoxDecoration(
            color: buttonIndex == index ? Color(0xffc79f58) : Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5.0),
              topRight: Radius.circular(5.0),
            ),
          ),
          child: AutoSizeText(
            getTranslatedText(title),
            textAlign: TextAlign.center,
            minFontSize: 5,
            maxFontSize: 12,
            stepGranularity: 1,
            maxLines: 1,
            style: TextStyle(
              color: buttonIndex == index ? Colors.black : Colors.white,
            ),
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
                  widget.vm.prize!.rouletteItems![selectedValue].title ?? "lose",
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
        padding: EdgeInsets.symmetric(horizontal: 10.auto),
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
                    getTranslatedText("dialogDARUnavailableTitle"),
                    style: TextStyle(color: Colors.black, fontSize: 23.auto),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    getTranslatedText("roulette_is_played_text_3"),
                    style: TextStyle(color: Colors.black, fontSize: 20.auto),
                    textAlign: TextAlign.center,
                  ),
                  InkWell(
                    onTap: () => navigateToPromo(),
                    child: Container(
                      height: 25.auto,
                      padding: EdgeInsets.only(top: 5.auto),
                      child: Text(
                        getTranslatedText("roulette_is_played_text_3"),
                        style: TextStyle(color: Colors.red, fontSize: 13.auto),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildCloseDialogButton(0),
          ],
        ),
      );

  _buildCloseDialogButton(double position) => Positioned(
        top: position,
        right: position,
        child: InkWell(
          onTap: () => position != 5.auto ? widget.onTapCloseIcon() : closeRewardClick(),
          child: Container(
            height: 25,
            width: 25,
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                width: 2,
                color: Colors.white,
              ),
              color: Colors.black,
            ),
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );

  _buildExpandedPromoContent() {
    return Container(
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
            return PromotionMainDetails(promotion: widget.contents);
          case 1:
            return PromotionTermsContent(
                termsContent:
                    ((widget.contents?.localization?[getCurrentLanguage().apiCode]?.content?.isNotEmpty ?? false)
                            ? widget.contents?.localization![getCurrentLanguage().apiCode]!.content!
                            : widget.contents?.content ?? "") ??
                        "");
          case 2:
            return PromotionTermsContent(termsContent: widget.contents?.terms ?? "");
          case 3:
            return PromotionHistory(
              historyList: widget.vm.rouletteHistoryList,
              prize: widget.vm.prize,
            );
          default:
            return Container();
        }
      }()),
    );
  }

  navigateToPromo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(RoutePath.promotion);
    });
  }

  closeRewardClick() {
    shownReward = false;
    setState(() {
      preventClickMoreThanOnce = false;
      // to prevent reward dialog show after roulette closed
      isDisplayReward = true;
      isClick = false;
    });
    Navigator.pop(context);
  }

  navigateToPhoneVerification() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Navigator.of(context).pushNamed(RoutePath.phoneVerification);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PhoneVerification(
                  isFromRouletteRoute: true,
                )),
      );
    });
  }

  _buildGreyedOutBackground() => BoxDecoration(
        color: Colors.black.withOpacity(0.75),
      );
}
