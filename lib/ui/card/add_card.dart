import 'package:api/data/provider/input_validation_provider.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/card_text_form_field.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_picker.dart';
import 'package:tgp_flutter2/custom/custom_picker_dialog.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
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
  bool isBankNameEnabledEdit = true;

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
            child: CustomScaffold(
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
                        if (!_isAddCardHideCertainField()) _buildBankTypePicker(),
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
        walletBalance: _vm.wallet?.totalBalance,
      );

  _buildAddCardTitle() => Container(
      margin: EdgeInsets.only(top: 10.auto, left: 10.auto, bottom: 25.auto),
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
        visible: !(_vm.config?.addCardHideChannel ?? false),
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

  _buildBankTextField(String title, String hint, TextEditingController controller, bool isNum,
          {bool isBankName = false}) =>
      CustomTextFormField(
        title: getTranslatedText(title),
        hintText: getTranslatedText(hint),
        onChanged: (value) => _onTextChange(value),
        onFieldSubmitted: (value) => _onTextChange(value),
        controller: controller,
        focusNode: null,
        width: context.screenWidth - 70.auto,
        textInputType: isNum ? TextInputType.number : TextInputType.text,
        textInputAction: TextInputAction.next,
        enabled: isBankName ? isBankNameEnabledEdit : true,
      );

  _buildCryptoAddressTextField() => CustomTextFormField(
        title: getTranslatedText(_isAddCardDisplayGCash() ? "gcash_bank_name" : "crypto_address"),
        hintText: getTranslatedText(_isAddCardDisplayGCash() ? "enter_gcash_bank_name" : "enter_crypto_address"),
        onChanged: (value) => _onTextChange(value),
        onFieldSubmitted: (value) => _onTextChange(value),
        controller: _addressController,
        focusNode: null,
        width: context.screenWidth - 70.auto,
        textInputType: TextInputType.text,
        textInputAction: TextInputAction.next,
      );

  _buildRealNameTextField() => CustomTextFormField(
        title: ((() {
          if (_vm.config?.addCardDisplayFPS ?? false)
            return getTranslatedText("fps_bank_name");
          else if (_vm.config?.addCardInputAddFPS ?? false)
            return getTranslatedText("fps_name");
          else
            return getTranslatedText("realname");
        })()),
        hintText: ((() {
          if (_vm.config?.addCardDisplayFPS ?? false)
            return getTranslatedText("enter_fps_bank_name_hint");
          else if (_vm.config?.addCardInputAddFPS ?? false)
            return getTranslatedText("enter_fps_name_hint");
          else
            return getTranslatedText("enter_realname_hint");
        })()),
        onChanged: (value) => _onTextChange(value),
        onFieldSubmitted: (value) => _onTextChange(value),
        controller: _realNameController,
        focusNode: null,
        width: context.screenWidth - 70.auto,
        textInputType: TextInputType.text,
        textInputAction: TextInputAction.next,
      );

  _buildPhoneTextField() => CustomTextFormField(
        title: ((() {
          if (_vm.config?.addCardDisplayFPS ?? false)
            return getTranslatedText("fps_phone_number");
          else if (_vm.config?.addCardInputAddFPS ?? false)
            return getTranslatedText("fps_number");
          else
            return getTranslatedText("phone_number");
        })()),
        hintText: ((() {
          if (_vm.config?.addCardDisplayFPS ?? false)
            return getTranslatedText("enter_fps_phone_number_hint");
          else if (_vm.config?.addCardInputAddFPS ?? false)
            return getTranslatedText("enter_fps_number_hint");
          else
            return getTranslatedText("enter_phone_hint");
        })()),
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
          if (!_isAddCardHideCertainField())
            ((_vm.config?.addCardBankDropDown ?? false))
                ? CustomPicker(
                    title: "bank_name",
                    displayText:
                        bankNamePickerText == null ? getTranslatedText("select_bank_name") : bankNamePickerText,
                    list: _vm.bankNameList,
                    isHintText: false,
                    width: context.screenWidth,
                    onClick: () {
                      _buildBottomSheet("bank_name", _vm.bankNameList);
                    })
                : _buildBankTextField("bank_name", "enter_bank_name", _bankNameController, false, isBankName: true),
          Visibility(
            visible: !_isAddCardHideCertainField() && (_vm.config?.addCardBankBranch ?? true),
            child: _buildBankTextField("bank_branch", "enter_bank_branch", _bankBranchController, false),
          ),
          _buildBankTextField("bank_acc_name", "enter_bank_acc_name", _nameController, false),
          _buildBankTextField(
            _isAddCardDisplayGCash() ? "gcash_bank_name" : "crypto_address",
            _isAddCardDisplayGCash() ? "enter_gcash_bank_name" : "enter_crypto_address",
            _bankNumController,
            true,
          ),
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

  _buildConfirmButton() => Container(
        margin: EdgeInsets.symmetric(horizontal: 10.auto),
        child: ColorButton(
          title: getTranslatedText("confirm"),
          onClick: () {
            _onClick();
          },
          isEnabled: isButtonEnabled,
          color: CustomColor.theme_button_color,
          radius: 9.6,
        ),
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
            else if (((_vm.config?.addCardBankDropDown ?? false) || _isAddCardHideCertainField()) &&
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
      channelPickerText = _vm.pWithdrawalInfo!.channelName;
      if (_vm.pWithdrawalInfo?.channelCode != "CustomBank") {
        _bankNameController.text = _vm.pWithdrawalInfo?.channelCode ?? "";
        isBankNameEnabledEdit = false;
      } else {
        _bankNameController.text = "";
        isBankNameEnabledEdit = true;
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

  _isAddCardDisplayGCash() => (_vm.config?.addCardDisplayGCash ?? false) && getCurrentLanguage().apiCode == "en-US";

  _isAddCardHideCertainField() => _vm.config?.addCardHideCertainField ?? false;

  _handleApiState() {
    handleApiState(_vm.addBankCardApiState, onSuccess: () {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.of(context).pop(true);
      });
    });
  }
}
