import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:api/entity/deposit_redirect.dart';
import 'package:api/entity/deposit_redirect_applepay.dart';
import 'package:api/entity/manual_deposit_order.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/deposit/deposit_html.dart';

import 'deposit_view_model.dart';
import 'deposit_web.dart';

class DepositOrderView extends StatefulWidget {
  final String? method;
  final String? id;
  final DepositRedirect? depositRedirect;
  final String? depositAmount;
  final String? depositChannel;
  final String? promotionName;
  final String? transName;
  final DepositRedirectApplePay? depositRedirectApplePay;
  final String? exchangeRate;
  final String? expectedAmount;
  final String? htmlText;
  final bool isHelp2Pay;

  DepositOrderView({
    this.method,
    this.id,
    this.depositRedirect,
    this.depositAmount,
    this.depositChannel,
    this.promotionName,
    this.transName,
    this.depositRedirectApplePay,
    this.exchangeRate,
    this.expectedAmount,
    this.htmlText,
    this.isHelp2Pay = false,
  });

  @override
  _DepositOrderViewState createState() => _DepositOrderViewState();
}

class _DepositOrderViewState extends BaseState<DepositOrderView> {
  var _vm = DepositViewModel();

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.htmlText?.isNotEmpty ?? false)
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DepositHtml(
                      htmlText: widget.htmlText,
                    )));
      else
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DepositWeb(
                      url: widget.depositRedirect != null
                          ? widget.depositRedirect!.paymentUrl
                          : widget.depositRedirectApplePay!.paymentUrl,
                      brandLogoUrl: _vm.brandLogoUrl,
                    )));
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<DepositViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return CustomScaffold(
              appBar: CustomAppBar(
                title: getTranslatedText("deposit"),
              ),
              body: _buildLeepayOrder());
        });
  }

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
                    widget.depositAmount!,
                    style: TextStyle(
                        fontSize: (38.5).auto, color: CustomColor.theme_button_color, fontWeight: FontWeight.w400),
                    //"$amount"
                  ),
                ),
                Divider(
                  thickness: (1.0).auto,
                  color: CustomColor.very_light_pink_four,
                ),
                _buildOrderText("order_no", _getOrderNoText()),
                _buildText("payment_type", widget.method),
                _buildText("payment_channel", widget.depositChannel),
                handleNullWidget(widget.exchangeRate == null, _buildText("exchange_rate", widget.exchangeRate)),
                handleNullWidget(widget.expectedAmount == null, _buildText("expected_amount", widget.expectedAmount)),
                handleNullWidget(widget.transName == null, _buildText("transfer_name", widget.transName)),
                handleNullWidget(widget.promotionName == null, _buildText("promotion_picker", widget.promotionName)),
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
                  onClick: () => Navigator.pop(context)))
        ],
      );

  _getOrderNoText() {
    if (widget.depositRedirect != null)
      return widget.depositRedirect!.formId;
    else
      return widget.depositRedirectApplePay!.formId;
  }

  _buildOrderText(String title, String? content) => Container(
        margin: EdgeInsets.only(top: 15.auto),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                getTranslatedText(title) ?? title,
                style: TextStyle(fontSize: 13.auto, color: CustomColor.theme_text_black_color),
              ),
            ),
            Expanded(
              flex: 8,
              child: AutoSizeText(
                content ?? "",
                style: TextStyle(fontSize: 13.auto, color: CustomColor.theme_text_black_color),
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
            style: TextStyle(fontSize: 13.auto, color: CustomColor.theme_text_black_color),
          ),
          AutoSizeText(
            content ?? "",
            style: TextStyle(fontSize: 13.auto, color: CustomColor.theme_text_black_color),
            minFontSize: 2,
            maxLines: 1,
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }

  _handleApiState() {
    handleApiState(_vm.uploadDepositImageApiState, onSuccess: () {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
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
