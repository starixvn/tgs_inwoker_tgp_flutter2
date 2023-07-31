import 'package:api/api.dart';
import 'package:api/entity/vip.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class VipViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();

  get userProfile => userRepo.userProfile;

  get brandLogoUrl => contentRepo.brandLogo?.mobileUrl;

  @override
  List<BaseRepository> get repoList => [
        userRepo,
      ];
  var getVipApiState;
  List<Vip>? vipList;
  Map<int, Vip> vipMap = new Map<int, Vip>();

  getVip() async {
    setLoading();
    getVipApiState = await contentRepo.getVip(1, 20, false, true);
    if (getVipApiState.isSuccess) {
      // bankCardList = getBankCardListApiState.result;
      vipList = getVipApiState.result.items;
      //vipMap[level]
      vipList!.forEach((e) {
        vipMap[(e.level!).toInt()] = e;
      });
      vipMap = Map.fromEntries(
          vipMap.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));

      print(vipMap);
    }
    setLoading(false);
    return getVipApiState;
  }
}
