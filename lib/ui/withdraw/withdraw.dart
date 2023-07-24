import 'package:api/data/provider/input_validation_provider.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/card_text_form_field.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:tgp_flutter2/custom/custom_picker.dart';
import 'package:tgp_flutter2/custom/custom_picker_dialog.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/custom_text_form_field.dart';
import 'package:api/entity/bank_card.dart';
import 'package:api/entity/bank_type.dart';
import 'package:api/extension/format.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/ui/profile_info/email/email_verification.dart';
import 'package:tgp_flutter2/ui/withdraw/withdraw_dialog.dart';
import 'package:tgp_flutter2/ui/withdraw/withdraw_view_model.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';

import '../../globalUtil/GlobalValueUtil.dart';

class Withdraw extends StatefulWidget {
  @override
  _WithdrawState createState() => _WithdrawState();
}

class _WithdrawState extends BaseState<Withdraw> {
  var _vm = WithdrawViewModel();

  //UserProfile user;
  var isDetailsButtonEnabled = false, isNextButtonEnabled = false;
  var selectedBankCard;
  TextEditingController _amountController = TextEditingController(),
      _usdtController = TextEditingController(),
      _remarkController = TextEditingController();
  var amount;
  InputValidationProvider validate = new InputValidationProvider();
  String? selectedBankCardText;

  @override
  void initState() {
    _initData();
    GlobalValueUtil.pausesong();
    super.initState();
  }

