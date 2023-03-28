import 'package:api/api.dart';
import 'package:api/entity/affiliate_rebate_details.dart';
import 'package:api/entity/affiliate_rebate_game_type.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class AffiliateViewModel extends BaseViewModel {
  final userRepo = UserRepository.getSingleton();
  final contentRepo = ContentRepository.getSingleton();

  get userProfile => userRepo.userProfile;

  @override
  List<BaseRepository> get repoList => [userRepo, contentRepo];

  var getBrandAllAgentState;

  List<AffiliateRebateDetails> rebateList = [];
  List<AffiliateRebateDetails> filteredRebateList = [];
  List<dynamic> rebateGameTypeList = [AffiliateGameType.Sportsbook];
  var selectedRebateGameType = AffiliateGameType.Sportsbook;
  getBrandAllAgent() async {
    setLoading();
    getBrandAllAgentState = await contentRepo.getBrandAllAgent();
    if (getBrandAllAgentState.isSuccess) {
      rebateList = getBrandAllAgentState.result;
      rebateGameTypeList = _getRebateGameTypeList(rebateList);
      selectedRebateGameType = rebateGameTypeList.first;
    }
    setLoading(false);
    return getBrandAllAgentState;
  }

  _getRebateGameTypeList(List<AffiliateRebateDetails> rebateList) {
    List<dynamic> uniqueAgentGameTypes = [];
    for (int i = 0; i < rebateList.length; i++) {
      if (!uniqueAgentGameTypes.contains(rebateList[i].allAgentGameType)) {
        uniqueAgentGameTypes.add(rebateList[i].allAgentGameType);
      }
    }
    return uniqueAgentGameTypes;
  }

  List<AffiliateRebateDetails> filterGamesByType(List<AffiliateRebateDetails> games, AffiliateGameType type) {
    return games.where((game) => game.allAgentGameType == type).toList();
  }
}
