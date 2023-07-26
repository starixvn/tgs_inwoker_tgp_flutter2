import 'package:flutter/material.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_item.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_view_model.dart';
import 'package:api/extension/screen_apis.dart';

import '../../custom/custom_login_app_bar.dart';
import '../../globalUtil/GlobalValueUtil.dart';
import '../../route_path.dart';

class Promotion extends StatefulWidget {
  @override
  _PromotionState createState() => _PromotionState();
}

class _PromotionState extends BaseState<Promotion> {
  var height, width, ratio;
  var currentTabIndex = 0;
  var currentBottomIndex = 1;
  PromotionViewModel _vm = PromotionViewModel();
  BuildContext? key = GlobalKey().currentContext;
  var languageCode;

  @override
  void initState() {
    _vm.getPromotionList();
    GlobalValueUtil.pausesong();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<PromotionViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return  _buildPromotion();
          // return CustomScaffold(
          //   appBar: EnvironmentConfig.template_version == 14
          //       ? CustomLoginAppBar(
          //           onClickLoginButton: () => Navigator.of(context).pushNamed(RoutePath.login),
          //           onClickRegisterButton: () => Navigator.of(context).pushNamed(RoutePath.register),
          //           onClickLogoutButton: () {},
          //           isLogin: _vm.userProfile != null,
          //           // brandLogoUrl: _vm.brandLogoUrl,
          //           userProfile: _vm.userProfile,
          //           // config: _vm.config,
          //           // totalBalance: _vm.totalBalance,
          //           //_vm.totalBalance,
          //           // brandName: EnvironmentConfig.brandName,
          //           onClickBalance: () {},
          //           // onPauseMusic: () {},
          //           // onResumeMusic: () {},
          //           randomNumber: 0,
          //           // isShowMarquee: isShowMarquee,
          //           // marquee: _vm.announcement,
          //         )
          //       : CustomAppBar(
          //           title: getTranslatedText("promotion_center"),
          //         ),
          //   body:
          // );
        });
  }

  _buildPromotion() {
    var code = getCurrentLanguage().apiCode;
    if (code == "zh-CN" || code == "zh-TW")
      languageCode = code;
    else
      languageCode = "en-US";
    if (_vm.promotionList == null)
      return buildProgressDialog(_vm.brandLogoUrl);
    else if (_vm.promotionList.isEmpty) {
      return Container(
        margin: EdgeInsets.only(left: 11.auto, right: 11.auto, top: 10.auto),
        height: 150.auto,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                child: Image.asset(
                  "images/promotion/promo_empty${EnvironmentConfig.template_version == 8 ? "_t8_$languageCode" : ""}.png",
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Visibility(
              visible: EnvironmentConfig.template_version != 8,
              child: Container(
                margin: EdgeInsets.only(
                  left: 15.auto,
                  right: 15.auto,
                ),
                width: context.screenWidth / 2.3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGradientText(getTranslatedText("promotion_empty1")),
                    _buildGradientText(getTranslatedText("promotion_empty2")),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: context.screenHeight,
        color: EnvironmentConfig.template_version == 14 ? CustomColor.theme_bar_gradient_2 : Colors.transparent,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(bottom: 10.auto),
          children: List.generate(_vm.promotionList.length, (index) {
            return PromotionItem(
              promotion: _vm.promotionList[index],
              vm: _vm,
              index: index,
            );
          }),
        ),
      );
    }
  }

  _buildGradientText(String text) => ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: [
              Color(0xff446597),
              Color(0xff282828),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Offset.zero & bounds.size);
        },
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: context.screenWidth / 25, fontWeight: FontWeight.bold).copyWith(color: Colors.white),
        ),
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
    handleApiState(_vm.getPromotionListApiState, isAutoHideLoading: false, onSuccess: () {});
  }
}
