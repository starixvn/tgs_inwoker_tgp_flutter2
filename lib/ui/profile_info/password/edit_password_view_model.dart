import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class EditPasswordViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();
  var editPasswordApiState;

  @override
  List<BaseRepository> get repoList => [userRepo];

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  editPassword(String oldPassword, String newPassword) async {
    setLoading();
    editPasswordApiState = await userRepo.editPassword(oldPassword, newPassword);
    setLoading(false);
    return editPasswordApiState;
  }
}
