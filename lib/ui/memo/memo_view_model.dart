import 'package:api/api.dart';
import 'package:api/entity/delivery_box.dart';
import 'package:api/entity/station_letter.dart';
import 'package:api/entity/vip.dart';
import 'package:tgp_flutter2/base_viewmodel.dart';

class MemoViewModel extends BaseViewModel {
  MessageRepository messageRepo = MessageRepository.getSingleton();

  @override
  List<BaseRepository> get repoList => [];

  var getStationLetterListApiState, getDeliveryBoxListApiState, readStationLetterApiState, getStationLetterDetailsApiState;

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
}
