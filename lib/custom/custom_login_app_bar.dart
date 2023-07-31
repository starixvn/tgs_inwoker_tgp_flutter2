import 'package:api/NotificationServices/NotificationServiceName.dart';
import 'package:api/NotificationServices/notification_center.dart';
import 'package:api/entity/env_features_config.dart';
import 'package:api/entity/main_wallet.dart';
import 'package:api/entity/user_profile.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_util.dart';
import 'package:api/localizations/language_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter_svg/svg.dart';
import 'package:marquee/marquee.dart';
import 'package:tgp_flutter2/globalUtil/GlobalValueUtil.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';
import 'package:tgp_flutter2/custom/wallet_text_container.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';

class CustomLoginAppBar extends StatefulWidget implements PreferredSizeWidget {
  CustomLoginAppBar({
    required this.onClickLoginButton,
    required this.onClickRegisterButton,
    required this.onClickLogoutButton,
    required this.isLogin,
    this.userProfile,
    this.onClickBalance,
    // this.onPauseMusic,
    // this.onResumeMusic,
    required this.randomNumber,
    this.isShowMarquee = false,
    this.marquee = "",
    this.scaffoldKey,
    this.barrierWidget,
    required this.isShowBarrier,
  });

  final Function onClickLoginButton;
  final Function onClickRegisterButton;
  final Function onClickLogoutButton;
  final bool isLogin;
  final UserProfile? userProfile;
  final Function? onClickBalance;

  // final Function? onPauseMusic;
  // final Function? onResumeMusic;
  final int randomNumber;
  final bool? isShowMarquee;
  final String? marquee;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Widget? barrierWidget;
  final bool isShowBarrier;

  @override
  _CustomLoginAppBarState createState() => _CustomLoginAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight((EnvironmentConfig.template_version == 2) ? 60 : 90);
}

class _CustomLoginAppBarState extends BaseState<CustomLoginAppBar> {
  bool isShowMenu = false;

