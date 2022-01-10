import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';
import 'package:api/entity/brand_communication.dart';

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
      if (communicationList != null && communicationList!.length > 0)
        phone = communicationList?.first.phone;
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
      List<String> replace = [
        userProfile?.username ?? "",
        userProfile?.email ?? "",
        languageCode
      ]; //corresponding list
      Map<String, String> map = Map.fromIterables(pattern, replace);
      liveChatUrl = getLiveChatUrlApiState.result?.setting?.url;
      //  map.entries.fold(getLiveChatUrlApiState.result.setting.url, (prev, e) => prev!.replaceAll(e.key, e.value));
    }
    setLoading(false);
    return getLiveChatUrlApiState;
  }
}
