import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_svg/svg.dart';
import 'package:marquee/marquee.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:api/entity/user_profile.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/home_view_model.dart';

import '../../globalUtil/GlobalValueUtil.dart';

class HomeT9 extends StatefulWidget {
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final Function initData;
  final HomeViewModel homeViewModel;
  final GameViewModel gameViewModel;
  final int? randomNumber;
  final Widget gameView;

  HomeT9({
    this.onPauseBgMusic,
    this.onResumeBgMusic,
    required this.initData,
    required this.homeViewModel,
    required this.gameViewModel,
    this.randomNumber,
    required this.gameView,
  });

  @override
  _HomeT9State createState() => _HomeT9State();
}

class _HomeT9State extends BaseState<HomeT9> {
  List<String> imgList = [
    '1',
    '2',
    //'images/banner_2.jpg'
  ];
  String marquee = "《GD真人维护公告》GD真人将于 7 月 2 8 日 09:00 至 14:00 进行维护 维护期间不提供游戏相关服务。若有问题欢迎与在线客服联系 如有问题欢迎与在线客服联系，谢谢";
  ScrollController controller = ScrollController();
  var currentTabIndex = "0";
  UserProfile? user;
  var currentBottomIndex = 0;
  var isMenu = false;

  var itemHeightRatio = 335 / 90;
  int _current = 0;
  CarouselController carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: _buildImageSlider(),
        ),
        Expanded(
          flex: 3,
          child: Container(
            margin: EdgeInsets.only(top: 10.auto, left: 10.auto, right: 10.auto),
            child: Column(
              children: [
                _buildTextMarquee(),
                widget.gameView,
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildImageSlider() => Container(
        height: context.screenHeight / 5,
        child: widget.homeViewModel.bannerList == null || widget.homeViewModel.bannerList!.isEmpty
            ? buildEmptyContainer(borderRadius: 20)
            : ImageSlideshow(
                initialPage: 0,
                indicatorColor: Colors.transparent,
                indicatorBackgroundColor: Colors.transparent,
                children: List.generate(
                    widget.homeViewModel.bannerList!.length,
                    (index) => widget.homeViewModel.bannerList![index].mobileUrl == null
                        ? buildEmptyContainer(borderRadius: 20)
                        : ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            child: CachedNetworkImage(
                              placeholder: (context, url) => buildEmptyContainer(borderRadius: 20),
                              imageUrl: widget.homeViewModel.bannerList![index].mobileUrl!,
                              //handling error
                              fit: BoxFit.fill,
                              errorWidget: (context, url, error) => buildEmptyContainer(borderRadius: 20),
                            ),
                          )),
                isLoop: true,
                autoPlayInterval: 3000),
      );

  _buildTextMarquee() {
    var announcement = widget.homeViewModel.announcement;
    return Container(
      padding: EdgeInsets.only(top: 3.auto, bottom: 5.auto),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          //  if (widget.homeViewModel.config?.onlineUser ?? false)
          Expanded(
            flex: GlobalValueUtil.languageCode.contains("zh") ? 2 : 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTranslatedText("online_user") + " :",
                  style: TextStyle(
                    fontSize: 10.auto,
                    color: CustomColor.theme_text_black_white_color,
                  ),
                ),
                Container(
                  child: Text(
                    (widget.randomNumber ?? 26500).toString(),
                    style: TextStyle(
                      fontSize: 10.auto,
                      color: CustomColor.theme_text_black_white_color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: SvgPicture.asset(
              "images/home/ic_marquee.svg",
              height: 15.auto,
              color: CustomColor.announcement_icon_color,
            ),
          ),
          Expanded(
            flex: _getNoticeFlex(),
            child: Container(
              // width: (languageCode?.contains("zh") ?? false) ? context.screenWidth / 10 : context.screenWidth / 5,
              child: Text(
                getTranslatedText("notice"),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: CustomColor.theme_text_black_white_color,
                  fontSize: 11.auto,
                ),
                /* maxFontSize: 12,
                minFontSize: 5,*/
                maxLines: 1,
                //stepGranularity: 1,
              ),
            ),
          ),
          Expanded(
              flex: 7,
              child: handleNullWidget(
                announcement.isEmpty,
                Container(
                  // decoration: BoxDecoration(color: CustomColor.theme_bar_gradient_1, borderRadius: BorderRadius.circular(10.0)),
                  margin: EdgeInsets.only(left: 10.auto, right: 10.auto),
                  height: 18.auto,
                  child: Marquee(
                      text: announcement,
                      style: TextStyle(
                        color: CustomColor.theme_marquee_text_color,
                        fontSize: 10.auto,
                      ),
                      scrollAxis: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      blankSpace: 300.auto,
                      pauseAfterRound: Duration(seconds: 1),
                      showFadingOnlyWhenScrolling: false),
                ),
              ))
        ],
      ),
    );
  }

  _getNoticeFlex() {
    if (GlobalValueUtil.languageCode.contains("zh") )
      return 1;
    else if (GlobalValueUtil.languageCode == "th-TH" || GlobalValueUtil.languageCode == "vi-VN")
      return 2;
    else
      return 4;
  }
}
