import 'package:api/entity/promotion.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_item_details.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_view_model.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:api/extension/format.dart';

class PromotionItem extends StatefulWidget {
  final String imagePath;
  final Promotion promotion;
  final PromotionViewModel vm;

  PromotionItem({Key key, this.imagePath, this.promotion, this.vm}) : super(key: key);

  @override
  _PromotionItemState createState() => _PromotionItemState();
}

class _PromotionItemState extends BaseState<PromotionItem> {
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PromotionItemDetails(imagePath: widget.imagePath, promotion: widget.promotion, vm: widget.vm)));
      },
      child: Container(
              margin: EdgeInsets.only(left: 11.auto, right: 11.auto, top: 10.auto), child: _buildPromotionImage()),
    );
  }

  _buildPromotionImage() {
    var imageUrl;
    if(widget.promotion.localization?.mobileBanner?.isNotEmpty ?? "" ){
      imageUrl = widget.promotion.localization.mobileBanner;
    }else if(widget.promotion.mobileBanner?.isNotEmpty ?? ""){
      imageUrl = widget.promotion.mobileBanner;
    }else imageUrl = "";
    print(imageUrl);
    return imageUrl.isEmpty
        ? Container(
            color: CustomColor.very_light_pink_four,
          )
        : Container(
            margin: EdgeInsets.only(left: 11.auto, right: 11.auto, top: 10.auto),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                          width: 375,
                          height: 183,
                          color: CustomColor.very_light_pink_four,
                        ),
                    imageUrl: imageUrl,
                    errorWidget: (context, url, error) => Container(
                          color: CustomColor.very_light_pink_four,
                        ),
                    //handling error
                    fit: BoxFit.fill)),
          );
  }

  _getPromotionTitleName() {
    if (widget.promotion.localization.name != null)
      return widget.promotion.localization.name;
    else
      return widget.promotion.name;
  }
}
