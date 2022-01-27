import 'dart:io';

import 'package:api/entity/bank_type.dart';
import 'package:api/entity/deposit_redirect.dart';
import 'package:api/entity/manual_deposit_order.dart';
import 'package:api/entity/payment_qr_code.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tgp_flutter2/custom/card_text_form_field.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:tgp_flutter2/custom/custom_picker.dart';
import 'package:tgp_flutter2/custom/custom_picker_dialog.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_text_form_field.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:api/entity/payment.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/deposit/deposit_html.dart';
import 'package:tgp_flutter2/ui/deposit/deposit_method_view_model.dart';
import 'package:tgp_flutter2/ui/deposit/deposit_order_view.dart';
import 'package:tgp_flutter2/ui/deposit/manual_deposit_order_view.dart';

class DepositMethod extends StatefulWidget {
  final String? paymentCode;
  final Map<BankType, List<Payment>>? depositMethodList;
  final List<Map<String, String>>? promotionList;

  DepositMethod({
    this.paymentCode,
    this.depositMethodList,
    this.promotionList,
  });

  @override
  _DepositMethodState createState() => _DepositMethodState();
}

class _DepositMethodState extends BaseState<DepositMethod> with AutomaticKeepAliveClientMixin {
  String? methodPickerText, channelPickerText, promotionPickerText;
  TextEditingController _amountController = TextEditingController(),
      _bankNameController = TextEditingController(),
      _transferNameController = TextEditingController();
  var isButtonEnabled = false, isHintText = false, isPromotionEnabled = false;
  var selectedPayment;
  var paymentMin, paymentMax;
  int? amount;
  late DepositMethodViewModel _vm;
  Payment? _payment;
  String? promotionName, promotionId;
  var paymentChannelId;
  var currBankType;
  File? uploadImage;

