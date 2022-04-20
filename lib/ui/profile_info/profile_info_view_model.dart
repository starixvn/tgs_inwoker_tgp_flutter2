import 'package:api/api.dart';
import 'package:api/entity/profile_info_item.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class ProfileInfoViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [userRepo];

  get userProfile => userRepo.userProfile;

  get config => contentRepo.featuresConfig;

  List<Map<String, dynamic>> messagingMap = [];

  getUserProfile() async {
    await userRepo.getBasicInfo();
  }

  getMessagingList() {
    List list = config?.customMessaging ?? [];
    Map<String, Map<String, dynamic>> map = {
      "qq": {"item": ProfileInfoItem.QQ_NUMBER, "text": userProfile.qq},
      "wechat": {"item": ProfileInfoItem.WECHAT_NUMBER, "text": userProfile.wechat},
      "fb": {"item": ProfileInfoItem.MESSENGER, "text": userProfile.facebookMessenger},
      "telegram": {"item": ProfileInfoItem.TELEGRAM, "text": userProfile.telegram},
      "line": {"item": ProfileInfoItem.LINE, "text": userProfile.line},
      "viber": {"item": ProfileInfoItem.VIBER, "text": userProfile.viber},
      "whatsapp": {"item": ProfileInfoItem.WHATSAPP, "text": userProfile.whatsapp},
    };
    if (messagingMap.isNotEmpty) messagingMap.clear();
    if (config?.qqWeChat ?? true) {
      messagingMap.add(map["qq"]!);
      messagingMap.add(map["wechat"]!);
    }
    map.forEach((key, value) {
      if (list.contains(key)) {
        messagingMap.add(value);
      }
    });
    notifyListeners();
  }
}
