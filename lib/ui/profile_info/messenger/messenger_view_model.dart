import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class MessengerViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [userRepo];

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get config => contentRepo.featuresConfig;

  var setMessengerIdApiState;

  setMessengerId(String messenger) async {
    setLoading();
    var _status = await userRepo.setMessagingAppID("fb", messenger);
    if (_status.isSuccess) {
      setMessengerIdApiState = await userRepo.getBasicInfo();
    } else
      setMessengerIdApiState = _status;
    setLoading(false);
    return setMessengerIdApiState;
  }
}
