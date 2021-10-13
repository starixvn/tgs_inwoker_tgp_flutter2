import 'package:api/entity/language.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
import 'package:tgp_flutter2/ui/maintenance/maintenance.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  final userRepo = UserRepository.getSingleton();

  get apiError => userRepo.apiError;

  getTranslatedText(String key) => LanguageProvider().getTranslated(context, key);

  handleApiState(
    EventResult eventResult, {
    Function onSuccess,
    Function onError,
    bool isAutoHideLoading = true,
    bool isRequireResult = false,
    bool isCheckSessionExpired = true,
    bool isSplashScreen = false,
  }) async {
    if (eventResult == null) return;
    if (!eventResult.isHandled) {
      if (eventResult.isError) {
        if (isAutoHideLoading) ProgressDialog.hide();
        if (eventResult.errorCode == 210) {
          UserRepository.getSingleton().clearSession();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(RoutePath.empty, (Route<dynamic> route) => false);
            Navigator.of(context).pushNamed(RoutePath.blacklistedUser);
          });
        } else if ((eventResult.errorCode == 102 || eventResult.errorCode == 101) &&
            isCheckSessionExpired &&
            !isSplashScreen) {
          UserRepository.getSingleton().clearSession();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) => WillPopScope(
                      onWillPop: () async => false,
                      child: CustomDialog(
                        title: "登录已超时",
                        description: "请再登录",
                        buttonText1: "登录",
                        buttonText2: "不了",
                        onClick: () {
                          Navigator.of(context).pushReplacementNamed("/home");
                          Navigator.of(context).pushNamed("/login");
                        },
                        onClick2: () {
                          Navigator.of(context).pushReplacementNamed("/home");
                        },
                      ),
                    ));
          });
        } else if (eventResult.errorMsgId != null) {
          if (eventResult.errorMsgId == 'UnderMaintenance') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(RoutePath.maintenance);
              Navigator.of(context).popAndPushNamed(RoutePath.maintenance);
            });
          } else if (onError != null) {
            onError(eventResult.error);
          } else {
            String error = userRepo.apiError[eventResult.errorMsgId];
            CustomToast.show(error);
          }
        } else {
          _showErrorMessage(eventResult);
        }
      } else if (eventResult.isMaintenance) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => Maintenance(
                        isShowCS: true,
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

  buildProgressDialog(String url) => Center(
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
            Lottie.asset(
              "loading/loading_t${EnvironmentConfig.template_version}.json",
              width: 150,
              height: 150,
            ),
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
    CustomToast.show(errorMessage);
  }

  String parseHtmlString(String htmlString) {
    final document = parse(htmlString ?? "");
    final String parsedString = parse(document.body.text).documentElement.text;

    return parsedString;
  }

  getCurrentLanguage() {
    var list = LanguageProvider().list;
    Language deviceLanguage = list.singleWhere((e) => e.locale == Localizations.localeOf(context));
    return deviceLanguage;
  }

  handleNullWidget(bool isNull, Widget widget) {
    if (isNull)
      return Container();
    else
      return widget;
  }
}
