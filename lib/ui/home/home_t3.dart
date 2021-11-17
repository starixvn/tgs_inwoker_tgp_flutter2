import 'package:api/entity/game_type.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:api/entity/user_profile.dart';
import 'package:tgp_flutter2/custom/custom_login_app_bar.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/main.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/home/game/game_t3/game_t3.dart';
import 'package:tgp_flutter2/ui/home/home_view_model.dart';

class HomeT3 extends StatefulWidget {
  final bool isFirstRun;

  HomeT3({this.isFirstRun});

  @override
  _HomeT3State createState() => _HomeT3State();
}

class _HomeT3State extends BaseState<HomeT3> {
  List<String> imgList = [
    '1',
    '2',
    //'images/banner_2.jpg'
  ];

  //var gameList = ["sport", "live", "slot", "fishing", "lotto", "e-game", "card"];
  var gameRowList = [
    GameType.ESports,
    GameType.LiveDealerLobby,
  ];
  var gameList = [
    GameType.Slot,
    GameType.Fishing,
    GameType.LotteryLobby,
    GameType.EGame,
    GameType.CardGameLobby,
  ];
  ScrollController controller = ScrollController();
  var currentTabIndex = "0";
  UserProfile user;
  var currentBottomIndex = 0;
  var isMenu = false;

  var itemHeightRatio = 335 / 90;
  var _vm = HomeViewModel();
  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  void initState() {
    _vm.getAnnouncement();
    _vm.getBanner();
    _vm.resumeIfNeed();
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<HomeViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: CustomColor.theme_bg_color,
            appBar: CustomLoginAppBar(
              onClickLoginButton: () => Navigator.of(context).pushNamed(RoutePath.login),
              isLogin: _vm.userProfile != null,
              brandLogoUrl: _vm.brandLogoUrl,
            ),
            body: /* Stack(
              children: [*/
                Container(
              margin: EdgeInsets.all(10.auto),
              child: Column(
                children: [
                  _buildImageSlider(),
                  Expanded(
                      flex: 3,
                      child: Column(
                        children: [_buildImageRow(), _buildGameImageGridView()],
                      ))
                ],
              ),
            ),
            /*_buildOverlay(),
                _buildMenu(),
              ],
            ),*/
          );
        });
  }

  _buildImageSlider() {
    String brand = EnvironmentConfig.appTitleName == "PG Gaming" ? "PGG" : EnvironmentConfig.appTitleName;
    return Expanded(
        flex: 1,
        child: _vm.bannerList == null || _vm.bannerList.isEmpty
            ? _buildEmptyContainer()
            :
            /*Swiper(
                itemBuilder: (BuildContext context, int index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      placeholder: (context, url) => _buildEmptyContainer(),
                      imageUrl: _vm.bannerList[index].mobileUrl ?? "",
                      //handling error
                      fit: BoxFit.fill,
                      errorWidget: (context, url, error) => _buildEmptyContainer(),
                    ),
                  );
                },
                autoplay: true,
                itemCount: 2,
                pagination: SwiperPagination(
                  alignment: Alignment.bottomCenter,
                  margin: EdgeInsets.all(context.screenHeight / 150),
                  builder: DotSwiperPaginationBuilder(
                    color: Colors.grey,
                    activeColor: Colors.red,
                    size: 5.auto,
                    activeSize: 5.auto,
                  ),
                ))*/
            ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    CarouselSlider(
                      items: List.generate(
                          _vm.bannerList.length,
                          (index) => ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  height: 400,
                                  width: context.screenWidth,
                                  placeholder: (context, url) => _buildEmptyContainer(),
                                  imageUrl: _vm.bannerList[index].mobileUrl ?? "",
                                  //handling error
                                  fit: BoxFit.fill,
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
                        children: List.generate(_vm.bannerList.length, (index) {
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

  _buildImageRow() => Expanded(
        flex: 2,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(gameRowList.length, (index) {
              return InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              GameT3(gamePlatformCode: "", gameType: gameRowList[index], index: index))),
                  child: Container(
                    width: context.screenWidth / 2 - 15.auto,
                    child: Stack(
                      children: [
                        Image.asset("images/home/${gameRowList[index].getImagePath()}.png"),
                        Positioned(
                          bottom: 7.auto,
                          right: 18.auto,
                          child: Text(
                            gameRowList[index].getName(context),
                            style: TextStyle(color: CustomColor.theme_text_black_white_color, fontSize: 23.auto),
                          ),
                        ),
                      ],
                    ),
                  ));
            })),
      );

  _buildGameImageGridView() => Expanded(
        flex: 3,
        child: StaggeredGridView.countBuilder(
          crossAxisCount: 2,
          itemCount: gameList.length,
          itemBuilder: (BuildContext context, int index) => InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GameT3(gamePlatformCode: "", gameType: gameList[index], index: index))),
              child: Stack(
                children: [
                  Image.asset("images/home/${gameList[index].getImagePath()}.png"),
                  Positioned(
                    bottom: 20.auto,
                    left: 55.auto,
                    child: Text(
                      gameList[index].getName(context),
                      style: TextStyle(color: CustomColor.theme_text_black_white_color, fontSize: 23.auto),
                    ),
                  ),
                ],
              )),
          staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
          mainAxisSpacing: 15.auto,
          crossAxisSpacing: 15.auto,
        ),
      );

  navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(RoutePath.login);
    });
  }

  _displayDialog() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var loginLater = prefs.getBool("login_later") ?? false;
    if (_vm.userProfile == null && !loginLater) {
      showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          title: getTranslatedText("login_expired"),
          description: getTranslatedText("login_again"),
          buttonText1: getTranslatedText("login"),
          buttonText2: getTranslatedText("no"),
          onClick: this.navigateToLogin,
          onClick2: () {
            prefs.setBool("login_later", true);
            Navigator.pop(context);
          },
        ),
      );
    }
  }

  _handleApiState() {
    if (widget.isFirstRun != null && widget.isFirstRun) {
      if (_vm.isNotLogin) {
        navigateToLogin();
        _vm.markIsNotLogin();
      } else if (_vm.isExpired) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayDialog();
        });
      }
    }
    handleApiState(_vm.getBasicInfoApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getAnnouncementApiState, isAutoHideLoading: false, onSuccess: () {});
    handleApiState(_vm.getBannerApiState, isAutoHideLoading: false, onSuccess: () {});
  }
}
