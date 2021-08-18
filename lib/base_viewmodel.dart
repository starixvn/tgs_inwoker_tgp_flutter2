import 'package:flutter/material.dart';
import 'package:api/api.dart';

abstract class BaseViewModel extends ChangeNotifier{
  List<BaseRepository> get repoList;
  var changeNotifierListener;
  var isLoading = false;

  BaseViewModel(){
    changeNotifierListener = (){
      notifyListeners();
    };
    repoList.forEach((repo) {
      repo.addListener(changeNotifierListener);
    });
  }

  @override
  void dispose() {
    repoList.forEach((repo) {
      repo.removeListener(changeNotifierListener);
    });
    super.dispose();
  }

  setLoading([bool isLoading = true]){
    this.isLoading = isLoading;
    notifyListeners();
  }


}