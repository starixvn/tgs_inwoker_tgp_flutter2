import 'package:api/entity/language.dart';
import 'package:api/extension/screen_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';

class LanguageDialog extends StatefulWidget {
  final List<Language> languageList;
  final ValueChanged<Language> changeLanguage;

  LanguageDialog({
    required this.languageList,
    required this.changeLanguage,
  });

  @override
  _LanguageDialogState createState() => _LanguageDialogState();
}

class _LanguageDialogState extends BaseState<LanguageDialog> {
  var isButtonClicked = false, isButton2Clicked = false;

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil.getInstance().appBarHeight, horizontal: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the card compact
        children: <Widget>[
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xff242958),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  width: context.screenWidth,
                  child: Text(
                    "LANGUAGE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.auto,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]..addAll(List.generate(
            widget.languageList.length,
            (index) => InkWell(
              onTap: (){
                widget.changeLanguage(widget.languageList[index]);
              },
              child: Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    width: context.screenWidth,
                    decoration: BoxDecoration(
                      color: Color(0xff181c42),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.languageList[index].name,
                      style: TextStyle(
                        fontSize: 18.auto,
                        color: Colors.white,
                      ),
                    ),
                  ),
            ))),
      ),
    );
  }
}
