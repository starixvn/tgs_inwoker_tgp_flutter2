import 'dart:io';

import 'package:api/entity/game_provider2.dart';
import 'package:api/entity/game_type.dart';
import 'package:api/entity/language.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:api/api.dart';
import 'package:api/localizations/language_provider.dart';
import 'package:api/network/event_result.dart';
import 'package:html/parser.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/maintenance/maintenance.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();

  get config => contentRepo.featuresConfig;

  get apiError => userRepo.apiError;

  getTranslatedText(String? key, {bool isByBrand = false}) => LanguageProvider.getSingleton().getTranslated(context, key, isByBrand: isByBrand);

  handleApiState(
    EventResult? eventResult, {
    required Function onSuccess,
    Function? onError,
    bool isAutoHideLoading = true,
    bool isRequireResult = false,
    bool isCheckSessionExpired = true,
    bool isSplashScreen = false,
    bool isLogoutApiState = false,
    bool isMaintenanceDialog = false,
    Function? onLogout,
  }) async {
    if (eventResult == null) return;
    if (!eventResult.isHandled) {
      if (onLogout != null) {
        //force user to logout even api return error or maintenance
        onLogout();
      } else if (eventResult.isError && !isLogoutApiState) {
        if (isAutoHideLoading) ProgressDialog.hide();
        if (eventResult.errorCode == 210) {
          UserRepository.getSingleton().clearSession();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(RoutePath.myHome, (Route<dynamic> route) => false);
            Navigator.of(context).pushNamed(RoutePath.blacklistedUser);
          });
        } else if (eventResult.errorMsgId != null) {
          if (eventResult.errorMsgId == 'UnderMaintenance') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (isMaintenanceDialog) {
                showApiErrorMessageInDialog(eventResult);
              } else {
                Navigator.of(context).pushReplacementNamed(RoutePath.maintenance);
              }
            });
          } else if (onError != null) {
            onError(eventResult.error);
          } else
            showApiErrorMessage(eventResult);
        } else {
          _showErrorMessage(eventResult);
        }
      } else if (eventResult.isMaintenance && !isLogoutApiState) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => Maintenance(
                        isShowCS: true,
                        isShowsAppBar: false,
                      )),
              (Route<dynamic> route) => false);
        });
      } else if (eventResult.isSuccess) {
        if (isAutoHideLoading) ProgressDialog.hide();
        if (isRequireResult) {
          onSuccess(eventResult.result);
        } else
          onSuccess();
      }
    }
    eventResult.isHandled = true;
  }

  buildProgressDialog(String? url) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            url == null
                ? Container()
                : CachedNetworkImage(
                    placeholder: (context, url) => Container(),
                    imageUrl: url,
                    //handling error
                    width: 200.auto,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(),
                  ),
            SizedBox(
              height: 20.auto,
            ),
            buildLottie(size: 80.0),
          ],
        ),
      );

  _showErrorMessage(EventResult eventResult) {
    var errorMessage = eventResult.error;
    final errorMap = {
      101: "invalid_credentials",
      201: "player_not_found",
      206: "invalid_invitation_code",
      207: "turnover_required",
      208: "transfer_failed",
      209: "transfer_failed",
      401: "enter_username_error_message",
      405: "invalid_otp",
      407: "failed_participate_promotion",
      900: "request_failed",
      901: "operation_not_allow"
    };
    final errorKey = errorMap[eventResult.errorCode];
    if (errorKey != null) {
      errorMessage = getTranslatedText(errorKey);
    }
    CustomToast.show(errorMessage ?? "");
  }

  showApiErrorMessageInDialog(EventResult eventResult) {
    if (userRepo.apiError != null) {
      String error = userRepo.apiError![eventResult.errorMsgId] ?? "";
      showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
                description: error,
                buttonText1: getTranslatedText("confirm"),
                onClick: () {
                  Navigator.of(context).pop();
                },
              ));
    }
  }

  showApiErrorMessage(EventResult eventResult) {
    if (userRepo.apiError != null) {
      String error = userRepo.apiError![eventResult.errorMsgId] ?? "";
      CustomToast.show(error);
    }
  }

  String parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString = parse(document.body?.text).documentElement!.text;
    return parsedString;
  }

  getCurrentLanguage() {
    var list = LanguageProvider.getSingleton().list;
    Language? deviceLanguage;
    if (list.length == 1) {
      return list.first;
    } else {
      deviceLanguage = list.singleWhere((e) => e.locale == Localizations.localeOf(context));
      return deviceLanguage;
    }
  }

  handleNullWidget(bool isNull, Widget? widget) {
    if (isNull)
      return Container();
    else
      return widget;
  }

  handleDeepLink(String comType, String value) async {
    var url = "";
    var defaultLink = "";
    var checkExistingLink = "";
    if (comType.contains("WeChat")) {
      url = "weixin://dl/add?phone=$value";
      defaultLink = Platform.isIOS ? "https://apps.apple.com/my/app/wechat/id414478124" : "https://play.google.com/store/apps/details?id=com.tencent.mm";
      checkExistingLink = url;
    } else if (comType.contains("WhatsApp")) {
      url = Platform.isIOS ? "whatsapp://wa.me/+$value" : "whatsapp://send?phone=+$value";
      defaultLink =
          Platform.isIOS ? "https://apps.apple.com/my/app/whatsapp-messenger/id310633997" : "https://play.google.com/store/apps/details?id=com.whatsapp";
      checkExistingLink = url;
    } else if (comType.contains("Telegram")) {
      url = "tg://addcontact?phone=$value";
      defaultLink = Platform.isIOS
          ? "https://apps.apple.com/my/app/telegram-messenger/id686449807"
          : "https://play.google.com/store/apps/details?id=org.telegram.messenger";
      checkExistingLink = "https://t.me/";
    } else if (comType.contains("Zalo")) {
      url = "https://zalo.me/$value";
      defaultLink = Platform.isIOS ? "https://apps.apple.com/my/app/zalo/id579523206" : "https://play.google.com/store/apps/details?id=com.zing.zalo";
      checkExistingLink = "https://zalo.me/";
    } else if (comType.contains("KakaoTalk")) {
      url = "kakaolink://send/";
      defaultLink =
          Platform.isIOS ? "https://apps.apple.com/my/app/kakaotalk-messenger/id362057947" : "https://play.google.com/store/apps/details?id=com.kakao.talk";
      checkExistingLink = "";
    } else if (comType.contains("Line")) {
      url = Platform.isIOS ? "line://ti/p/$value" : "http://line.me/ti/p/$value";
      defaultLink = Platform.isIOS ? "https://apps.apple.com/my/app/line/id443904275" : "market://details?id=jp.naver.line.android";
      checkExistingLink = url;
    } else if (comType.contains("Skype")) {
      url = Platform.isIOS ? "skype:" : "skype:$value";
      defaultLink = Platform.isIOS ? "https://apps.apple.com/my/app/skype-for-iphone/id304878510" : "market://details?id=com.skype.raider";
      checkExistingLink = url;
    } else if (comType.contains("Viber")) {
      url = "viber://pa?chatURI=$value";
      defaultLink = Platform.isIOS ? "https://apps.apple.com/my/app/viber-messenger-chats-calls/id382617920" : "market://details?id=com.viper.voip";
      checkExistingLink = url;
    }

    // if (Platform.isIOS) {

    if (await canLaunch(checkExistingLink)) {
      final bool launchSuccess = Platform.isIOS ? await launch(url, forceSafariVC: false) : await launch(url);
      // if (launchSuccess) {
      // ProgressDialog.hide();
      // }
      // launch(url, forceSafariVC: false);
    } else {
      final bool launchSuccess = Platform.isIOS ? await launch(defaultLink) : await launch(defaultLink);
      // if (launchSuccess) {
      // ProgressDialog.hide();
      // }
    }
  }

  navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(RoutePath.login);
    });
  }

  showPreLoginDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
              title: getTranslatedText("login_hint"),
              description: getTranslatedText("login_dialog_des"),
              buttonText1: getTranslatedText("login_or_signup"),
              buttonText2: getTranslatedText("got_it"),
              onClick: this.navigateToLogin,
              onClick2: () {
                Navigator.pop(context);
              },
              popIndex: 2,
            ));
  }

  buildEmptyContainer({double borderRadius = 0}) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: CustomColor.very_light_pink_four,
        ),
      );

  getImagePath(GameProvider2 gameProvider) {
    //temp set t11 getting image from dev-t3
    var url = EnvironmentConfig.environmentStage == "development"
        ? 'https://dev-t${EnvironmentConfig.light_mode ? "5" : EnvironmentConfig.template_version}.rpgp.cc/'
        : EnvironmentConfig.url;
    var frontImagePath = "${url}assets/images/wapGame${_getFrontImagePathVersion()}"; //"images/game/T${_getFrontImagePathVersion()}/";
    var gameType = gameProvider.gameType!.getImagePath();
    var gamePlatformCode = gameProvider.code?.toLowerCase();
    // var imageFileFormat = EnvironmentConfig.template_version == 10 ? "png" : "jpg";

    var appendPathForDarkLightMode = EnvironmentConfig.template_version == 10 ? (EnvironmentConfig.dark_mode ? "dark/" : "light/") : "";
    return "$frontImagePath/$appendPathForDarkLightMode${gameType == "" ? "sports" : gameType}-$gamePlatformCode.png";
  }

  String _getFrontImagePathVersion() {
    switch (EnvironmentConfig.template_version) {
      case 1:
        if (EnvironmentConfig.light_mode)
          return "/T5";
        else
          return "/T1T2";
      case 2:
        return "";
      case 3:
        return "/T3T4";
      case 4:
        return "/T3T4";
      case 11:
        return "/T11";
      case 15:
        return "/T15/gold";
      default:
        return "/T${EnvironmentConfig.template_version}";
    }
  }

  _isSportsHideLogo(String? gamePlatformCode) => (config?.sportsHideLogo ?? false) && (gamePlatformCode == "wgfm" || gamePlatformCode == "wgvia");

  buildLottie({double size = 50.0}) => Center(
        child: SizedBox(
          height: size,
          width: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(CustomColor.theme_button_color),
          ),
        ),
      );

  String getBankDisplayName(String bankType) {
    switch (bankType) {
      case "bank":
        return getTranslatedText("bank_transfer");
      case "Crypto":
        return getTranslatedText("crypto");
      case "ThirdParty":
        return "Third Party";
      case "EWallet":
        return "E-wallet";
      default:
        return bankType;
    }
  }
}
