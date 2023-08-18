import 'package:api/extension/format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';

import 'ErrorDialogUtils.dart';

class ReplyDialog extends StatefulWidget {
  final String? id;
  final String? title;
  final Function(String) onSentClick;

  ReplyDialog({this.id, this.title, required this.onSentClick});

  @override
  _ReplyDialogState createState() => _ReplyDialogState();
}

class _ReplyDialogState extends BaseState<ReplyDialog> {
  var isButtonEnabled = false;
  TextEditingController fieldController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            vertical: context.screenHeight / 90,
            horizontal: context.screenWidth / 20,
          ),
          decoration: new BoxDecoration(
            color: EnvironmentConfig.template_version == 14 ? CustomColor.theme_bar_gradient_1 : Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.centerRight,
                child: _buildCloseDialogButton(),
              ),
              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Text(
                        "主旨",
                        style: TextStyle(color:_getTextColor(), fontSize: 12.5),
                      )),
                  Expanded(
                    flex: 5,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Container(
                            width: context.screenWidth * 0.1,
                            decoration: BoxDecoration(
                              color: Color(0xffF8F8F8),
                              border: Border.all(color: Color(0xffD0D0D0)),
                            ),
                            child: Text(
                              "Re：${widget.title}",
                              style: TextStyle(
                                color:_getTextColor(),
                                fontSize: 12.5,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 5,
                            child: Container()
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 5),
              Container(
                height: context.screenHeight / 8,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Text(
                          "站内信",
                          style: TextStyle(color:_getTextColor(), fontSize: 12.5),
                        )),
                    Expanded(
                      flex: 5,
                      child: Container(
                        height: 222,
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xffB7C7CC)),
                        ),
                        child: TextFormField(
                          controller: fieldController,
                          onChanged: (value) => onTextChange(),
                          style: TextStyle(fontSize: 12.5),
                          maxLines: null,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(0),
                            isDense: true,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(flex: 1, child: Container()),
                  Expanded(
                    flex: 5,
                    child: ColorButton(
                      title: getTranslatedText("submit"),
                      onClick: () async {
                        if (fieldController.text.isNotEmpty) {
                          await widget.onSentClick(fieldController.text);
                          fieldController.clear();
                          ErrorDialogUtils.showErrorDialog(context, getTranslatedText("memo_reply_success"), getTranslatedText("memo_reply_confirm"),popCount: 3);
                        }
                      },
                      isEnabled: isButtonEnabled,
                      width: 60.auto,
                      height: 17,
                      fontSize: 14,
                      radius: 5,
                      padding: 4,
                      textColor: /*_isDarkMode() || EnvironmentConfig.light_mode || EnvironmentConfig.template_version == 14 ?*/
                          Colors.white /*: CustomColor.theme_app_bar_color*/,
                      color: /*EnvironmentConfig.template_version == 3 ||
                            EnvironmentConfig.template_version == 4 ||
                            EnvironmentConfig.template_version == 10 ||
                            EnvironmentConfig.template_version == 14 ||
                            _isDarkMode() ||
                            EnvironmentConfig.light_mode
                            ? */
                          CustomColor.theme_button_color /* : Colors.white*/,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  onTextChange() {
    if (fieldController.text.isNotEmpty) {
      setState(() {
        isButtonEnabled = true;
      });
    } else {
      setState(() {
        isButtonEnabled = false;
      });
    }
  }

  _buildCloseDialogButton() => InkWell(
        onTap: () => Navigator.pop(context),
        child: Icon(
          Icons.close,
          color: Colors.black,
          size: 20,
        ),
      );

  Color _getTextColor() => EnvironmentConfig.template_version == 14 ? Colors.white : Colors.black;
}
