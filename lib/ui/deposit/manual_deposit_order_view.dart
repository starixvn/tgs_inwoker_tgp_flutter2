import 'dart:io';

import 'package:api/entity/payment_extended.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:api/entity/deposit_redirect.dart';
import 'package:api/entity/deposit_redirect_applepay.dart';
import 'package:api/entity/manual_deposit_order.dart';
import 'package:api/entity/promotion.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';

import 'deposit_view_model.dart';
import 'deposit_web.dart';

class ManualDepositOrderView extends StatefulWidget {
  final String? method;
  final String? id;
  final ManualDepositOrder? manualDepositOrder;
  final DepositRedirect? depositRedirect;
  final String? depositAmount;
  final String? depositChannel;
  final String? orderNo;
  final String? promotionName;
  final PaymentExtended? paymentQrCode;

  ManualDepositOrderView(
      {this.method,
      this.id,
      this.manualDepositOrder,
      this.depositRedirect,
      this.depositAmount,
      this.depositChannel,
      this.orderNo,
      this.promotionName,
      this.paymentQrCode});

  @override
  _ManualDepositOrderViewState createState() => _ManualDepositOrderViewState();
}

class _ManualDepositOrderViewState extends BaseState<ManualDepositOrderView> {
  File? uploadImage;
  var _vm = DepositViewModel();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<DepositViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return CustomScaffold(
              appBar: _buildAppBar(),
              body: _buildManualBankDepositOrder());
        });
  }

  _buildAppBar() => CustomAppBar(
        title: getTranslatedText("deposit"),
      ) /* AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: gradientDecoration,
        ),
        centerTitle: true,
        title: Text(
          getTranslatedText("deposit"),
          style: TextStyle(fontSize: 20.auto, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      )*/
      ;

  _buildManualBankDepositOrder() => ListView(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white),
            padding: EdgeInsets.only(
                left: 15.auto, right: 15.auto, top: 15.auto, bottom: 15.auto),
            child: Column(
              children: [
                Row(
                  children: [
                    _displayImage(),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              getTranslatedText("amount"),
                              style: TextStyle(
                                  fontSize: 13.auto, color: CustomColor.grey),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: AutoSizeText(
                              Format().currencyWithDecimalFormat(
                                  widget.manualDepositOrder!.amount),
                              style: TextStyle(
                                  fontSize: 38, fontWeight: FontWeight.w400),
                              minFontSize: 10,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(
                  thickness: (1.0).auto,
                  color: CustomColor.very_light_pink_four,
                ),
                _buildOrderText("order_no", widget.orderNo ?? widget.id!),
                _buildText(
                    "payment_type", widget.manualDepositOrder!.methodName),
                _buildText(
                    "payment_channel", widget.manualDepositOrder!.channelName),
                _buildText(
                    "receiver_bank",
                    widget.manualDepositOrder!.qrCode == null
                        ? widget.manualDepositOrder!.bankAccountName
                        : widget.manualDepositOrder!.bankName),
                Visibility(
                  visible: widget.manualDepositOrder!.qrCode == null,
                  child: _buildText("receiver_bank_account",
                      widget.manualDepositOrder!.bankAccount),
                ),
                Visibility(
                  visible: widget.promotionName != null,
                  child: _buildText(
                      "promotion_picker", widget.promotionName ?? ""),
                ),
                _buildUploadTextRow(),
                uploadImage == null
                    ? Container()
                    : Container(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                            height: 80, child: Image.file(uploadImage!)))
              ],
            ),
          ),
          Container(
            margin:
                EdgeInsets.only(left: 15.auto, right: 15.auto, top: 10.auto),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ColorButton(
                  title: getTranslatedText("upload_prof"),
                  onClick: () =>
                      _vm.uploadDepositImage(uploadImage!, widget.id!),
                  isEnabled: uploadImage == null ? false : true,
                  radius: 4.8,
                  height: 44.5,
                ),
                Container(
                    margin: EdgeInsets.only(top: 10.auto),
                    child: ColorButton(
                        title: getTranslatedText("cancel_deposit"),
                        onClick: () => Navigator.pop(context),
                        isEnabled: true,
                        radius: 4.8,
                        height: 44.5))
              ],
            ),
          )
        ],
      );

  _displayImage() {
    if (widget.manualDepositOrder?.qrCode?.isEmpty ?? false)
      return Expanded(
        flex: 2,
        child: Container()
        // QrImage(
        //   data: widget.manualDepositOrder!.qrCode!,
        //   version: QrVersions.auto,
        //   size: 150.0,
        // ),
      );
    else if (widget.paymentQrCode?.qrCodeFileUrl?.isEmpty ?? false)
      return Expanded(
        flex: 2,
        child: Image.network(
          widget.paymentQrCode!.qrCodeFileUrl!,
          width: 150,
          height: 150,
        ),
      );
    else if ((widget.paymentQrCode?.qrCodeFileUrl?.isEmpty ?? false) ||
        (widget.manualDepositOrder?.qrCode?.isEmpty ?? false))
      return Expanded(flex: 1, child: Container());
    else
      return Container();
  }

  _buildOrderText(String title, String content) => Container(
        margin: EdgeInsets.only(top: 15.auto),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                getTranslatedText(title) ?? title,
                style: TextStyle(fontSize: 13.auto, color: CustomColor.grey),
              ),
            ),
            Expanded(
              flex: 8,
              child: AutoSizeText(
                content,
                style: TextStyle(fontSize: 13.auto, color: Colors.black),
                minFontSize: 2,
                maxLines: 1,
                textAlign: TextAlign.end,
              ),
            )
          ],
        ),
      );

  _buildText(String title, String? content) {
    if (content == "BankTransfer")
      content = getTranslatedText("bank_transfer");
    else if (content == "Crypto") content = getTranslatedText("crypto");
    return Container(
      margin: EdgeInsets.only(top: 15.auto),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getTranslatedText(title) ?? title,
            style: TextStyle(fontSize: 13.auto, color: CustomColor.grey),
          ),
          AutoSizeText(
            content ?? "",
            style: TextStyle(fontSize: 13.auto, color: Colors.black),
            minFontSize: 2,
            maxLines: 1,
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }

  _buildUploadTextRow() => Container(
        margin: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
            //bg image
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 7,
              child: Text(
                getTranslatedText("upload_prof_hint"),
                style: TextStyle(fontSize: 10.auto, color: CustomColor.grey),
              ),
            ),
            Expanded(
              flex: 3,
              child: ColorButton(
                title: getTranslatedText("pick_prof"),
                width: 70.auto,
                height: 30.auto,
                onClick: () {
                  chooseImage();
                },
                isEnabled: true,
                radius: 9.6,
              ),
            )
          ],
        ),
      );

  Future<void> chooseImage() async {
    /*File choosedImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    //set source: ImageSource.camera to get image from camera
    setState(() {
      uploadImage = choosedImage;
    });*/

    ImagePicker picker = ImagePicker();
    XFile? choosedImage = await picker.pickImage(source: ImageSource.gallery);
    File imageFile;
    imageFile = File(choosedImage!.path);
    var bytes = imageFile.readAsBytesSync().lengthInBytes;
    if (bytes > 2097152) {
      //restrict upload image size to 2MB
      CustomToast.show(getTranslatedText("image_size_limit"));
    } else {
      setState(() {
        uploadImage = imageFile;
      });
    }
  }

  _handleApiState() {
    handleApiState(_vm.uploadDepositImageApiState, onSuccess: () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
            title: null,
            description: getTranslatedText("upload_success"),
            buttonText1: getTranslatedText("confirm"),
            onClick: () {
              Navigator.pop(
                context,
              );
              Navigator.pop(
                context,
              );
            },
            onClick2: () {
              Navigator.pop(context);
            },
            popIndex: 2,
          ),
        );
      });
    });
  }
}
