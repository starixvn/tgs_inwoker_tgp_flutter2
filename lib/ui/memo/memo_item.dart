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
import 'package:tgp_flutter2/ui/memo/sent.dart';
import 'package:tgp_flutter2/ui/vip/vipT14.dart';
import 'package:tgp_flutter2/ui/vip/vip_view_model.dart';

import '../../custom/custom_text_form_field.dart';
import '../report/account_report_view.dart';
import 'compose.dart';
import 'inbox.dart';
import 'memo_view_model.dart';

class MemoItem extends StatefulWidget {
  final String title;
  final String date;

  const MemoItem({Key? key, required this.title, required this.date}) : super(key: key);

  @override
  _MemoItemState createState() => _MemoItemState();
}

class _MemoItemState extends BaseState<MemoItem> with SingleTickerProviderStateMixin {
  var _tabController;
  var currentTabIndex = 0;
  var tabList = [
    {"id": "0", "text": "compose"},
    {"id": "1", "text": "inbox"},
    {"id": "2", "text": "sent"},

    /*{"id": "4", "text": "返水记录"},*/
  ];
  MemoViewModel _vm = MemoViewModel();

  @override
  void initState() {
    _tabController = TabController(length: tabList.length, vsync: this, initialIndex: currentTabIndex);
    super.initState();
  }

  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          thickness: (1.0).auto,
          color: Color(0xffeaeaea),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title),
            Text(widget.date),
          ],
        ),
      ],
    );
  }
}
