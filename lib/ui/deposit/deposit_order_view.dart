import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:api/entity/deposit_redirect.dart';
import 'package:api/entity/deposit_redirect_applepay.dart';
import 'package:api/entity/manual_deposit_order.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';

import 'deposit_view_model.dart';
import 'deposit_web.dart';

class DepositOrderView extends StatefulWidget {
  final String method;
  final String id;
  final ManualDepositOrder manualDepositOrder;
  final DepositRedirect depositRedirect;
  final String depositAmount;
  final String depositChannel;
  final String orderNo;
  final String promotionName;
  final String transName;
  final DepositRedirectApplePay depositRedirectApplePay;
  final String exchangeRate;
  final String expectedAmount;

  DepositOrderView(
      {Key key,
      this.method,
      this.id,
      this.manualDepositOrder,
      this.depositRedirect,
      this.depositAmount,
      this.depositChannel,
      this.orderNo,
      this.promotionName,
      this.transName,
      this.depositRedirectApplePay,
      this.exchangeRate,
      this.expectedAmount})
      : super(key: key);

  @override
  _DepositOrderViewState createState() => _DepositOrderViewState();
}

class _DepositOrderViewState extends BaseState<DepositOrderView> {
  File uploadImage;
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
          return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.grey[100],
              appBar: _buildAppBar(),
              body: widget.depositRedirect != null || widget.depositRedirectApplePay != null
                  ? _buildLeepayOrder()
                  : _buildManualDepositOrder());
        });
  }

  _buildAppBar() => AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: gradientDecoration,
        ),
        centerTitle: true,
        title: Text(
          getTranslatedText("deposit"),
          style: TextStyle(fontSize: 20.auto, color: CustomColor.theme_text_color2),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );

  _buildManualDepositOrder() => ListView(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white),
            padding: EdgeInsets.only(left: 15.auto, right: 15.auto, top: 15.auto, bottom: 15.auto),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    getTranslatedText("amount"),
                    style: TextStyle(fontSize: 13.auto, color: CustomColor.grey),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "¥ ${widget.manualDepositOrder.amount.toString()}",
                    style: TextStyle(
                        fontSize: (38.5).auto, color: CustomColor.theme_button_color, fontWeight: FontWeight.w400),
                  ),
                ),
                Divider(
                  thickness: (1.0).auto,
                  color: CustomColor.very_light_pink_four,
                ),
                //_buildText("deposit_channel", widget.manualDepositOrder.methodName),
                _buildOrderText("order_no", widget.orderNo),
                _buildText("payment_type", widget.manualDepositOrder.methodName),
                _buildText("payment_channel", widget.manualDepositOrder.methodName),
                _buildText("receiver_bank", widget.manualDepositOrder.bankAccountName),
                _buildText("receiver_bank_account", widget.manualDepositOrder.bankAccount),
                if (widget.promotionName != null) _buildText("promotion_picker", widget.promotionName ?? ""),
                _buildUploadTextRow(),
                uploadImage == null
                    ? Container()
                    : Container(
                        alignment: Alignment.centerRight, child: SizedBox(height: 80, child: Image.file(uploadImage)))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 15.auto, right: 15.auto, top: 10.auto),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ColorButton(
                    title: getTranslatedText("upload_prof"),
                    onClick: () => _vm.uploadDepositImage(uploadImage.path, widget.id),
                    isEnabled: uploadImage == null ? false : true,
                    radius: 4.8,
                    height: 44.5),
                Container(
                    margin: EdgeInsets.only(top: 10.auto),
                    child: ColorButton(
                        title: getTranslatedText("cancel_deposit"),
                        onClick: () => Navigator.pop(context),
                        isEnabled: true,
                        radius: 4.8,
                        height: 44.5))
                /*RaisedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: CustomColor.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.auto),
                    child: Text(
                      getTranslatedText("cancel_deposit"),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                RaisedButton(
                    onPressed: () => {_vm.uploadDepositImage(uploadImage.path, widget.id)},
                    color: CustomColor.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.auto),
                      child: Text(
                        getTranslatedText("upload_prof"),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    )),*/
              ],
            ),
          )
        ],
      );

  _buildLeepayOrder() => ListView(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white),
            padding: EdgeInsets.only(left: 15.auto, right: 15.auto, top: 15.auto, bottom: 15.auto),
            child: Column(
              children: [
                Container(
                  //decoration: BoxDecoration(color: Colors.white),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    getTranslatedText("amount"),
                    style: TextStyle(fontSize: 13.auto, color: CustomColor.grey),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    //"10.00",
                    widget.depositAmount,
                    style: TextStyle(
                        fontSize: (38.5).auto, color: CustomColor.theme_button_color, fontWeight: FontWeight.w400),
                    //"¥ $amount"
                  ),
                ),
                Divider(
                  thickness: (1.0).auto,
                  color: CustomColor.very_light_pink_four,
                ),
                widget.depositRedirect != null
                    ? _buildOrderText("order_no", widget.depositRedirect.formId)
                    : _buildOrderText("order_no", widget.depositRedirectApplePay.formId),
                _buildText("payment_type", widget.method),
                _buildText("payment_channel", widget.depositChannel),
                if (widget.exchangeRate != null) _buildText("exchange_rate", widget.exchangeRate),
                if (widget.expectedAmount != null) _buildText("expected_amount", widget.expectedAmount),
                if (widget.transName != null) _buildText("transfer_name", widget.transName ?? ""),
                if (widget.promotionName != null) _buildText("promotion_picker", widget.promotionName ?? ""),
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.only(left: 15.auto, right: 15.auto, top: 10.auto),
              child: ColorButton(
                  title: getTranslatedText("done"),
                  radius: 4.8,
                  height: 44.5,
                  isEnabled: true,
                  onClick: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DepositWeb(
                              url: widget.depositRedirect != null
                                  ? widget.depositRedirect.paymentUrl
                                  : widget.depositRedirectApplePay.paymentUrl)))))
        ],
      );

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
                content ?? "",
                style: TextStyle(fontSize: 13.auto, color: Colors.black),
                minFontSize: 2,
                maxLines: 1,
                textAlign: TextAlign.end,
              ),
            )
          ],
        ),
      );

  _buildText(String title, String content) {
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
            Text(
              getTranslatedText("upload_prof_hint"),
              style: TextStyle(fontSize: 10.auto, color: CustomColor.grey),
            ),
            ColorButton(
              title: getTranslatedText("pick_prof"),
              width: 70.auto,
              height: 30.auto,
              onClick: () {
                chooseImage();
              },
              isEnabled: true,
              color: CustomColor.theme_button_color,
              radius: 9.6,
            )
          ],
        ),
      );

  Future<void> chooseImage() async {
    File choosedImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    //set source: ImageSource.camera to get image from camera
    setState(() {
      uploadImage = choosedImage;
    });
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
          ),
        );
      });
    });
  }
}
