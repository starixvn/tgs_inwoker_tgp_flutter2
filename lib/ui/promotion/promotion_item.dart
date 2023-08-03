import 'package:api/NotificationServices/NotificationServiceName.dart';
import 'package:api/NotificationServices/notification_center.dart';
import 'package:api/entity/promotion.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_item_details.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_view_model.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:api/extension/format.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PromotionItem extends StatefulWidget {
  final Promotion promotion;
  final PromotionViewModel vm;
  final int index;

  PromotionItem({
    required this.promotion,
    required this.vm,
    required this.index,
  });

  @override
  _PromotionItemState createState() => _PromotionItemState();
}

class _PromotionItemState extends BaseState<PromotionItem> {
  var imageUrl;

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 11.auto, right: 11.auto, top: 10.auto),
      child: EnvironmentConfig.template_version == 10 || EnvironmentConfig.brandName == "SKY8" ? _buildPromotionT10() : _buildPromotion(),
    );
  }

  _buildPromotion() => InkWell(
        onTap: () => _navigateToDetails(),
        child: Container(
          margin: EdgeInsets.only(left: 11.auto, right: 11.auto, top: 10.auto),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildPromotionImage(),
          ),
        ),
      );


  _buildPromotionT10() => InkWell(
        onTap: () => _navigateToDetails(),
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          color: (EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode || EnvironmentConfig.brandName == "SKY8")
              ? CustomColor.theme_bg_color
              : Colors.white,
          elevation: 5,
          child: Column(
            children: [
              Container(
                width: context.screenWidth,
                child: _buildPromotionImage(),
              ),
              Container(
                height: 45.auto,
                padding: EdgeInsets.all(10.auto),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 17,
                      child: Container(
                        margin: EdgeInsets.only(right: 3.auto),
                        child: Text(
                          widget.promotion.name ?? "",
                          style: TextStyle(
                            color: (() {
                              if (EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode)
                                return CustomColor.theme_text_black_white_color;
                              else if (EnvironmentConfig.brandName == "SKY8")
                                return Colors.white;
                              else
                                return CustomColor.theme_text_black_color;
                            }()),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

  // _buildPromotionT10() => Card(
  //       semanticContainer: true,
  //       clipBehavior: Clip.antiAlias,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(20.0),
  //       ),
  //       color: EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode ? CustomColor.theme_bg_color : Colors.white,
  //       elevation: 5,
  //       child: Column(
  //         children: [
  //           Container(
  //             width: context.screenWidth,
  //             child: _buildPromotionImage(),
  //           ),
  //           Container(
  //             height: 45.auto,
  //             padding: EdgeInsets.all(10.auto),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Expanded(
  //                   flex: 17,
  //                   child: Container(
  //                     margin: EdgeInsets.only(right: 3.auto),
  //                     child: Text(
  //                       widget.promotion.name ?? "",
  //                       style: TextStyle(
  //                           color: EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode
  //                               ? CustomColor.theme_text_black_white_color
  //                               : CustomColor.theme_text_black_color),
  //                       overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: _buildDetailsButton(),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );

  _buildPromotionImage() {
    _getImageUrl();
    return imageUrl?.isEmpty ?? true
        ? _buildEmptyImage()
        : CachedNetworkImage(
            height: 150.auto,
            placeholder: (context, url) => _buildEmptyImage(),
            imageUrl: imageUrl,
            errorWidget: (context, url, error) => _buildEmptyImage(),
            //handling error
            fit: BoxFit.fill);
  }

  _buildDetailsButton() => Container(
        alignment: Alignment.center,
    decoration: BoxDecoration(
        border: Border.all(color: CustomColor.theme_button_color),
      borderRadius: BorderRadius.all(Radius.circular(10))
    ),
        /*width: width??context.screenWidth,
          height: 25.auto,*/
        child: SizedBox(
          width: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 1,
                child: AutoSizeText(
                  getTranslatedText("details"),
                  style: TextStyle(
                    color: EnvironmentConfig.brandName == "SKY8" ? Colors.white : CustomColor.theme_button_color,
                  ),
                  minFontSize: 14,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );

  // OutlineBorderButton(
  //   title: getTranslatedText("details"),
  //   onClick: () {},
  //   isEnabled: true,
  //   width: 60,
  //   height: 17,
  //   color: EnvironmentConfig.brandName == "SKY8" ? Colors.white : CustomColor.theme_button_color,
  //   fontSize: 14,
  //   radius: 10,
  //   padding: 4,
  // );

  _buildEmptyImage() => Container(
        height: 150.auto,
        color: EnvironmentConfig.template_version == 14 ? CustomColor.theme_bar_gradient_2 : CustomColor.very_light_pink_four,
      );

  _navigateToDetails() {
    Widget view = PromotionItemDetails(
      imagePath: imageUrl,
      promotion: widget.promotion,
      vm: widget.vm,
      index: widget.index,
    );
    if (EnvironmentConfig.template_version == 14) {
      NotificationCenter().notify(
        NotificationServiceName().showDialogViewToHome,
        data: {"view": view, "title": ""},
      );
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => view));
    }
  }

  _getImageUrl() {
    var language = getCurrentLanguage().apiCode ?? "en-US";
    if (widget.promotion.localization?[language]?.mobileBanner?.isNotEmpty ?? false) {
      imageUrl = widget.promotion.localization![language]?.mobileBanner;
    } else if (widget.promotion.mobileBanner?.isNotEmpty ?? false) {
      imageUrl = widget.promotion.mobileBanner;
    } else
      imageUrl = "";
  }
}
