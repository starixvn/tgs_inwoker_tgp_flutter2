import 'package:api/entity/game_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/custom/custom_dialog.dart';
import 'package:api/entity/language.dart';
import 'package:api/entity/user_profile.dart';
import 'package:api/localizations/language_provider.dart';
import 'package:tgp_flutter2/custom/custom_login_app_bar.dart';
import 'package:tgp_flutter2/main.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:marquee/marquee.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/customer_service/customer_service.dart';
import 'package:tgp_flutter2/ui/game/game.dart';
import 'package:tgp_flutter2/ui/home/home_view_model.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/ui/profile/profile.dart';
import 'package:tgp_flutter2/ui/promotion/promotion.dart';
import 'package:tgp_flutter2/ui/transaction/deposit_withdraw_transaction.dart';
import 'package:tgp_flutter2/ui/transaction/transaction.dart';

class Home extends StatefulWidget {
  final bool isFirstRun;

  Home({this.isFirstRun});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends BaseState<Home> {
  List<String> imgList = [
    'banner_1',
    'banner_2',
    //'images/banner_2.jpg'
  ];

  //var gameList = ["sport", "live", "slot", "fishing", "lotto", "e-game", "card"];
  var gameList = [
    GameType.ESports,
    GameType.LiveDealerLobby,
    GameType.Slot,
    GameType.Fishing,
    GameType.LotteryLobby,
    GameType.EGame,
    GameType.CardGameLobby,
  ];
  String marquee = "《GD真人维护公告》GD真人将于 7 月 2 8 日 09:00 至 14:00 进行维护 维护期间不提供游戏相关服务。若有问题欢迎与在线客服联系 如有问题欢迎与在线客服联系，谢谢";
  ScrollController controller = ScrollController();
  var currentTabIndex = "0";
  UserProfile user;
  var currentBottomIndex = 0;

  var itemHeightRatio = 335 / 90;
  var _vm = HomeViewModel();
  List _page = [
    MyHomePage(index:0),
    MyHomePage(index:1),
    MyHomePage(index:2),
    MyHomePage(index:3),
    MyHomePage(index:4),
  ];

  @override
  void initState() {
    _vm.getAnnouncement();
    _vm.getApiError();
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
            ),
            bottomNavigationBar: SizedBox(
                height: 43.auto,
                child: BottomAppBar(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBottomBarItem(0, "ic_promotion", "优惠"),
                      _buildBottomBarItem(1, "ic_transaction", "账务"),
                      _buildBottomBarItem(2, "ic_deposit", "存提"),
                      _buildBottomBarItem(3, "ic_cs", "客服"),
                      _buildBottomBarItem(4, "ic_profile", "我的"),
                    ],
                  ),
                )),
            body: Container(
              margin: EdgeInsets.all(10.auto),
              child: Column(
                children: [_buildImageSlider(), Expanded(flex: 4, child: _buildGameImageGridView())],
              ),
            ),
          );
        });
  }

  _buildBottomBarItem(int index, String imagePath, String title, {bool isNewMessage = false}) => Expanded(
        child: Stack(
          children: [
            SizedBox(
              height: 58.auto,
              width: context.screenWidth / 5,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MyHomePage(index: index)));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _buildImageIcon(imagePath, index, isNewMessage),
                      Container(
                        margin: EdgeInsets.only(top: 3.auto),
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 9.auto,
                            color: CustomColor.theme_bg_color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  _buildImageIcon(String imagePath, int index, bool isNewMessage) => SvgPicture.asset(
        "images/bottom_nav_bar/$imagePath.svg",
        matchTextDirection: true,
        height: 18.auto,
        color: CustomColor.theme_bg_color,
      );

  _buildImageSlider() => Expanded(
        flex: 1,
        child: Swiper(
          itemBuilder: (BuildContext context, int index) {
            return AspectRatio(
              aspectRatio: 360 / 200,
              child: Image.asset(
                "images/home_banner/${imgList[index]}.png",
                fit: BoxFit.fill,
              ),
            );
          },
          autoplay: true,
          itemCount: imgList.length,
          pagination: SwiperPagination(
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.all(context.screenHeight / 150),
            builder: DotSwiperPaginationBuilder(
              color: Colors.grey,
              activeColor: Colors.red,
              size: 5.auto,
              activeSize: 5.auto,
            ),
          ),
        ),
      );

  _buildGameImageGridView() => StaggeredGridView.countBuilder(
        crossAxisCount: 2,
        itemCount: gameList.length,
        itemBuilder: (BuildContext context, int index) => InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Game(gamePlatformCode: "", gameType: gameList[index], index: index))),
            child: Image.asset("images/home/${gameList[index].getImagePath()}.png")),
        staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
        mainAxisSpacing: 15.auto,
        crossAxisSpacing: 15.auto,
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
  }
}
