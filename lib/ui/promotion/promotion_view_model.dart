import 'package:api/api.dart';
import 'package:api/entity/promotion.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class PromotionViewModel extends BaseViewModel {
  final contentRepo = ContentRepository.getSingleton();
  final userRepo = UserRepository.getSingleton();
  var getPromotionState;

  @override
  List<BaseRepository> get repoList => [userRepo, contentRepo];

  get userProfile => userRepo.userProfile;
  var getPromotionListApiState, joinPromotionApiState;
  var promotionList;
  int page, rows = 10;
  bool endRecord;

  getPromotionList({isLoadMore = false}) async {
    setLoading();

    if (isLoadMore) {
      if (page * rows < getPromotionListApiState.result.totalCount)
        page++;
      else
        return;
    } else
      page = 1;

    if (userProfile == null)
      getPromotionListApiState = await contentRepo.getPromotionList(page, rows, true, true);
    else
      getPromotionListApiState = await contentRepo.getPlayerPromotionList(page, rows, true, true);
    List<Promotion> list = [];
    if (getPromotionListApiState.isSuccess) {
      list = getPromotionListApiState.result.items;
      if (promotionList == null) promotionList = [];
      if(list.isNotEmpty) promotionList.addAll(list);
      endRecord = promotionList.length >= getPromotionListApiState.result.totalCount ? true : false;
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
