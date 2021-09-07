import 'package:api/entity/promotion.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_view_model.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:api/extension/format.dart';

class PromotionItemDetails extends StatefulWidget {
  final String imagePath;
  final Promotion promotion;
  final PromotionViewModel vm;

  PromotionItemDetails({Key key, this.imagePath, this.promotion, this.vm}) : super(key: key);

  @override
  _PromotionItemDetailsState createState() => _PromotionItemDetailsState();
}

class _PromotionItemDetailsState extends BaseState<PromotionItemDetails> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: ListView(
        children: [
          /*Stack(
            children: [*/
          widget.promotion.localization?.mobileBanner == null && widget.promotion.mobileBanner == null
              ? Container()
              : CachedNetworkImage(
                  placeholder: (context, url) => Container(
                        color: CustomColor.very_light_pink_four,
                      ),
                  imageUrl: widget.promotion.localization.mobileBanner,
                  //handling error
                  fit: BoxFit.fill),
          Container(
              margin: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 15.auto),
              child: Text(
                "【${getTranslatedText("promotion_condition")}】",
                style: TextStyle(color: CustomColor.theme_button_color, fontSize: 14.auto, fontWeight: FontWeight.bold),
              )),
          _buildPromotionText(
              "${getTranslatedText("promotion_person")}：\n VIP" + widget.promotion.vipLevels.join(", VIP")),
          _buildPromotionText("${getTranslatedText("promotion_time")}：\n " +
              Format().dateTimeFormat(widget.promotion.from) +
              " - " +
              Format().dateTimeFormat(widget.promotion.to)),
          _buildPromotionText(parseHtmlString(widget.promotion.localization.content)),
          _buildJoinButton()
        ],
      ),
    );
  }

  _buildAppBar() => CustomAppBar(
        title: getTranslatedText("promotion_center"),
      );

  _buildJoinButton() => Container(
        margin: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 15.auto),
        child: ColorButton(
          title: getTranslatedText("join"),
          onClick: () {
            _onClick();
          },
          isEnabled: true,
          color: CustomColor.theme_button_color,
          radius: 9.6,
        ),
      );

  _onClick() {
    if (widget.vm.userProfile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamed("/login");
      });
      return;
    }
    ProgressDialog.show(context);
    widget.vm.joinPromotion(widget.promotion.id);
  }

  _buildPromotionText(String displayText) => Container(
        margin: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 15.auto),
        child: Text(displayText),
      );

  _getPromotionTitleName() {
    if (widget.promotion.localization == null || widget.promotion.localization.name.isEmpty)
      return widget.promotion.name;
    else
      return widget.promotion.localization.name;
  }
}
