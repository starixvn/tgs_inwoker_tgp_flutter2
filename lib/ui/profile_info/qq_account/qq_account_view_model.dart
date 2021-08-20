import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class QQAccountViewModel extends BaseViewModel{
  final userRepo = UserRepository.getSingleton();
  var setQQApiState;

  @override
  List<BaseRepository> get repoList => [userRepo];
  get userProfile => userRepo.userProfile;

  setQQAccount(String qq) async{
    setLoading();
    var _status = await userRepo.setQQAccount(qq);
    if(_status.isSuccess){
      setQQApiState = await userRepo.getBasicInfo();
    }else setQQApiState = _status;
    setLoading(false);
    return setQQApiState;
  }

}