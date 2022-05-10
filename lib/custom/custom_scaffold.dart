import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

class CustomScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;

  CustomScaffold({
    this.appBar,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: (EnvironmentConfig.template_version == 9 && EnvironmentConfig.dark_mode)
          ? Colors.transparent
          : CustomColor.theme_bg_color,
      appBar: appBar ,//?? PreferredSizeWidget(),
      body: Container(
        decoration: (EnvironmentConfig.template_version == 9 && EnvironmentConfig.dark_mode)
            ? BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, 0),
                  colors: [
                    Color.fromRGBO(78, 110, 164, 1.0),
                    Color.fromRGBO(199, 219, 231, 1.0),
                    Colors.white
                  ],
                  radius: 1.5,
                ),
              )
            : BoxDecoration(),
        child: body,
      ),
    );
  }
}
