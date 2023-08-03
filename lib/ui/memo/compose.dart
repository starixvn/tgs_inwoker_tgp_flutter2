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
import 'package:tgp_flutter2/ui/vip/vipT14.dart';
import 'package:tgp_flutter2/ui/vip/vip_view_model.dart';

import '../../custom/custom_text_form_field.dart';
import '../report/account_report_view.dart';
import 'memo_view_model.dart';

class Compose extends StatefulWidget {
  @override
  _ComposeState createState() => _ComposeState();
}

class _ComposeState extends BaseState<Compose> {
  TextEditingController _subjectController = TextEditingController();
  TextEditingController _memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          CustomTextFormField(
            title: "Subject",
            hintText: "PLease enter subject",
            onChanged: (value) {},
            onFieldSubmitted: (value) {},
            controller: _subjectController,
            width: context.screenWidth - 70.auto,
            textInputType: TextInputType.text,
            textInputAction: TextInputAction.next,
          ),
          CustomTextFormField(
            title: "Memo",
            hintText: "Please enter memo",
            onChanged: (value) {},
            onFieldSubmitted: (value) {},
            controller: _memoController,
            width: context.screenWidth - 70.auto,
            textInputType: TextInputType.text,
            textInputAction: TextInputAction.next,
          ),
          _buildSubmitButton()
        ],
      ),
    );
  }

  _buildSubmitButton() => Container(
      width: context.screenWidth,
      padding: EdgeInsets.all(10.auto),
      child: ColorButton(
        title: getTranslatedText("submit"),
        onClick: () {

        },
        isEnabled: true,
        color: CustomColor.theme_button_color,
        radius: 9.6,
      ));
}
