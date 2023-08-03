import 'dart:ui';
import 'package:api/entity/vip.dart';
import 'package:api/extension/format.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
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
import 'package:tgp_flutter2/ui/vip/table/TableBody.dart';
import 'package:tgp_flutter2/ui/vip/table/TableHead.dart';
import 'package:tgp_flutter2/ui/vip/vip_view_model.dart';

class VipViewT14 extends StatefulWidget {
  final VipViewModel vm;

  VipViewT14({required this.vm});

  @override
  _VipViewT14State createState() => _VipViewT14State();
}

class _VipViewT14State extends BaseState<VipViewT14> {
  List list = [
    "levelKeepAccumulateBetAmount",
    "levelKeepAccumulateDeposit",
    "levelUpAccumulateBetAmount",
    "levelUpAccumulateDeposit",
    "birthdayBenefit",
    "promotionBenefit",
    "quarterlyBenefit",
    "cardGameRebate",
    "lotteryRebate",
    "slotRebate",
    "sportsRebate",
    "virtualSportsRebate",
  ];

  late LinkedScrollControllerGroup _controllers;
  late ScrollController _headController;
  late ScrollController _bodyController;
  int maxNum = 100;

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _headController = _controllers.addAndGet();
    _bodyController = _controllers.addAndGet();
  }

  @override
  void dispose() {
    _headController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Container(
        height: context.screenHeight,
        width: context.screenWidth,
        child: Column(
          children: [
            TableHead(
              scrollController: _headController,
            ),
            Expanded(
              child: TableBody(
                scrollController: _bodyController,
                vm: widget.vm,
              ),
            ),
          ],
        ));
  }
}
