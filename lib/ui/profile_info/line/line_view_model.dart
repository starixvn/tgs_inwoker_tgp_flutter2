import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class LineViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [userRepo];

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get config => contentRepo.featuresConfig;

  var setLineIdApiState;

  setLineId(String line) async {
    setLoading();
    var _status = await userRepo.setMessagingAppID("line", line);
    if (_status.isSuccess) {
      setLineIdApiState = await userRepo.getBasicInfo();
    } else
      setLineIdApiState = _status;
    setLoading(false);
    return setLineIdApiState;
  }
}
