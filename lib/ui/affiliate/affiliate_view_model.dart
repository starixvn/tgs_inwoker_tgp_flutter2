import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class AffiliateViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();

  get userProfile => userRepo.userProfile;


  @override
  List<BaseRepository> get repoList => [userRepo,];


}
