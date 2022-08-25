import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class ProfileTopItem extends StatefulWidget {
  final String title;
  final String imagePath;
  final String routePath;

  ProfileTopItem({
    required this.title,
    required this.imagePath,
    required this.routePath,
  });

  @override
  _ProfileTopItemState createState() => _ProfileTopItemState();
}

class _ProfileTopItemState extends BaseState<ProfileTopItem> {
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.auto, bottom: 10.auto),
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () => _navigate(),
        child: Column(
          children: [
            widget.imagePath == "transfer"
                ? Container(
              height: 50.auto,
              child: SvgPicture.asset(
                "images/profile/t2/ic_${widget.imagePath}.svg",
                height: 40.auto,
              ),
            )
                : ImageIcon(
                    AssetImage("images/menu/ic_menu_${widget.imagePath}.png"),
                    size: 50.auto,
                  ),
            Text(
              getTranslatedText(widget.title),
              style: TextStyle(fontSize: 15.auto),
            )
          ],
        ),
      ),
    );
  }

  _navigate() => WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamed("/${widget.routePath}");
      });
}
