import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';

class ProfileTopItem extends StatefulWidget {
  final String title;
  final String imagePath;
  final String routePath;

  ProfileTopItem({
    Key key,
    this.title,
    this.imagePath,
    this.routePath,
  }) : super(key: key);

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
            ImageIcon(
              AssetImage("images/home/${widget.imagePath}.png"),
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
