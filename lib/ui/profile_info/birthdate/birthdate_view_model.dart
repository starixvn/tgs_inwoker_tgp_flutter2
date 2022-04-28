import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class BirthdateViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [userRepo];

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get config => contentRepo.featuresConfig;

  var setBirthdateApiState;

  setBirthdate(String birthdate) async {
    setLoading();
    var _status = await userRepo.setBirthdate(birthdate);
    if (_status.isSuccess) {
      setBirthdateApiState = await userRepo.getBasicInfo();
    } else
      setBirthdateApiState = _status;
    setLoading(false);
    return setBirthdateApiState;
  }
}
