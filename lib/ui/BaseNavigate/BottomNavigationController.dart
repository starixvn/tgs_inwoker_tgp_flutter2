import 'dart:async';
import 'dart:math';

import 'package:api/NotificationServices/NotificationServiceName.dart';
import 'package:api/NotificationServices/notification_center.dart';
import 'package:api/entity/response/ws_response.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:api/websocket/web_socket_deposit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/main_view_model.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/ui/customer_service/customer_service.dart';
import 'package:tgp_flutter2/ui/profile/profile.dart';
import 'package:tgp_flutter2/ui/promotion/promotion.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../custom/custom_app_bar.dart';
import '../../custom/custom_dialog.dart';
import '../../custom/custom_login_app_bar.dart';
import '../../custom/custom_progress_dialog.dart';
import '../../environment_config.dart';
import '../../globalUtil/GlobalValueUtil.dart';
import '../../route_path.dart';
import '../deposit/deposit.dart';
import '../dialog/deposit_order_dialog.dart';
import '../dialog/vip_rebate_dialog.dart';
import '../home/end_drawer_menu.dart';
import '../home/game/game_view_model.dart';
import '../home/home.dart';
import '../home/home_view_model.dart';
import '../menu/menu.dart';

class BottomNavigationController extends StatefulWidget {
  final dynamic versionUpdate;
  final bool isFirstRun;

  const BottomNavigationController({
    this.versionUpdate,
    this.isFirstRun = false,
  });

  @override
  _BottomNavigationControllerState createState() => _BottomNavigationControllerState();
}

