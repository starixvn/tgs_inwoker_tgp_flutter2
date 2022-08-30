import 'dart:math';
import 'dart:ui';
import 'package:api/entity/user_profile.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:api/entity/campaign_details.dart';
import 'package:tgp_flutter2/ui/Wheel/fortune_wheel.dart';
import 'package:tgp_flutter2/ui/home/home_view_model.dart';
import 'package:tgp_flutter2/ui/profile_info/phone/phone_verification.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_main_details.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_terms_content.dart';

class RouletteDialog extends StatefulWidget {
  final Function onTapCloseIcon;
  final UserProfile? userProfile;
  final bool isPlayed;
  final List<CampaignDetails>? campaign;
  final HomeViewModel vm;
  final bool isDepositRoulette;
  final String? depositRouletteId;

//  final int rouletteCount;

  RouletteDialog({
    required this.onTapCloseIcon,
    this.isPlayed = false,
    this.userProfile,
    required this.vm,
    this.campaign,
    this.isDepositRoulette = false,
    this.depositRouletteId,
  });

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
      duration: const Duration(seconds: 1),
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
          Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              isDisplayReward = true;
            });
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
                    padding: EdgeInsets.only(
                      top: height / 30,
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          bottom: -8,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Image.asset(
                              "images/roulette/roulette_bottom.png",
                              height: height / 3.5,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 9,
                              child: Container(
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
                                                  width: height - 20.auto,
                                                  height: height - 20.auto,
                                                ),
                                              ),
                                              Center(
                                                child: FortuneWheel<int>(
                                                  children: totalList(),
                                                  size: height - 25.auto,
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
                                          } else if ((widget.vm.config?.promoRouletteSMSVerification ?? false) &&
                                              (widget.userProfile?.phone?.isEmpty ?? true)) {
                                            navigateToPhoneVerification();
                                          } else {
                                            animate();

                                            if (!widget.isDepositRoulette) {
                                              await widget.vm.getRouletteResult().then((_apiState) {
                                                if (_apiState.isSuccess) {
                                                  setState(() {
                                                    selectedValue = widget.vm.rotatedResultId ?? 0;
                                                    // to fix controller animate in different direction but except 0
                                                    var list = [0, 5, 4, 3, 2, 1];
                                                    currentSelectValue = ((1 / 6) * list[selectedValue]) * 2.0 * pi;
                                                    isClick = true;
                                                  });
                                                } else {
                                                  // for handling api return error
                                                  _controller.reset();
                                                }
                                              });
                                            } else {
                                              await widget.vm
                                                  .getDepositRouletteResult(widget.depositRouletteId ?? "")
                                                  .then((_apiState) {
                                                if (_apiState.isSuccess) {
                                                  setState(() {
                                                    selectedValue = widget.vm.depositRotatedResultId ?? 0;
                                                    // to fix controller animate in different direction but except 0
                                                    var list = [0, 5, 4, 3, 2, 1];
                                                    currentSelectValue = ((1 / 6) * list[selectedValue]) * 2.0 * pi;
                                                    isClick = true;
                                                  });
                                                } else {
                                                  // for handling api return error
                                                  _controller.reset();
                                                }
                                              });
                                            }
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
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildRoulettePromoButton(0, "roulette_promo_home"),
                                  _buildRoulettePromoButton(1, "roulette_promo_content"),
                                  _buildRoulettePromoButton(2, "roulette_promo_terms"),
                                ],
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
          width: 70.auto,
          height: context.screenHeight / 10,
          alignment: Alignment.center,
          padding: EdgeInsets.all(3.auto),
          color: buttonIndex == index ? Color(0xffc79f58) : Colors.black,
          child: AutoSizeText(
            getTranslatedText(title),
            textAlign: TextAlign.center,
            minFontSize: 5,
            maxFontSize: 14,
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
                    getTranslatedText("roulette_is_played_text_1"),
                    style: TextStyle(color: Colors.black, fontSize: 23.auto),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    getTranslatedText("roulette_is_played_text_2"),
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
          onTap: () => widget.onTapCloseIcon(),
          child: Container(
            height: 25,
            width: 25,
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                width: 2,
                color: !(widget.isPlayed || isDisplayReward) ? Colors.white : Colors.black,
              ),
              color: !(widget.isPlayed || isDisplayReward) ? Colors.black : Colors.transparent,
            ),
            child: Icon(
              Icons.close,
              color: !(widget.isPlayed || isDisplayReward) ? Colors.white : Colors.black,
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
                  termsContent:
                      ((widget.vm.roulettePromo?.localization?[getCurrentLanguage().apiCode]?.content?.isNotEmpty ??
                                  false)
                              ? widget.vm.roulettePromo?.localization![getCurrentLanguage().apiCode]!.content!
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(RoutePath.promotion);
    });
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
}
