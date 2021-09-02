import 'package:api/api.dart';
import 'package:api/init.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

import 'environment_config.dart';

class MainViewModel extends BaseViewModel {
  final contentRepo = ContentRepository.getSingleton();
  final userRepo = UserRepository.getSingleton();
  var authApiState, getLanguageApiState;

  @override
  List<BaseRepository> get repoList => [];

  getAuthToken() async {
    setLoading();
    InitData().getData(EnvironmentConfig.url,EnvironmentConfig.jwtKey,EnvironmentConfig.currency);
    authApiState = await userRepo.auth();
    setLoading(false);
    return authApiState;
  }

  getLanguageOption() async {
    setLoading();
    getLanguageApiState = await contentRepo.getLanguageOption();
    if (getLanguageApiState.isSuccess) {}
    setLoading(false);
    return getLanguageApiState;
  }
}
