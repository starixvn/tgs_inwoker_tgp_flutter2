import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class PayPasswordViewModel extends BaseViewModel{
  //final authRepo = AuthenticationRepository.getSingleton();
  final userRepo = UserRepository.getSingleton();
  final authRepo = AuthenticationRepository.getSingleton();
  var addPayPasswordApiState, getPayPasswordCodeApiState, payPasswordVerifyApiState;
  var securityKey;

  @override
  List<BaseRepository> get repoList => [userRepo,authRepo];
  get userProfile => userRepo.userProfile;

  addPayPassword(String password)async{
    setLoading();
    var status = await authRepo.addPayPassword(password);
    if(status.isSuccess) addPayPasswordApiState = await userRepo.getBasicInfo();
    else addPayPasswordApiState = status;
    setLoading(false);
    return addPayPasswordApiState;
  }

  getPayPasswordCode() async{
    setLoading();
    getPayPasswordCodeApiState = await authRepo.getPayPasswordCode();
    if(getPayPasswordCodeApiState.isSuccess){
      securityKey = getPayPasswordCodeApiState.result;
    }
    setLoading(false);
    return getPayPasswordCodeApiState;
  }

  payPasswordVerify(String password, String code) async{
    setLoading();
    payPasswordVerifyApiState = await authRepo.payPasswordVerify(password, code, securityKey);
    setLoading(false);
    return payPasswordVerifyApiState;
  }
}