import 'package:api/network/event_result.dart';
import 'package:api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class LoginViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();
  final authRepo = AuthenticationRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [userRepo];

  String token;
  bool isUsernameExist = false;
  var securityKey, _username, _password;
  var logoutApiState,
      getAllWalletState,
      loginApiState,
      registerApiState,
      checkUsernameApiState,
      getReVerifyCodeApiState,
      phoneReVerifyApiState;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  login(String username, String password, bool rememberMe) async {
    setLoading();
    loginApiState = await userRepo.login(username, password);
    if (loginApiState.isSuccess) {
      token = loginApiState.result.token;
      print(token);
      savePreferences(username, password, rememberMe);
      getUserInfo();
      getWalletBalance();
    }
    setLoading(false);
    return loginApiState;
  }

  register(String username, String password, String rpassword, [String invitationCode]) async {
    setLoading();
    var _status = await userRepo.register(username, password, rpassword, invitationCode ?? "");
    if (_status.isSuccess) {
      registerApiState = await login(username, password, true);
    } else
      registerApiState = _status;
    setLoading(false);
    return registerApiState;
  }

  getUserInfo() async {
    await userRepo.getBasicInfo();
  }

  getWalletBalance() async {
    await userRepo.getWalletBalance();
  }

  checkUsername(String username) async {
    setLoading();
    checkUsernameApiState = await userRepo.checkUsername(username);
    if (checkUsernameApiState.isSuccess) {
      isUsernameExist = checkUsernameApiState.result.isExist;
    }
    setLoading(false);
    return checkUsernameApiState;
  }

  savePreferences(String username, String password, bool rememberMe) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", token);
    if (rememberMe) {
      prefs.setString("username", username);
      prefs.setString("password", password);
    }
  }

  removePrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("username") != null || prefs.getString("username").isNotEmpty) await prefs.remove("username");
    if (prefs.getString("password") != null || prefs.getString("password").isNotEmpty) await prefs.remove("password");
  }

  getUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("username") ?? "";
  }

  getPassword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("password") ?? "";
  }

  getApiError() async {
    await userRepo.getApiErrorLocalization();
  }

  getReVerifyCode(String username, String password, String areaCode, String phone) async {
    setLoading();
    getReVerifyCodeApiState = await authRepo.getReVerifyCode(username, password, areaCode, phone);
    if (getReVerifyCodeApiState.isSuccess) {
      securityKey = getReVerifyCodeApiState.result;
      _username = username;
      _password = password;
    }
    setLoading(false);
    return getReVerifyCodeApiState;
  }

  phoneVerify(String verificationCode) async {
    setLoading();
    var _status = await authRepo.phoneReVerify(
      securityKey,
      verificationCode,
    );
    if (_status.isSuccess) {
      phoneReVerifyApiState = await login(_username, _password, true);
    } else
      phoneReVerifyApiState = _status;
    setLoading(false);
    return phoneReVerifyApiState;
  }
}