  @override
  void initState() {
    // NotificationCenter().subscribe(NotificationServiceName().isShowingMenu, (bool? value) {
    //   if (value != null) {
    //     setState(() {
    //       isShowMenu = value;
    //     });
    //   }
    // });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildAppBarWidget(),
        Visibility(visible: widget.isShowBarrier, child: widget.barrierWidget ?? Container()),
      ],
    );
  }

  _buildAppBarWidget() {
    if (EnvironmentConfig.template_version == 1) {
      return AppBar(
        actions: [Container()],
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: gradientDecoration,
          child: _getAppBarWidget(),
        ),
        centerTitle: false,
      );
    } else if (EnvironmentConfig.template_version == 8 && (EnvironmentConfig.dark_mode)) {
      return AppBar(
        actions: [Container()],
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.transparent.withOpacity(1.0), CustomColor.theme_bar_gradient_2],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [0, 0.5]),
          ),
          child: _getAppBarWidget(),
        ),
        centerTitle: false,
      );
    } else if (EnvironmentConfig.template_version == 9 && (EnvironmentConfig.dark_mode)) {
      return AppBar(
        actions: [Container()],
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(1.0), CustomColor.theme_bar_gradient_2, CustomColor.theme_bar_gradient_2],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: _getAppBarWidget(),
        ),
        centerTitle: false,
      );
    } else if (EnvironmentConfig.template_version == 2 && EnvironmentConfig.brandName == "PB3") {
      return AppBar(
        actions: [Container()],
        automaticallyImplyLeading: false,
        backgroundColor: CustomColor.theme_app_bar_color,
        centerTitle: true,
        flexibleSpace: Container(
          alignment: Alignment.center,
          child: SafeArea(
            child: CachedNetworkImage(
              placeholder: (context, url) => Container(
                height: 30.auto,
                width: 30.auto,
              ),
              imageUrl: GlobalValueUtil.brandLogo?.mobileUrl ?? "",
              //handling error
              height: _isDisplayUserDetailsRow() ? 38.auto : 50.auto,
              width: 100.auto,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              errorWidget: (context, url, error) => Container(),
            ),
          ),
        ),
      );
    } else if (EnvironmentConfig.template_version == 15 && EnvironmentConfig.brandName == "SKY8") {
      return AppBar(
        actions: [Container()],
        automaticallyImplyLeading: false,
        backgroundColor: CustomColor.theme_app_bar_color,
        centerTitle: false,
        toolbarHeight: 10,
        flexibleSpace: Container(
          child: _appBarWithMusicPlayer(),
        ),
      );
    } else {
      return AppBar(
        actions: [Container()],
        // for hiding default end drawer icon
        automaticallyImplyLeading: false,
        backgroundColor: CustomColor.theme_app_bar_color,
        centerTitle: false,
        elevation: EnvironmentConfig.template_version == 14 ? 0 : 4,
        flexibleSpace: Container(
          child: _getAppBarWidget(),
        ),
      );
    }
  }

  _appBarWithMusicPlayer() => SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _getAppBarTitle(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (EnvironmentConfig.template_version == 11) _getOnlineUsersText(),
                _getMusicPlayerWidget(),
              ],
            ),
          ],
        ),
      );

  _getMusicPlayerWidget() => Container(
        margin: EdgeInsets.only(right: 5.auto),
        width: 70.auto,
        child: Row(
          children: [_getMediaActionButton(true), _getMediaActionButton(false)],
        ),
      );

  _getAppBarWidget() => SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _getAppBarTitle(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: _getActionButton(),
                      ),
                      if (EnvironmentConfig.template_version == 11) _getOnlineUsersText(),
                    ],
                  ),
                ],
              ),
            ),
            if (EnvironmentConfig.template_version == 14 && (widget.isShowMarquee ?? false))
              Expanded(
                flex: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 0,
                        child: Text(
                          "NEWS: ",
                          style: TextStyle(
                            color: CustomColor.theme_text_black_white_color,
                            fontSize: 10.auto,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: Container(
                          // decoration: BoxDecoration(color: CustomColor.theme_bar_gradient_1, borderRadius: BorderRadius.circular(10.0)),
                          margin: EdgeInsets.only(left: 3.auto, right: 10.auto),
                          height: 18.auto,
                          child: Marquee(
                            text: widget.marquee ?? "",
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
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );

  _getAppBarTitle() => (GlobalValueUtil.brandLogo?.mobileUrl?.isEmpty ?? true)
      ? Container()
      : Container(
          height: EnvironmentConfig.template_version == 15 ? 50.0 : 100.0,
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: EnvironmentConfig.template_version == 15 ? 10 : 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                placeholder: (context, url) => Container(
                  height: 30.auto,
                  width: 30.auto,
                ),
                imageUrl: GlobalValueUtil.brandLogo?.mobileUrl ?? "",
                //handling error
                height: _isDisplayUserDetailsRow() ? 38.auto : 40.auto,
                width: 100.auto,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
                errorWidget: (context, url, error) => Container(),
              ),
              _getUserDetailsRow(),
            ],
          ),
        );

  List<Widget> _getActionButton() {
    List<Widget> list = [];
    if (GlobalValueUtil.featuresConfig?.homePageDisplayVIP ?? false) list.add(_getVipButton());

    list.addAll(widget.isLogin
        ? ((EnvironmentConfig.template_version == 14)
            ? [
                WalletTextContainer(
                    height: ScreenUtil.getInstance().appBarHeight / 2, width: (context.screenWidth * 0.3), balance: "${GlobalValueUtil.totalBalance != null ? Format().amountFormat(GlobalValueUtil.totalBalance ?? 0) : "-"}"),
              ]
            : [
                _getUsernameText(),
                _getLogoutButton(),
              ])
        : [
            _getLoginButton(),
            _getRegisterButton(),
          ]);
    if (EnvironmentConfig.template_version == 14) {
      list.add(Container(
        child: Builder(builder: (context) {
          return IconButton(
            icon: new Icon(Icons.menu, color: CustomColor.theme_button_color),
            onPressed: () {
              widget.scaffoldKey?.currentState?.openEndDrawer();
            },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          );
        }),
      ));
    }
    return list;
  }

  _getOnlineUsersText() => Padding(
        padding: EdgeInsets.only(right: 10),
        child: Text(
          "${getTranslatedText("online_user")} : ${widget.randomNumber}",
          textAlign: TextAlign.right,
          style: TextStyle(
            color: EnvironmentConfig.template_version == 15 ? CustomColor.theme_button_color : Colors.white,
            fontSize: 10.auto,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  _getLoginButton() => EnvironmentConfig.template_version == 10
      //t10 use color button, else use outline border button
      ? Container(
          padding: EdgeInsets.symmetric(horizontal: 5.auto, vertical: 10.auto),
          height: 50.auto,
          child: ColorButton(
            title: getTranslatedText("login"),
            onClick: () => widget.onClickLoginButton(),
            isEnabled: true,
            width: 60.auto,
            height: 17,
            fontSize: 14,
            radius: 5,
            padding: 4,
            textColor: Colors.black,
            color: CustomColor.theme_button_color,
          ),
        )
      : Container(
          padding: EdgeInsets.symmetric(horizontal: 5.auto, vertical: 10.auto),
          height: 50.auto,
          child: OutlineBorderButton(
            title: getTranslatedText("login"),
            onClick: () => widget.onClickLoginButton(),
            isEnabled: true,
            width: 60.auto,
            height: 17,
            color: ((() {
              if (_isDarkMode())
                return CustomColor.theme_text_black_color;
              else
                return Colors.white;
            })()),
            fontSize: 14,
            radius: EnvironmentConfig.template_version == 14 ? 10 : 5,
            padding: 4,
          ),
        );

  _getRegisterButton() => Container(
        padding: EdgeInsets.symmetric(horizontal: 5.auto, vertical: 10.auto),
        height: 50.auto,
        child: ColorButton(
          title: getTranslatedText("register"),
          onClick: () => widget.onClickRegisterButton(),
          isEnabled: true,
          width: 60.auto,
          height: 17,
          fontSize: 14,
          radius: EnvironmentConfig.template_version == 14 ? 10 : 5,
          padding: 4,
          textColor: _isDarkMode() || EnvironmentConfig.light_mode || EnvironmentConfig.template_version == 14 ? Colors.white : CustomColor.theme_app_bar_color,
          color: EnvironmentConfig.template_version == 3 ||
                  EnvironmentConfig.template_version == 4 ||
                  EnvironmentConfig.template_version == 10 ||
                  EnvironmentConfig.template_version == 14 ||
                  _isDarkMode() ||
                  EnvironmentConfig.light_mode
              ? CustomColor.theme_button_color
              : Colors.white,
        ),
      );

  _getVipButton() {
    if (EnvironmentConfig.template_version == 10 && EnvironmentConfig.dark_mode)
      return InkWell(
        onTap: () => Navigator.of(context).pushNamed("/vip"),
        child: Container(
          width: 60.auto,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: CustomColor.theme_button_color,
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.all(1),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: CustomColor.theme_bg_color,
            ),
            padding: EdgeInsets.only(top: 5.auto, bottom: 5.auto, left: 5.auto),
            child: Row(
              children: [
                Expanded(
                  flex: 0,
                  child: Image.asset(
                    "images/login_app_bar/vip.png",
                    matchTextDirection: true,
                    height: 15.auto,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    "VIP",
                    style: TextStyle(color: CustomColor.theme_button_color),
                    minFontSize: 14,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    stepGranularity: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    else if (EnvironmentConfig.template_version == 14)
      return InkWell(
        onTap: () => Navigator.of(context).pushNamed("/vip"),
        child: Container(
          margin: EdgeInsets.only(right: 10),
          child: Column(
            children: [
              Image.asset(
                "images/login_app_bar/vip.png",
                matchTextDirection: true,
                height: 15.auto,
              ),
              AutoSizeText(
                "VIP",
                style: TextStyle(color: CustomColor.theme_button_color, fontWeight: FontWeight.bold),
                minFontSize: 14,
                maxLines: 1,
                textAlign: TextAlign.center,
                stepGranularity: 1,
              ),
            ],
          ),
        ),
      );
    else if (!(EnvironmentConfig.template_version == 11 || EnvironmentConfig.brandName == "IDR1"))
      return Container(
        height: 50.auto,
        padding: EdgeInsets.all(10.auto),
        child: ColorButton(
          title: "VIP",
          onClick: () => Navigator.of(context).pushNamed("/vip"),
          isEnabled: true,
          width: 60.auto,
          height: 17,
          fontSize: 14,
          radius: 5,
          padding: 4,
          textColor: _isDarkMode() || EnvironmentConfig.light_mode ? Colors.white : CustomColor.theme_text_black_color,
          color: EnvironmentConfig.template_version == 3 || _isDarkMode() || EnvironmentConfig.light_mode ? CustomColor.theme_button_color : Colors.white,
          icon: Container(
            margin: EdgeInsets.only(right: 3.auto),
            child: Image.asset(
              "images/login_app_bar/vip.png",
              matchTextDirection: true,
              height: 18.auto,
            ),
          ),
        ),
      );
    else
      return InkWell(
        onTap: () => Navigator.of(context).pushNamed("/vip"),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          padding: EdgeInsets.all(1),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black,
            ),
            padding: EdgeInsets.all(5),
            child: Image.asset(
              "images/login_app_bar/vip.png",
              matchTextDirection: true,
              height: 15.auto,
            ),
          ),
        ),
      );
  }

  _getLogoutButton() => Container(
        height: 50.auto,
        padding: EdgeInsets.symmetric(vertical: 10.auto, horizontal: 10.auto),
        child: ColorButton(
          title: getTranslatedText("exit"),
          onClick: () => widget.onClickLogoutButton(),
          isEnabled: true,
          width: 60.auto,
          height: 17,
          radius: 5,
          padding: 2,
          textColor: _isDarkMode() || EnvironmentConfig.light_mode ? Colors.white : CustomColor.theme_app_bar_color,
          color: EnvironmentConfig.template_version == 3 || EnvironmentConfig.template_version == 10 || _isDarkMode() || EnvironmentConfig.light_mode
              ? CustomColor.theme_button_color
              : Colors.white,
        ),
      );

  _getUsernameText() => Container(
        padding: EdgeInsets.only(left: 8.auto),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              widget.userProfile?.username ?? "",
              style: TextStyle(
                color: CustomColor.theme_app_bar_text_color,
                fontWeight: FontWeight.bold,
                fontSize: ((GlobalValueUtil.featuresConfig?.homePageDisplayBalance ?? false) || (GlobalValueUtil.featuresConfig?.newTransferUI ?? false))
                    ? 10.auto
                    : 14.auto,
              ),
            ),
            if (GlobalValueUtil.featuresConfig?.homePageDisplayBalance ?? false) _getBalanceText(),
            if (GlobalValueUtil.featuresConfig?.newTransferUI ?? false)
              InkWell(
                onTap: () => widget.onClickBalance != null ? widget.onClickBalance!() : null,
                child: Container(
                  height: 20.auto,
                  //  color: CustomColor.black,
                  child: Row(
                    children: [
                      Text(
                        getTranslatedText("balance") + ": ",
                        style: TextStyle(
                          color: CustomColor.theme_app_bar_text_color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.auto,
                        ),
                      ),
                      _getBalanceText()
                    ],
                  ),
                ),
              )
          ],
        ),
      );

  _getBalanceText() => Text(
        GlobalValueUtil.totalBalance != null ? Format().amountFormat(GlobalValueUtil.totalBalance ?? 0) : "-",
        style: TextStyle(
          color: (GlobalValueUtil.featuresConfig?.newTransferUI ?? false) && EnvironmentConfig.template_version == 3
              ? CustomColor.theme_button_color
              : CustomColor.theme_app_bar_text_color,
          fontWeight: FontWeight.bold,
          fontSize: (GlobalValueUtil.featuresConfig?.newTransferUI ?? false) ? 16.auto : 14.auto,
        ),
        textAlign: TextAlign.left,
      );

  _getUserDetailsRow() => _isDisplayUserDetailsRow()
      ? Container(
          height: 12.auto,
          margin: EdgeInsets.only(top: 5.auto, right: 10.auto),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (_isDisplayPhone()) _getPhoneText(),
              if (GlobalValueUtil.featuresConfig?.customVIP ?? false) _getVipText(),
            ],
          ),
        )
      : Container();

  _getPhoneText() => Row(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 3.auto),
            child: Image.asset(
              "images/home/ic_phone.png",
              width: 10.auto,
              height: 10.auto,
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 5.auto),
            child: AutoSizeText(
              GlobalValueUtil.phone ?? "",
              style: TextStyle(color: CustomColor.theme_app_bar_text_color, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
              minFontSize: 10,
              stepGranularity: 1,
            ),
          ),
        ],
      );

  _getVipText() => Row(
        children: [
          Visibility(
            visible: widget.isLogin,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 3.auto),
              child: Image.asset(
                "images/home/ic_vip.png",
                width: 10.auto,
                height: 10.auto,
              ),
            ),
          ),
          Visibility(
            visible: widget.isLogin,
            child: AutoSizeText(
              _getVipPresentText(widget.userProfile?.vipLevel ?? 0),
              style: TextStyle(color: CustomColor.theme_app_bar_text_color, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
              minFontSize: 10,
              stepGranularity: 1,
            ),
          ),
        ],
      );

  _getVipPresentText(int level) {
    if (EnvironmentConfig.vipPresentType == 2) {
      switch (level) {
        case 1:
          return "VIP 1";
        case 2:
          return "Silver";
        case 3:
          return "Gold";
        case 4:
          return "Platinum";
        case 5:
          return "Diamond";
        default:
          return "";
      }
    } else {
      return "VIP $level";
    }
  }

  _getMediaActionButton(bool play) => InkWell(
        onTap: () async {
          if (play) {
            setState(() {
              GlobalValueUtil.playerStatus = AssetPlayerStatus.normal;
              // widget.onResumeMusic!();
              GlobalValueUtil.playsong();
            });
          } else {
            setState(() {
              GlobalValueUtil.playerStatus = AssetPlayerStatus.manualClickPause;
              GlobalValueUtil.pausesong();
            });
          }
        },
        splashColor: Colors.transparent,
        child: Container(
          width: 35.auto,
          height: 35.auto,
          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(10),
          //   color: CustomColor.theme_button_color,
          // ),
          alignment: Alignment.center,
          padding: EdgeInsets.all(1),
          child: Image.asset(
            "images/audio/${play ? "play" : "pause"}.png",
            matchTextDirection: true,
            height: 22.5.auto,
          ),
        ),
      );

  _isDarkMode() => ((EnvironmentConfig.template_version == 8 || EnvironmentConfig.template_version == 9) && !EnvironmentConfig.dark_mode);

  _isDisplayUserDetailsRow() => (_isDisplayPhone() || (GlobalValueUtil.featuresConfig?.customVIP ?? false));

  _isDisplayPhone() =>
      (GlobalValueUtil.featuresConfig?.displayPhone ?? false) &&
      GlobalValueUtil.phone != null &&
      (GlobalValueUtil.phone ?? "").isNotEmpty &&
      EnvironmentConfig.brandName != "SKY8";
}
