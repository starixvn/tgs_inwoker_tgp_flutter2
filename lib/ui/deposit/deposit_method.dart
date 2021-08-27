import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/card_text_form_field.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_picker.dart';
import 'package:tgp_flutter2/custom/custom_picker_dialog.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_text_form_field.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:api/entity/payment.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/deposit/deposit_method_view_model.dart';
import 'package:tgp_flutter2/ui/deposit/deposit_order_view.dart';

class DepositMethod extends StatefulWidget {
  final String paymentCode;
  final Map<String, List<Payment>> depositMethodList;
  final List<Map<String, String>> promotionList;

  DepositMethod({Key key, this.paymentCode, this.depositMethodList, this.promotionList}) : super(key: key);

  @override
  _DepositMethodState createState() => _DepositMethodState();
}

class _DepositMethodState extends BaseState<DepositMethod> with AutomaticKeepAliveClientMixin {
  String methodPickerText, channelPickerText, promotionPickerText;
  TextEditingController _amountController = TextEditingController(),
      _bankNameController = TextEditingController(),
      _transferNameController = TextEditingController();
  var isButtonEnabled = false, isHintText = false;
  var selectedPayment;
  var paymentMin, paymentMax;
  int amount;

  DepositMethodViewModel _vm;
  Payment _payment;
  String promotionName, promotionId;
  var paymentChannelId;

