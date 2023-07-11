import 'package:api/entity/promotion.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_view_model.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:api/extension/format.dart';

import '../../environment_config.dart';

class PromotionMainDetails extends StatefulWidget {
  final Promotion? promotion;

  PromotionMainDetails({
    required this.promotion,
  });

  @override
  _PromotionMainDetailsState createState() => _PromotionMainDetailsState();
}

class _PromotionMainDetailsState extends BaseState<PromotionMainDetails> {
  Widget build(BuildContext context) {
    var lists = widget.promotion?.vipLevels ?? [];

    List sortVip(List array) {
      return array..sort((a, b) => a.compareTo(b));
    }

    return widget.promotion != null
        ? ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Container(
                  margin: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 15.auto),
                  child: Text(
                    "【${getTranslatedText("promotion_condition")}】",
                    style: TextStyle(color: CustomColor.theme_button_color, fontSize: 14.auto),
                  )),
              _buildPromotionText("${getTranslatedText("promotion_person")}：\n VIP" + (sortVip(lists)).join(", VIP")),
              _buildPromotionText("${getTranslatedText("promotion_time")}：\n " +
                  Format().dateTimeFormat(widget.promotion?.from) +
                  " - " +
                  Format().dateTimeFormat(widget.promotion?.to)),
            ],
          )
        : Container();
  }

  _buildPromotionText(String displayText) => Container(
        margin: EdgeInsets.only(
          left: 10.auto,
          right: 10.auto,
          top: 15.auto,
        ),
        child: Text(
          displayText,
          style: TextStyle(
            fontSize: 13.auto,
            color: (EnvironmentConfig.template_version == 10 || EnvironmentConfig.template_version == 1) && EnvironmentConfig.dark_mode
                ? CustomColor.theme_text_black_white_color
                : CustomColor.theme_text_black_color,
          ),
        ),
      );
}
