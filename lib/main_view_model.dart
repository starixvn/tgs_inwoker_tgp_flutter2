import 'package:api/api.dart';
import 'package:api/init.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';

import 'environment_config.dart';

class MainViewModel extends BaseViewModel {
  final contentRepo = ContentRepository.getSingleton();
  final userRepo = UserRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [];

  bool isNotLogin = false, isExpired = false;
  var authApiState, getLanguageApiState, getBrandLogoApiState, autoLoginApiState, getBasicInfoApiState;
  double gameBalance = 0.0;
  double? totalBalance;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get balance => userRepo.wallet?.main;

  get userProfile => userRepo.userProfile;

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

  resumeIfNeed() async {
    setLoading();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    if (token != null) {
      print(token);
      await getUserInfo();
      if (userProfile == null) await autoLogin();
      print("Token: " + token);
      print("Authorization: " + prefs.getString("auth_token")!);
    } else
      isNotLogin = true;
    setLoading(false);
    notifyListeners();
  }

  getUserInfo() async {
    setLoading();
    getBasicInfoApiState = await userRepo.getBasicInfo();
    if (getBasicInfoApiState.isSuccess) {
      print("111");
    }
    setLoading(false);
    return getBasicInfoApiState;
  }

  autoLogin() async {
    setLoading();
    autoLoginApiState = await userRepo.login(await getUsername(), await getPassword());
    if (autoLoginApiState.isSuccess) {
      savePreferences(autoLoginApiState.result.token);
      getUserInfo();
    }
    setLoading(false);
    return autoLoginApiState;
  }

  savePreferences(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", token);
  }

  getUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("username") ?? "";
  }

  getPassword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("password") ?? "";
  }
}
