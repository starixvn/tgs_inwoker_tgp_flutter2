

import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class LanguageViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [userRepo];

  getApiError() async {
    await userRepo.getApiErrorLocalization();
  }
}
