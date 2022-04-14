import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class ViberViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [userRepo];

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get config => contentRepo.featuresConfig;

  var setViberIdApiState;

  setViberId(String viber) async {
    setLoading();
    var _status = await userRepo.setMessagingAppID("viber", viber);
    if (_status.isSuccess) {
      setViberIdApiState = await userRepo.getBasicInfo();
    } else
      setViberIdApiState = _status;
    setLoading(false);
    return setViberIdApiState;
  }
}
