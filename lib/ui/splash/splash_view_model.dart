import 'package:flutter/material.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';
 import 'package:api/api.dart';
import 'package:api/init.dart';
import 'package:tgp_flutter2/environment_config.dart';

class SplashViewModel extends BaseViewModel{
  final userRepo = UserRepository.getSingleton();
  var authApiState;

  @override
  List<BaseRepository> get repoList => [userRepo];

  getAuthToken()async{
    setLoading();
    InitData().getData(EnvironmentConfig.url,EnvironmentConfig.jwtKey,EnvironmentConfig.currency);
    authApiState = await userRepo.auth();
    setLoading(false);
    return authApiState;
  }
}