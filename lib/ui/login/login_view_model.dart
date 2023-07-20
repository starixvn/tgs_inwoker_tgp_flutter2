import 'package:api/entity/language.dart';
import 'package:api/localizations/language_provider.dart';
import 'package:api/network/event_result.dart';
import 'package:api/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

import '../../main.dart';

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
      getBankCardListApiState,
      getAffiliateStatusState;

  String? username, password;
  bool isPhoneReVerificationReset = false;
  String? securityKey;
  bool isNavigateFromSmsVerification = false;
  String nextStepType = "";
  bool haveAffiliate = false;

  get brandLogo => contentRepo.brandLogo;

  get config => contentRepo.featuresConfig;

  List<Language> get languageList => LanguageProvider.getSingleton().list;

  Language getDeviceLanguage(BuildContext context) => languageList.singleWhere((e) => e.locale == Localizations.localeOf(context));

  login(String username, String password, bool rememberMe) async {
    setLoading();
    loginApiState = await userRepo.login(username, password);
    if (loginApiState.isSuccess) {
      token = loginApiState.result.token;
      print(token);
      savePreferences(username, password, rememberMe);
      await getUserInfo();
      await getWalletBalance();
      await getBankCardList();
    }
    setLoading(false);
    return loginApiState;
  }

  register(String _username, String _password, String rpassword, String? invitationCode, bool isAgent) async {
    setLoading();
    registerApiState = await userRepo.register(_username, _password, rpassword, invitationCode, isAgent);
    if (registerApiState.isSuccess && config?.smsVerification ?? false) {
      username = _username;
      password = _password;
      isPhoneReVerificationReset = true;
    }
    setLoading(false);
    return registerApiState;
  }

  var verifyEmailState, verifyPhoneState;

  loginWithPhoneAndEmail(String username, String password, String phone, String areacode, String email) async {
    setLoading();
    loginApiState = await userRepo.login(username, password);
    if (loginApiState.isSuccess) {
      token = loginApiState.result.token;
      print(token);
      savePreferences(username, password, true);
      verifyPhoneState = await authRepo.getReVerifyCode(username, password, areacode, phone, nextStepType, isIdrRegister: false);
      print(verifyPhoneState);
      if (verifyPhoneState.isSuccess) {
        authRepo.phoneReVerify(verifyPhoneState.result, "123456");
      }

      verifyEmailState = await authRepo.getEmailVerifyCode(email, isIdrRegister: false);
      if (verifyEmailState.isSuccess) {
        authRepo.emailVerification(verifyEmailState.result, "123456");
      }
      await getUserInfo();
      await getWalletBalance();
      await getBankCardList();
    }
    setLoading(false);
    return loginApiState;
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

  getReVerifyCode(String areaCode, String phone) async {
    setLoading();
    getReVerifyCodeApiState = await authRepo.getReVerifyCode("", "", areaCode, phone, nextStepType, isIdrRegister: true);
    if (getReVerifyCodeApiState.isSuccess) {
      securityKey = getReVerifyCodeApiState.result?["stepResponse"] ?? "";
      username = await getUsername();
      password = await getPassword();
      //if (config.registerShowPhone ?? false) phoneVerify("123456");
    }
    setLoading(false);
    return getReVerifyCodeApiState;
  }

  phoneVerify(String verificationCode, bool isIdrRegister) async {
    setLoading();
    phoneReVerifyApiState = await authRepo.phoneReVerify(securityKey ?? "", verificationCode, isIdrRegister: isIdrRegister);
    isNavigateFromSmsVerification = true;
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

  setIsNavigateFromSmsVerificationToTrue() {
    isNavigateFromSmsVerification = true;
  }

  idrRegister(String _username, String _password) async {
    setLoading();
    registerApiState = await userRepo.idrRegister(_username, _password);
    if (registerApiState.isSuccess) {
      if (config?.smsVerification ?? false) {
        username = _username;
        password = _password;
        isPhoneReVerificationReset = true;
      }
      nextStepType = registerApiState.result.nextStepType;
    }
    setLoading(false);
    return registerApiState;
  }

  idrLoginWithPhoneAndEmail(String username, String password, String phone, String areacode, String email) async {
    setLoading();
    loginApiState = await userRepo.login(username, password);
    if (loginApiState.isSuccess) {
      token = loginApiState.result.token;
      print(token);
      savePreferences(username, password, true);
      verifyPhoneState = await authRepo.getReVerifyCode(username, password, areacode, phone, nextStepType, isIdrRegister: true);
      if (verifyPhoneState.isSuccess) {
        await authRepo.phoneReVerify(verifyPhoneState.result?["stepResponse"] ?? "", "123456", isIdrRegister: true);
        if (config.registerShowEmail ?? false) {
          verifyEmailState = await authRepo.getEmailVerifyCode(email, isIdrRegister: true);
          if (verifyEmailState.isSuccess) {
            await authRepo.emailVerification(verifyEmailState.result["stepResponse"] ?? "", "123456", isIdrRegister: true);
          }
        }
      }
      await getUserInfo();
      await getWalletBalance();
      await getBankCardList();
    }
    setLoading(false);
    return loginApiState;
  }

  getAffiliateStatus() async {
    setLoading();
    getAffiliateStatusState = await contentRepo.getAffiliateStatus();
    if (getAffiliateStatusState.isSuccess) {
      haveAffiliate = getAffiliateStatusState.result.switchOn;
    }
    setLoading(false);
    notifyListeners();
    return getAffiliateStatusState;
  }

  changeLanguage(Language language, BuildContext context) async {
    Locale? _locale = await LanguageProvider.getSingleton().setLocale(language);
    MyApp.setLocale(context, _locale!);
    await getApiError();
  }
}
