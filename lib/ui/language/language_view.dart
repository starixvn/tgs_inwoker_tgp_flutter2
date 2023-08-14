import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:api/entity/language.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:api/localizations/language_provider.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/main.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/ui/language/language_item.dart';
import 'package:tgp_flutter2/ui/language/language_view_model.dart';

import '../../globalUtil/GlobalValueUtil.dart';

class LanguageView extends StatefulWidget {
  @override
  _LanguageViewState createState() => _LanguageViewState();
}

class _LanguageViewState extends BaseState<LanguageView> {
  var isEditing = false, isSelected = false;
  var list = LanguageProvider.getSingleton().list;
  var _vm = LanguageViewModel();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    var deviceLanguage = list.singleWhere((e) => e.locale == Localizations.localeOf(context));
    return ProviderWidget<LanguageViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          return CustomScaffold(
              appBar: CustomAppBar(
                title: getTranslatedText("language"),
              ),
              body: ListView(
                children: List.generate(
                    list.length,
                    (index) => Container(
                          child: InkWell(
                            onTap: () => _changeLanguage(list[index]),
                            child: LanguageItem(
                              imagePath: list[index].imageRes,
                              text: list[index].name,
                              isSelected: deviceLanguage == list[index],
                            ),
                          ),
                        )),
              ));
        });
  }

  void _changeLanguage(Language language) async {
    Locale? _locale = await LanguageProvider.getSingleton().setLocale(language);
    MyApp.setLocale(context, _locale!);
    await _vm.getApiError();
    GlobalValueUtil.updateLanguageCode();
  }
}
