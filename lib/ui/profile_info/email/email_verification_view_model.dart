import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class EmailVerificationViewModel extends BaseViewModel {
  final authRepo = AuthenticationRepository.getSingleton();
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();
  var getEmailCodeApiState, emailVerifyApiState;

  @override
  List<BaseRepository> get repoList => [];

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get config => contentRepo.featuresConfig;

  var securityKey;

  getEmailCode(String email) async {
    setLoading();
    getEmailCodeApiState = await authRepo.emailVerify(email);
    if (getEmailCodeApiState.isSuccess) {
      securityKey = getEmailCodeApiState.result;
    }
    setLoading(false);
    return getEmailCodeApiState;
  }

  emailVerify(String verificationCode) async {
    setLoading();
    var _status = await authRepo.submitVerifyCode(securityKey, verificationCode);
    if (_status.isSuccess) {
      emailVerifyApiState = await userRepo.getBasicInfo();
    } else
      emailVerifyApiState = _status;
    setLoading(false);
    return emailVerifyApiState;
  }
}
