import 'package:api/api.dart';
import 'package:api/init.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';

import 'environment_config.dart';

class MainViewModel extends BaseViewModel {
  final contentRepo = ContentRepository.getSingleton();
  final userRepo = UserRepository.getSingleton();
  var authApiState, getLanguageApiState, getBrandLogoApiState;

  @override
  List<BaseRepository> get repoList => [];

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  getAuthToken() async {
    setLoading();
    InitData().getData(EnvironmentConfig.url, EnvironmentConfig.jwtKey, EnvironmentConfig.currency);
    authApiState = await userRepo.auth();
    setLoading(false);
    return authApiState;
  }

  getLanguageOption() async {
    setLoading();
    getLanguageApiState = await contentRepo.getLanguageOption();
    setLoading(false);
    return getLanguageApiState;
  }

  getBrandLogo() async {
    setLoading();
    getBrandLogoApiState = await contentRepo.getBrandLogo();
    setLoading(false);
    return getBrandLogoApiState;
  }

  getApiError() async {
    await userRepo.getApiErrorLocalization();
  }
}
