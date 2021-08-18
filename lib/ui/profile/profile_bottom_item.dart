import 'package:animated_widgets/widgets/opacity_animated.dart';
import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:animated_widgets/widgets/size_animated.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

import 'animated_dot.dart';

class ProfileBottomItem extends StatefulWidget {
  final String title;
  final String imagePath;
  final String routePath;
  final int navigationID;
  final bool isMessage;

  ProfileBottomItem({Key key, this.title, this.imagePath, this.routePath, this.navigationID, this.isMessage})
      : super(key: key);

  @override
  _ProfileBottomItemState createState() => _ProfileBottomItemState();
}

class _ProfileBottomItemState extends BaseState<ProfileBottomItem> {
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigate(),
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.9),
        ),
        elevation: 5,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              //margin: EdgeInsets.symmetric(vertical: 13,horizontal: 10),
              margin: EdgeInsets.only(left: 5.auto, right: 5.auto, top: 10.auto, bottom: 5.auto),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_buildImageIcon(), _buildProfileBottomItemText()],
              ),
            ),
            _buildNotification()
          ],
        ),
      ),
    );
  }

  _buildImageIcon() => ImageIcon(
        widget.imagePath == "ic_customer_service"
            ? AssetImage("images/bottom_navigation_bar/ic_customer_service.png")
            : AssetImage("images/profile/${widget.imagePath}.png"),
        size: 27.auto,
      );

  _buildProfileBottomItemText() => Container(
        padding: EdgeInsets.only(top: 10.auto),
        child: AutoSizeText(
          widget.title,
          style: TextStyle(fontSize: 10),
          textAlign: TextAlign.center,
          minFontSize: 5,
          stepGranularity: 1,
          maxLines: 1,
        ),
      );

  _navigate() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.navigationID == 0) {
          Navigator.of(context).pushNamed("/${widget.routePath}");
        } else {
          /*Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Transaction(
                        tabIndex: widget.navigationID,
                      )));*/
        }
      });

  _buildNotification() => Visibility(
      visible: widget.isMessage,
      child: Positioned(top: context.screenWidth / 24, right: context.screenWidth / 18, child: AnimatedDot()));
}
