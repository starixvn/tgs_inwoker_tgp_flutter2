import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:api/entity/brand_communication.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';

class MaintenanceDialog extends StatefulWidget {
  final List<BrandCommunication>? communicationList;

  MaintenanceDialog({this.communicationList});

  @override
  _MaintenanceDialogState createState() => _MaintenanceDialogState();
}

class _MaintenanceDialogState extends BaseState<MaintenanceDialog> {
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

  _dialogContent() => Wrap(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                  color: CustomColor.theme_button_color,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  )),
              padding: EdgeInsets.symmetric(horizontal: 10.auto),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Instant Messaging",
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
          ),
          Expanded(
            flex: 19,
            child: GridView.count(
              padding: EdgeInsets.all(10.auto),
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: List.generate(widget.communicationList!.length, (index) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: _buildCSRow(widget.communicationList![index].type, "cs_join", "cs_qr_code",
                      "support-" + widget.communicationList![index].type!.toLowerCase(),
                      qrCode: widget.communicationList![index]),
                );
              }),
            ),
          ),
        ],
      );

  _buildCSRow(String? title, String text, String routePath, String imagePath, {BrandCommunication? qrCode}) => InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: qrCode?.appId ?? qrCode?.phone));
          CustomToast.show(getTranslatedText("copy_text"));
        },
        child: Column(
          children: [
            SvgPicture.asset(
              "images/support/$imagePath.svg",
              height: 100.auto,
              color: CustomColor.theme_button_color,
            ),
            Container(
              margin: EdgeInsets.only(left: 10.auto),
              child: Text(
                getTranslatedText(title) ?? title ?? "",
              ),
            ),
          ],
        ),
      );
}
