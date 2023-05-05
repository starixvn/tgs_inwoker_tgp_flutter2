import 'dart:convert';
import 'dart:io';

import 'package:api/api.dart';
import 'package:api/entity/env_features_config.dart';
import 'package:api/init.dart';
import 'package:api/network/event_result.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';

import 'environment_config.dart';

class MainViewModel extends BaseViewModel {
  final contentRepo = ContentRepository.getSingleton();
  final userRepo = UserRepository.getSingleton();
  final depositRepo = BankRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [];

  bool isNotLogin = false, isExpired = false;
  var authApiState, getLanguageApiState, getBrandLogoApiState, autoLoginApiState, getBasicInfoApiState;
  var versionUpdateState;
  double gameBalance = 0.0;
  double? totalBalance;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get balance => userRepo.wallet?.main;

  get userProfile => userRepo.userProfile;

  get config => contentRepo.featuresConfig;

  get depositList => depositRepo.depositPaymentList;

  getVersion() async {
    setLoading();
    EventResult<dynamic> eventResult = await contentRepo.getVersionJson(EnvironmentConfig.brandName);
    if (eventResult.isSuccess) {
      var package = await PackageInfo.fromPlatform();
      try {
        var versionList = jsonDecode(eventResult.result);
        var platform = Platform.isAndroid
            ? "android"
            : Platform.isIOS
                ? "iOS"
                : "";
        var version = versionList.where((element) => element["platform"] == platform).first;

        if (version["version"] != package.version) {
          versionUpdateState = version;
        }
      } catch (e) {
        //ignore
      }
    }
    setLoading(false);
  }

  getEnvFeatures() async {
    // var brand;
    // if (EnvironmentConfig.environmentStage == "staging" &&
    //     !(EnvironmentConfig.brandName == "PGG" ||
    //         EnvironmentConfig.brandName == "MGM" ||
    //         EnvironmentConfig.brandName.contains("PB")))
    //   brand = "stg_${EnvironmentConfig.brandName}";
    // else if (EnvironmentConfig.environmentStage == "development" && EnvironmentConfig.template_version == 11)
    //   brand = "T11";
    // else if(EnvironmentConfig.environmentStage == "production" && EnvironmentConfig.brandName == "PB3")
    //   brand = "inyobet";
    // else
    //   brand = EnvironmentConfig.brandName;
    setLoading();
    await contentRepo.getEnvFeaturesJson(EnvironmentConfig.configFileName);
    setLoading(false);
  }

  getAuthToken() async {
    setLoading();
    InitData().getData(EnvironmentConfig.url, EnvironmentConfig.jwtKey, EnvironmentConfig.currency,
        EnvironmentConfig.assetUrl, EnvironmentConfig.default_lang);
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

  Future<bool> resumeIfNeed() async {
    setLoading();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    if (token != null) {
      print(token);

      await getUserInfo();
      if (userProfile == null) await autoLogin();
      print("Token: " + token);
      print("Authorization: " + prefs.getString("auth_token")!);

      return true;
    } else
      isNotLogin = true;
    setLoading(false);
    notifyListeners();
    return false;
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

  getPayment() async {
    setLoading();
    var state = await depositRepo.getPayment();
    setLoading(false);
    return state;
  }
}
