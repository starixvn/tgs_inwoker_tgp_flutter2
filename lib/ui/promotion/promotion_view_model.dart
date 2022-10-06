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

    // if (isLoadMore) {
    //   if (page! * rows < getPromotionListApiState.result.totalCount)
    //     page = page!+1;
    //   else
    //     return;
    // } else
    //   page = 1;
    //if (userProfile == null)
    getPromotionListApiState = await contentRepo.getPromotionList();
    // else
    //   getPromotionListApiState = await contentRepo.getPlayerPromotionList(page, rows, true, true);
    // List<Promotion> list = [];
    if (getPromotionListApiState.isSuccess) {
      setLoading(false);
      // list = getPromotionListApiState.result;
      // if (promotionList == null) promotionList = [];
      // if (list.isNotEmpty) promotionList.addAll(list);
      // endRecord = promotionList.length >= getPromotionListApiState.result.totalCount ? true : false;
      List<Promotion> theList = getPromotionListApiState.result;

      promotionList = theList;
      promotionList.sort((a, b) => a.order!.compareTo(b.order!));
    } else {
      promotionList = [];
      setLoading(false);
    }

    return getPromotionListApiState;
  }

  joinPromotion(String id) async {
    setLoading();
    joinPromotionApiState = await contentRepo.joinPromotion(id);
    setLoading(false);
    return joinPromotionApiState;
  }
}
