import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

import '../../custom/custom_text_form_field.dart';
import 'ErrorDialogUtils.dart';
import 'memo_view_model.dart';

class Compose extends StatefulWidget {
  final MemoViewModel vm;

  Compose({required this.vm});

  @override
  _ComposeState createState() => _ComposeState();
}

class _ComposeState extends BaseState<Compose> {

  var isButtonEnabled = false;
  TextEditingController _subjectController = TextEditingController();
  TextEditingController _memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Wrap(
      // preventing white box display in full height
      children: [
        Container(
          decoration:
              EnvironmentConfig.template_version == 14 ? BoxDecoration() : BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.auto)),
          padding: EnvironmentConfig.template_version == 14 ? EdgeInsets.zero : EdgeInsets.all(15.auto),
          margin: EnvironmentConfig.template_version == 14 ? EdgeInsets.zero : EdgeInsets.all(10.auto),
          child: Wrap(
            children: [
              CustomTextFormField(
                  title: getTranslatedText("memo_subject"),
                  titleFontWeight: FontWeight.bold,
                  hintText: getTranslatedText("enter_memo_subject"),
                  onChanged: (value) => onTextChange(),
                  onFieldSubmitted: (value) => onTextChange(),
                  controller: _subjectController,
                  width: context.screenWidth - 70.auto,
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  elevation: EnvironmentConfig.template_version == 14 ? 5 : 0),
              CustomTextFormField(
                  title: getTranslatedText("memo"),
                  titleFontWeight: FontWeight.bold,
                  hintText: getTranslatedText("enter_memo"),
                  onChanged: (value) => onTextChange(),
                  onFieldSubmitted: (value) => onTextChange(),
                  controller: _memoController,
                  width: context.screenWidth - 70.auto,
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  elevation: EnvironmentConfig.template_version == 14 ? 5 : 0),
              _buildSubmitButton()
            ],
          ),
        ),
      ],
    );
  }

  _buildSubmitButton() => Container(
      width: context.screenWidth,
      padding: EdgeInsets.all(10.auto),
      child: ColorButton(
        title: getTranslatedText("submit"),
        onClick: () async {
          if (_subjectController.text.isNotEmpty && _memoController.text.isNotEmpty) {
              await widget.vm.postStationLetter(_subjectController.text,_memoController.text);
             _subjectController.clear();
             _memoController.clear();
          }
          ErrorDialogUtils.showErrorDialog(context, 'Send Success');
        },
        isEnabled: isButtonEnabled,
        color: CustomColor.theme_button_color,
        radius: 9.6,
      ));

  onTextChange() {
    if (_subjectController.text.isNotEmpty && _memoController.text.isNotEmpty) {
      setState(() {
        isButtonEnabled = true;
      });
    } else {
      setState(() {
        isButtonEnabled = false;
      });
    }
  }
}
