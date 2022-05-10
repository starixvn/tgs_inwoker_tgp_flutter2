import 'package:api/extension/format.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/profile_info/birthdate/birthdate_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class Birthdate extends StatefulWidget {
  @override
  _BirthdateState createState() => _BirthdateState();
}

class _BirthdateState extends BaseState<Birthdate> {
  var _vm = BirthdateViewModel();
  var isButtonEnabled = false, isDatePickerEnabled = false;
  var buttonText;
  String? date;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _getUserProfile();
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<BirthdateViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return CustomScaffold(
              appBar: CustomAppBar(
                title: getTranslatedText("birthdate"),
                onPop: () => Navigator.pop(context, true),
              ),
              body: Container(
                  child: /*userProfile == null?
                  Center(child: CircularProgressIndicator(),):*/
                      Container(
                margin: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 20.auto),
                child: Column(
                  children: [
                    _buildDatePicker(),
                    _buildButton(),
                    _buildFooterText(),
                  ],
                ),
              )));
        });
  }

  _buildDatePicker() => Container(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10.auto),
              alignment: Alignment.topLeft,
              child: Text(
                getTranslatedText("birthdate"),
                style: TextStyle(color: CustomColor.theme_text_black_white_color, fontSize: 12.auto),
                textAlign: TextAlign.start,
              ),
            ),
            InkWell(
              onTap: isDatePickerEnabled?() => _showDatePicker(context):null,
              child: Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                  child: Container(
                    width: context.screenWidth - 40.auto,
                    padding: EdgeInsets.all(10.auto),
                    child: Text(
                      date != null ? date : getTranslatedText("birthdate_hint"),
                      style: TextStyle(
                        color: date != null ? CustomColor.theme_button_color : CustomColor.very_light_pink_two,
                        fontSize: 13.auto,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  )),
            ),
          ],
        ),
      );

  _showDatePicker(BuildContext context) async {
    var currentDate = DateTime.now();
    final DateTime? dateTime = await showDatePicker(
        context: context, initialDate: currentDate, firstDate: DateTime(1000), lastDate: currentDate);

    if (dateTime != null) {
      setState(() {
        date = Format().dateFormat(dateTime);
        isButtonEnabled = true;
      });
    }
  }

  _buildButton() => Container(
      width: context.screenWidth,
      margin: EdgeInsets.all(10.auto),
      child: ColorButton(
        title: buttonText ?? "",
        onClick: () {
          _onClick();
        },
        isEnabled: isButtonEnabled,
        color: CustomColor.theme_button_color,
        radius: 9.6,
      ));

  _buildFooterText() => Visibility(
        visible: _vm.userProfile.birthdate != null,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed("/customer_service");
          },
          child: RichText(
            text: TextSpan(
              text: getTranslatedText("edit_birthdate_cs"),
              style: TextStyle(fontSize: 11.auto, color: CustomColor.theme_text_black_white_color),
              children: [
                TextSpan(
                  text: getTranslatedText("online_cs"),
                  style: TextStyle(
                      decoration: TextDecoration.underline, color: CustomColor.theme_button_color, fontSize: 11.auto),
                ),
              ],
            ),
          ),
        ),
      );

  _getUserProfile() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      var _birthdate = _vm.userProfile.birthdate;
      setState(() {
        if (_birthdate != null && _birthdate.isNotEmpty) {
          date = _birthdate;
          buttonText = getTranslatedText("verified");
          isButtonEnabled = false;
          isDatePickerEnabled = false;
        } else {
          buttonText = getTranslatedText("done");
          isDatePickerEnabled = true;
        }
      });
    });
  }

  _onClick() async {
    ProgressDialog.show(context, _vm.brandLogoUrl);
    _vm.setBirthdate(date!);
  }

  _handleApiState() {
    handleApiState(_vm.setBirthdateApiState, onSuccess: () async {
      await _getUserProfile();
      CustomToast.show(getTranslatedText("success"));
    });
  }
}
