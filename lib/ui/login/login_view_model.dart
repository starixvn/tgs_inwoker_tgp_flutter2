import 'package:api/network/event_result.dart';
import 'package:api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class LoginViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();
  final authRepo = AuthenticationRepository.getSingleton();
  final bankRepo = BankRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [userRepo];

  String? token;
  bool isUsernameExist = false;

  // var _username, _password;
  var logoutApiState,
      getAllWalletState,
      loginApiState,
      registerApiState,
      checkUsernameApiState,
      getReVerifyCodeApiState,
      phoneReVerifyApiState,
      getBankCardListApiState;
  String? username, password;
  bool isPhoneReVerificationReset = false;
  String? securityKey;

  get brandLogo => contentRepo.brandLogo;

  get config => contentRepo.featuresConfig;

  login(String username, String password, bool rememberMe) async {
    setLoading();
    loginApiState = await userRepo.login(username, password);
    if (loginApiState.isSuccess) {
      token = loginApiState.result.token;
      print(token);
      savePreferences(username, password, rememberMe);
      getUserInfo();
      getWalletBalance();
      getBankCardList();
    }
    setLoading(false);
    return loginApiState;
  }

  register(String _username, String _password, String rpassword, String? invitationCode, bool isAgent) async {
    setLoading();
    registerApiState = await userRepo.register(_username, _password, rpassword, invitationCode, isAgent);
    if (registerApiState.isSuccess && config?.smsVerification) {
      username = _username;
      password = _password;
      isPhoneReVerificationReset = true;
    }
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
    prefs.setString("token", token!);
    if (rememberMe) {
      prefs.setString("username", username);
      prefs.setString("password", password);
    }
  }

  removePrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("username")?.isNotEmpty ?? false) await prefs.remove("username");
    if (prefs.getString("password")?.isNotEmpty ?? false) await prefs.remove("password");
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

  getReVerifyCode(String _username, String _password, String areaCode, String phone) async {
    setLoading();
    getReVerifyCodeApiState = await authRepo.getReVerifyCode(_username, _password, areaCode, phone);
    if (getReVerifyCodeApiState.isSuccess) {
      securityKey = getReVerifyCodeApiState.result;
      username = _username;
      password = _password;
    }
    setLoading(false);
    return getReVerifyCodeApiState;
  }

  phoneVerify(String verificationCode) async {
    setLoading();
    phoneReVerifyApiState = await authRepo.phoneReVerify(
      securityKey ?? "",
      verificationCode,
    );
    setLoading(false);
    return phoneReVerifyApiState;
  }

  setIsPhoneReVerificationResetToFalse() {
    isPhoneReVerificationReset = false;
  }

  getBankCardList() async {
    setLoading();
    getBankCardListApiState = await bankRepo.getBankCardList();
    setLoading(false);
    return getBankCardListApiState;
  }
}
