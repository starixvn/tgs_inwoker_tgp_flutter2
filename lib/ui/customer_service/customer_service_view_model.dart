import 'dart:io';

import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';
import 'package:api/entity/brand_communication.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerServiceViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [userRepo];

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  var getBrandCommunicationApiState, getLiveChatUrlApiState;
  List<BrandCommunication>? communicationList;
  String? liveChatUrl;
  String? phone;

  getBrandCommunication() async {
    setLoading();
    getBrandCommunicationApiState = await userRepo.getBrandCommunication();
    if (getBrandCommunicationApiState.isSuccess) {
      communicationList = getBrandCommunicationApiState.result;
      if (communicationList != null && communicationList!.length > 0) phone = communicationList?.first.phone;
    }
    setLoading(false);
    print("cjeckcommniuiica: $communicationList");
    return getBrandCommunicationApiState;
  }

  getLiveChatUrl(String languageCode) async {
    setLoading();
    getLiveChatUrlApiState = await userRepo.getLiveChatUrl();
    if (getLiveChatUrlApiState.isSuccess) {
      List<String> pattern = ["{name}", "{email}", "{lang}"]; //ABV list
      List<String> replace = [userProfile?.username ?? "", userProfile?.email ?? "", languageCode]; //corresponding list
      Map<String, String> map = Map.fromIterables(pattern, replace);
      liveChatUrl = getLiveChatUrlApiState.result?.setting?.url;
      //  map.entries.fold(getLiveChatUrlApiState.result.setting.url, (prev, e) => prev!.replaceAll(e.key, e.value));
    }
    setLoading(false);
    return getLiveChatUrlApiState;
  }

  handleDeepLink(String comType, String value) async {
    setLoading();
    var url = "";
    var defaultLink = "";
    var checkExistingLink = "";
    if (comType.contains("WeChat")) {
      url = "weixin://dl/add?phone=$value";
      defaultLink = Platform.isIOS
          ? "https://apps.apple.com/my/app/wechat/id414478124"
          : "https://play.google.com/store/apps/details?id=com.tencent.mm";
      checkExistingLink = url;
    } else if (comType.contains("WhatsApp")) {
      url = Platform.isIOS ? "whatsapp://wa.me/+$value" : "whatsapp://send?phone=+$value";
      defaultLink = Platform.isIOS
          ? "https://apps.apple.com/my/app/whatsapp-messenger/id310633997"
          : "https://play.google.com/store/apps/details?id=com.whatsapp";
      checkExistingLink = url;
    } else if (comType.contains("Telegram")) {
      url = "tg://addcontact?phone=$value";
      defaultLink = Platform.isIOS
          ? "https://apps.apple.com/my/app/telegram-messenger/id686449807"
          : "https://play.google.com/store/apps/details?id=org.telegram.messenger";
      checkExistingLink = "https://t.me/";
    } else if (comType.contains("Zalo")) {
      url = "https://zalo.me/$value";
      defaultLink = Platform.isIOS
          ? "https://apps.apple.com/my/app/zalo/id579523206"
          : "https://play.google.com/store/apps/details?id=com.zing.zalo";
      checkExistingLink = "https://zalo.me/";
    } else if (comType.contains("KakaoTalk")) {
      url = "kakaolink://send/";
      defaultLink = Platform.isIOS
          ? "https://apps.apple.com/my/app/kakaotalk-messenger/id362057947"
          : "https://play.google.com/store/apps/details?id=com.kakao.talk";
      checkExistingLink = "";
    } else if (comType.contains("Line")) {
      url = Platform.isIOS ? "line://ti/p/$value" : "http://line.me/ti/p/$value";
      defaultLink = Platform.isIOS
          ? "https://apps.apple.com/my/app/line/id443904275"
          : "market://details?id=jp.naver.line.android";
      checkExistingLink = url;
    } else if (comType.contains("Skype")) {
      url = Platform.isIOS ? "skype:" : "skype:$value";
      defaultLink = Platform.isIOS
          ? "https://apps.apple.com/my/app/skype-for-iphone/id304878510"
          : "market://details?id=com.skype.raider";
      checkExistingLink = url;
    } else if (comType.contains("Viber")) {
      url = "viber://pa?chatURI=$value";
      defaultLink = Platform.isIOS
          ? "https://apps.apple.com/my/app/viber-messenger-chats-calls/id382617920"
          : "market://details?id=com.viper.voip";
      checkExistingLink = url;
    }

    // if (Platform.isIOS) {

    if (await canLaunch(checkExistingLink)) {
      final bool launchSuccess = Platform.isIOS ? await launch(url, forceSafariVC: false) : await launch(url);
      if (launchSuccess) {
        setLoading(false);
      }
      // launch(url, forceSafariVC: false);
    } else {
      final bool launchSuccess = Platform.isIOS ? await launch(defaultLink) : await launch(defaultLink);
      if (launchSuccess) {
        setLoading(false);
      }
    }
  }
}
