import 'package:api/entity/promotion.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter/scheduler.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_item_details.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_view_model.dart';

class PromotionDialog extends StatefulWidget {
  final List<Promotion> promotionList;
  final Function onClick;

  PromotionDialog({
    required this.promotionList,
    required this.onClick
  });

  @override
  _PromotionDialogState createState() => _PromotionDialogState();
}

class _PromotionDialogState extends BaseState<PromotionDialog> {
  PromotionViewModel vm = PromotionViewModel();

  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.screenHeight / 30,
        horizontal: context.screenWidth / 20,
      ),
      decoration: new BoxDecoration(
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
          Container(
            padding: EdgeInsets.only(bottom: 13.auto, left: 10.auto),
            alignment: Alignment.topLeft,
            child: Text(
              getTranslatedText("promotion_center"),
              style: TextStyle(
                fontSize: 18.auto,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Flexible(
            flex: 19,
            child: ScrollConfiguration(
              behavior: MyBehavior(),
              child: ListView(
                shrinkWrap: true,
                children: List.generate(widget.promotionList.length, (index) {
                  String imageUrl;
                  Promotion promo = widget.promotionList[index];
                  if (promo.localization?.mobileBanner?.isNotEmpty ?? false) {
                    imageUrl = promo.localization!.mobileBanner!;
                  } else if (promo.mobileBanner?.isNotEmpty ?? false) {
                    imageUrl = promo.mobileBanner!;
                  } else
                    imageUrl = "";
                  return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PromotionItemDetails(imagePath: imageUrl, promotion: promo, vm: vm)));
                      },
                      child: Container(height: 150.auto, child: _buildPromotionImage(imageUrl)));
                }).toList(),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 5.auto),
            height: 50.auto,
            child: _buildDoneButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionImage(String imageUrl) {
    return Container(
            margin: EdgeInsets.only(left: 11.auto, right: 11.auto, top: 10.auto),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.isEmpty
                  ? Container(
                color: CustomColor.very_light_pink_four,
              )
                  :  CachedNetworkImage(
                  height: 150.auto,
                  placeholder: (context, url) => Container(
                        width: 375,
                        height: 150.auto,
                        color: CustomColor.very_light_pink_four,
                      ),
                  imageUrl: imageUrl,
                  errorWidget: (context, url, error) => Container(
                        color: CustomColor.very_light_pink_four,
                      ),
                  //handling error
                  fit: BoxFit.fill),
            ),
          );
  }

  _buildDoneButton() => ColorButton(
        onClick: () {
          widget.onClick();
        },
        title: getTranslatedText("confirm"),
        isEnabled: true,
        radius: 45.auto,
        width: context.screenWidth / 3.5,
        height: context.screenHeight / 18,
      );
}
