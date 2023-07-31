import 'dart:ui';
import 'package:api/entity/vip.dart';
import 'package:api/extension/format.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/vip/vipT14.dart';
import 'package:tgp_flutter2/ui/vip/vip_view_model.dart';

import '../../globalUtil/GlobalValueUtil.dart';
import 'announcement_view_model.dart';

class AnnouncementItemDetails extends StatefulWidget {
  final AnnouncementViewModel vm;
  final int index;

  AnnouncementItemDetails({required this.vm, required this.index});

  @override
  _AnnouncementItemDetailsState createState() => _AnnouncementItemDetailsState();
}

class _AnnouncementItemDetailsState extends BaseState<AnnouncementItemDetails> {
  int currIndex = 0;
  late Map<String, String> currAnnouncement;

  @override
  void initState() {
    currIndex = widget.index;
    currAnnouncement = widget.vm.contentList[currIndex];
    super.initState();
  }

  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(title: "TOP NEWS"),
      body: Container(
        height: context.screenHeight,
        color: CustomColor.theme_bar_gradient_2,
        padding: EdgeInsets.symmetric(horizontal: 10.auto),
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 10),
            Container(
              // margin: EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  width: context.screenWidth,
                  height: 150.auto,
                  placeholder: (context, url) => buildEmptyContainer(),
                  imageUrl: "https://tgs-t14.wokerspace.com/assets/images/news/w${currIndex + 1}.jpg",
                  //handling error
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => buildEmptyContainer(),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 50.auto,
              // padding: EdgeInsets.all(10.auto),
              child: Row(
                children: [
                  Expanded(
                    flex: 0,
                    child: InkWell(
                      onTap: () => setState(() {
                        if (currIndex == 0)
                          currIndex = widget.vm.contentList.length - 1;
                        else
                          currIndex--;
                        currAnnouncement = widget.vm.contentList[currIndex];
                      }),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: GlobalValueUtil.calculateTextSize(
                        text: currAnnouncement["title"] ?? "",
                        style: TextStyle(fontSize: 16.auto),
                        context: context,
                      ).height,
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.fitHeight,
                        child: Text(
                          currAnnouncement["title"] ?? "",
                          style: TextStyle(color: Colors.white, fontSize: 16.auto),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 0,
                    child: InkWell(
                      onTap: () => setState(() {
                        if (currIndex == widget.vm.contentList.length - 1)
                          currIndex = 0;
                        else
                          currIndex++;
                        currAnnouncement = widget.vm.contentList[currIndex];
                      }),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.auto),
            Container(
              alignment: Alignment.center,
              child: Text(
                "By ${currAnnouncement["writer"] ?? ""}",
                style: TextStyle(color: Colors.white, fontSize: 16.auto),
              ),
            ),
            SizedBox(height: 10.auto),
            Container(
              alignment: Alignment.center,
              child: Text(
                "${currAnnouncement["date"] ?? ""}",
                style: TextStyle(color: Colors.white, fontSize: 16.auto),
              ),
            ),
            SizedBox(height: 10.auto),
            Container(
              alignment: Alignment.center,
              child: Html(
                data: //"""<style>tr{ border: 1px solid; } </style>""" +
                    currAnnouncement["content2"] ?? "",
                style: {
                  'body': Style(
                    color: Colors.white,
                  )
                },
              ),
              // Text(
              //   currAnnouncement["content2"] ?? "",
              //   style: TextStyle(color: Colors.white, fontSize: 16.auto),
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
