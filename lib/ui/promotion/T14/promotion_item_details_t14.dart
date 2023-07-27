import 'package:api/entity/promotion.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/globalUtil/GlobalValueUtil.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_main_details.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_terms_content.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_view_model.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:api/extension/format.dart';

import '../../../custom/custom_login_app_bar.dart';
import '../../../environment_config.dart';
import '../../deposit/deposit.dart';
import '../../home/end_drawer_menu.dart';

class PromotionItemDetailsT14 extends StatefulWidget {
  final String imagePath;
  final Promotion promotion;
  final PromotionViewModel vm;
  final int index;

  PromotionItemDetailsT14({
    required this.imagePath,
    required this.promotion,
    required this.vm,
    required this.index,
  });

  @override
  _PromotionItemDetailsT14State createState() => _PromotionItemDetailsT14State();
}

class _PromotionItemDetailsT14State extends BaseState<PromotionItemDetailsT14> {
  bool isExpanded = false;
  int currIndex = 0;

  late Promotion currPromotion;

  @override
  void initState() {
    currIndex = widget.index;
    if (widget.vm.promotionList == null) {
      currPromotion = widget.promotion;
      widget.vm.getPromotionList();
    } else
      currPromotion = widget.vm.promotionList[currIndex];
    super.initState();
  }

  Widget build(BuildContext context) {
    return Container(
      height: context.screenHeight,
      color: CustomColor.theme_bar_gradient_2,
      padding: EdgeInsets.symmetric(horizontal: 10.auto),
      child: ListView(
        shrinkWrap: true,
        children: [
          Container(
            height: 50.auto,
            // padding: EdgeInsets.all(10.auto),
            child: Row(
              children: [
                Expanded(
                  flex: 0,
                  child: InkWell(
                    onTap: () => setState(() {
                      if (currIndex == 0)
                        currIndex = widget.vm.promotionList.length - 1;
                      else
                        currIndex--;
                      currPromotion = widget.vm.promotionList[currIndex];
                    }),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: GlobalValueUtil.calculateTextSize(
                      text: currPromotion.name ?? "",
                      style: TextStyle(fontSize: 16.auto),
                      context: context,
                    ).height,
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: Text(
                        currPromotion.name ?? "",
                        style: TextStyle(color: Colors.white, fontSize: 16.auto),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 0,
                  child: InkWell(
                    onTap: () => setState(() {
                      if (currIndex == widget.vm.promotionList.length - 1)
                        currIndex = 0;
                      else
                        currIndex++;
                      currPromotion = widget.vm.promotionList[currIndex];
                    }),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildPromotionImage(),
          SizedBox(height: 10.auto),
          Container(
            height: GlobalValueUtil.calculateTextSize(
              text: currPromotion.name ?? "",
              style: TextStyle(fontSize: 16.auto),
              context: context,
            ).height,
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: Text(
                currPromotion.name ?? "",
                style: TextStyle(color: Colors.white, fontSize: 16.auto),
              ),
            ),
          ),
          SizedBox(height: 10.auto),
          Container(
            padding: EdgeInsets.all(10.auto),
            margin: EdgeInsets.symmetric(horizontal: 10.auto),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color(0xff0e0f1a),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Html(
                    data: """<style>tr{ border: 1px solid; } </style>""" +
                        (((currPromotion.localization?[getCurrentLanguage().apiCode]?.content)?.isNotEmpty ?? false)
                            ? (currPromotion.localization?[getCurrentLanguage().apiCode]?.content) ?? ""
                            : currPromotion.content ?? ""),
                    style: {
                      'body': Style(
                        fontSize: FontSize(11.auto),
                        color: Colors.white,
                      )
                    },
                  ),
                ),
                SizedBox(height: 10.auto),
                Container(
                  child: Text(
                    "${getTranslatedText("promotion_time")}：\n " +
                        Format().dateTimeFormat(currPromotion.from) +
                        " - " +
                        Format().dateTimeFormat(currPromotion.to),
                    style: TextStyle(
                      fontSize: 11.auto,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 10.auto),
          if (currPromotion.terms?.isNotEmpty ?? false)
            Row(
              children: [
                InkWell(
                  onTap: () => setState(() {
                    isExpanded = !isExpanded;
                  }),
                  child: Icon(
                    isExpanded ? Icons.remove : Icons.add,
                    color: CustomColor.theme_button_color,
                  ),
                ),
                Text(
                  "Terms and conditions",
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          if (isExpanded)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Html(
                data: """<style>tr{ border: 1px solid; } </style>""" + (currPromotion.terms ?? ""),
                style: {
                  'body': Style(
                    fontSize: FontSize(13.auto),
                    color: EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode
                        ? CustomColor.theme_text_black_white_color
                        : CustomColor.theme_text_black_color,
                  )
                },
              ),
            ),
          _buildJoinButton()
        ],
      ),
    );
  }

  _buildAppBar() => CustomLoginAppBar(
        onClickLoginButton: () => Navigator.of(context).pushNamed(RoutePath.login),
        onClickRegisterButton: () => Navigator.of(context).pushNamed(RoutePath.register),
        onClickLogoutButton: () {},
        isLogin: widget.vm.userProfile != null,
        // brandLogoUrl: _vm.brandLogoUrl,
        userProfile: widget.vm.userProfile,
        // config: _vm.config,
        // totalBalance: _vm.totalBalance,
        //_vm.totalBalance,
        // brandName: EnvironmentConfig.brandName,
        onClickBalance: () {},
        // onPauseMusic: () {},
        // onResumeMusic: () {},
        randomNumber: 0,
        isShowBarrier: false,
        // isShowMarquee: isShowMarquee,
        // marquee: _vm.announcement,
      );

  _buildJoinButton() => Visibility(
        visible: currPromotion.promotionType != "Dummy",
        child: Container(
          margin: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 15.auto, bottom: 20.auto),
          child: ColorButton(
            title: "Claim Bonus",
            onClick: () {
              _onClick();
            },
            isEnabled: true,
            color: CustomColor.theme_button_color,
            radius: 9.6,
          ),
        ),
      );

  _buildPromotionImage() {
    String imageUrl;
    if (currPromotion.localization?[getCurrentLanguage().apiCode]?.mobileBanner?.isNotEmpty ?? false) {
      imageUrl = currPromotion.localization![getCurrentLanguage().apiCode]!.mobileBanner!;
    } else if (currPromotion.mobileBanner?.isNotEmpty ?? false) {
      imageUrl = currPromotion.mobileBanner!;
    } else
      imageUrl = "";
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: imageUrl.isEmpty
            ? Container(
                height: 150.auto,
              )
            : CachedNetworkImage(
                height: 150.auto,
                placeholder: (context, url) => Container(
                  color: CustomColor.very_light_pink_four,
                ),
                imageUrl: imageUrl,
                //handling error
                errorWidget: (context, url, error) => Container(
                  color: CustomColor.very_light_pink_four,
                ),
                fit: BoxFit.fill,
              ),
      ),
    );
  }

  _onClick() {
    if (widget.vm.userProfile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamed("/login");
      });
      return;
    } else if (currPromotion.promotionType == "FirstDeposit" ||
        currPromotion.promotionType == "DailySecondDeposit" ||
        currPromotion.promotionType == "DailyFirstDeposit" ||
        currPromotion.promotionType == "DepositAccumulateRoulette" ||
        currPromotion.promotionType == "DepositReward") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Deposit(isNewPage: true)));
      });
    } else {
      ProgressDialog.show(context, widget.vm.brandLogoUrl);
      widget.vm.joinPromotion(currPromotion.id ?? "");
    }
  }
}
