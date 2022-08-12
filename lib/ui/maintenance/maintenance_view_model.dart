import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';
import 'package:api/entity/brand_communication.dart';
import 'package:tgp_flutter2/environment_config.dart';

class MaintenanceViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [userRepo];

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get config => contentRepo.featuresConfig;
  get beginTime => contentRepo.maintenanceBeginTime;
  get endTime => contentRepo.maintenanceEndTime;
  get content => contentRepo.maintenanceContent;

  var getBrandCommunicationApiState, getLiveChatUrlApiState, getMaintenanceTimeApiState;
  List<BrandCommunication>? communicationList;
  String? liveChatUrl;
  //String? beginTime, endTime, content;

  getBrandCommunication() async {
    setLoading();
    getBrandCommunicationApiState = await userRepo.getBrandCommunication();
    if (getBrandCommunicationApiState.isSuccess) {
      communicationList = getBrandCommunicationApiState.result;
    }
    setLoading(false);
    return getBrandCommunicationApiState;
  }

  getLiveChatUrl(String languageCode) async {
    setLoading();
    getLiveChatUrlApiState = await userRepo.getLiveChatUrl();
    if (getLiveChatUrlApiState.isSuccess) {
      List<String> pattern = ["{name}", "{email}", "{lang}"]; //ABV list
      List<String> replace = [
        userProfile?.username ?? " ",
        userProfile?.email ?? " ",
        languageCode
      ]; //corresponding list
      Map<String, String> map = Map.fromIterables(pattern, replace);
      liveChatUrl = getLiveChatUrlApiState.result?.setting?.url;
      //map.entries.fold(getLiveChatUrlApiState.result.setting.url, (prev, e) => prev!.replaceAll(e.key, e.value));

    }
    setLoading(false);
    return getLiveChatUrlApiState;
  }

  getEnvFeatures() async {
    var brand = EnvironmentConfig.environmentStage == "staging" &&
            !(EnvironmentConfig.brandName == "PGG" || EnvironmentConfig.brandName == "MGM")
        ? "stg_${EnvironmentConfig.brandName}"
        : EnvironmentConfig.brandName;
    setLoading();
    await contentRepo.getEnvFeaturesJson(brand);
    setLoading(false);
  }

  //getMaintenanceTime
  getMaintenanceDetails() async {
    setLoading();
    getMaintenanceTimeApiState = await contentRepo.getMaintenanceDetails();
    if (getMaintenanceTimeApiState.isSuccess) {
      // beginTime = getMaintenanceTimeApiState.result["beginTime"];
      // endTime = getMaintenanceTimeApiState.result["endTime"];
      // content = getMaintenanceTimeApiState.result["content"];
    }
    setLoading(false);
    return getMaintenanceTimeApiState;
  }
}
