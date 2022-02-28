import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class ProfileInfoViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [userRepo];

  get userProfile => userRepo.userProfile;

  get config => contentRepo.featuresConfig;

  getUserProfile() async {
    await userRepo.getBasicInfo();
  }
}
