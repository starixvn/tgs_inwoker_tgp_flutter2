import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class WechatViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();
  var setWechatApiState;

  @override
  List<BaseRepository> get repoList => [userRepo];

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get config => contentRepo.featuresConfig;

  setWechatAccount(String qq) async {
    setLoading();
    var _status = await userRepo.setWechatAccount(qq);
    if (_status.isSuccess) {
      setWechatApiState = await userRepo.getBasicInfo();
    } else
      setWechatApiState = _status;
    setLoading(false);
    return setWechatApiState;
  }
}
