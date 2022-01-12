import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:api/entity/brand_communication.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';

import 'maintenance_view_model.dart';

class MaintenanceDialog extends StatefulWidget {
  final List<BrandCommunication>? communicationList;

  MaintenanceDialog({this.communicationList});

  @override
  _MaintenanceDialogState createState() => _MaintenanceDialogState();
}

class _MaintenanceDialogState extends BaseState<MaintenanceDialog> {
  var _vm = MaintenanceViewModel();

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        backgroundColor: Colors.white,
        child: _dialogContent());
  }

  _dialogContent() => Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: CustomColor.theme_button_color,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  )),
              padding: EdgeInsets.symmetric(vertical: 5.auto, horizontal: 10.auto),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslatedText("instant_messaging"),
                    style: TextStyle(color: Colors.white),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
            Flexible(
              flex: 19,
              child: GridView.count(
                padding: EdgeInsets.all(10.auto),
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio:0.9,
                children: List.generate(widget.communicationList!.length, (index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: _buildCSRow(widget.communicationList![index].type, "cs_join", "cs_qr_code",
                        "m-support-" + widget.communicationList![index].type!.toLowerCase(),
                        qrCode: widget.communicationList![index]),
                  );
                }),
              ),
            ),
          ],
        ),
      );

  _buildCSRow(String? title, String text, String routePath, String imagePath, {BrandCommunication? qrCode}) => InkWell(
        onTap: () {
          var contact = qrCode?.appId ?? qrCode?.phone;
          if (contact != null) {
            Clipboard.setData(ClipboardData(text: contact));
            CustomToast.show(getTranslatedText("copy_text"));
            handleDeepLink(title ?? "", contact);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "images/support/$imagePath.png",
              height: 80.auto,
            ),
            Container(
              margin: EdgeInsets.only(top: 5.auto),
              child: Text(
                getTranslatedText(title) ?? title ?? "",
              ),
            ),
            Container(
              height: 30.auto,
              margin: EdgeInsets.only(top: 2.auto),
              child: _buildContactRow(qrCode)
            )
          ],
        ),
      );

  _buildContactRow(BrandCommunication? qrCode){
    var text = qrCode?.appId != null ?  "ID: ${qrCode?.appId ?? ""}" : qrCode?.phone != null ? "${getTranslatedText("phone_number")}: ${qrCode?.phone ?? ""}" : "";
    return AutoSizeText(text,
      minFontSize: 8,
      maxLines: 2,
      textAlign: TextAlign.center,
    );

  }
}
