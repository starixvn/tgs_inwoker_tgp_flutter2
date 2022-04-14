import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class TelegramViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();


  @override
  List<BaseRepository> get repoList => [userRepo];

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get config => contentRepo.featuresConfig;

  var setTelegramIdApiState;

  setTelegramId(String telegram) async {
    setLoading();
    var _status = await userRepo.setMessagingAppID("telegram", telegram);
    if (_status.isSuccess) {
      setTelegramIdApiState = await userRepo.getBasicInfo();
    } else
      setTelegramIdApiState = _status;
    setLoading(false);
    return setTelegramIdApiState;
  }
}
