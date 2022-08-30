import 'package:api/api.dart';
import 'package:api/entity/promotion.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';
import 'package:api/entity/campaign_details.dart';

class PromotionViewModel extends BaseViewModel {
  final contentRepo = ContentRepository.getSingleton();
  final userRepo = UserRepository.getSingleton();
  var getPromotionState;

  @override
  List<BaseRepository> get repoList => [userRepo, contentRepo];

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  var getPromotionListApiState, joinPromotionApiState;
  var promotionList;
  int? page;
  int rows = 10;
  bool endRecord = false;

  getPromotionList() async {
    setLoading();
    getPromotionListApiState = await contentRepo.getPromotionList();
    if (getPromotionListApiState.isSuccess) {
      promotionList = getPromotionListApiState.result;
    } else
      promotionList = [];
    setLoading(false);
    return getPromotionListApiState;
  }

  joinPromotion(String id) async {
    setLoading();
    joinPromotionApiState = await contentRepo.joinPromotion(id);
    setLoading(false);
    return joinPromotionApiState;
  }
}
