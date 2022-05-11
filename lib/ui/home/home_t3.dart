import 'package:api/entity/game_type.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marquee/marquee.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:api/entity/user_profile.dart';
import 'package:tgp_flutter2/custom/custom_login_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/main.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/home/game/game_t3/game_t3.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';
import 'package:tgp_flutter2/ui/home/home_view_model.dart';
import 'package:tgp_flutter2/ui/home/promotion_dialog.dart';

class HomeT3 extends StatefulWidget {
  final bool isFirstRun;
  final Function? onPauseBgMusic;
  final Function? onResumeBgMusic;
  final Function initData;
  final HomeViewModel homeViewModel;
  final GameViewModel gameViewModel;
  final int? randomNumber;

  HomeT3({
    this.isFirstRun = false,
    this.onPauseBgMusic,
    this.onResumeBgMusic,
    required this.initData,
    required this.homeViewModel,
    required this.gameViewModel,
    this.randomNumber
  });

  @override
  _HomeT3State createState() => _HomeT3State();
}

class _HomeT3State extends BaseState<HomeT3> {
  var currentTabIndex = "0";
  UserProfile? user;
  var currentBottomIndex = 0;
  var isMenu = false;
  var itemHeightRatio = 335 / 90;
  int _current = 0;
  String? imageLanguageCode = "en-US", languageCode;

  @override
  void initState() {
    getLanguage();
    super.initState();
  }

