import 'package:api/data/provider/input_validation_provider.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/card_text_form_field.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_picker.dart';
import 'package:tgp_flutter2/custom/custom_picker_dialog.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_text_form_field.dart';
import 'package:api/entity/bank_type.dart';
import 'package:api/entity/withdrawal_info.dart';
import 'package:api/extension/format.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'card_view_model.dart';

class AddCard extends StatefulWidget {
  @override
  _AddCardState createState() => _AddCardState();
}

class _AddCardState extends BaseState<AddCard> {
  var _bankNumController = TextEditingController(),
      _addressController = TextEditingController(),
      _bankNameController = TextEditingController(),
      _nameController = TextEditingController(),
      _bankBranchController = TextEditingController(),
      _realNameController = TextEditingController(),
      _phoneController = TextEditingController();
  var _vm = CardViewModel();
  var isButtonEnabled = false;
  String? bankTypePickerText, channelPickerText, bankNamePickerText;
  bool isCrypto = true;
  InputValidationProvider validate = new InputValidationProvider();

  @override
  void initState() {
    onSelectedBankType();
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<CardViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return ScrollConfiguration(
            behavior: MyBehavior(),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: CustomColor.theme_bg_color,
              appBar: _buildAppBar(),
              body: _vm.bankTypeList == null
                  ? buildProgressDialog(_vm.brandLogoUrl)
                  : ListView(
                      padding: EdgeInsets.only(
                        left: 10.auto,
                        right: 10.auto,
                        top: 5.auto,
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      children: [
                        _buildAddCardTitle(),
                        _buildBankTypePicker(),
                        _buildChannelPicker(),
                        ListView(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          children: _getWidgetList(),
                        ),
                        _getHintText(),
                        _buildConfirmButton()
                      ],
                    ),
            ),
          );
        });
  }

  _buildAppBar() => CustomAppBar(
        title: getTranslatedText("add_card"),
        walletBalance: _vm.wallet?.main,
      );

  _buildAddCardTitle() => Container(
      margin: EdgeInsets.only(top: 10.auto, left: 20.auto, bottom: 10.auto),
      alignment: Alignment.topLeft,
      child: Text(
        getTranslatedText("add_card"),
        style: TextStyle(fontWeight: FontWeight.w500, color: CustomColor.theme_text_black_white_color),
      ));

  _buildBankTypePicker() => CustomPicker(
      title: "bank_type",
      displayText: bankTypePickerText == null ? getTranslatedText("select_bank_type") : bankTypePickerText,
      list: _vm.bankTypeList.keys.toList(),
      isHintText: false,
      width: context.screenWidth,
      onClick: () {
        _buildBottomSheet("bank_type", _vm.bankTypeList.keys.toList());
      });

  _buildChannelPicker() => Visibility(
        visible:!( _vm.config?.addCardHideChannel ?? false),
        child: CustomPicker(
            title: "channel",
            displayText: channelPickerText == null ? getTranslatedText("select_channel") : channelPickerText,
            list: _vm.withdrawalInfoList,
            isHintText: false,
            width: context.screenWidth,
            onClick: () {
              _buildBottomSheet("channel", _vm.withdrawalInfoList!);
            }),
      );

  _buildBankTextField(String title, String hint, TextEditingController controller, bool isNum) => CardTextFormField(
        title: getTranslatedText(title),
        hintText: getTranslatedText(hint),
        onChanged: (value) => _onTextChange(value),
        onFieldSubmitted: (value) => _onTextChange(value),
        controller: controller,
        focusNode: null,
        width: context.screenWidth - 70.auto,
        textInputType: isNum ? TextInputType.number : TextInputType.text,
        textInputAction: TextInputAction.next,
      );

  _buildCryptoAddressTextField() => CardTextFormField(
        title: getTranslatedText("address"),
        hintText: getTranslatedText("enter_address"),
        onChanged: (value) => _onTextChange(value),
        onFieldSubmitted: (value) => _onTextChange(value),
        controller: _addressController,
        focusNode: null,
        width: context.screenWidth - 70.auto,
        textInputType: TextInputType.text,
        textInputAction: TextInputAction.next,
      );

  _buildRealNameTextField() => CardTextFormField(
        title: getTranslatedText("realname"),
        hintText: getTranslatedText("enter_realname_hint"),
        onChanged: (value) => _onTextChange(value),
        onFieldSubmitted: (value) => _onTextChange(value),
        controller: _realNameController,
        focusNode: null,
        width: context.screenWidth - 70.auto,
        textInputType: TextInputType.text,
        textInputAction: TextInputAction.next,
      );

  _buildPhoneTextField() => CardTextFormField(
        title: getTranslatedText("phone_number"),
        hintText: getTranslatedText("enter_phone_hint"),
        onChanged: (value) => _onTextChange(value),
        onFieldSubmitted: (value) => _onTextChange(value),
        controller: _phoneController,
        focusNode: null,
        width: context.screenWidth - 70.auto,
        textInputType: TextInputType.text,
        textInputAction: TextInputAction.next,
      );

  List<Widget> _getWidgetList() {
    switch (_vm.pBankType) {
      case BankType.BANK:
        return [
          (_vm.config?.addCardBankDropDown ?? false)
              ? CustomPicker(
                  title: "bank_name",
                  displayText: bankNamePickerText == null ? getTranslatedText("select_bank_name") : bankNamePickerText,
                  list: _vm.bankNameList,
                  isHintText: false,
                  width: context.screenWidth,
                  onClick: () {
                    _buildBottomSheet("bank_name", _vm.bankNameList);
                  })
              : _buildBankTextField("bank_name", "enter_bank_name", _bankNameController, false),
          Visibility(
            visible: _vm.config.addCardBankBranch,
            child: _buildBankTextField("bank_branch", "enter_bank_branch", _bankBranchController, false),
          ),
          _buildBankTextField("bank_acc_name", "enter_bank_acc_name", _nameController, false),
          _buildBankTextField("card_number", "enter_card_number", _bankNumController, true),
        ];
      case BankType.CRYPTO:
        return [
          _buildCryptoAddressTextField(),
        ];
      default:
        return [
          _buildRealNameTextField(),
          _buildPhoneTextField(),
        ];
    }
  }

  _getHintText() => Container(
        margin: EdgeInsets.only(top: 2.auto, bottom: 20.auto),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "images/card/ic_hint.png",
              width: 15.auto,
              height: 15.auto,
            ),
            Container(
              margin: EdgeInsets.only(left: 5.auto),
              child: Text(
                getTranslatedText("add_card_hint"),
                style: TextStyle(fontSize: 9.auto, color: Colors.red),
              ),
            )
          ],
        ),
      );

  _buildConfirmButton() => ColorButton(
        title: getTranslatedText("confirm"),
        onClick: () {
          _onClick();
        },
        isEnabled: isButtonEnabled,
        color: CustomColor.theme_button_color,
        radius: 9.6,
      );

  _buildBottomSheet(String title, List<dynamic> list) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext bc) {
          return CustomPickerDialog(
              title: title,
              list: list,
              onChanged: (value) {
                setState(() {
                  if (value is BankType)
                    onSelectedBankType(bankType: value);
                  else if (value is WithdrawalInfo)
                    onSelectedWithdrawalInfo(withdrawalInfo: value);
                  else if (value is String) onSelectedBankName(bank: value);
                  Navigator.pop(context);
                });
              });
        });
  }

  _onTextChange(String value) {
    setState(() {
      switch (_vm.pBankType) {
        case BankType.CRYPTO:
          {
            if (_addressController.text.isNotEmpty)
              isButtonEnabled = true;
            else
              isButtonEnabled = false;
            break;
          }
        case BankType.BANK:
          {
            //addCardBankDropDown is false, check _bankNameController.text
            if (!(_vm.config?.addCardBankDropDown ?? false) &&
                    (_bankNumController.text.isNotEmpty) &&
                    (_bankNameController.text.isNotEmpty) &&
                    (_nameController.text.isNotEmpty) /*&&
                (_bankBranchController.text.isNotEmpty)*/
                )
              isButtonEnabled = true;
            else if ((_vm.config?.addCardBankDropDown ?? false) &&
                    (_bankNumController.text.isNotEmpty) &&
                    (_nameController.text.isNotEmpty) /*&&
                (_bankBranchController.text.isNotEmpty)*/
                )
              isButtonEnabled = true;
            else
              isButtonEnabled = false;
            break;
          }
        default:
          {
            if ((_realNameController.text.isNotEmpty) && (_phoneController.text.isNotEmpty))
              isButtonEnabled = true;
            else
              isButtonEnabled = false;
            break;
          }
      }
    });
  }

  onSelectedBankType({BankType? bankType}) async {
    await _vm.onSelectedBankType(bankType);
    BankType _currentBankType = bankType ?? _vm.pBankType!;
    onSelectedWithdrawalInfo();
    setState(() {
      isCrypto = _currentBankType == BankType.CRYPTO;
      bankTypePickerText = _currentBankType.getName(context);
    });
  }

  onSelectedWithdrawalInfo({WithdrawalInfo? withdrawalInfo}) async {
    await _vm.onSelectedWithdrawalInfo(withdrawalInfo: withdrawalInfo);
    onSelectedBankName();
    setState(() {
      //  channelPickerText = _vm.pWithdrawalInfo.channelName.replaceAll(RegExp("_"), " ");
      if (_vm.pWithdrawalInfo!.channelName == "PrimePay_BankTransfer_Custom") {
        channelPickerText = getTranslatedText("custom_bank");
      } else {
        channelPickerText = _vm.pWithdrawalInfo!.channelName;
      }
    });
  }

  onSelectedBankName({String? bank}) async {
    await _vm.onSelectedBankName(bankName: bank);
    setState(() {
      //  channelPickerText = _vm.pWithdrawalInfo.channelName.replaceAll(RegExp("_"), " ");
      bankNamePickerText = getTranslatedText(_vm.pBankName);
    });
  }

  _onClick() {
    ProgressDialog.show(context, _vm.brandLogoUrl);
    if (isCrypto)
      _vm.addBankCard(address: _addressController.text);
    else
      _vm.addBankCard(
        bankName:
            (_vm.config?.addCardBankDropDown ?? false) ? getTranslatedText(_vm.pBankName) : _bankNameController.text,
        bankAccount: _bankNumController.text,
        bankBranch: _bankBranchController.text,
        name: _nameController.text,
        phone: _phoneController.text,
        realName: _realNameController.text,
      );
  }

  _handleApiState() {
    handleApiState(_vm.addBankCardApiState, onSuccess: () {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.of(context).pop(true);
      });
    });
  }
}
