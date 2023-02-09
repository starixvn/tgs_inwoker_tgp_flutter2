import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class PhoneVerificationViewModel extends BaseViewModel {
  final authRepo = AuthenticationRepository.getSingleton();
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();
  var submitVerifyCodeApiState, getPhoneVerifyCodeApiState;

  @override
  List<BaseRepository> get repoList => [];

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get config => contentRepo.featuresConfig;

  var securityKey;

  getPhoneVerifyCode(String area, String phone,
      {bool isFromRegister = false}) async {
    setLoading();
    getPhoneVerifyCodeApiState = isFromRegister
        //isFromRegister calling api/player/register
        ? await authRepo.getReVerifyCode("", "", area, phone, "",
            isIdrRegister: true)
        : await authRepo.getPhoneVerify(area, phone);
    if (getPhoneVerifyCodeApiState.isSuccess) {
      //securityKey = getPhoneVerifyCodeApiState.result;
      securityKey = getPhoneVerifyCodeApiState.result?["stepResponse"] ?? "";
    }
    setLoading(false);
    return getPhoneVerifyCodeApiState;
  }

  performSetPhoneDontCareDuplicate(String area, String phone) async {
    setLoading();
    submitVerifyCodeApiState =
        await authRepo.setPhoneDontCareDuplicate(area, phone);
    if (submitVerifyCodeApiState.isSuccess) {
      userRepo.getBasicInfo();
    }
    setLoading(false);
    return submitVerifyCodeApiState;
  }

  submitVerifyCode(int index, String verificationCode,
      {bool isFromRegister = false}) async {
    setLoading();
    var _status = isFromRegister
        //isFromRegister calling api/player/register
        ? await authRepo.phoneReVerify(
            securityKey ?? "",
            verificationCode,
          )
        : await authRepo.submitVerifyCode(securityKey, verificationCode,
            isPhone: true);
    if (_status.isSuccess && index == 1) {
      submitVerifyCodeApiState = await userRepo.getBasicInfo();
    } else
      submitVerifyCodeApiState = _status;
    setLoading(false);
    return submitVerifyCodeApiState;
  }
}