  void initState() {
    _vm = DepositMethodViewModel(widget.depositMethodList!);
    if (_vm.depositMethodList!.isNotEmpty) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        onSelectedMethod(_vm.depositMethodList!.keys.first);
      });
    }
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  Widget build(BuildContext context) {
    super.build(context);
    return ProviderWidget<DepositMethodViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return Container(
            margin: EdgeInsets.only(
                left: 10.auto, right: 10.auto, top: 10.auto, bottom: MediaQuery.of(context).viewInsets.bottom),
            child: ListView(
              children: [
                _buildCard("deposit_method", _vm.depositMethodList!.keys.toList(), isDepositMethod: true),
                _buildCard("deposit_channel", _vm.paymentList),
                if (_isManualDeposit()) _buildTransferToAccount(_payment?.methodCode, _payment?.qrCode),
                if (isShowBankAcc()) _buildNameTextField("bank_acc_name", "enter_bank_acc_name", _bankNameController),
                if (_isApplePayDeposit())
                  _buildNameTextField("transfer_name", "enter_transfer_name", _transferNameController),
                _buildAmountTextField(),
                if (_isShowExchangeRateText())
                  _buildExchangeRateText(),
                if (_isUmPayDeposit()) _buildHintText(),
                _buildCard("promotion_picker", widget.promotionList),
                _buildUploadImageColumn(),
                _buildButton(),
              ],
            ),
          );
        });
  }

  _buildCard(String title, List<dynamic>? list, {bool isDepositMethod = false}) {
    var display;
    if (list is List<BankType>) {
      display = methodPickerText;
      isHintText = false;
    } else if (list is List<Payment>) {
      display = channelPickerText;
      isHintText = false;
    } else if (list is List<Map<String, dynamic>>) {
      if (promotionName == null || promotionName == getTranslatedText("promotion_picker_hint")) {
        display = getTranslatedText("promotion_picker_hint");
        isHintText = true;
      } else {
        display = promotionName;
        isHintText = false;
      }
    } else
      display = "";
    return Container(
        margin: EdgeInsets.only(bottom: 15.auto,),
        child: Opacity(
          opacity: 1,
          child: CustomPicker(
            title: title,
            displayText: display ?? "",
            //isDeposit? depositText??"请选择红利": pickerText?? "",
            list: list ?? [],
            isHintText: isHintText,
            width: context.screenWidth,
            onClick: (list?.isEmpty ?? true)
                ? () {
                    CustomToast.show(getTranslatedText("empty_promotion"));
                  }
                : () {
                    _buildBottomSheet(title, list ?? []);
                  },
          ),
        ));
  }

  _buildBottomSheet(String title, List<dynamic> list) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return CustomPickerDialog(
              title: title,
              list: list,
              onChanged: (value) {
                setState(() {
                  if (value is BankType)
                    onSelectedMethod(value);
                  else if (value is Payment) {
                    onSelectedChannel(
                      value,
                    );
                  } else if (value is Map<String, String>) {
                    onSelectedPromotion(
                      value,
                    );
                  }
                  /*ielse if(value is PaymentBank) onSelectedBank(value as PaymentBank);
                  else if(value is DepositBonusGroup) onSelectedDepositGroup(value as DepositBonusGroup);
                  else if(value is DepositBonus) onSelectedDeposit(value as DepositBonus);*/
                  Navigator.pop(context);
                  FocusScope.of(context).unfocus();
                });
              });
        });
  }

  _buildAmountTextField() => Container(
        //margin: EdgeInsets.only(top: 15.auto),
        child: CustomTextFormField(
          title: getTranslatedText("deposit_amount") ?? "",
          hintText: getTranslatedText("enter") +
              " " +
              (Format().amountFormat(paymentMin)) +
              "-" +
              (Format().amountFormat(paymentMax)),
          onChanged: (value) => onTextChange(),
          onFieldSubmitted: (value) => onTextChange(),
          controller: _amountController,
          width: context.screenWidth - 70.auto,
          textInputType: TextInputType.number,
          textInputAction: TextInputAction.done,
          bottomMargin: _isUmPayDeposit()|| _isShowExchangeRateText() ? 0 : 15,
        ),
      );

  _buildNameTextField(String title, String hint, TextEditingController controller) => Container(
        child: CustomTextFormField(
          title: getTranslatedText(title),
          hintText: getTranslatedText(hint),
          onChanged: (value) => onTextChange(),
          onFieldSubmitted: (value) => onTextChange(),
          controller: controller,
          width: context.screenWidth - 70.auto,
          textInputType: TextInputType.text,
          textInputAction: TextInputAction.next,
        ),
      );

  _buildButton() => Container(
      margin: EdgeInsets.only(
        left: 10.auto,
        right: 10.auto,
        top: 15.auto,
      ),
      child: ColorButton(
        onClick: () => _onClick(),
        title: getTranslatedText("submit"),
        color: CustomColor.theme_button_color,
        radius: 9.6,
        isEnabled: isButtonEnabled,
      ));

  _buildExchangeRateText() => Container(
        margin: EdgeInsets.only(
          left: 10.auto,
          right: 10.auto,
          bottom: 20.auto
        ),
        child: Row(
          children: [
            Text(
              getTranslatedText("exchange_rate") + ": ",
              style: TextStyle(fontSize: 13.auto, color: CustomColor.theme_text_grey_white_color),
            ),
            Text(
              _vm.exchangeRate ?? "0.00",
              style: TextStyle(fontSize: 13.auto, color: CustomColor.theme_button_color),
            ),
            Spacer(),
            Text(
              getTranslatedText("expected_amount") + ": ",
              style: TextStyle(fontSize: 13.auto, color: CustomColor.theme_text_grey_white_color),
            ),
            Text(
              _calculateExpectedAmount(),
              style: TextStyle(fontSize: 13.auto, color: CustomColor.theme_button_color),
            ),
          ],
        ),
      );

  _buildTransferToAccount(String? methodCode, PaymentQrCode? paymentQrCode) {
    if (paymentQrCode == null || (_vm.config?.deposit_DualPage ?? false)) return Container();

    List<Widget> content = methodCode?.toUpperCase() == "THIRDPARTY" && paymentQrCode.qrCodeFileUrl != null
        ? _buildTransferToQr(paymentQrCode.qrCodeFileUrl!)
        : (paymentQrCode.name != null && paymentQrCode.bankAccount != null)
            ? _buildTransferToBank(paymentQrCode.logo, paymentQrCode.name!, paymentQrCode.bankAccount!)
            : [];

    if (content.isNotEmpty) {
      return Container(
        margin: EdgeInsets.only(
          left: 10.auto,
          right: 10.auto,
          top: 13.auto,
          bottom: 18.auto,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getTranslatedText("deposit_to_account"),
              style: TextStyle(
                fontSize: 12.auto,
                  color: CustomColor.theme_text_black_white_color
              ),
            ),
            SizedBox(height: 3.auto),
          ]..addAll(content),
        ),
      );
    }
    return Container();
  }

  _buildTransferToQr(String qrUrl) {
    return [
      /* Image.network(
        qrUrl,
        width: 100,
        height: 100,
      )*/
      CachedNetworkImage(
        placeholder: (context, url) => Container(
          color: CustomColor.very_light_pink_four,
        ),
        imageUrl: qrUrl,
        width: 100,
        height: 100,
        //handling error
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Container(),
      ),
    ];
  }

  _buildTransferToBank(String? logo, String name, String bankAccount) {
    return [
      logo != null
          ? CachedNetworkImage(
              width: 120.auto,
              placeholder: (context, url) => Container(
                    color: CustomColor.very_light_pink_four,
                  ),
              imageUrl: logo,
              //handling error
              fit: BoxFit.fill)
          : Container(),
      SizedBox(height: 3.auto),
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          Text(
            getTranslatedText("deposit_to_bank_account_name") + ": ",
            style: TextStyle(
                fontSize: 11.auto, fontWeight: FontWeight.bold, color: CustomColor.theme_text_grey_white_color),
          ),
          Text(
            name,
            style: TextStyle(fontSize: 11.auto, color: CustomColor.theme_text_grey_white_color),
          ),
        ],
      ),
      SizedBox(height: 3.auto),
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          Text(
            getTranslatedText("card_number") + ": ",
            style: TextStyle(
                fontSize: 11.auto, fontWeight: FontWeight.bold, color: CustomColor.theme_text_grey_white_color),
          ),
          Text(
            bankAccount,
            style: TextStyle(fontSize: 11.auto, color: CustomColor.theme_text_grey_white_color),
          ),
        ],
      ),
    ];
  }

  _buildHintText() => Container(
        margin: EdgeInsets.only(
          left: 10.auto,
          right: 10.auto,
          bottom: 20.auto
        ),
        child: AutoSizeText(
          getTranslatedText("play_pay_hint_text"),
          style: TextStyle(color: CustomColor.theme_text_grey_white_color, fontSize: 15),
          minFontSize: 10,
          maxFontSize: 13,
          stepGranularity: 1,
          maxLines: 2,
        ),
      );

  _buildUploadImageColumn() => Visibility(
        visible: _isManualDeposit() && !(_vm.config?.deposit_DualPage ?? false),
        child: Container(
          padding: EdgeInsets.only(left: 5.auto, right: 5.auto),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(
                  left: 5.auto,
                  bottom: 5.auto,
                ),
                child: Text(
                  getTranslatedText("upload_prof"),
                  style: TextStyle(
                    fontSize: 12.auto,
                    color: CustomColor.theme_text_black_white_color
                  ),
                ),
              ),
              Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 5,
                child: Column(
                  children: [
                    _buildUploadTextRow(),
                    uploadImage == null
                        ? Container()
                        : Container(
                            padding: EdgeInsets.all(10.auto),
                            alignment: Alignment.centerRight,
                            child: SizedBox(height: 80, child: Image.file(uploadImage!))),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  _buildUploadTextRow() => Visibility(
        visible: _isManualDeposit() && !(_vm.config?.deposit_DualPage ?? false),
        child: Container(
          margin: EdgeInsets.only(
            left: 10.auto,
            right: 10.auto,
          ),
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
                  height: 20.auto,
                  onClick: () {
                    chooseImage();
                  },
                  isEnabled: true,
                  radius: 9.6,
                ),
              )
            ],
          ),
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
    if (bytes > 10485760) {
      //restrict upload image to 10MB
      CustomToast.show(getTranslatedText("image_size_limit"));
    } else {
      setState(() {
        uploadImage = imageFile;
      });
      onTextChange();
    }
  }

  _calculateExpectedAmount() {
    if (_vm.exchangeRate != null) {
      var expectedAmount = (amount ?? 0) * (1 / double.parse(_vm.exchangeRate));
      return Format().doubleToString(expectedAmount);
    } else
      return "0.00";
  }

  onTextChange() {
    if (_amountController.text.isNotEmpty) {
      amount = int.parse(_amountController.text);
    } else {
      amount = 0;
    }
    if (isShowBankAcc() &&
        _bankNameController.text.isNotEmpty &&
        uploadImage?.path != null &&
        amount! >= paymentMin &&
        amount! <= paymentMax) {
      //is manual deposit or apple deposit, and showing bank account
      setState(() {
        isButtonEnabled = true;
      });
    } else if ((_isManualDeposit() || _isApplePayDeposit()) &&
        (_vm.config?.depositManualApplePayHideBankAcc ?? false) &&
        uploadImage?.path != null &&
        amount! >= paymentMin &&
        amount! <= paymentMax) {
      //is manual deposit or apple deposit, but not showing bank account
      setState(() {
        isButtonEnabled = true;
      });
    } else if (!(_isManualDeposit() && _isApplePayDeposit()) && amount! >= paymentMin && amount! <= paymentMax) {
      setState(() {
        isButtonEnabled = true;
      });
    } else {
      setState(() {
        isButtonEnabled = false;
      });
    }
  }

  _onClick() {
    ProgressDialog.show(context, _vm.brandLogoUrl);
    switch (widget.paymentCode) {
      case "Manual":
        _vm.getManualDepositId(currBankType, _bankNameController.text, _amountController.text, _payment!.id,
            promotionId ?? null, uploadImage?.path);
        break;
      case "ApplePay":
        _vm.applePayDepositOrder(
            _amountController.text, _payment!.id, promotionId ?? null, _transferNameController.text);
        break;
      case "PrimePay":
        _vm.primePayDepositOrder(_amountController.text, _payment!.id, promotionId ?? null);
        break;
      case "UmPay":
        _vm.umPayDepositOrder(_amountController.text, _payment!.id, promotionId ?? null, methodPickerText == "Crypto");
        break;
      case "MaticPay":
        _vm.maticPayDepositOrder(_amountController.text, _payment!.id, promotionId ?? null);
        break;
      case "LeePay":
        _vm.leePayDepositOrder(_amountController.text, _payment!.id, promotionId ?? null);
        break;
      case "Help2Pay":
        _vm.help2PayDepositOrder(_amountController.text, _payment!.id, promotionId ?? null);
        break;
      case "SkyPay":
        _vm.skyPayDepositOrder(_amountController.text, _payment!.id, promotionId ?? null);
        break;
      default:
        _vm.getManualDepositId(currBankType, _bankNameController.text, _amountController.text, _payment!.id,
            promotionId ?? null, uploadImage!.path);
        break;
    }
  }

  _isManualDeposit() => widget.paymentCode == "Manual";

  _isApplePayDeposit() => widget.paymentCode == "ApplePay";

  _isLeePayDeposit() => widget.paymentCode == "LeePay";

  _isUmPayDeposit() => widget.paymentCode == "UmPay";

  _isShowExchangeRateText() => _isLeePayDeposit() || (_isUmPayDeposit() && methodPickerText == getTranslatedText("crypto"));

  onSelectedMethod(BankType bankType) async {
    _vm.filterMethod(bankType);
    onSelectedChannel(_vm.paymentList!.first);
    setState(() {
      currBankType = bankType;
      methodPickerText = bankType.getName(context);
    });
  }

  onSelectedChannel(Payment payment) {
    setState(() {
      _payment = payment;
      channelPickerText = (payment.channelName ?? "").replaceAll("_", " ");
      paymentMin = payment.transferLimit?.from ?? 0;
      paymentMax = payment.transferLimit?.to ?? 0;
    });
    if (_isLeePayDeposit())
      _vm.getExchangeRate(_payment!.id, false);
    else if (_isUmPayDeposit() && methodPickerText == "Crypto") _vm.getExchangeRate(_payment!.id, true);
  }

  onSelectedPromotion(Map<String, String> map) {
    setState(() {
      promotionName = getTranslatedText(map["name"]!) ?? map["name"];
      if (map["id"] == "-1") {
        promotionId = null;
      } else {
        promotionId = map["id"];
      }
    });
  }

  _clearTextField() {
    setState(() {
      _amountController.clear();
      _bankNameController.clear();
      _transferNameController.clear();
      promotionId = null;
      isButtonEnabled = false;
      uploadImage = null;
    });
  }

  isShowBankAcc() =>
      (_isManualDeposit() || _isApplePayDeposit()) && !(_vm.config?.depositManualApplePayHideBankAcc ?? false);

  _handleApiState() {
    handleApiState(_vm.getLeepayOrderApiState, isRequireResult: true, onSuccess: (result) {
      _navigateToDepositOrder(
          depositRedirect: _vm.getLeepayOrderApiState.result,
          exchangeRate: _vm.exchangeRate,
          expectedAmount: _calculateExpectedAmount());
    });
    handleApiState(_vm.getUmPayDepositOrderApiState, isRequireResult: true, onSuccess: (result) {
      methodPickerText == "Crypto"
          ? _navigateToDepositOrder(
              depositRedirect: _vm.getUmPayDepositOrderApiState.result,
              exchangeRate: _vm.exchangeRate,
              expectedAmount: _calculateExpectedAmount())
          : _navigateToDepositOrder(depositRedirect: _vm.getUmPayDepositOrderApiState.result);
    });
    handleApiState(_vm.primePayDepositOrderApiState, onSuccess: () {
      _navigateToDepositOrder(depositRedirect: _vm.primePayDepositOrderApiState.result);
    });

    handleApiState(_vm.getManualDepositIdApiState, isRequireResult: true, onSuccess: (result) {
      paymentChannelId = result;
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        ProgressDialog.show(context, _vm.brandLogoUrl);
      });
    });
    handleApiState(_vm.getDepositOrderApiState, onSuccess: () {
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ManualDepositOrderView(
                      id: paymentChannelId,
                      method: _payment!.methodCode,
                      depositAmount: Format().currencyWithDecimalFormat(double.parse(_amountController.text)),
                      depositChannel: channelPickerText!,
                      promotionName: promotionId != "-1" ? promotionName : null,
                      orderNo: _vm.orderNo,
                      manualDepositOrder: _vm.getDepositOrderApiState.result,
                      paymentQrCode: _payment!.qrCode,
                    )));
        _clearTextField();
      });
    });
    handleApiState(_vm.applePayDepositOrderApiState, onSuccess: () {
      if (_vm.applePayDepositOrderApiState.result.errorMsg.isEmpty) {
        _navigateToDepositOrder(
          depositRedirect: _vm.applePayDepositOrderApiState.result,
          exchangeRate: _vm.exchangeRate,
          expectedAmount: _calculateExpectedAmount(),
          transferName: _transferNameController.text,
        );
      } else
        CustomToast.show(_vm.applePayDepositOrderApiState.result.errorMsg);
    });

    handleApiState(_vm.maticPayDepositOrderApiState, onSuccess: () {
      _navigateToDepositOrder(
          depositRedirect: _vm.maticPayDepositOrderApiState.result,
          exchangeRate: _vm.exchangeRate,
          expectedAmount: _calculateExpectedAmount());
    });
    handleApiState(_vm.getExchangeRateApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.help2PayDepositOrderApiState, onSuccess: () {
      /*_navigateToDepositOrder(
          depositRedirect: _vm.help2PayDepositOrderApiState.result,
          exchangeRate: _vm.exchangeRate,
          expectedAmount: _calculateExpectedAmount());*/
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        await _vm.getHelp2PayHtmlText(_vm.help2PayDepositOrderApiState.result.paymentUrl);
      });
    });

    handleApiState(_vm.getHelp2PayHtmlTextApiState, onSuccess: () {
      /*_navigateToDepositOrder(
          depositRedirect: _vm.help2PayDepositOrderApiState.result,
          exchangeRate: _vm.exchangeRate,
          expectedAmount: _calculateExpectedAmount());*/
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DepositHtml(
                      htmlText: _vm.getHelp2PayHtmlTextApiState.result.toString(),
                    )));
      });
    });

    handleApiState(_vm.skyPayDepositOrderApiState, onSuccess: () {
      _navigateToDepositOrder(
        depositRedirect: _vm.skyPayDepositOrderApiState.result,
      );
    });

    handleApiState(_vm.uploadDepositImageApiState, onSuccess: () {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
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
              _clearTextField();
            },
          ),
        );
      });
    });
  }

  _navigateToDepositOrder({
    DepositRedirect? depositRedirect,
    String? exchangeRate,
    String? expectedAmount,
    String? transferName,
    String? htmlText,
  }) =>
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DepositOrderView(
                      method: _payment?.methodCode,
                      depositRedirect: depositRedirect,
                      depositAmount: Format().currencyWithDecimalFormat(double.parse(_amountController.text)),
                      depositChannel: channelPickerText,
                      promotionName: promotionId != "-1" ? promotionName : null,
                      //orderNo: orderNo,
                      exchangeRate: exchangeRate,
                      expectedAmount: expectedAmount,
                      transName: transferName,
                      htmlText: htmlText,
                      id: _payment?.id ?? "",
                    )));
        _clearTextField();
      });
}
