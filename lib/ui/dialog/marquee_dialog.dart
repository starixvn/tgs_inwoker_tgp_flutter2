import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';

class MarqueeDialog extends StatefulWidget {
  final String? title, description;
  final Function onClick;

  MarqueeDialog({
    this.title,
    required this.description,
    required this.onClick,
  });

  @override
  _MarqueeDialogState createState() => _MarqueeDialogState();
}

class _MarqueeDialogState extends BaseState<MarqueeDialog> {
  var isButtonClicked = false;

  @override
  void dispose() {
    if (!isButtonClicked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onClick();
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
        color: CustomColor.theme_button_color,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the card compact
        children: <Widget>[_buildTopContent(), _buildBottomContent()],
      ),
    );
  }

  _buildTopContent() => Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 13.auto, left: 20.auto, top: 20.auto),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/marquee_dialog/marquee_top_bg.png"),
                fit: BoxFit.fill,
              ),
            ),
            alignment: Alignment.centerLeft,
            height: context.screenHeight / 6.5,
            child: SizedBox(
              width: 130,
              height: context.screenHeight / 6.5,
              child: Container(
                alignment: Alignment.centerLeft,
                child: AutoSizeText(
                  getTranslatedText("marquee_welcome"),
                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 25),
                ),
              ),
            ),
          ),
          Positioned(
            top: -30.auto,
            right: -15.auto,
            child: Container(
              height: context.screenHeight / 5,
              child: Image.asset("images/marquee_dialog/marquee_girl.png"),
            ),
          ),
          Positioned(
            top: -70,
            right: 0,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                height: 25,
                width: 25,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(width: 2, color: Colors.white),
                  color: Colors.black,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          )
        ],
      );

  _buildBottomContent() => Container(
      width: context.screenWidth,
      padding: EdgeInsets.all(20.auto),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/marquee_dialog/marquee_bottom_bg.png"),
          fit: BoxFit.fill,
        ),
      ),
      height: context.screenHeight / 2.7,
      child: Column(
        children: [
          widget.title != null
              ? Text(
                  widget.title!,
                  style: TextStyle(
                    fontSize: 13.auto,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: widget.title == null ? TextAlign.center : TextAlign.start,
                )
              : Container(),
          Container(
            height: context.screenHeight / 2.7 - 75.auto,
            width: context.screenWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: CustomColor.black.withOpacity(0.5),
            ),
            margin: EdgeInsets.only(top: 10.auto),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.auto),
              child: Text(
                widget.description ?? "",
                style: TextStyle(
                  fontSize: 13.auto,
                  color: Colors.white,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ],
      ));
}
