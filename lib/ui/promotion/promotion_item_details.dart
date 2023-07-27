import 'package:api/entity/promotion.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_main_details.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_terms_content.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_view_model.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:api/extension/format.dart';

import '../../environment_config.dart';
import '../deposit/deposit.dart';
import 'T14/promotion_item_details_t14.dart';

class PromotionItemDetails extends StatefulWidget {
  final String imagePath;
  final Promotion promotion;
  final PromotionViewModel vm;
  final int index;

  PromotionItemDetails({
    required this.imagePath,
    required this.promotion,
    required this.vm,
    required this.index,
  });

  @override
  _PromotionItemDetailsState createState() => _PromotionItemDetailsState();
}

class _PromotionItemDetailsState extends BaseState<PromotionItemDetails> {
  Widget build(BuildContext context) {
    return EnvironmentConfig.template_version == 14
        ? PromotionItemDetailsT14(imagePath: widget.imagePath, promotion: widget.promotion, vm: widget.vm, index: widget.index,)
        : CustomScaffold(
            color: Colors.white,
            appBar: _buildAppBar(),
            body: Container(
              height: context.screenHeight,
              color: EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode ? CustomColor.theme_bg_color : Colors.white,
              child: ListView(
                shrinkWrap: true,
                children: [
                  _buildPromotionImage(),
                  PromotionMainDetails(promotion: widget.promotion),
                  PromotionTermsContent(
                      termsContent: (((widget.promotion.localization?[getCurrentLanguage().apiCode]?.content)?.isNotEmpty ?? false)
                          ? (widget.promotion.localization?[getCurrentLanguage().apiCode]?.content) ?? ""
                          : widget.promotion.content ?? "")),
                  PromotionTermsContent(termsContent: widget.promotion.terms ?? ""),
                  _buildJoinButton()
                ],
              ),
            ),
          );
  }

  _buildAppBar() => CustomAppBar(
        title: getTranslatedText("promotion_center"),
      );

  _buildJoinButton() => Visibility(
        visible: widget.promotion.promotionType != "Dummy",
        child: Container(
          margin: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 15.auto, bottom: 20.auto),
          child: ColorButton(
            title: getTranslatedText("join"),
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
    return widget.imagePath.isEmpty
        ? Container(
            height: 150.auto,
          )
        : CachedNetworkImage(
            height: 150.auto,
            placeholder: (context, url) => Container(
                  color: CustomColor.very_light_pink_four,
                ),
            imageUrl: widget.imagePath,
            //handling error
            errorWidget: (context, url, error) => Container(
                  color: CustomColor.very_light_pink_four,
                ),
            fit: BoxFit.fill);
  }

  _onClick() {
    if (widget.vm.userProfile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamed("/login");
      });
      return;
    } else if (widget.promotion.promotionType == "FirstDeposit" ||
        widget.promotion.promotionType == "DailySecondDeposit" ||
        widget.promotion.promotionType == "DailyFirstDeposit" ||
        widget.promotion.promotionType == "DepositAccumulateRoulette" ||
        widget.promotion.promotionType == "DepositReward") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Deposit(isNewPage: true)));
      });
    } else {
      ProgressDialog.show(context, widget.vm.brandLogoUrl);
      widget.vm.joinPromotion(widget.promotion.id ?? "");
    }
  }
}
