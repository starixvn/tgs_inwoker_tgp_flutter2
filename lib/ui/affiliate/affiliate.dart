import 'dart:ui';
import 'dart:io';
import 'dart:typed_data';

import 'package:api/entity/affiliate_rebate_game_type.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:external_path/external_path.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/custom/custom_picker.dart';
import 'package:tgp_flutter2/custom/custom_picker_dialog.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/affiliate/affiliate_view_model.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/ui/message/message_view.dart';
import 'package:tgp_flutter2/ui/profile_info/profile_info.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class Affiliate extends StatefulWidget {
  @override
  _AffiliateState createState() => _AffiliateState();
}

class _AffiliateState extends BaseState<Affiliate> {
  var isEditing = false, isSelected = false;
  AffiliateViewModel _vm = AffiliateViewModel();
  String? affiliateUrl;

  @override
  void initState() {
    _vm.getBrandAllAgent();
    _requestPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getAffiliateUrl();
    });
    super.initState();
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print(info);
  }

  _getAffiliateUrl() {
    setState(() {
      if (_vm.userProfile.playerCode != null)
        affiliateUrl = "${EnvironmentConfig.url}p/${_vm.userProfile.playerCode}?do=register";
    });
  }

  onSelectedAffiliateGameType(gameType) {
    setState(() {
      _vm.selectedRebateGameType = gameType!;
    });
  }

  rebuildAllChildren(BuildContext context) {
    rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  ScreenshotController screenshotController = ScreenshotController();

  _saveScreenShot() async {
    if (affiliateUrl == null) return;

    // Check for storage permission
    var status = await Permission.storage.request();
    if (status.isGranted) {
      // Capture screenshot
      var imageFile = await screenshotController.capture();

      //save to album
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(imageFile!.toList()),
        quality: 60,
        name: "affiliate_qr_code",
      );
      print(result);

      CustomToast.show(getTranslatedText("affiliate_qr_code_saved"));
    } else {
      // Permission denied
      CustomToast.show(getTranslatedText("storage_permission_required"));
    }
  }

  _copyScreenShot() async {}

  Widget build(BuildContext context) {
    _handleApiState();
    rebuildAllChildren(context);
    return ProviderWidget<AffiliateViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          return CustomScaffold(
            appBar: _buildAppBar(),
            body: Container(
              padding: EdgeInsets.only(top: 15.auto, left: 10.auto, right: 10.auto),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getTranslatedText("affiliate_qr_code"),
                    style: TextStyle(fontSize: 14.auto),
                    textAlign: TextAlign.center,
                  ),
                  affiliateUrl == null
                      ? Container()
                      : Container(
                          margin: EdgeInsets.only(top: 10.auto),
                          height: 140.auto,
                          width: 140.auto,
                          color: Colors.white,
                          child: Screenshot(
                              controller: screenshotController,
                              child: Container(
                                color: Colors.white,
                                padding: EdgeInsets.all(10),
                                child: PrettyQr(
                                  size: 200,
                                  data: affiliateUrl!,
                                  errorCorrectLevel: QrErrorCorrectLevel.M,
                                  roundEdges: false,
                                ),
                              ))),
                  Container(
                    padding: EdgeInsets.only(top: 5.auto),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //container with padding left and right
                        //   Container(
                        //   padding: EdgeInsets.only(left: 5.auto, right: 5.auto),
                        //  child: OutlineBorderButton(
                        //   title: getTranslatedText("copy"),
                        //  onClick: () {
                        //                    _copyScreenShot();
                        //             },
                        //              isEnabled: true,
                        //           width: 75.auto,
                        //         height: 17,
                        //       color: CustomColor.theme_text_black_color,
                        //     fontSize: 14,
                        //              radius: 5,
                        //                padding: 4,
                        //            isBold: true,
                        //        ),
                        //     ),

                        Container(
                          padding: EdgeInsets.only(left: 5.auto, right: 5.auto),
                          child: OutlineBorderButton(
                            title: getTranslatedText("download"),
                            onClick: () {
                              _saveScreenShot();
                            },
                            isEnabled: true,
                            width: 75.auto,
                            height: 17,
                            color: CustomColor.theme_text_black_color,
                            fontSize: 14,
                            radius: 5,
                            padding: 4,
                            isBold: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildReferIdText(),
                  _buildIdLink(),
                  _buildAffiliateGameTypePicker(),
                  _buildTableScrollView()
                  //_buildProfileItem()
                ],
              ),
            ),
          );
        });
  }

  _buildAppBar() => CustomAppBar(
        title: getTranslatedText("affiliate"),
      );

  /* AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: gradientDecoration,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          getTranslatedText("affiliate"),
          style: TextStyle(fontSize: 16.auto),
        ),
      );*/

  _buildReferIdText() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: EnvironmentConfig.template_version == 11 ? CustomColor.theme_button_color : Colors.white,
        ),
        padding: EdgeInsets.only(
          left: 10.auto,
          right: 5.auto,
          top: 10.auto,
          bottom: 10.auto,
        ),
        margin: EdgeInsets.only(top: 10.auto),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                margin: EdgeInsets.only(right: 10.auto),
                child: Text(
                  getTranslatedText("my_refer_id"),
                  style: TextStyle(
                      color: CustomColor.theme_text_black_color, fontSize: 14.auto, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: Text(
                _vm.userProfile.playerCode ?? "",
                style: TextStyle(color: CustomColor.theme_text_black_color, fontSize: 14.auto),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.only(left: 3.auto),
                  height: 25.auto,
                  child: OutlineBorderButton(
                    title: getTranslatedText("copy"),
                    onClick: () {
                      Clipboard.setData(ClipboardData(text: _vm.userProfile.playerCode ?? ""));
                      CustomToast.show(getTranslatedText("copy_text"));
                    },
                    isEnabled: true,
                    width: 50.auto,
                    height: 17,
                    color: CustomColor.theme_text_black_color,
                    fontSize: 14,
                    radius: 5,
                    padding: 4,
                    isBold: true,
                  )),
            )
          ],
        ),
      );

  _buildIdLink() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: EnvironmentConfig.template_version == 11 ? CustomColor.theme_button_color : Colors.white,
        ),
        padding: EdgeInsets.only(
          left: 10.auto,
          right: 5.auto,
          top: 10.auto,
          bottom: 10.auto,
        ),
        margin: EdgeInsets.only(top: 10.auto),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                margin: EdgeInsets.only(right: 3.auto),
                child: Text(
                  getTranslatedText("affiliate_link"),
                  style: TextStyle(
                      color: CustomColor.theme_text_black_color, fontSize: 14.auto, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: Container(
                child: Text(
                  affiliateUrl ?? "",
                  style: TextStyle(
                    color: CustomColor.theme_text_black_color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.only(left: 3.auto),
                  height: 25.auto,
                  child: OutlineBorderButton(
                    title: getTranslatedText("copy"),
                    onClick: () {
                      Clipboard.setData(ClipboardData(text: affiliateUrl ?? ""));
                      CustomToast.show(getTranslatedText("copy_text"));
                    },
                    isEnabled: true,
                    width: 50.auto,
                    height: 17,
                    color: CustomColor.theme_text_black_color,
                    fontSize: 14,
                    radius: 5,
                    padding: 4,
                    isBold: true,
                  )),
            )
          ],
        ),
      );

  _buildButton() => Container(
      padding: EdgeInsets.only(bottom: 10.auto, top: 20.auto),
      child: ColorButton(
        title: getTranslatedText("download_qr"),
        onClick: () {},
        isEnabled: true,
        radius: 9.4,
      ));

  _buildTableScrollView() => Expanded(
        child: SingleChildScrollView(
          child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
              margin: EdgeInsets.only(top: 15.auto, bottom: 5.auto),
              // height: 250,
              child: _buildRebateTable()),
        ),
      );

  _buildAffiliateGameTypePicker() => Visibility(
      visible: _vm.rebateList.length > 0,
      child: Container(
        margin: EdgeInsets.only(top: 15.auto, bottom: 5.auto),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 5.auto),
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  Text(
                    getTranslatedText("affiliate_rebate_title"),
                    style: TextStyle(
                        fontSize: 14.auto,
                        color: CustomColor.theme_text_black_white_color,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                  width: context.screenWidth,
                  height: 50.auto,
                  padding: EdgeInsets.only(
                    left: 15.auto,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 5.auto),
                  child: InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {
                        _buildBottomSheet(_vm.rebateGameTypeList);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 9,
                            child: AutoSizeText(
                              (_vm.selectedRebateGameType).getName(context),
                              style: TextStyle(
                                color: CustomColor.theme_text_black_white_color,
                              ),
                              maxFontSize: 14,
                              minFontSize: 8,
                              maxLines: 1,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 18.0,
                            ),
                          )
                        ],
                      ))),
            ),
          ],
        ),
      ));

  _buildBottomSheet(List<dynamic> list) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext bc) {
          return Container(
            height: bc.screenHeight - 250,
            child: SingleChildScrollView(
              child: Wrap(children: [
                Container(
                  alignment: Alignment.center,
                  width: context.screenWidth,
                  padding: EdgeInsets.only(bottom: 5),
                  margin: EdgeInsets.only(left: 5, right: 5, top: 5),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0))),
                  child: Text(
                    getTranslatedText("affiliate_rebate_title"),
                    style: TextStyle(
                      fontSize: 14.auto,
                      color: CustomColor.theme_text_black_white_color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Wrap(
                  children: List.generate(list.length, (index) {
                    var item = list[index] as AffiliateGameType;
                    return ListTile(
                      title: AutoSizeText(
                        item.getName(bc),
                        // style: TextStyle(fontSize: 13.auto),
                        textAlign: TextAlign.center,
                        //overflow: TextOverflow.ellipsis,
                        minFontSize: 10,
                        maxFontSize: 13,
                        stepGranularity: 1,
                      ),
                      onTap: () {
                        onSelectedAffiliateGameType(list[index]);
                        Navigator.pop(context);
                      },
                      hoverColor: Colors.transparent,
                      dense: true,
                    );
                  }),
                ),
              ]),
            ),
          );
        });
  }

  _buildRebateTable() => Visibility(
      visible: _vm.rebateList.length > 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            child: Table(
              columnWidths: {
                0: FlexColumnWidth(1.0),
                1: FlexColumnWidth(1.0),
                2: FlexColumnWidth(1.0),
              },
              border: TableBorder(
                  horizontalInside: BorderSide(width: 2, color: CustomColor.theme_bg_color, style: BorderStyle.solid)),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
                    children: [
                      Container(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                          height: 40,
                          child: Text(
                            getTranslatedText("affiliate_rebate_players"),
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )),
                      Container(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                          height: 40,
                          child: Text(
                            getTranslatedText("affiliate_rebate_turnover"),
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )),
                      Container(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                          height: 40,
                          child: Text(
                            getTranslatedText("affiliate_rebate_rebates") + "(%)",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ))
                    ]),
                for (var item in _vm.filterGamesByType(_vm.rebateList, _vm.selectedRebateGameType))
                  TableRow(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: item == _vm.filterGamesByType(_vm.rebateList, _vm.selectedRebateGameType).last
                              ? BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10))
                              : BorderRadius.circular(0)),
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                          height: 40,
                          child: Text(
                            item.rank.toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                            height: 40,
                            child: Text(
                              item.turnover.toString(),
                              textAlign: TextAlign.center,
                            )),
                        Container(
                            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                            height: 40,
                            child: Text(
                              item.rebatePercentage.toString(),
                              textAlign: TextAlign.center,
                            ))
                      ])
              ],
            ),
          ),
        ],
      ));

  _handleApiState() {
    handleApiState(_vm.getBrandAllAgentState, onSuccess: () {});
  }
}
