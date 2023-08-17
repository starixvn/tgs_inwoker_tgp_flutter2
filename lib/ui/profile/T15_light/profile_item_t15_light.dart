import 'package:animated_widgets/widgets/opacity_animated.dart';
import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:animated_widgets/widgets/size_animated.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/report/report_view.dart';

import '../animated_dot.dart';

class ProfileItemT15Light extends StatefulWidget {
  final String title;
  final String imagePath;
  final String routePath;
  final int navigationID;
  final bool isMessage;
  final VoidCallback logout;
  final bool isNotify;

  ProfileItemT15Light({
    required this.title,
    required this.imagePath,
    required this.routePath,
    required this.navigationID,
    required this.isMessage,
    required this.logout,
    this.isNotify = false,
  });

  @override
  _ProfileItemT15LightState createState() => _ProfileItemT15LightState();
}

class _ProfileItemT15LightState extends BaseState<ProfileItemT15Light> {
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigate(),
      child: Container(
        width: context.screenWidth,
        alignment: Alignment.center,
        color: Colors.white,
        //margin: EdgeInsets.symmetric(vertical: 13,horizontal: 10),
        margin: EdgeInsets.only(bottom: 15.auto),
        padding: EdgeInsets.symmetric(horizontal: 40.auto, vertical: 10.auto),
        child: Row(
          // direction: Axis.vertical,
          // alignment: WrapAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.imagePath.isNotEmpty) Expanded(flex: 0, child: _buildImageIcon()),
            if (widget.imagePath.isNotEmpty) SizedBox(width: 10),
            Expanded(flex: 1, child: _buildProfileBottomItemText()),
            Expanded(flex: 0, child: Icon(Icons.keyboard_arrow_right, color: Color(0xffcfd3dd))),
          ],
        ),
      ),
    );
  }

  _buildImageIcon() => widget.imagePath == "ic_lang"
      ? Image.asset(
          "images/login/ic_language.png",
          height: 20.auto,
          color: Color(0xffa8afc1),
        )
      : SvgPicture.asset(
          (() {
            switch (widget.imagePath) {
              case "ic_vip":
                return "images/profile/t2/${widget.imagePath}.svg";
              case "ic_transfer":
              case "ic_signout":
              case "ic_announcement":
              case "ic_favourite":
                return "images/profile/t14/${widget.imagePath}.svg";
              default:
                return "images/profile/t1/${widget.imagePath}.svg";
            }
          }()),
          height: 20.auto,
          matchTextDirection: true,
          color: Color(0xffa8afc1),
        );

  _buildProfileBottomItemText() {
    return Text(
      widget.title,
      textAlign: TextAlign.start,
      style: TextStyle(color: Colors.black, fontSize: 10.auto),
    );
  }

  // Expanded(
  //   flex: 1,
  //   child: ClipRRect(
  //     child: ,
  //   ),
  // );

  _navigate() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.navigationID == -1) {
          widget.logout();
        } else if (widget.navigationID == 0) {
          Navigator.of(context).pushNamed("/${widget.routePath}");
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReportView(
                        tabIndex: widget.navigationID,
                      )));
        }
      });

  _buildNotification() =>
      Visibility(visible: widget.isMessage, child: Positioned(top: context.screenWidth / 24, right: context.screenWidth / 18, child: AnimatedDot()));
}
