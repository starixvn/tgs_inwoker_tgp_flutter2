import 'package:api/entity/promotion.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/route_path.dart';
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
          _buildPromotionImage(),
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
          _buildPromotionContentText(
              parseHtmlString(widget.promotion.content ?? widget.promotion.localization.content)),
          _buildPromotionTermsText(widget.promotion.terms),
          _buildJoinButton()
        ],
      ),
    );
  }

  _buildAppBar() => CustomAppBar(
        title: getTranslatedText("promotion_center"),
      );

  _buildJoinButton() => Container(
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
      );

  _buildPromotionImage() {
    var imageUrl;
    if (widget.promotion.localization?.mobileBanner?.isNotEmpty ?? "") {
      imageUrl = widget.promotion.localization.mobileBanner;
    } else if (widget.promotion.mobileBanner?.isNotEmpty ?? "") {
      imageUrl = widget.promotion.mobileBanner;
    } else
      imageUrl = "";
    return imageUrl.isEmpty
        ? Container()
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
            fit: BoxFit.fill);
  }

  _onClick() {
    if (widget.vm.userProfile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamed("/login");
      });
      return;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamed(RoutePath.deposit);
      });
    }
  }

  _buildPromotionText(String displayText) => Container(
        margin: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 15.auto),
        child: Text(displayText),
      );

  _buildPromotionContentText(String displayText) => Container(
        margin: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 15.auto),
        child: Text(
          displayText,
          style: TextStyle(color: CustomColor.theme_text_black_white_color),
        ),
      );

  _buildPromotionTermsText(String displayText) => Container(
        margin: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 15.auto),
        child: RichText(
            text: HTML.toTextSpan(
          context,
          displayText ?? "",
          defaultTextStyle: TextStyle(fontSize: 12.auto),
          overrideStyle: <String, TextStyle>{
            'p': TextStyle(fontSize: 15.auto),
            'span': TextStyle(fontSize: 15.auto),
          },
        )),
      );

  _getPromotionTitleName() {
    if (widget.promotion.localization == null || widget.promotion.localization.name.isEmpty)
      return widget.promotion.name;
    else
      return widget.promotion.localization.name;
  }
}
