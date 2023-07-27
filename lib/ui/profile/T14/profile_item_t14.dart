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

class ProfileItemT14 extends StatefulWidget {
  final String title;
  final String imagePath;
  final String routePath;
  final int navigationID;
  final bool isMessage;
  final VoidCallback logout;
  final bool isNotify;

  ProfileItemT14({
    required this.title,
    required this.imagePath,
    required this.routePath,
    required this.navigationID,
    required this.isMessage,
    required this.logout,
    this.isNotify = false,
  });

  @override
  _ProfileItemT14State createState() => _ProfileItemT14State();
}

class _ProfileItemT14State extends BaseState<ProfileItemT14> {
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigate(),
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            //margin: EdgeInsets.symmetric(vertical: 13,horizontal: 10),
            margin: EdgeInsets.only(left: 5.auto, right: 5.auto, top: 10.auto, bottom: 5.auto),
            child: Column(
              // direction: Axis.vertical,
              // alignment: WrapAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildImageIcon(),
                SizedBox(height: 10),
                _buildProfileBottomItemText(),
              ],
            ),
          ),
          if (widget.isMessage && widget.isNotify)
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                height: 5,
                width: 5,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
        ],
      ),
      // Stack(
      //   alignment: Alignment.center,
      //   children: [
      //
      //     _buildNotification()
      //   ],
      // ),
    );
  }

  _buildImageIcon() => widget.imagePath == "ic_lang"
      ? Image.asset(
          "images/login/ic_language.png",
          width: 40.auto,
          height: 40.auto,
          color: Colors.white,
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
          width: 40.auto,
          height: 40.auto,
          matchTextDirection: true,
          color: Colors.white,
        );

  _buildProfileBottomItemText() {
    String title = widget.title.replaceAll(" ", "\n");
    return Text(
      title,
      softWrap: true,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white, fontSize: 10.auto),
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
