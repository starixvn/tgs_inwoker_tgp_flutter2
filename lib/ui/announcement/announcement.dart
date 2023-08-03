import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/announcement/announcement_item_details.dart';

import '../../src/custom_color.dart';
import 'announcement_view_model.dart';

class Announcement extends StatefulWidget {
  @override
  _AnnouncementState createState() => _AnnouncementState();
}

class _AnnouncementState extends BaseState<Announcement> {
  var isEditing = false, isSelected = false;
  AnnouncementViewModel _vm = AnnouncementViewModel();
  int vipIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<AnnouncementViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          // _handleApiState();
          return CustomScaffold(
            appBar: _buildAppBar(),
            body: Container(
              height: context.screenHeight,
              child: ListView(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(10.auto),
                  children: List.generate(
                      _vm.contentList.length,
                      (index) => Container(
                            child: _buildAnnouncementItem(index),
                          ))),
            ),
          );
        });
  }

  _buildAppBar() => CustomAppBar(title: getTranslatedText("top_news"));

  _buildAnnouncementItem(int index) => InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AnnouncementItemDetails(vm: _vm, index: index)));
        },
        child: Container(
            decoration: BoxDecoration(color: CustomColor.theme_bar_gradient_1, borderRadius: BorderRadius.all(Radius.circular(20))),
            margin: EdgeInsets.only(bottom: 10.auto),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.auto),
              child: Column(
                children: [
                  CachedNetworkImage(
                    width: context.screenWidth,
                    height: 150.auto,
                    placeholder: (context, url) => buildEmptyContainer(),
                    imageUrl: "${EnvironmentConfig.url}/assets/images/news/w${index + 1}.jpg",
                    //handling error
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => buildEmptyContainer(),
                  ),
                  Container(
                    width: context.screenWidth,
                    padding: EdgeInsets.all(10.auto),
                    alignment: Alignment.centerLeft,
                    child: Text(_vm.contentList[index]["title"] ?? "", style: TextStyle(color: Colors.white, fontSize: 20.auto)),
                  ),
                  Container(
                    width: context.screenWidth,
                    padding: EdgeInsets.only(left: 10.auto, right: 10.auto, bottom: 10.auto),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _vm.contentList[index]["content"] ?? "",
                      style: TextStyle(color: Colors.white, fontSize: 12.auto),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),
      );
}