  void initState() {
    _vm = DepositMethodViewModel(widget.depositMethodList);
    if (_vm.depositMethodList.isNotEmpty) {
      methodPickerText = _vm.depositMethodList.keys.first;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onSelectedMethod(methodPickerText);
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
                _buildCard("deposit_method", _vm.depositMethodList.keys.toList(), isDepositMethod: true),
                _buildCard("deposit_channel", _vm.paymentList),
                if (_isManualDeposit())
                  _buildNameTextField("bank_acc_name", "enter_bank_acc_name", _bankNameController),
                if (_isApplePayDeposit())
                  _buildNameTextField("transfer_name", "enter_transfer_name", _transferNameController),
                _buildAmountTextField(),
                if (_isLeePayDeposit() || (_isUmPayDeposit() && methodPickerText == "Crypto")) _buildExchangeRateText(),
                _buildCard("promotion_picker", widget.promotionList),
                _buildButton(),
              ],
            ),
          );
        });
  }

  _buildCard(String title, List<dynamic> list, {bool isDepositMethod = false}) {
    var display;
    if (list is List<String>) {
      if (methodPickerText == "BankTransfer")
        display = getTranslatedText("bank_transfer");
      else
        display = getTranslatedText(methodPickerText.toLowerCase());
      isHintText = true;
    } else if (list is List<Payment>) {
      display = channelPickerText;
      isHintText = true;
    } else if (list is List<Map<String, dynamic>>) {
      if (promotionName != null) {
        display = promotionName;
        isHintText = true;
      } else {
        display = getTranslatedText("promotion_picker_hint");
        isHintText = true;
      }
    } else
      display = "";
    return Container(
        margin: EdgeInsets.only(top: 10.auto),
        child: Opacity(
          opacity: 1,
          child: CustomPicker(
            title: title,
            displayText: display ?? "",
            //isDeposit? depositText??"请选择红利": pickerText?? "",
            list: list,
            isHintText: isHintText,
            width: context.screenWidth,
            onClick: () {
              _buildBottomSheet(title, list);
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
                  if (value is String)
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
                });
              });
        });
  }

  _buildAmountTextField() => Container(
        margin: EdgeInsets.only(top: 10.auto),
        child: CardTextFormField(
          title: getTranslatedText("deposit_amount") ?? "",
          hintText: getTranslatedText("enter") +
              (Format().amountFormat(paymentMin) ?? "10.00") +
              "-" +
              (Format().amountFormat(paymentMax) ?? "100,000") +
              getTranslatedText("yuan"),
          onChanged: (value) => onTextChange(),
          onFieldSubmitted: (value) => onTextChange(),
          controller: _amountController,
          width: context.screenWidth - 70.auto,
          textInputType: TextInputType.number,
          textInputAction: TextInputAction.done,
        ),
      );

  _buildNameTextField(String title, String hint, TextEditingController controller) => Container(
        margin: EdgeInsets.only(top: 10.auto),
        child: CardTextFormField(
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
        title: getTranslatedText("next"),
        color: CustomColor.theme_button_color,
        radius: 9.6,
        isEnabled: isButtonEnabled,
      ));

  _buildExchangeRateText() => Container(
        margin: EdgeInsets.only(
          left: 10.auto,
          right: 10.auto,
          top: 5.auto,
        ),
        child: Row(
          children: [
            Text(
              getTranslatedText("exchange_rate") + ": ",
              style: TextStyle(fontSize: 13.auto, color: CustomColor.grey),
            ),
            Text(
              _vm.exchangeRate ?? "0.00",
              style: TextStyle(fontSize: 13.auto, color: CustomColor.theme_button_color),
            ),
            Spacer(),
            Text(
              getTranslatedText("expected_amount") + ": ",
              style: TextStyle(fontSize: 13.auto, color: CustomColor.grey),
            ),
            Text(
              _calculateExpectedAmount(),
              style: TextStyle(fontSize: 13.auto, color: CustomColor.theme_button_color),
            ),
          ],
        ),
      );

  _calculateExpectedAmount() {
    if (_vm.exchangeRate != null) {
      var expectedAmount = (amount ?? 0) * (1 / double.parse(_vm.exchangeRate)) ?? 0.00;
      return Format().doubleToString(expectedAmount);
    } else
      return "0.00";
  }

  onTextChange() {
    if (_amountController.text != null && _amountController.text.isNotEmpty) {
      amount = int.parse(_amountController.text);
    } else {
      amount = 0;
    }
    if (_isManualDeposit() &&
        _bankNameController.text != null &&
        _bankNameController.text.isNotEmpty &&
        amount >= paymentMin &&
        amount <= paymentMax) {
      setState(() {
        isButtonEnabled = true;
      });
    } else if (amount >= paymentMin && amount <= paymentMax) {
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
    ProgressDialog.show(context);
    if (_isManualDeposit())
      _vm.getManualDepositId(_bankNameController.text, _amountController.text, _payment.id, promotionId ?? null);
    else if (_isApplePayDeposit())
      _vm.applePayDepositOrder(_amountController.text, _payment.id, promotionId ?? null, _transferNameController.text);
    else if (widget.paymentCode == "PrimePay") {
      _vm.primePayDepositOrder(_amountController.text, _payment.id, promotionId ?? null);
    }else if (_isUmPayDeposit()) {
      _vm.umPayDepositOrder(_amountController.text, _payment.id, promotionId ?? null, methodPickerText == "Crypto");
    } else //currently is LeePay
      _vm.leePayDepositOrder(_amountController.text, _payment.id, promotionId ?? null);
  }

  _isManualDeposit() {
    return widget.paymentCode == "Manual";
  }

  _isApplePayDeposit() {
    return widget.paymentCode == "ApplePay";
  }

  _isLeePayDeposit() {
    return widget.paymentCode == "LeePay";
  }

  _isUmPayDeposit() {
    return widget.paymentCode == "UmPay";
  }

  onSelectedMethod(String method) async {
    _vm.filterMethod(method);
    onSelectedChannel(_vm.paymentList.first);
    setState(() {
      methodPickerText = method;
    });
  }

  onSelectedChannel(Payment payment) {
    setState(() {
      _payment = payment;
      channelPickerText = payment.channelName.replaceAll("_", " ");
      paymentMin = payment.transferLimit.from;
      paymentMax = payment.transferLimit.to;
    });
    if (_isLeePayDeposit()) _vm.getExchangeRate(_payment.id, false);
    else if(_isUmPayDeposit() && methodPickerText == "Crypto")_vm.getExchangeRate(_payment.id, true);
  }

  onSelectedPromotion(Map<String, String> map) {
    setState(() {
      promotionName = getTranslatedText(map["name"]) ?? map["name"];
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
    });
  }

  _handleApiState() {
    handleApiState(_vm.getLeepayOrderApiState, isRequireResult: true, onSuccess: (result) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DepositOrderView(
                      method: _payment.methodCode,
                      depositRedirect: _vm.getLeepayOrderApiState.result,
                      depositAmount: Format().currencySymbolWithDecimalFormat(double.parse(_amountController.text)),
                      depositChannel: channelPickerText,
                      promotionName: promotionId != "-1" ? promotionName : null,
                      exchangeRate: _vm.exchangeRate,
                      expectedAmount: _calculateExpectedAmount(),
                    )));
        _clearTextField();
      });
    });
    handleApiState(_vm.getUmPayDepositOrderApiState, isRequireResult: true, onSuccess: (result) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => methodPickerText == "Crypto"?DepositOrderView(
                  method: _payment.methodCode,
                  depositRedirect: _vm.getUmPayDepositOrderApiState.result,
                  depositAmount: Format().currencySymbolWithDecimalFormat(double.parse(_amountController.text)),
                  depositChannel: channelPickerText,
                  promotionName: promotionId != "-1" ? promotionName : null,
                  exchangeRate: _vm.exchangeRate,
                  expectedAmount: _calculateExpectedAmount(),
                ):DepositOrderView(
                  method: _payment.methodCode,
                  depositRedirect: _vm.getUmPayDepositOrderApiState.result,
                  depositAmount: Format().currencySymbolWithDecimalFormat(double.parse(_amountController.text)),
                  depositChannel: channelPickerText,
                  promotionName: promotionId != "-1" ? promotionName : null,
                )));
        _clearTextField();
      });
    });
    handleApiState(_vm.primePayDepositOrderApiState, onSuccess: () {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DepositOrderView(
                      method: _payment.methodCode,
                      depositRedirect: _vm.primePayDepositOrderApiState.result,
                      depositAmount: Format().currencySymbolWithDecimalFormat(double.parse(_amountController.text)),
                      depositChannel: channelPickerText,
                      promotionName: promotionId != "-1" ? promotionName : null,
                    )));
        _clearTextField();
      });
    });

    handleApiState(_vm.getManualDepositIdApiState, isRequireResult: true, onSuccess: (result) {
      paymentChannelId = result;
    });
    handleApiState(_vm.getDepositOrderApiState, onSuccess: () {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DepositOrderView(
                      method: _payment.methodCode,
                      id: paymentChannelId,
                      manualDepositOrder: _vm.getDepositOrderApiState.result,
                      depositAmount: Format().currencySymbolWithDecimalFormat(double.parse(_amountController.text)),
                      depositChannel: channelPickerText,
                      orderNo: _vm.orderNo,
                      promotionName: promotionId != "-1" ? promotionName : null,
                    )));
        _clearTextField();
      });
    });

    handleApiState(_vm.applePayDepositOrderApiState, onSuccess: () {
      if (_vm.applePayDepositOrderApiState.result.errorMsg.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DepositOrderView(
                        method: _payment.methodCode,
                        depositRedirectApplePay: _vm.applePayDepositOrderApiState.result,
                        depositAmount: Format().currencySymbolWithDecimalFormat(double.parse(_amountController.text)),
                        depositChannel: channelPickerText,
                        transName: _transferNameController.text,
                        promotionName: promotionId != "-1" ? promotionName : null,
                      )));
          _clearTextField();
        });
      } else
        CustomToast.show(_vm.applePayDepositOrderApiState.result.errorMsg);
    });
  }
}
