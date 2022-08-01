import 'package:api/entity/promotion.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter/scheduler.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';
import 'package:tgp_flutter2/ui/login/login_view_model.dart';
import 'package:tgp_flutter2/ui/login/phone_re_verification/phone_re_verification.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_item_details.dart';
import 'package:tgp_flutter2/ui/promotion/promotion_view_model.dart';

class PhoneVerificationDialog extends StatefulWidget {
  PhoneVerificationDialog();

  @override
  _PhoneVerificationDialogState createState() => _PhoneVerificationDialogState();
}

class _PhoneVerificationDialogState extends BaseState<PhoneVerificationDialog> {
  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //widget.onClick();
    });
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Container(
      height: context.screenHeight/2.7,
        padding: EdgeInsets.symmetric(
          vertical: context.screenHeight / 30,
          horizontal: context.screenWidth / 20,
        ),
        decoration: new BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 13.auto, left: 10.auto),
              alignment: Alignment.topLeft,
              child: Text(
                getTranslatedText("phone_re-verify"),
                style: TextStyle(
                  fontSize: 18.auto,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            PhoneReVerification(),
          ],
        ));
  }
}
