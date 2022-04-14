import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class WhatsappViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [userRepo];

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get config => contentRepo.featuresConfig;

  var setWhatsappIdApiState;

  setWhatsappId(String whatsapp) async {
    setLoading();
    var _status = await userRepo.setMessagingAppID("whatsapp", whatsapp);
    if (_status.isSuccess) {
      setWhatsappIdApiState = await userRepo.getBasicInfo();
    } else
      setWhatsappIdApiState = _status;
    setLoading(false);
    return setWhatsappIdApiState;
  }
}