  getLanguage() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    languageCode = _prefs.getString("LANGUAGE_CODE") ?? EnvironmentConfig.default_lang;
    imageLanguageCode = ((languageCode?.contains("th") ?? false)) ? languageCode : "en-US";
  }

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10.auto, left: 10.auto, right: 10.auto),
      child: Column(
        children: [
          _buildTextMarquee(),
          _buildImageSlider(),
          Expanded(
              child: widget.gameViewModel.gameRowListT3 == null || widget.gameViewModel.gameListT3 == null
                  ? buildProgressDialog(widget.homeViewModel.brandLogoUrl)
                  : ListView(
                      children: [_buildImageRow(), _buildGameImageGridView()],
                    ))
        ],
      ),
    );
  }

  _buildTextMarquee() {
    var announcement = _removeMultiLine(parseHtmlString(widget.homeViewModel.announcement ?? ""));
    return Container(
      padding: EdgeInsets.only(bottom: 5.auto),
      child: Row(
        children: [
          Expanded(
            flex: (languageCode?.contains("zh") ?? false) ? 2 : 3,
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
              color: CustomColor.theme_button_color,
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
                  fontSize: 12.auto,
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
            child: announcement.isEmpty
                ? Container()
                : Container(
                    // decoration: BoxDecoration(color: CustomColor.theme_bar_gradient_1, borderRadius: BorderRadius.circular(10.0)),
                    margin: EdgeInsets.only(left: 3.auto, right: 10.auto),
                    height: 18.auto,
                    child: Marquee(
                      text: announcement,
                      style: TextStyle(
                        color: CustomColor.theme_text_black_white_color,
                        fontSize: 10.auto,
                      ),
                      scrollAxis: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      blankSpace: 300.auto,
                      pauseAfterRound: Duration(seconds: 1),
                      showFadingOnlyWhenScrolling: false,
                    ),
                  ),
          )
        ],
      ),
    );
  }

  _getNoticeFlex() {
    if ((languageCode?.contains("zh") ?? false))
      return 1;
    else if (languageCode == "th-TH" || languageCode == "vi-VN")
      return 2;
    else
      return 4;
  }

  _removeMultiLine(String text) {
    return text.replaceAll("\n", " ");
  }

  _buildImageSlider() {
    String brand = EnvironmentConfig.appTitleName == "PG Gaming" ? "PGG" : EnvironmentConfig.appTitleName;
    return Container(
        height: context.screenHeight / 5,
        child: widget.homeViewModel.bannerList == null || widget.homeViewModel.bannerList!.isEmpty
            ? _buildEmptyContainer()
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    CarouselSlider(
                      items: List.generate(
                          widget.homeViewModel.bannerList!.length,
                          (index) => ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: widget.homeViewModel.bannerList![index].mobileUrl == null
                                    ? _buildEmptyContainer()
                                    : CachedNetworkImage(
                                        height: 400,
                                        width: context.screenWidth,
                                        placeholder: (context, url) => _buildEmptyContainer(),
                                        imageUrl: widget.homeViewModel.bannerList![index].mobileUrl!,
                                        //handling error
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) => _buildEmptyContainer(),
                                      ),
                              )),
                      options: CarouselOptions(
                        height: 400,
                        aspectRatio: context.screenWidth / 400,
                        viewportFraction: 1,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 3),
                        autoPlayAnimationDuration: Duration(milliseconds: 500),
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal,
                        onPageChanged: (index, _) {
                          setState(() {
                            _current = index;
                          });
                        },
                      ),
                    ),
                    Container(
                      height: 400,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(widget.homeViewModel.bannerList!.length, (index) {
                          return Container(
                            width: 8.auto,
                            height: 8.auto,
                            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: _current == index ? Colors.redAccent : Colors.grey),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ));
  }

  _buildEmptyContainer() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: CustomColor.very_light_pink_four,
        ),
      );

  _buildImageRow() {
    getLanguage();
    return Container(
      height: 180.auto,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(widget.gameViewModel.gameRowListT3!.length, (index) {
            return InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GameT3(
                              gamePlatformCode: "",
                              gameType: widget.gameViewModel.gameRowListT3![index],
                              index: index,
                              config: widget.homeViewModel.config,
                              onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                              onResumeBgMusic: () =>
                                  (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                            ))),
                child: Container(
                  width: context.screenWidth / 2 - 15.auto,
                  child: (widget.homeViewModel.config?.homePageAnimated ?? false)
                      ? Image.asset(
                          _getFullGameTabImagePath(widget.gameViewModel.gameRowListT3![index].getImagePath()),
                        )
                      : Stack(
                          children: [
                            Image.asset("images/home/${widget.gameViewModel.gameRowListT3![index].getImagePath()}.png"),
                            Positioned(
                              bottom: 7.auto,
                              right: 10.auto,
                              child: Container(
                                width: 80.auto,
                                height: 90.auto,
                                alignment: Alignment.bottomCenter,
                                child: AutoSizeText(
                                  // gameType.getName(context, _vm.config?.menuItemShootFish ?? false),
                                  widget.gameViewModel.gameRowListT3![index]
                                      .getName(context, widget.homeViewModel.config?.menuItemShootFish ?? false),
                                  maxFontSize: 23,
                                  minFontSize: 10,
                                  stepGranularity: 1,
                                  style: TextStyle(color: CustomColor.theme_text_black_white_color, fontSize: 23),
                                ),
                              ),
                            ),
                          ],
                        ),
                ));
          })),
    );
  }

  _buildGameImageGridView() {
    return Container(
      height: 260.auto,
      margin: EdgeInsets.only(top: 8.auto, bottom: 10.auto),
      child: StaggeredGridView.countBuilder(
        crossAxisCount: 2,
        itemCount: widget.gameViewModel.gameListT3!.length,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) => InkWell(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GameT3(
                        gamePlatformCode: "",
                        gameType: widget.gameViewModel.gameListT3![index],
                        index: index,
                        config: widget.homeViewModel.config,
                        onPauseBgMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                        onResumeBgMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                      ))),
          child: (widget.homeViewModel.config?.homePageAnimated ?? false)
              ? Image.asset(
                  _getFullGameTabImagePath(widget.gameViewModel.gameListT3![index].getImagePath()),
                )
              : Stack(
                  children: [
                    Image.asset(
                      _getFullGameTabImagePath(widget.gameViewModel.gameListT3![index].getImagePath()),
                    ),
                    Positioned(
                        bottom: 20.auto,
                        left: 60.auto,
                        child: Container(
                          width: 70.auto,
                          height: 40.auto,
                          alignment: Alignment.bottomLeft,
                          child: AutoSizeText(
                            widget.gameViewModel.gameListT3![index]
                                .getName(context, widget.homeViewModel.config?.menuItemShootFish ?? false),
                            maxFontSize: 23,
                            minFontSize: 10,
                            stepGranularity: 1,
                            style: TextStyle(color: CustomColor.theme_text_black_white_color, fontSize: 23.auto),
                          ),
                        )),
                  ],
                ),
        ),
        staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
        mainAxisSpacing: 15.auto,
        crossAxisSpacing: 15.auto,
      ),
    );
  }

  _getFullGameTabImagePath(String path) {
    if (widget.homeViewModel.config?.homePageAnimated ?? false)
      return "images/game_tab/t3/$imageLanguageCode/$path.gif";
    else
      return "images/game_tab/t3/$path.png";
  }

  navigateToLogin() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(RoutePath.login);
    });
  }
}
