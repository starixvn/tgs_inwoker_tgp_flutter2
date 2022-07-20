import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_picker_dialog.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:api/entity/wallet.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/transfer/transfer_picker.dart';
import 'package:tgp_flutter2/ui/transfer/transfer_text_form_field.dart';
import 'package:tgp_flutter2/ui/transfer/wallet_transfer_view_model.dart';

class WalletTransfer extends StatefulWidget {
  @override
  _WalletTransferState createState() => _WalletTransferState();
}

class _WalletTransferState extends BaseState<WalletTransfer>
    with TickerProviderStateMixin {
  WalletTransferViewModel _vm = WalletTransferViewModel();
  var _amountController = TextEditingController();
  var isEnabled = false, isMaxAmountButtonEnabled = false;

  Wallet? fromWallet, toWallet;
  String? textFromWallet, textToWallet;
  var transferAmount;
  FocusNode _focusNode = FocusNode();
  var _key = GlobalKey();
  AnimationController? _controller;
  Animation<double>? _animation;
  int? amount;
  bool toggleValue = false;

  @override
  void dispose() {
    _controller!.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void initState() {
    //_focusNode.addListener(checkButtonState);
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.linear,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (_vm.isFetchingBalance) _controller!.forward(from: 0.0);
        }
      });
    _vm.getAllWallet();
    _vm.getAutoTransferValue();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<WalletTransferViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          //updateData();
          return CustomScaffold(appBar: _buildAppBar(),
              body: Container(
                child: Column(
                  children: [
                    Column(
                      children: [
                        _buildWallet(),
                        _buildFromWallet(),
                        _buildToWallet()
                      ],
                    ),
                    _buildAmountTextField(),
                    _buildAutoTransferToggleButton(),
                    _buildTransferAllButton(),
                    _buildButton()
                  ],
                ),
              ));
        });
  }

  _buildAppBar() => CustomAppBar(
        title: getTranslatedText("transfer"),
        widget: Container(
          margin: EdgeInsets.all(7.auto),
          alignment: Alignment.center,
          child: RotationTransition(
            turns: _animation!,
            child: IconButton(
              icon: Image.asset(
                "images/ic_refresh.png",
                color: EnvironmentConfig.template_version == 8
                    ? Colors.black
                    : Colors.white,
              ),
              onPressed: () {
                _vm.getAllWallet();
              },
            ),
          ),
        ),
        isPassTrueWhenPop: true,
      );

  _buildWalletDetails(String title, Widget widget, {bool isLast = false}) =>
      Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Wrap(
          children: [
            Container(
              padding:
                  EdgeInsets.only(left: 20.auto, top: 15.auto, bottom: 15.auto),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(flex: 3, child: Text(title)),
                  Expanded(flex: 7, child: widget)
                ],
              ),
            ),
            Visibility(
              visible: !isLast,
              child: Divider(
                height: 2.auto,
              ),
            )
          ],
        ),
      );

  _buildWallet() => _buildWalletDetails(
      getTranslatedText("total_balance"),
      Text(
        _vm.mainWallet != null
            ? Format().amountFormat(_vm.mainWallet.main)
            : "",
        style: TextStyle(color: CustomColor.theme_text_grey_color),
      ));

  _buildFromWallet() => Container(
        child: _buildWalletDetails(
            getTranslatedText("transfer_from"),
            TransferPicker(
                title: getTranslatedText("transfer_from"),
                displayText:
                    textFromWallet ?? getTranslatedText("please_select"),
                list: [],
                isHintText: textFromWallet == null ||
                    textFromWallet == getTranslatedText("please_select"),
                onClick: () {
                  _buildPicker("transfer_from", _vm.walletList, true);
                })),
      );

  _buildToWallet() => _buildWalletDetails(
      getTranslatedText("transfer_to"),
      TransferPicker(
          title: getTranslatedText("transfer_to"),
          displayText: textToWallet ?? getTranslatedText("please_select"),
          list: [],
          isHintText: textToWallet == null ||
              textToWallet == getTranslatedText("please_select"),
          onClick: () {
            _buildPicker("transfer_to", _vm.walletList, false);
          }),
      isLast: true);

  _buildAmountTextField() => Container(
        margin: EdgeInsets.only(top: 10.auto),
        child: _buildWalletDetails(
            getTranslatedText("amount"),
            TransferTextFormField(
              hintText: getTranslatedText("enter_amount"),
              onChanged: (value) {
                checkButtonState();
              },
              onFieldSubmitted: (value) {},
              controller: _amountController,
              focusNode: _focusNode,
              width: context.screenWidth - 140.auto,
              button: Container(
                key: _key,
                child: ColorButton(
                  onClick: this.getMaxAmount,
                  isEnabled: isMaxAmountButtonEnabled,
                  radius: 4.8,
                  color: CustomColor.theme_button_color,
                  width: 40.auto,
                  height: 25.auto,
                  title: getTranslatedText("max_amount"),
                ),
              ),
              textInputType: TextInputType.number,
              textInputAction: TextInputAction.done,
            )),
      );

  _buildPicker(String title, List<Wallet> list, bool isFrom) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext bc) {
          return CustomPickerDialog(
              title: title,
              list: list,
              onChanged: (value) {
                setState(() {
                  if (isFrom) {
                    if (!value.isMainWallet)
                      setToWallet(list.first);
                    else
                      setToWallet(fromWallet != null
                          ? fromWallet?.isMainWallet ?? true
                              ? null
                              : fromWallet
                          : null);
                    setFromWallet(value);
                  } else {
                    if (!value.isMainWallet)
                      setFromWallet(list.first);
                    else
                      setFromWallet(toWallet != null
                          ? toWallet?.isMainWallet ?? true
                              ? null
                              : toWallet
                          : null);
                    setToWallet(value);
                  }
                  checkButtonState();
                  Navigator.pop(context);
                });
              });
        });
  }

  _buildTransferAllButton() => Container(
        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Row(
          children: [
            ElevatedButton(
                onPressed: () {
                  _vm.performWithdrawFromAllBrand();
                  setState(() {
                    ProgressDialog.show(context, _vm.brandLogoUrl);
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: CustomColor.theme_button_color,
                ),
                child: Text(getTranslatedText("collect_all").toString()))
          ],
        ),
      );

  _buildButton() => Container(
        margin: EdgeInsets.symmetric(horizontal: 10.auto),
        child: Row(
          children: [_buildMaxButton(), _buildConfirmButton()],
        ),
      );

  _buildMaxButton() => Expanded(
        flex: 1,
        child: Container(
          margin: EdgeInsets.only(right: 10.auto),
          child: ColorButton(
            title: getTranslatedText("max_amount"),
            onClick: () {
              getMaxAmount();
            },
            isEnabled: true,
            color: CustomColor.theme_button_color,
            radius: 9.6,
          ),
        ),
      );

  _buildConfirmButton() => Expanded(
        flex: 1,
        child: ColorButton(
          title: getTranslatedText("confirm"),
          onClick: () {
            onClick();
          },
          isEnabled: isEnabled,
          radius: 9.6,
        ),
      );

  _buildAutoTransferToggleButton() => Container(
        margin: EdgeInsets.all(10.auto),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              flex: 9,
              child: Container(
                  margin: EdgeInsets.only(right: 10.auto),
                  child: AutoSizeText(
                    getTranslatedText("auto_transfer"),
                    style: TextStyle(
                        color: CustomColor.theme_text_grey_white_color),
                    minFontSize: 8,
                    maxLines: 2,
                  )),
            ),
            Expanded(
              flex: 1,
              child: FlutterSwitch(
                value: _vm.autoTransferValue,
                width: 35,
                height: 17.5,
                toggleSize: 17.5,
                padding: 2,
                activeColor: CustomColor.theme_button_color,
                onToggle: (val) {
                  ProgressDialog.show(context, _vm.brandLogoUrl);
                  _vm.setAutoTransferValue();
                },
              ),
            ),
          ],
        ),
      );

  getMaxAmount() {
    setState(() {
      _amountController.text = _vm.walletList
          .singleWhere((e) => e.gpCode == fromWallet!.gpCode)
          .balance!
          .floor()
          .toString();
      checkButtonState();
    });
  }

  setFromWallet(Wallet? wallet) {
    fromWallet = wallet;
    if (wallet == null)
      textFromWallet = getTranslatedText("please_select");
    else {
      textFromWallet = (getTranslatedText(wallet.title) ?? wallet.title) ??
          getTranslatedText("please_select");
      setState(() {
        isMaxAmountButtonEnabled = true;
      });
    }
  }

  setToWallet(Wallet? wallet) {
    toWallet = wallet;
    if (wallet == null)
      textToWallet = getTranslatedText("please_select");
    else
      textToWallet = (getTranslatedText(wallet.title) ?? wallet.title) ??
          getTranslatedText("please_select");
  }

  checkButtonState() {
    if (_amountController.text.isNotEmpty) {
      amount = int.parse(_amountController.text);
    } else
      amount = 0;
    if (fromWallet == null ||
        toWallet == null ||
        amount == 0 ||
        amount! > fromWallet!.balance!) {
      setState(() {
        isEnabled = false;
      });
      return;
    } else {
      setState(() {
        isEnabled = true;
      });
    }
  }

  onClick() {
    if (fromWallet == null ||
        toWallet == null ||
        _amountController.text.isEmpty) {
      return;
    } else {
      setState(() {
        ProgressDialog.show(context, _vm.brandLogoUrl);
        final isFundOut = fromWallet!.isMainWallet;
        final gpCode = isFundOut ? toWallet!.gpCode : fromWallet!.gpCode;
        _vm.transferWallet(
            gpCode, int.parse(_amountController.text), isFundOut);
      });
    }
  }

  clearData() {
    setFromWallet(null);
    setToWallet(null);
    isEnabled = false;
    FocusScope.of(context).requestFocus(new FocusNode());
    _amountController.clear();
  }

  _handleApiState() {
    if (_vm.isFetchingBalance) {
      if (!_controller!.isAnimating) _controller!.forward(from: 0.0);
    }
    handleApiState(_vm.transferWalletApiState, isMaintenanceDialog: true,
        onSuccess: () {
      CustomToast.show(getTranslatedText("success"));

      WidgetsBinding.instance.addPostFrameCallback((_) {
        clearData();
      });
    });
    handleApiState(_vm.setAutoTransferApiState, onSuccess: () {});
    handleApiState(_vm.getAutoTransferApiState, onSuccess: () {});
    handleApiState(_vm.withdrawFromAllBrandState, onSuccess: () {});
    /*if(_vm.transferAllToMainWalletApiState == null && _vm.transferWalletApiState == null&& _vm.getWalletApiState ==null) {
      return;
    }
    if (_vm.transferAllToMainWalletApiState?.isError ?? false) {
      CustomToast.show(_vm.transferAllToMainWalletApiState.error);
    }
    if (_vm.transferWalletApiState?.isError ?? false) {
      CustomToast.show(_vm.transferWalletApiState.error);
    }
    if(!(_vm.isLoading)){
       ProgressDialog.hide();
    }*/
  }
}
