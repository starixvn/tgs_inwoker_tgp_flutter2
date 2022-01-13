import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class RealNameVerificationViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();
  var idVerifyApiState;

  @override
  List<BaseRepository> get repoList => [userRepo];

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get config => contentRepo.featuresConfig;

  idVerify(String realname, String id) async {
    setLoading();
    var _status = idVerifyApiState = await userRepo.setIdentity(realname, id);
    if (_status.isSuccess) {
      idVerifyApiState = await userRepo.getBasicInfo();
    } else
      idVerifyApiState = _status;
    setLoading(false);
    return idVerifyApiState;
  }
}