  _initData() async {
    await _checkUserProfile();
    _vm.getTurnoverAmount();
    _vm.getWithdrawalInfoList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getBankText();
    });
  }

  Widget build(BuildContext context) {
    return ProviderWidget<WithdrawViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return CustomScaffold(
            appBar: _buildAppBar(),
            body: _vm.bankCardList == null
                ? buildProgressDialog(_vm.brandLogoUrl)
                : Container(
                    padding: EdgeInsets.only(
                        left: 10.auto, right: 10.auto, bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: ScrollConfiguration(
                      behavior: MyBehavior(),
                      child: ListView(
                        children: [
                          _buildWithdrawCard(),
                          _buildEditBankItem(),
                          _buildBankPicker(),
                          _buildTextField("amount", "enter_withdraw_amount", _amountController, true),
                          _buildPlayerNoteTextField(),
                          //_buildTextField("pay_password", "enter_pay_password", _payPasswordController, false),
                          if (_isUSDT()) _buildUSDTExchangeRateText(),
                          if (_isUSDT()) _buildUSDTAmount(),
                          _buildHintText(),

                          _buildButton(),
                          //_buildCustomerServiceText()
                        ],
                      ),
                    ),
                  ),
          );
        });
  }

  _buildAppBar() => CustomAppBar(
        title: getTranslatedText("withdrawal"),
        walletBalance: _vm.wallet?.totalBalance,
        isPassTrueWhenPop: true,
      );

  _buildWithdrawCard() => Container(
        padding: EdgeInsets.only(top: 15.auto),
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 5,
          child: Column(
            children: [
              _buildWithdrawItem(getTranslatedText("available_withdraw"), (_vm.wallet?.main ?? 0.0)),
              _buildWithdrawItem(getTranslatedText("turnover"), (_vm.turnover ?? 0.0)),
            ],
          ),
        ),
      );

  _buildWithdrawItem(String title, double amount) => Container(
        margin: EdgeInsets.symmetric(vertical: 10.auto),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 3,
              height: 20.auto,
              color: Colors.black,
              margin: EdgeInsets.symmetric(vertical: 5.auto, horizontal: 15.auto),
              alignment: Alignment.topCenter,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: CustomColor.grey, fontSize: 14.auto),
                ),
                Container(
                  padding: EdgeInsets.only(top: 5.auto),
                  child: Text(
                    EnvironmentConfig.brandName == "IDR1"
                    //without decimal places
                        ? Format().currencyFormat(amount.toInt())
                    //with 2 decimal places
                        :Format().currencyWithDecimalFormat(amount),
                    style: TextStyle(color: CustomColor.theme_button_color, fontSize: 12.auto),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            )
          ],
        ),
      );

  _buildEditBankItem() => Container(
        padding: EdgeInsets.symmetric(vertical: 10.auto, horizontal: 10.auto),
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: () async {
            await Navigator.of(context).pushNamed(RoutePath.mainCard);
            await _vm.getBankCardList();
            setState(() {
              _getBankText();
            });
          },
          child: Wrap(children: [
            Container(
              margin: EdgeInsets.only(right: 5.auto),
              child: Image.asset(
                "images/withdraw/ic_edit_card.png",
                width: 15.auto,
                height: 15.auto,
                color: CustomColor.theme_text_grey_white_color,
              ),
            ),
            Text(
              getTranslatedText("manage_card"),
              style: TextStyle(color: CustomColor.theme_text_grey_white_color, fontSize: 12.auto),
            )
          ]),
        ),
      );

  _buildBankPicker() => CustomPicker(
        title: getTranslatedText("bank_card"),
        displayText: selectedBankCardText ?? "",
        list: _vm.bankCardList ?? [],
        isHintText: selectedBankCard != null || _vm.bankCardList != null || (_vm.bankCardList?.isNotEmpty ?? false)
            ? false
            : true,
        width: context.screenWidth,
        onClick: () {
          _buildPickerDialog("bank_card", _vm.bankCardList ?? []);
        },
      );

  _buildPickerDialog(String title, List<BankCard> list) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext bc) {
          return CustomPickerDialog(
              title: title,
              list: list,
              onChanged: (value) {
                print(value.fees);
                setState(() {
                  selectedBankCard = value;
                  selectedBankCardText = _getDisplayBankAccountText(selectedBankCard);
                  Navigator.pop(context);
                });
              });
        });
  }

  _getBankText() {
    if (_vm.bankCardList == null || (_vm.bankCardList?.isEmpty ?? true)) {
      selectedBankCardText = getTranslatedText("select_bank_card");
    } else {
      if (selectedBankCard == null) {
        selectedBankCard = _vm.bankCardList?.first;
      }
      selectedBankCardText = _getDisplayBankAccountText(selectedBankCard);
    }
  }

  _getDisplayBankAccountText(BankCard bankCard) {
    switch (bankCard.bankType) {
      case "Crypto":
        return bankCard.bankDetail?.address;
      case "Usdt":
        return bankCard.bankDetail?.address;
      case "Bank":
        return bankCard.bankDetail?.bankAccount;
      default:
        return bankCard.bankDetail?.phone;
    }
  }

  _buildPlayerNoteTextField() => Visibility(
        visible: (_isEWallet() || _isPulsa() || _isBank()) && (_vm.config?.addPlayerNote ?? false),
        child: Container(
          margin: EdgeInsets.only(
            top: 20.auto,
          ),
          child: CustomTextFormField(
            title: getTranslatedText("playerNote"),
            hintText: getTranslatedText("plsEnterPlayerNote"),
            onChanged: (value) {
              onTextChange();
            },
            onFieldSubmitted: (value) => onTextChange(),
            controller: _remarkController,
            width: context.screenWidth - 70.auto,
            textInputType: TextInputType.text,
            textInputAction: TextInputAction.next,
          ),
        ),
      );

  _buildTextField(String titleText, String hintText, TextEditingController controller, bool isNum) => Container(
        margin: EdgeInsets.only(top: 15.auto),
        child: CustomTextFormField(
          title: getTranslatedText(titleText),
          hintText: getTranslatedText(hintText),
          onChanged: (value) => onTextChange(),
          onFieldSubmitted: (value) => onTextChange(),
          controller: controller,
          focusNode: null,
          width: context.screenWidth - 70.auto,
          textInputType: isNum ? TextInputType.number : TextInputType.visiblePassword,
          textInputAction: _isUSDT() ? TextInputAction.next : TextInputAction.done,
          bottomMargin: 0,
          // tipsText: "${getTranslatedText("amount_limit")}: " +
          //     "${Format().amountFormat(selectedBankCard?.transferLimit?.from ?? 0)} - " +
          //     "${Format().amountFormat(selectedBankCard?.transferLimit?.to ?? 0)}",
          // customPart: Row(
          //   children: [
          //     Text(
          //       getTranslatedText("fees_withdraw") + ": ",
          //       style: TextStyle(
          //           color: CustomColor.theme_app_bar_color, fontSize: 12.auto),
          //       textAlign: TextAlign.start,
          //     ),
          //     Text(
          //       "${selectedBankCard?.fees ?? 0}",
          //       style: TextStyle(
          //           color: CustomColor.theme_app_bar_color,
          //           fontSize: 12.auto,
          //           fontWeight: FontWeight.bold),
          //       textAlign: TextAlign.start,
          //     ),
          //     Text(
          //       "%",
          //       style: TextStyle(
          //           color: CustomColor.theme_app_bar_color,
          //           fontSize: 12.auto,
          //           fontWeight: FontWeight.bold),
          //       textAlign: TextAlign.start,
          //     ),
          //   ],
          // ),
        ),
      );

  _buildUSDTAmount() {
    _usdtController.text = _calculateUSDTExchangeRate();
    return Container(
      margin: EdgeInsets.only(top: 15.auto),
      child: CustomTextFormField(
        title: getTranslatedText("deposit_usdt_amount"),
        hintText: "",
        onChanged: (value) {},
        onFieldSubmitted: (value) {},
        controller: _usdtController,
        focusNode: null,
        width: context.screenWidth - 70.auto,
        textInputType: TextInputType.number,
        textInputAction: TextInputAction.done,
        bottomMargin: 0,
        enabled: false,
      ),
    );
  }

  _buildHintText() => Container(
        margin: EdgeInsets.only(left: 15.auto, bottom: 15.auto),
        child: Text(
          getTranslatedText("withdrawal_warning"),
          style: TextStyle(color: Colors.red, fontSize: 11.auto),
        ),
      );

  _buildButton() => Container(
        margin: EdgeInsets.symmetric(horizontal: 10.auto),
        child: ColorButton(
          onClick: this.onNextButtonClick,
          isEnabled: isNextButtonEnabled,
          radius: 9.6,
          color: CustomColor.theme_button_color,
          title: getTranslatedText("submit"),
        ),
      );

  _buildUSDTExchangeRateText() => Container(
        margin: EdgeInsets.only(left: 10.auto, right: 10.auto, bottom: 10.auto),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                text: getTranslatedText("exchange_rate") + ": ",
                style: TextStyle(fontSize: 11.auto, color: CustomColor.theme_text_grey_white_color),
                children: [
                  TextSpan(
                    text: "1",
                    style: TextStyle(color: CustomColor.theme_button_color, fontSize: 11.auto),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                text: "USDT: ",
                style: TextStyle(fontSize: 11.auto, color: CustomColor.theme_text_grey_white_color),
                children: [
                  TextSpan(
                    text: _vm.config.withdrawalUSDTExchangeRate?.toString() ?? "0.00",
                    style: TextStyle(color: CustomColor.theme_button_color, fontSize: 11.auto),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  _calculateUSDTExchangeRate() {
    if (_vm.config.withdrawalUSDTExchangeRate != null) {
      double expectedAmount = (amount ?? 0) * (_vm.config.withdrawalUSDTExchangeRate ?? 0);
      return Format().doubleToString(expectedAmount);
    } else
      return "0.00";
  }

  _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: "",
        description: getTranslatedText("withdraw_success"),
        buttonText1: getTranslatedText("confirm"),
        buttonText2: (_vm.userProfile.realname != null && !_vm.userProfile.identityAuthentication)
            ? getTranslatedText("verify_realname")
            : null,
        onClick: () => Navigator.pop(context),
        onClick2: () => (_vm.userProfile.realname != null && !_vm.userProfile.identityAuthentication)
            ? Navigator.pushNamed(context, RoutePath.realNameVerification)
            : null,
      ),
    );
  }

  onTextChange() {
    if (_amountController.text.isNotEmpty) {
      amount = int.parse(_amountController.text);
    } else
      amount = 0;
    if (amount == 0) {
      setState(() {
        isNextButtonEnabled = false;
      });
      return;
    } else {
      setState(() {
        isNextButtonEnabled = true;
      });
    }
  }

  onNextButtonClick() {
    if ((_vm.config?.withdrawalHundredDigit ?? false) && !validate.validateIncremental100(_amountController.text)) {
      setState(() {
        CustomToast.show(getTranslatedText("withdrawal_amount_warning"));
      });
    } else if (amount < (selectedBankCard?.transferLimit?.from ?? 0)) {
      showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
            description: getTranslatedText("withdraw_reach_min"),
            buttonText1: getTranslatedText("confirm"),
            onClick: () {
              Navigator.pop(
                context,
              );
            }),
      );
    } else if (amount > (selectedBankCard?.transferLimit?.to ?? 0)) {
      showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
            description: getTranslatedText("withdraw_reach_max"),
            buttonText1: getTranslatedText("confirm"),
            onClick: () {
              Navigator.pop(
                context,
              );
            }),
      );
    } else {
      ProgressDialog.show(context, _vm.brandLogoUrl);
      _vm.withdraw(amount, selectedBankCard.id, "", _remarkController.text);
    }
  }

  _checkUserProfile() async {
    var result;
    //fetch bank list

    // if (_vm.userProfile.email == null && (_vm.config?.emailVerification ?? true)) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) async {
    //     result = await Navigator.push(
    //       context,
    //       new MaterialPageRoute(
    //         builder: (context) => EmailVerification(1),
    //       ),
    //     );
    //   });
    // Navigator.of(context).pushNamed("/email_verification");
    //}
    // else if (_vm.userProfile.isSetPayPassword == false) {
    //   result = await Navigator.of(context).pushNamed("/pay_password");
    // }
    //else {
    await _vm.getBankCardList();
    return;
    //}

    // if (result == null) //no result mean not set email or pay password
    //   Navigator.pop(context);
    // else
    //   _checkUserProfile();
  }

  _isUSDT() => (selectedBankCard?.bankType ?? "Bank") == "Usdt";

  _isEWallet() => selectedBankCard?.bankType == "EWallet";

  _isPulsa() => selectedBankCard?.bankType == BankType.PULSA;

  _isBank() => selectedBankCard?.bankType == "Bank";

  _handleApiState() {
    handleApiState(_vm.withdrawApiState, onSuccess: () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDialog();
        _amountController.clear();
        // _payPasswordController.clear();
        isNextButtonEnabled = false;
      });
    });

    handleApiState(_vm.getBankCardListApiState, isAutoHideLoading: false, onSuccess: () {});
  }
}
