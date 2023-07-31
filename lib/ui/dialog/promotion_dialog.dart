import 'package:api/NotificationServices/NotificationServiceName.dart';
import 'package:api/NotificationServices/notification_center.dart';
import 'package:api/entity/promotion.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter/scheduler.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_item_details.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_view_model.dart';

import '../promotion/T14/promotion_item_details_t14.dart';

class PromotionDialog extends StatefulWidget {
  final List<Promotion> promotionList;
  final Function onClick;

  PromotionDialog({required this.promotionList, required this.onClick});

  @override
  _PromotionDialogState createState() => _PromotionDialogState();
}

class _PromotionDialogState extends BaseState<PromotionDialog> {
  PromotionViewModel _vm = PromotionViewModel();

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onClick();
    });
    super.dispose();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<PromotionViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            backgroundColor: Colors.transparent,
            child: dialogContent(context),
          );
        });
  }

  dialogContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.screenHeight / 30,
        horizontal: context.screenWidth / 20,
      ),
      decoration: new BoxDecoration(
        color: EnvironmentConfig.template_version == 14 ? CustomColor.theme_bar_gradient_1 : Colors.white,
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
            alignment: EnvironmentConfig.template_version == 14 ? Alignment.center : Alignment.topLeft,
            child: Text(
              getTranslatedText("promotion_center"),
              style: TextStyle(fontSize: 18.auto, fontWeight: FontWeight.w500, color: EnvironmentConfig.template_version == 14 ? Colors.white : Colors.black),
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
                  if (promo.localization?[getCurrentLanguage().apiCode]?.mobileBanner?.isNotEmpty ?? false) {
                    imageUrl = promo.localization![getCurrentLanguage().apiCode]!.mobileBanner!;
                  } else if (promo.mobileBanner?.isNotEmpty ?? false) {
                    imageUrl = promo.mobileBanner!;
                  } else
                    imageUrl = "";
                  return InkWell(
                      onTap: () {
                        Widget view = PromotionItemDetails(
                          imagePath: imageUrl,
                          promotion: promo,
                          vm: _vm,
                          index: index,
                        );
                        if (EnvironmentConfig.template_version == 14) {
                          Navigator.pop(context);
                          NotificationCenter().notify(
                            NotificationServiceName().showDialogViewToHome,
                            data: {"view": view, "title": ""},
                          );
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => view));
                        }
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => PromotionItemDetails(
                        //               imagePath: imageUrl,
                        //               promotion: promo,
                        //               vm: _vm,
                        //               index: index,
                        //             )));
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
            : CachedNetworkImage(
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

  _handleApiState() {
    handleApiState(_vm.joinPromotionApiState, onSuccess: () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
            title: null,
            description: getTranslatedText("join_success"),
            buttonText1: getTranslatedText("confirm"),
            onClick: () {
              Navigator.pop(
                context,
              );
            },
          ),
        );
      });
    }, onError: (errorMsg) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
            title: null,
            description: getTranslatedText("promotion_joined"),
            buttonText1: getTranslatedText("confirm"),
            onClick: () {
              Navigator.pop(
                context,
              );
            },
          ),
        );
      });
    });
  }
}
