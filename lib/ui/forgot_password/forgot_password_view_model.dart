import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class ForgotPasswordViewModel extends BaseViewModel {
  final authRepo = AuthenticationRepository.getSingleton();
  final userRepo = UserRepository.getSingleton();
  var getForgotPasswordCodeApiState, resetPasswordApiState;

  @override
  List<BaseRepository> get repoList => [];

  get userProfile => userRepo.userProfile;

  var securityKey;

  getForgotPasswordCode(String phone) async {
    setLoading();
    getForgotPasswordCodeApiState = await authRepo.getForgotPasswordCode(phone);
    if (getForgotPasswordCodeApiState.isSuccess) {
      securityKey = getForgotPasswordCodeApiState.result;
    }
    setLoading(false);
    return getForgotPasswordCodeApiState;
  }

  resetPassword(String securityKey, String verificationCode, String newPassword) async {
    setLoading();
    resetPasswordApiState = await authRepo.resetPassword(securityKey, verificationCode, newPassword);
    if (resetPasswordApiState.isSuccess) {}
    setLoading(false);
    return resetPasswordApiState;
  }
}
