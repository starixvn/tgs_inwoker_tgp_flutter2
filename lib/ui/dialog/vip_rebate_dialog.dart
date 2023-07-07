import 'package:api/entity/payment.dart';
import 'package:api/entity/response/ws_response.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/list_extension.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

class VipRebateDialog extends StatefulWidget {
  final WsResponse data;
  final Function closeDialog;

  //
  VipRebateDialog({required this.data, required this.closeDialog});

  @override
  _VipRebateDialogState createState() => _VipRebateDialogState();
}

class _VipRebateDialogState extends BaseState<VipRebateDialog> {
  bool dismissed = false;

  @override
  void initState() {
    super.initState();

    // Dismiss the dialog after 15 seconds if it hasn't already been dismissed
    Future.delayed(Duration(seconds: 15), () {
      if (!mounted) {
        return;
      }
      widget.closeDialog();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.closeDialog();
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
      alignment: Alignment.bottomCenter,
      insetPadding: EdgeInsets.only(bottom: context.screenHeight / 13, left: 10, right: 10),
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: [
        Container(
            decoration: new BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 0, child: Container(height: 50, child: Image.asset("images/ic_vip_rebate.png"))),
                SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: RichText(
                      text: new TextSpan(
                        children: <TextSpan>[
                          new TextSpan(text: getTranslatedText("vip_rebate"), style: TextStyle(color: Color(0xff9fa3b4))),
                          new TextSpan(text: '${widget.data.payload?.amount??0.0}', style: TextStyle(color: Colors.red)),
                          new TextSpan(text: getTranslatedText("vip_rebate_claim"), style: TextStyle(color: Color(0xff9fa3b4))),
                        ],
                      ),
                    ),
                    // Text(
                    //   "你还有反水 ${0.000090} 可以领取....",
                    //   style: TextStyle(color: Color(0xff9fa3b4)),
                    // ),
                  ),
                ),
                Expanded(flex: 0, child: _buildCloseDialogButton()),
              ],
            )),
      ],
    );
  }

  _buildCloseDialogButton() => InkWell(
        onTap: () => widget.closeDialog(),
        child: Container(
          height: 25,
          width: 25,
          margin: EdgeInsets.all(10),
          child: Icon(
            Icons.close,
            color: Color(0xff717171),
            size: 20,
          ),
        ),
      );

  _closeDialog() {}
}
