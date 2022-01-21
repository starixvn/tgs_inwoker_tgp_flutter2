import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
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
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _getAffiliateUrl();
    });
    super.initState();
  }

  _getAffiliateUrl() {
    setState(() {
      if (_vm.userProfile.playerCode != null)
        affiliateUrl =
            EnvironmentConfig.url + "${getCurrentLanguage().apiCode}/p/${_vm.userProfile.playerCode}?do=register";
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[100],
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
                    child: QrImage(
                      data: affiliateUrl!,
                      version: QrVersions.auto,
                      size: 150.0,
                    ),
                  ),
            _buildReferIdText(),
            _buildIdLink(),
            //_buildProfileItem()
          ],
        ),
      ),
    );
  }

  _buildAppBar() => CustomAppBar(title: getTranslatedText("affiliate"));

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
          color: Colors.white,
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
                      color: CustomColor.theme_text_black_white_color, fontSize: 14.auto, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              flex: 10,
              child: Text(
                _vm.userProfile.playerCode ?? "",
                style: TextStyle(color: CustomColor.theme_text_black_white_color, fontSize: 14.auto),
              ),
            )
          ],
        ),
      );

  _buildIdLink() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
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
                      color: CustomColor.theme_text_black_white_color, fontSize: 14.auto, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: Container(
                child: Text(
                  affiliateUrl ?? "",
                  style: TextStyle(
                    color: CustomColor.theme_text_black_white_color,
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
}
