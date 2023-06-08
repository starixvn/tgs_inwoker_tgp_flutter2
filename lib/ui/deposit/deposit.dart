import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/GlobalValueUtil.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:api/extension/format.dart';
import 'package:tgp_flutter2/custom/deposit_dialog.dart';
import 'package:tgp_flutter2/custom/tab_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/deposit/deposit_method.dart';
import 'package:tgp_flutter2/ui/deposit/deposit_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class Deposit extends StatefulWidget {
  @override
  _DepositState createState() => _DepositState();
}

class _DepositState extends BaseState<Deposit> {
  DepositViewModel _vm = DepositViewModel();

  /*var tabList = [
    {"id": "0", "text": "人工支付"}
  ];*/
  var currentTabIndex = 0;
  var text = "";

  @override
  void initState() {
    GlobalValueUtil.pausesong();
    _initData();
    super.initState();
  }

  _initData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var code = _prefs.getString("LANGUAGE_CODE") ?? EnvironmentConfig.default_lang;
    await _vm.getPlayerPromotionList(code);
    _vm.getPayment();
    _displayDepositDialog();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<DepositViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return CustomScaffold(
              appBar: _buildAppBar(),
              body: (() {
                if (_vm.paymentCodeList == null)
                  return buildProgressDialog(_vm.brandLogoUrl);
                else
                  return handleNullWidget(
                      _vm.paymentCodeList!.isEmpty,
                      DefaultTabController(
                        length: _vm.paymentCodeList!.keys.length,
                        child: Column(
                          children: [
                            Container(
                              width: context.screenWidth,
                              child: TabBar(
                                isScrollable: true,
                                unselectedLabelColor: CustomColor.theme_text_grey_color,
                                labelColor: CustomColor.theme_label_text_highlight_color,
                                indicatorColor: Colors.transparent,
                                indicator: BoxDecoration(),
                                onTap: (index) {
                                  setState(() {
                                    currentTabIndex = index;
                                  });
                                },
                                labelPadding: EdgeInsets.symmetric(horizontal: 10.auto, vertical: 5.auto),
                                unselectedLabelStyle: TextStyle(color: CustomColor.theme_text_grey_color),
                                tabs: List.generate(_vm.paymentCodeList!.keys.length, (index) {
                                  return TabButton(
                                    text: getTranslatedText(_vm.paymentCodeList!.keys.toList()[index]) ?? "",
                                    index: index,
                                    currentTabIndex: currentTabIndex,
                                    width: 90.auto,
                                    height: 32.auto,
                                  );
                                }).toList(),
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                physics: NeverScrollableScrollPhysics(),
                                children: List.generate(_vm.paymentCodeList!.keys.length, (index) {
                                  return DepositMethod(
                                    paymentCode: _vm.paymentCodeList!.keys.toList()[index],
                                    depositMethodList: _vm.paymentCodeList!.values.toList()[index],
                                    promotionList: _vm.displayPromotionList,
                                  );
                                }).toList(),
                              ),
                            )
                          ],
                        ),
                      ));
              }()));
        });
  }

  _buildAppBar() => CustomAppBar(
        title: getTranslatedText("deposit"),
        walletBalance: _vm.wallet?.totalBalance,
        isPassTrueWhenPop: true,
      );

  _displayDepositDialog() {
    _vm.getDepositDialog();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_vm.config?.depositNotification ?? false) {
        /*if (EnvironmentConfig.brandName == "GMO") {
          _showDialog("bank_transferring_notification_content_GMO");
        } else {
          _showDialog("bank_transferring_notification_content");
        }*/
        if (_vm.depositDialogContent?.isNotEmpty ?? false) _showDialog(_vm.depositDialogContent ?? "");
      }
    });
  }

  _showDialog(String content) => showDialog(
        context: context,
        builder: (BuildContext context) => DepositDialog(
          title: getTranslatedText("bank_transferring_notification"),
          description: getTranslatedText(content),
          buttonText1: getTranslatedText("confirm"),
        ),
      );

  _handleApiState() {
    handleApiState(_vm.getPaymentApiState, isAutoHideLoading: false, onSuccess: () {
      if (_vm.getPaymentApiState.result.isEmpty) {
        CustomToast.show(getTranslatedText("deposit_not_available"));
      }
    });
    handleApiState(_vm.getPlayerPromotionListApiState, isAutoHideLoading: false, onSuccess: () {});
  }
}
