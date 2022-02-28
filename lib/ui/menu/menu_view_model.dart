import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class MenuViewModel extends BaseViewModel {
  final contentRepo = ContentRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [];

  get config => contentRepo.featuresConfig;
}
