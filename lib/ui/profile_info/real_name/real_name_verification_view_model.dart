import 'dart:io';

import 'package:api/api.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class RealNameVerificationViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();
  var idVerifyApiState, uploadIdImageApiState;

  @override
  List<BaseRepository> get repoList => [userRepo];

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  get config => contentRepo.featuresConfig;

  idVerify(String realname, String id, {File? imageFile}) async {
    setLoading();
    var _status = await userRepo.setIdentity(realname, id);
    if (_status.isSuccess) {
      if (imageFile != null) await uploadIdImage(imageFile);
      idVerifyApiState = await userRepo.getBasicInfo();
    } else
      idVerifyApiState = _status;
    setLoading(false);
    return idVerifyApiState;
  }

  uploadIdImage(File imageFile) async {
    setLoading();
    uploadIdImageApiState = await userRepo.uploadIdImage(imageFile);
    if (uploadIdImageApiState.isSuccess) {}
    setLoading(false);
    return uploadIdImageApiState;
  }
}