class _BottomNavigationControllerState extends BaseState<BottomNavigationController> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  // GlobalKey<SliderDrawerState> _sliderDrawerKey = GlobalKey<SliderDrawerState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isShowMenuOverlay = false, isShowMenu = false;
  bool isShowTopNavigate = false; // true: will show app bar with back button, false: show login app bar
  var _popupMenuItemIndex = 0;
  Color _changeColorAccordingToMenuItem = Colors.red;
  GameViewModel gameViewModel = new GameViewModel();
  late Home homeView;
  int _currentIndex = 0;
  bool updateCustomView = false;
  Widget customView = Container();
  String _appBarTitle = "";
  HomeViewModel homeViewModel = HomeViewModel();
  MainViewModel mainViewModel = MainViewModel();
  var randomGeneratedPlayerCount;
  late Timer _generateTimer;
  var isShowMarquee = false; //to check either hide show marquee in login app bar
  var isMenu = false;
  bool hideAppBar = false, hideBottomNavigationBar = false;
  bool isShowBalanceInAppBar = false;

  // int? preBottomIndex;
  List<int> preBottomNavigationRoute = [];

  // void _onItemTapped(int index) {
  //   if (index != 0) {
  //     updateCustomView = false;
  //   }
  //   setState(() {
  //     if ((index == 2 || index == 3) && EnvironmentConfig.template_version == 14) {
  //       isShowTopNavigate = true;
  //       preBottomNavigationRoute.add(_selectedIndex);
  //     } else {
  //       preBottomNavigationRoute.clear();
  //       isShowTopNavigate = false;
  //     }
  //     _appBarTitle = _getAppBarTitle();
  //     _selectedIndex = index;
  //   });
  // }

  @override
  void initState() {
    print(widget.isFirstRun);

    if (widget.versionUpdate != null) {
      Future.delayed(Duration.zero, () => _showNewVersionUpdateDialog(widget.versionUpdate));
    }

    _generateNewNumberEveryFewSec();

    NotificationCenter().subscribe(NotificationServiceName().bottomNavigationIndex, (int? value) {
      if (value != null) {
        _updateBottomIndex(value);
      }
    });

    NotificationCenter().subscribe(NotificationServiceName().showTopNavigate, (bool? value) {
      if (value != null) {
        setState(() {
          isShowTopNavigate = value;
        });
      }
    });

    NotificationCenter().subscribe(NotificationServiceName().showMarqueeInAppBar, (bool? value) {
      if (value != null) {
        setState(() {
          isShowMarquee = value;
        });
      }
    });
    NotificationCenter().subscribe(NotificationServiceName().showDialogViewToHome, (Map<String, dynamic> map) {
      if (homeViewModel.userProfile == null) {
        showPreLoginDialog();
        return;
      } else if (map["title"].isEmpty) {
        setState(() {
          updateCustomView = true;
          customView = map["view"];
        });
      } else {
        setState(() {
          isShowTopNavigate = true;
          updateCustomView = true;
          _appBarTitle = map["title"];
          customView = map["view"];
          isShowBalanceInAppBar = map["isShowBalance"];
          preBottomNavigationRoute.add(_selectedIndex);
        });
      }
      // }
    });
    NotificationCenter().subscribe(NotificationServiceName().closeDialogViewAtHome, closeCustomView);
    // NotificationCenter().subscribe(NotificationServiceName().logout, logout);
    super.initState();
  }

  _updateBottomIndex(int value) {
    setState(() {
      hideAppBar = value == 4 && EnvironmentConfig.template_version != 14 && homeViewModel.userProfile != null;
      hideBottomNavigationBar = false;
      isMenu = false;
      isShowTopNavigate = false;
      bool isNeedLogin = false;
      updateCustomView = false;
      isShowBalanceInAppBar = false;
      switch (_getBottomNavigationIconList()[value]) {
        case BottomNavigationIcon.home:
          {
            NotificationCenter().notify(NotificationServiceName().gameNeededLoadData, data: true);
            break;
          }
        case BottomNavigationIcon.profile:
          {
            if (homeViewModel.userProfile == null) {
              isNeedLogin = true;
              showPreLoginDialog();
            }
            break;
          }
        case BottomNavigationIcon.promotion:
          {
            if (EnvironmentConfig.template_version != 14) {
              isShowTopNavigate = true;
              hideBottomNavigationBar = true;
              preBottomNavigationRoute.add(_selectedIndex);
              _appBarTitle = getTranslatedText("promotion");
            }
            break;
          }
        case BottomNavigationIcon.deposit:
          {
            if (homeViewModel.userProfile == null) {
              isNeedLogin = true;
              showPreLoginDialog();
            } else if (EnvironmentConfig.template_version != 14) {
              isShowBalanceInAppBar = true;
              //show app bar with back button and title
              isShowTopNavigate = true;
              hideBottomNavigationBar = true;
              preBottomNavigationRoute.add(_selectedIndex);
              // Navigator.of(context).pushNamed(RoutePath.deposit);
            } else {
              isShowBalanceInAppBar = true;
              //show app bar with back button and title
              isShowTopNavigate = true;
              //for tracing back previous route when user click back button
              preBottomNavigationRoute.add(_selectedIndex);
            }
            NotificationCenter().notify(NotificationServiceName().depositNeededLoadData, data: true);
            _appBarTitle = getTranslatedText("deposit");
            break;
          }
        case BottomNavigationIcon.cs:
          {
            if (EnvironmentConfig.template_version != 14) {
              hideAppBar = true;
              preBottomNavigationRoute.add(_selectedIndex);
              // Navigator.of(context).pushNamed(RoutePath.customerService);
            } else {
              //show app bar with back button and title
              isShowTopNavigate = true;
              //for tracing back previous route when user click back button
              preBottomNavigationRoute.add(_selectedIndex);
            }
            _appBarTitle = getTranslatedText("customer_service") == "customer_service"
                ? "Customer Service"
                : (EnvironmentConfig.template_version == 14 ? getTranslatedText("contact_us") : getTranslatedText("customer_service"));
            break;
          }
        case BottomNavigationIcon.wallet:
          {
            if (homeViewModel.userProfile == null) {
              isNeedLogin = true;
              showPreLoginDialog();
              break;
            } else {
              // show wallet menu
              isMenu = true;
              NotificationCenter().notify(NotificationServiceName().isShowingMenu, data: true);
            }
            break;
          }
        default:
          {}
      }
      if (!isMenu && !isNeedLogin) _selectedIndex = value;
      if (!isShowTopNavigate) preBottomNavigationRoute.clear();
    });

    // if (_getRouteList()[value].isNotEmpty) {
    //   Navigator.of(context).pushNamed(_getRouteList()[value]);
    // } else {
    //   setState(() {
    //   setState(() {
    //     if (value == 2 && EnvironmentConfig.template_version != 14) {
    //       // show wallet menu
    //       isMenu = true;
    //       NotificationCenter().notify(NotificationServiceName().isShowingMenu, data: true);
    //     } else {
    //       // for handling t14, load content with app bar and bottom navigation bar
    //       isMenu = false;
    //       if ((value == 2 || value == 3)) {
    //         //show app bar with back button and title
    //         isShowTopNavigate = true;
    //         //for tracing back previous route when user click back button
    //         preBottomNavigationRoute.add(_selectedIndex);
    //       } else {
    //         //ignore tracing purpose
    //         preBottomNavigationRoute.clear();
    //         //show login app bar
    //         isShowTopNavigate = false;
    //       }
    //       NotificationCenter().notify(NotificationServiceName().isShowingMenu, data: false);
    //       hideAppBar = value == 4 && EnvironmentConfig.template_version != 14;
    //       _selectedIndex = value;
    //       _appBarTitle = _getAppBarTitle();
    //     }
    //   });
    // }
  }

  closeCustomView() {
    setState(() {
      updateCustomView = false;
    });
  }

  @override
  void deactivate() {
    GlobalValueUtil.stopsong();
    super.deactivate();
  }

  @override
  void dispose() {
    GlobalValueUtil.stopsong();
    _generateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      endDrawer: !isShowTopNavigate && (EnvironmentConfig.template_version == 14)
          ? Drawer(
              width: context.screenWidth * 0.65,
              backgroundColor: Color(0xff181c42),
              child: EndDrawerMenu(
                username: mainViewModel.userProfile?.username ?? "",
                width: context.screenWidth * 0.65,
                scaffoldKey: scaffoldKey,
                logout: () => _logout(),
              ),
            )
          : Container(),
      appBar: hideAppBar
          ? null
          : (isShowTopNavigate
              ? CustomAppBar(
                  title: _appBarTitle,
                  walletBalance: GlobalValueUtil.totalBalance,
                  isPassTrueWhenPop: true,
                  onPop: () {
                    if (updateCustomView) {
                      updateCustomView = false;
                    }
                    if (preBottomNavigationRoute.isNotEmpty) {
                      _updateBottomIndex(preBottomNavigationRoute.last);
                      preBottomNavigationRoute.removeLast();
                    }
                  },
                  isShowBalance: isShowBalanceInAppBar,
                )
              : CustomLoginAppBar(
                  onClickLoginButton: () => Navigator.of(context).pushNamed(RoutePath.login),
                  onClickRegisterButton: () => Navigator.of(context).pushNamed(RoutePath.register),
                  onClickLogoutButton: () => _logout(),
                  isLogin: homeViewModel.userProfile != null,
                  userProfile: homeViewModel.userProfile,
                  onClickBalance: () {
                    // setState(() {
                    //   isShowTransferUI = !isShowTransferUI;
                    // });
                  },
                  // onPauseMusic: () => (widget.onPauseBgMusic != null) ? widget.onPauseBgMusic!() : null,
                  // onResumeMusic: () => (widget.onResumeBgMusic != null) ? widget.onResumeBgMusic!() : null,
                  randomNumber: randomGeneratedPlayerCount ?? 0,
                  isShowMarquee: isShowMarquee,
                  marquee: homeViewModel.announcement,
                  scaffoldKey: scaffoldKey,
                  barrierWidget: _buildOverlay(),
                  isShowBarrier: isMenu,
                )),
      body: Container(
        height: context.screenHeight,
        width: context.screenWidth,
        color: CustomColor.theme_bg_color,
        child: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: _getCurrentTabView(),
            ),
            Visibility(
              visible: isMenu,
              child: _buildOverlay(),
            ),
            _buildMenu()
          ],
        ),
      ),
      bottomNavigationBar: hideBottomNavigationBar
          ? null
          : BottomAppBar(
              color: CustomColor.theme_bottom_app_bar_color,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildBottomNavigationBarItem(0),
                  _buildBottomNavigationBarItem(1),
                  _buildBottomNavigationBarItem(2),
                  _buildBottomNavigationBarItem(3),
                  _buildBottomNavigationBarItem(4),
                ],
              ),
            ),
    );
  }

  _closeMenu() {
    setState(() {
      isMenu = false;
    });
  }

  _buildMenu() => Visibility(
        visible: isMenu,
        child: Menu(),
      );

  _buildOverlay() => ModalBarrier(
        dismissible: true,
        color: Colors.black54.withOpacity(0.5),
        onDismiss: _closeMenu,
      );

  _generateNewNumberEveryFewSec() {
    Random _random = new Random();
    var checkIfHomeOnlineUsersIsNull = mainViewModel.config?.homeOnlineUsers != null;
    int min = checkIfHomeOnlineUsersIsNull ? mainViewModel.config.homeOnlineUsers["min"] : 20000;

    int max = checkIfHomeOnlineUsersIsNull ? mainViewModel.config.homeOnlineUsers["max"] : 30000;

    _generateTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      try {
        if (mounted) {
          // Check whether the widget is still mounted before calling setState
          setState(() {
            randomGeneratedPlayerCount = min + _random.nextInt(max - min);
          });
        }
      } catch (e) {
        print('Error: $e');
      }
    });
  }

  List<Widget> _getCurrentTabView() {
    List<Widget> viewList = [];
    for (BottomNavigationIcon icon in _getBottomNavigationIconList()) {
      viewList.add((updateCustomView)
          ? customView
          : (() {
              switch (icon) {
                case BottomNavigationIcon.home:
                  return Home(isFirstRun: widget.isFirstRun);
                case BottomNavigationIcon.promotion:
                  return Promotion();
                case BottomNavigationIcon.cs:
                  return CustomerService();
                case BottomNavigationIcon.profile:
                  return Profile();
                case BottomNavigationIcon.deposit:
                  return Deposit();
                default:
                  return Container();
              }
            }()));
    }
    return viewList;
    // var views = [
    //   _selectedIndex == 0 ? ((updateCustomView) ? customView : Home(isFirstRun: widget.isFirstRun)) : Home(isFirstRun: widget.isFirstRun),
    //   _selectedIndex == 1 ? ((updateCustomView) ? customView : _getView(Promotion())) : _getView(Promotion()),
    //   _selectedIndex == 2 ? ((updateCustomView) ? customView : _getView(Deposit())) : _getView(Deposit()),
    //   _selectedIndex == 3 ? ((updateCustomView) ? customView : _getView(CustomerService())) : _getView(CustomerService()),
    //   _selectedIndex == 4 ? ((updateCustomView) ? customView : Profile()) : Profile(),
    // ];
    // return
    //   views;
  }

  _buildBottomNavigationBarItem(int index) {
    String imagePath = _getTabBarList()[index];
    bool isMenu = imagePath.contains("ic_menu");
    return Expanded(
      child: SizedBox(
        height: context.screenWidth / 7,
        width: context.screenWidth / 5,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () {
              _updateBottomIndex(index);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildImageIcon(imagePath, index),
                Container(
                  margin: EdgeInsets.only(top: 3.auto),
                  child: Text(
                    getTranslatedText(_getTabBarItemText(index)),
                    style: TextStyle(
                      fontSize: 9.auto,
                      color: (_selectedIndex == index && (!isMenu || EnvironmentConfig.template_version == 10))
                          ? CustomColor.bottom_nav_selected_color
                          : CustomColor.bottom_nav_unselected_color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildImageIcon(String imagePath, int index) {
    print(imagePath);
/*    if (imagePath.contains("ic_menu")) {
      return Container(
        height: 35.auto,
        padding: EdgeInsets.symmetric(vertical: 5),
        child: CircleAvatar(
          backgroundColor: CustomColor.theme_title_text_color,
          child: ImageIcon(
            AssetImage(
              "images/bottom_nav_bar/${(EnvironmentConfig.template_version == 15 && _selectedIndex != index) ? imagePath.replaceAll("-selected", "") : imagePath}.png",
            ),
            size: 20.auto,
            color: _selectedIndex == index ? CustomColor.bottom_nav_selected_color : CustomColor.bottom_nav_unselected_color,
          ),
        ),
      );
    } else*/
    if (imagePath.contains(".svg")) {
      return EnvironmentConfig.template_version == 14 && !imagePath.contains("ic_cs")
          // preventing override color for t14 icon
          ? SvgPicture.asset(
              imagePath,
              width: 25.auto,
              height: 25.auto,
            )
          : SvgPicture.asset(
              imagePath,
              width: 25.auto,
              height: 25.auto,
              color: (_selectedIndex == index && !isMenu) ? CustomColor.bottom_nav_selected_color : CustomColor.bottom_nav_unselected_color,
            );
    } else {
      return Image.asset(
        (EnvironmentConfig.template_version == 15 && _selectedIndex != index) ? imagePath.replaceAll("-selected", "") : imagePath,
        width: 25.auto,
        height: 25.auto,
      );
    }
  }

  List<String> _getTabBarList() {
    switch (EnvironmentConfig.template_version) {
      case 14:
        return [
          "images/bottom_nav_bar/T14/ic_home.svg",
          "images/bottom_nav_bar/T14/ic_promotion.svg",
          "images/bottom_nav_bar/T14/ic_deposit.svg",
          "images/bottom_nav_bar/ic_cs.svg",
          "images/bottom_nav_bar/T14/ic_profile.svg",
        ];
      case 15:
        return [
          "images/bottom_nav_bar/T15/ic_home-selected.png",
          "images/bottom_nav_bar/T15/ic_promotion-selected.png",
          "images/bottom_nav_bar/ic_cs.svg",
          "images/bottom_nav_bar/T15/ic_deposit-selected.png",
          "images/bottom_nav_bar/T15/ic_profile-selected.png",
        ];
      default:
        return [
          "images/bottom_nav_bar/ic_home.svg",
          "images/bottom_nav_bar/ic_promotion.svg",
          "images/bottom_nav_bar/ic_deposit.svg",
          "images/bottom_nav_bar/ic_cs.svg",
          "images/bottom_nav_bar/ic_profile.svg",
        ];
    }
  }

  List<BottomNavigationIcon> _getBottomNavigationIconList() {
    switch (EnvironmentConfig.template_version) {
      case 14:
        return [
          BottomNavigationIcon.home,
          BottomNavigationIcon.promotion,
          BottomNavigationIcon.deposit,
          BottomNavigationIcon.cs,
          BottomNavigationIcon.profile,
        ];
      case 15:
        return [
          BottomNavigationIcon.home,
          BottomNavigationIcon.promotion,
          BottomNavigationIcon.cs,
          BottomNavigationIcon.deposit,
          BottomNavigationIcon.profile,
        ];
      default:
        return [
          BottomNavigationIcon.home,
          BottomNavigationIcon.promotion,
          BottomNavigationIcon.wallet,
          BottomNavigationIcon.cs,
          BottomNavigationIcon.profile,
        ];
    }
  }

  _getTabBarItemText(int index) {
    switch (_getBottomNavigationIconList()[index]) {
      case BottomNavigationIcon.home:
        return "home";
      case BottomNavigationIcon.promotion:
        return "promotion";
      case BottomNavigationIcon.wallet:
        return "wallet";
      case BottomNavigationIcon.cs:
        return "customer_service";
      case BottomNavigationIcon.profile:
        return "my_profile";
      case BottomNavigationIcon.deposit:
        return "deposit";
      case BottomNavigationIcon.withdraw:
        return "";
    }
  }

  _logout() {
    ProgressDialog.show(context, homeViewModel.brandLogoUrl);
    homeViewModel.logout().then((result) {
      setState(() {
        ProgressDialog.hide();
      });
    });
  }

  _showNewVersionUpdateDialog(dynamic data) {
    showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
            title: getTranslatedText("New update: ${data["version"]}"),
            description: data["content"],
            buttonText1: getTranslatedText("update"),
            onClick: () {
              Navigator.pop(
                context,
              );
              launch(data["link"]);
            }));
  }
}

class TooltipShape extends ShapeBorder {
  const TooltipShape();

  final BorderSide _side = BorderSide.none;
  final BorderRadiusGeometry _borderRadius = BorderRadius.zero;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(_side.width);

  @override
  Path getInnerPath(
    Rect rect, {
    TextDirection? textDirection,
  }) {
    final Path path = Path();

    path.addRRect(
      _borderRadius.resolve(textDirection).toRRect(rect).deflate(_side.width),
    );

    return path;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final Path path = Path();
    final RRect rrect = _borderRadius.resolve(textDirection).toRRect(rect);

    path.moveTo(0, 10);
    path.quadraticBezierTo(0, 0, 10, 0);
    path.lineTo(rrect.width - 30, 0);
    path.lineTo(rrect.width - 20, -10);
    path.lineTo(rrect.width - 10, 0);
    path.quadraticBezierTo(rrect.width, 0, rrect.width, 10);
    path.lineTo(rrect.width, rrect.height - 10);
    path.quadraticBezierTo(rrect.width, rrect.height, rrect.width - 10, rrect.height);
    path.lineTo(10, rrect.height);
    path.quadraticBezierTo(0, rrect.height, 0, rrect.height - 10);

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => RoundedRectangleBorder(
        side: _side.scale(t),
        borderRadius: _borderRadius * t,
      );
}
