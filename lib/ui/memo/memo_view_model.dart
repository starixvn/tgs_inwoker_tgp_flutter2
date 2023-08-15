import 'package:api/api.dart';
import 'package:api/entity/delivery_box.dart';
import 'package:api/entity/station_letter.dart';
import 'package:api/entity/vip.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class MemoViewModel extends BaseViewModel {
  MessageRepository messageRepo = MessageRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [];

  var getStationLetterListApiState,
      getDeliveryBoxListApiState,
      readStationLetterApiState,
      getStationLetterDetailsApiState,
      getDeliveryBoxDetailsApiState,
      postStationLetterState,
      replyStationLetterState;

  List<StationLetter>? stationLetterList;
  List<DeliveryBox>? deliveryBoxList;
  int page = 0, rows = 100;
  bool endRecord = false;

  getStationLetterList() async {
    setLoading();
    getStationLetterListApiState = await messageRepo.getStationLetterList();
    if (getStationLetterListApiState.isSuccess) {
      print(getStationLetterListApiState.result);
      stationLetterList = getStationLetterListApiState.result.items;
    }
    setLoading(false);
    return getStationLetterListApiState;
  }

  readStationLetter(String id) async {
    setLoading();
    readStationLetterApiState = await messageRepo.readStationLetter(id);
    setLoading(false);
    return readStationLetterApiState;
  }

  getStationLetterDetails(String id) async {
    setLoading();
    getStationLetterDetailsApiState = await messageRepo.getStationLetterDetails(id);
    if (getStationLetterDetailsApiState.isSuccess) {
      print(getStationLetterDetailsApiState.result);
      StationLetter letter = getStationLetterDetailsApiState.result;
      int index = (stationLetterList ?? []).indexWhere((element) => element.id == letter.id);
      (stationLetterList ?? [])[index]= letter;

      print((stationLetterList ?? [])[index]);
    }
    setLoading(false);
    return getStationLetterDetailsApiState;
  }

  postStationLetter(String subject, String content) async {
    setLoading();
    postStationLetterState = await messageRepo.postStationLetter(subject,content);
    if (postStationLetterState.isSuccess) {
      final resultMap = postStationLetterState.result as Map<String, dynamic>;
      if (resultMap.containsKey('stationLetterList')) {
        stationLetterList = (resultMap['stationLetterList'] as List<dynamic>)
            .map((e) => StationLetter.fromJson(e))
            .toList();
        print(stationLetterList);
      }
      // stationLetterList = postStationLetterState.result;
      print(postStationLetterState.result);
    }
    setLoading(false);
    return postStationLetterState;
  }

  // replyStationLetter(String id, String content) async {
  //   setLoading();
  //   replyStationLetterState = await messageRepo.replyStationLetter(id,content);
  //   if (replyStationLetterState.isSuccess) {
  //     stationLetterList = replyStationLetterState.result;
  //     print(replyStationLetterState.result);
  //   }
  //
  //   setLoading(false);
  //   return replyStationLetterState;
  // }

  replyStationLetter(String id, String content) async {
    setLoading();
    replyStationLetterState = await messageRepo.replyStationLetter(id,content);
    setLoading(false);
    return replyStationLetterState;
  }

  getDeliveryBoxList({isLoadMore = false}) async {
    setLoading();

    if (isLoadMore) {
      if (page * rows < getDeliveryBoxListApiState.result.totalCount)
        page++;
      else
        return;
    } else
      page = 1;

    getDeliveryBoxListApiState = await messageRepo.getDeliveryBoxList(page, rows);
    List<DeliveryBox> list = [];
    if (getDeliveryBoxListApiState.isSuccess) {
      list = getDeliveryBoxListApiState.result.items;
      if (deliveryBoxList == null) deliveryBoxList = [];
      if (page == 1) deliveryBoxList = [];
      deliveryBoxList!.addAll(list);
      endRecord = deliveryBoxList!.length >= getDeliveryBoxListApiState.result.totalCount ? true : false;
    }
    setLoading(false);
    return getDeliveryBoxListApiState;
  }

  getDeliveryBoxDetails(String id) async {
    setLoading();
    getDeliveryBoxDetailsApiState = await messageRepo.getDeliveryBoxDetails(id);
    if (getDeliveryBoxDetailsApiState.isSuccess) {
      print(getDeliveryBoxDetailsApiState.result);
      DeliveryBox delivery = getDeliveryBoxDetailsApiState.result;
      int index = (deliveryBoxList ?? []).indexWhere((element) => element.id == delivery.id);
      (deliveryBoxList ?? [])[index]= delivery;

      print((deliveryBoxList ?? [])[index]);
    }
    setLoading(false);
    return getDeliveryBoxDetailsApiState;
  }
}
