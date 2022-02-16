import 'package:flutter/material.dart';
import 'package:api/entity/bank_card.dart';
import 'package:api/entity/bank_type.dart';
import 'package:api/entity/game_provider.dart';
import 'package:api/entity/payment.dart';
import 'package:api/entity/promotion.dart';
import 'package:api/entity/status.dart';
import 'package:api/entity/wallet.dart';
import 'package:api/entity/withdrawal_info.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class CustomPickerDialog extends StatefulWidget {
  final String title;
  final List<dynamic> list;
  final ValueChanged<dynamic> onChanged;

  CustomPickerDialog({
    required this.title,
    required this.list,
    required this.onChanged,
  });

  @override
  _CustomPickerDialogState createState() => _CustomPickerDialogState();
}

class _CustomPickerDialogState extends BaseState<CustomPickerDialog> {
  Widget build(BuildContext context) {
    return Container(
      child: Wrap(children: [
        Container(
          alignment: Alignment.center,
          width: context.screenWidth,
          padding: EdgeInsets.only(bottom: 5),
          margin: EdgeInsets.only(left: 5, right: 5, top: 5),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0))),
          child: Text(
            getTranslatedText(widget.title),
            style: TextStyle(
              fontSize: 13.auto,
              color: CustomColor.theme_button_color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Wrap(
          children: List.generate(widget.list.length, (index) {
            return ListTile(
              title: _getPickerItem(index),
              onTap: () {
                widget.onChanged(widget.list[index]);
              },
              hoverColor: Colors.transparent,
              dense: true,
            );
          }),
        ),
      ]),
    );
  }

  _getText(int index) {
    if (widget.list is List<Payment>) {
      var name = widget.list[index].channelName.replaceAll(RegExp("_"), " ");
      return name;
    } else if (widget.list is List<GameProvider>) {
      GameProvider game = widget.list[index];
      return game.name;
    } else if (widget.list is List<BankType>) {
      BankType bankType = widget.list[index];
      return bankType.getName(context);
    } else if (widget.list is List<Wallet>) {
      Wallet wallet = widget.list[index];
      return (wallet.isMainWallet) ? getTranslatedText(wallet.title) : wallet.title;
    } else if (widget.list is List<Promotion>) {
      Promotion promotion = widget.list[index];
      return promotion.name;
    } else if (widget.list is List<Status>) {
      Status status = widget.list[index];
      String name = status.getName(context);
      return name;
    } else if (widget.list is List<WithdrawalInfo>) {
      if (widget.list[index].channelName == "PrimePay_BankTransfer_Custom") {
        return getTranslatedText("custom_bank");
      } else {
        var code = widget.list[index].channelName;
        return code;
      }
    } else if (widget.list is List<String>) {
      String bankName = widget.list[index];
      return getTranslatedText(bankName) ?? bankName;
    } else {
      return getTranslatedText(widget.list[index]) ?? widget.list[index];
    }
  }

  _getPickerItem(index) {
    if (widget.list is List<BankCard>)
      return _getBankCardPickerItem(index);
    else if (widget.list is List<Wallet>)
      return buildWalletItem(index);
    else
      return _buildText(index);
  }

  _buildText(int index) => Text(
        _getText(index),
        style: TextStyle(fontSize: 13.auto),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      );

  buildWalletItem(index) {
    Wallet wallet = widget.list[index];
    return Row(
      children: [
        Expanded(
            flex: 1,
            child: Text(
              (wallet.isMainWallet) ? getTranslatedText(wallet.title) : wallet.title,
              style: TextStyle(fontSize: 13.auto),
              textAlign: TextAlign.center,
            )),
        Expanded(
            flex: 1,
            child: Text(
              wallet.balance.toString(),
              style: TextStyle(fontSize: 13.auto),
              textAlign: TextAlign.center,
            ))
      ],
    );
  }

  _getBankCardPickerItem(index) {
    BankType bankType = widget.list[index].bankType;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            bankType.getName(context),
            style: TextStyle(fontSize: 13.auto),
            textAlign: TextAlign.left,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            (_getDisplayBankAccountText(widget.list[index])) ?? "",
            style: TextStyle(fontSize: 13.auto),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }

  String? _getDisplayBankAccountText(BankCard bankCard) {
    switch (bankCard.bankType) {
      case BankType.CRYPTO:
        return bankCard.bankDetail?.address;
      case BankType.THIRD_PARTY:
        return bankCard.bankDetail?.phone;
      case BankType.FPS:
        return bankCard.bankDetail?.phone;
      default:
        return bankCard.bankDetail?.bankAccount;
    }
  }
}
