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

class PromotionTermsContent extends StatefulWidget {
  final String termsContent;

  PromotionTermsContent({
    required this.termsContent,
  });

  @override
  _PromotionTermsContentState createState() => _PromotionTermsContentState();
}

class _PromotionTermsContentState extends BaseState<PromotionTermsContent> {

  Widget build(BuildContext context) {
    print(widget.termsContent);
    return Container(
      margin: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 15.auto),
      child: Html(
        data: """<style>tr{ border: 1px solid; } </style>""" + (widget.termsContent),
      ),
    );
  }
}
