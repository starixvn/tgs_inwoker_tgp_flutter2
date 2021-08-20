import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';


class ProfileInfoViewModel extends BaseViewModel{
  final userRepo = UserRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [userRepo ];
  get userProfile => userRepo.userProfile;


}