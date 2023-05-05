import 'package:api/entity/payment.dart';
import 'package:api/entity/response/ws_response.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/list_extension.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

class DepositOrderDialog extends StatefulWidget {
  final WsResponse data;
  final List<Payment> depositList;

  DepositOrderDialog({required this.data, required this.depositList});

  @override
  _DepositOrderDialogState createState() => _DepositOrderDialogState();
}

class _DepositOrderDialogState extends BaseState<DepositOrderDialog> {
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();

    // Dismiss the dialog after 15 seconds if it hasn't already been dismissed
    Future.delayed(Duration(seconds: 15), () {
      if (!mounted) {
        return;
      }
      _closeDialog();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _closeDialog();
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
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            vertical: context.screenHeight / 30,
            horizontal: context.screenWidth / 20,
          ),
          decoration: new BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/deposit_dialog/deposit_dialog_bg.png"),
              fit: BoxFit.cover,
            ),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: context.screenHeight / 30),
                alignment: Alignment.center,
                child: Text(
                  widget.data.type == "DepositNotify"
                      ? getTranslatedText("deposit_dialog_deposit_form")
                      : getTranslatedText("deposit_dialog_withdrawal_form"),
                  style: TextStyle(
                    fontSize: 25.auto,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Table(
                border: TableBorder.symmetric(
                  outside: BorderSide.none,
                  inside: BorderSide.none,
                ),
                columnWidths: {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(3),
                },
                children: [
                  _buildEachRowData(getTranslatedText("deposit_dialog_update_time"),
                      Format().dateTimeWithSecondFormat(widget.data.payload?.updatedOn ?? "")),
                  _buildRowSpacer(),
                  _buildEachRowData(getTranslatedText("deposit_dialog_order_no"), widget.data.payload?.orderNo ?? "",
                      isNeedAddCopiedButton: true),
                  _buildRowSpacer(),
                  _buildEachRowData(getTranslatedText("deposit_dialog_payment_channel"), _getPaymentMethodName()),
                  _buildRowSpacer(),
                  _buildEachRowData(getTranslatedText("deposit_dialog_amount"),
                      Format().currencyWithDecimalFormat(widget.data.payload?.amount ?? 0)),
                  _buildRowSpacer(),
                  _buildEachRowData(
                      getTranslatedText("deposit_dialog_status"), _getStatus(widget.data.payload?.status ?? 0)),
                ],
              )
            ],
          ),
        ),
        _buildCloseDialogButton(),
      ],
    );
  }

  String _getStatus(int status) {
    switch (status) {
      case 7000:
        return getTranslatedText("deposit_dialog_rejected");
      case 8000:
        return getTranslatedText("deposit_dialog_success");
      default:
        return getTranslatedText("deposit_dialog_waiting");
    }
  }

  _buildRowSpacer() => TableRow(children: [
        SizedBox(
          height: 3.auto,
        ),
        SizedBox(
          height: 3.auto,
        ),
      ]);

  _buildEachRowData(String firstRow, String secondRow, {bool isNeedAddCopiedButton = false}) => TableRow(children: [
        Text(firstRow),
        Row(
          children: [
            Text(secondRow),
            if (isNeedAddCopiedButton)
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: secondRow));
                  CustomToast.show(getTranslatedText("copy_text"));
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 5.auto),
                  child: ImageIcon(
                    AssetImage("images/support/ic_copy.png"),
                    size: 10.auto,
                    color: CustomColor.theme_text_black_color,
                  ),
                ),
              ),
          ],
        )
      ]);

  _buildCloseDialogButton() => Positioned(
        top: 10.auto,
        right: 10.auto,
        child: InkWell(
          onTap: () => _closeDialog(),
          child: Container(
            height: 25,
            width: 25,
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                width: 2,
                color: Colors.black,
              ),
              color: Colors.transparent,
            ),
            child: Icon(
              Icons.close,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
      );

  _getPaymentMethodName() {
    return widget.depositList
            .firstWhereOrNull((element) => element.id == (widget.data.payload?.brandPaymentId ?? ""))
            ?.channelName ??
        "";
  }

  _closeDialog() {
    if (!_dismissed) {
      Navigator.of(context).pop();
      setState(() {
        _dismissed = true;
      });
    }
  }
}
