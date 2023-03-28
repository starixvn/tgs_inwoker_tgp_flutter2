import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

class CustomScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Color? color;
  final bool? resizeToAvoidBottomInset;

  CustomScaffold({
    this.appBar,
    required this.body,
    this.color,
    this.resizeToAvoidBottomInset = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: ((EnvironmentConfig.template_version == 9 && EnvironmentConfig.dark_mode) ||
              EnvironmentConfig.template_version == 11)
          ? Colors.transparent
          : (color ?? CustomColor.theme_bg_color),
      appBar: appBar, //?? PreferredSizeWidget(),
      body: Container(
        decoration: ((() {
          if (EnvironmentConfig.template_version == 9 && EnvironmentConfig.dark_mode)
            return BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, 0),
                colors: [Color.fromRGBO(78, 110, 164, 1.0), Color.fromRGBO(199, 219, 231, 1.0), Colors.white],
                radius: 1.5,
              ),
            );
          else if (EnvironmentConfig.template_version == 11)
            return BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/t11_bg/game_bg.png"),
                fit: BoxFit.fill,
              ),
            );
          else
            return BoxDecoration();
        }())),
        child: body,
      ),
    );
  }
}
