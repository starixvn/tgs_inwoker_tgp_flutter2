import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/report/report_view.dart';

class MenuItemT2 extends StatefulWidget {
  final String? image;
  final String? text;
  final String? navigationPath;
  final int? navigationID;

  MenuItemT2({this.image, this.text, this.navigationPath, this.navigationID});

  @override
  _MenuItemT2State createState() => _MenuItemT2State();
}

class _MenuItemT2State extends BaseState<MenuItemT2> {
  var tabIndex;

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _onClick(),
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: null,
            onPressed: () => _onClick(),
            child: ((() {
              if (widget.image == "ic_transfer")
                return SvgPicture.asset(
                  "images/profile/t2/${widget.image}.svg",
                  matchTextDirection: true,
                  height: 28.auto,
                  color: Colors.white,
                );
              else if (widget.image?.contains("history") ?? false)
                return SvgPicture.asset(
                  "images/profile/t1/ic_account_report.svg",
                  matchTextDirection: true,
                  height: 25.auto,
                  color: Colors.white,
                );
              else
                return ImageIcon(
                  AssetImage("images/menu/${widget.image}.png"),
                  size: 25.auto,
                );
            }())),
            backgroundColor: Colors.transparent,
            materialTapTargetSize: MaterialTapTargetSize.padded,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.auto),
                side: BorderSide(
                  color: Colors.white,
                  width: 1.0,
                )),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.auto),
            child: Text(
              widget.text!,
              style: TextStyle(fontSize: 10.auto, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  _onClick() {
    if (widget.navigationID == 0) {
      Navigator.of(context).pushNamed("/${widget.navigationPath}");
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ReportView(
                    tabIndex: widget.navigationID!,
                  )));
    }
  }
}
