import 'dart:ui';
import 'package:api/entity/vip.dart';
import 'package:api/extension/format.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/vip/vip_view_model.dart';

class VipView extends StatefulWidget {
  @override
  _VipViewState createState() => _VipViewState();
}

class _VipViewState extends BaseState<VipView> {
  var isEditing = false, isSelected = false;
  VipViewModel _vm = VipViewModel();
  int vipIndex = 0;

  @override
  void initState() {
    _vm.getVip();
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<VipViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return CustomScaffold(appBar: _buildAppBar(),
            body: _vm.vipList == null
                ? buildProgressDialog(_vm.brandLogoUrl)
                : Container(
                    height: context.screenHeight,
                    margin: EdgeInsets.all(15.auto),
                    decoration:
                        BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        Container(
                          height: 120.auto,
                          padding: EdgeInsets.only(top: 15.auto, left: 5.auto, right: 5.auto),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: List.generate(
                              _vm.vipList!.length,
                              (index) {
                                return _buildVipIcon(index);
                              },
                            ),
                          ),
                        ),
                        _buildVipDetails()
                      ],
                    ),
                  ),
          );
        });
  }

  _buildAppBar() => CustomAppBar(
        title: "VIP",
      );

  _buildVipIcon(int index) => InkWell(
        onTap: () {
          setState(() {
            vipIndex = index;
          });
        },
        child: Container(
          padding: EdgeInsets.all(10.auto),
          decoration: BoxDecoration(
            border: Border.all(color: index == vipIndex ? CustomColor.theme_button_color : Colors.transparent),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 8,
                child: Image.asset(
                  "images/vip/vip0${index + 1}.png",
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "VIP ${index + 1}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      );

  _buildVipDetails() => Container(
        padding: EdgeInsets.all(15.auto),
        height: context.screenHeight - 200.auto,
        child: ListView(
          shrinkWrap: true,
          children: /*[
            _buildVipDetailsRow("hshs", "0"),
          ]*/
              _vm.vipMap.entries.map((e) {
            return Container(
              child: _buildVipDetailsColumn(e.key, e.value),
            );
          }).toList(),
        ),
      );

  _buildVipDetailsColumn(int key, Vip vip) => Visibility(
        visible: key == vipIndex + 1,
        child: Column(
          children: [
            _buildVipDetailsRow("levelKeepAccumulateBetAmount", _getAmount(vip.levelKeepAccumulateBetAmount)),
            _buildVipDetailsRow("levelKeepAccumulateDeposit", _getAmount(vip.levelKeepAccumulateDeposit)),
            _buildVipDetailsRow("levelUpAccumulateBetAmount", _getAmount(vip.levelUpAccumulateBetAmount)),
            _buildVipDetailsRow("levelUpAccumulateDeposit", _getAmount(vip.levelUpAccumulateDeposit)),
            _buildVipDetailsRow("birthdayBenefit", _getAmount(vip.birthBenefit)),
            _buildVipDetailsRow("promotionBenefit", _getAmount(vip.promotionBenefit)),
            _buildVipDetailsRow("quarterlyBenefit", _getAmount(vip.quarterlyBenefit)),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 30.auto, bottom: 5.auto),
              child: Text(
                getTranslatedText("vipRebate"),
                style: TextStyle(fontSize: 14.auto, fontWeight: FontWeight.bold),
              ),
            ),
            _buildVipDetailsRow("cardGameRebate", _getRebateAmount(vip.cardGameRebate)),
            _buildVipDetailsRow("liveDealerRebate", _getRebateAmount(vip.liveDealerRebate)),
            _buildVipDetailsRow("lotteryRebate", _getRebateAmount(vip.lotteryRebate)),
            _buildVipDetailsRow("slotRebate", _getRebateAmount(vip.slotRebate)),
            _buildVipDetailsRow("sportsRebate", _getRebateAmount(vip.sportsRebate)),
            _buildVipDetailsRow("virtualSportsRebate", _getRebateAmount(vip.virtualSportsRebate), isLast: true),
          ],
        ),
      );

  _buildVipDetailsRow(String title, String content, {bool isLast = false}) => Container(
        margin: EdgeInsets.only(top: 5.auto, bottom: isLast ? 15.auto : 5.auto),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 7,
              child: Text(
                getTranslatedText(title),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  content,
                ),
              ),
            )
          ],
        ),
      );

  _getAmount(double? amount) => Format().currencyFormat((amount ?? 0).toInt());

  _getRebateAmount(double? amount) => "${((amount ?? 0).toInt().toString())}%";

  _handleApiState() {
    handleApiState(_vm.getVipApiState, isAutoHideLoading: false, isSplashScreen: true, onSuccess: () {});
  }
}
