import 'package:api/entity/user_profile.dart';
import 'package:api/extension/format.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:api/extension/screen_apis.dart';

class HomeUserInfoView extends StatefulWidget {
  final UserProfile? userProfile;
  final double? wallet;
  final void Function()? onLoginTap;
  final Function? onRefreshHomePage;
  final int? randomNumber;
  final bool? forWGHK;

  HomeUserInfoView({
    this.userProfile,
    this.wallet,
    this.onLoginTap,
    this.onRefreshHomePage,
    this.randomNumber,
    this.forWGHK,
  });

  @override
  _HomeUserInfoViewState createState() => _HomeUserInfoViewState();
}

class _HomeUserInfoViewState extends BaseState<HomeUserInfoView> {
  @override
  Widget build(BuildContext context) {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: widget.forWGHK == true
            ? BorderRadius.circular(0)
            : BorderRadius.circular(5.0),
      ),
      elevation: 5,
      margin: widget.forWGHK == true
          ? EdgeInsets.only(top: 10.auto)
          : EdgeInsets.all(10.auto),
      child: Container(
        decoration: gradientDecoration,
        child: Column(
          children: [
            _buildTopRowContainer(),
            _buildBottomRowContainer(),
          ],
        ),
      ),
    );
  }

  _buildTopRowContainer() => Container(
        width: context.screenWidth,
        padding: EdgeInsets.only(
          top: 5.auto,
          left: 10.auto,
          right: 10.auto,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Wrap(
              //mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildWelcomeText(),
                Visibility(
                    visible: widget.userProfile != null,
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          widget.userProfile?.username ?? "",
                          style: TextStyle(
                              color:
                                  CustomColor.theme_label_text_highlight_color,
                              fontSize: 10.auto),
                          textAlign: TextAlign.center,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 3.auto),
                          child: Text(
                            "(VIP ${widget.userProfile?.vipLevel ?? 0}) ",
                            style: TextStyle(
                                color: Colors.white, fontSize: 10.auto),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )),
              ],
            ),
            Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTranslatedText("online_user") + " :",
                  style: TextStyle(
                    fontSize: 10.auto,
                    color: Colors.white,
                  ),
                ),
                Container(
                  child: Text(
                    (widget.randomNumber ?? 26500).toString(),
                    style: TextStyle(
                      fontSize: 10.auto,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  _buildBottomRowContainer() => Column(
        children: [
          Divider(
            color: Colors.white,
          ),
          Container(
            padding:
                EdgeInsets.only(bottom: 5.auto, left: 10.auto, right: 10.auto),
            color: CustomColor.theme_bar_gradient_1.withOpacity(0.4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.userProfile != null
                    ? _buildWalletText()
                    : _buildLoginRegisterButton(),
                Expanded(
                  flex: 4,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildHomeIcon("vip", "VIP", RoutePath.vip),
                      _buildHomeIcon("ic_deposit", getTranslatedText("deposit"),
                          RoutePath.deposit),
                      _buildHomeIcon(
                          "ic_transfer",
                          getTranslatedText("transfer"),
                          RoutePath.walletTransfer),
                      _buildHomeIcon("withdraw",
                          getTranslatedText("withdrawal"), RoutePath.withdraw)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  _buildWelcomeText() => AutoSizeText(
        (widget.userProfile != null
                ? getTranslatedText("welcome_back")
                : getTranslatedText("home_login_hint")) ??
            "",
        style: TextStyle(color: Colors.white, fontSize: 10.auto),
        minFontSize: 5,
        maxLines: 1,
        stepGranularity: 1,
      );

  _buildProfileInfoText() => AutoSizeText(
        getTranslatedText("profile_detail"),
        style: TextStyle(color: Colors.white, fontSize: 10.auto),
        textAlign: TextAlign.right,
        minFontSize: 8,
        maxLines: 1,
        stepGranularity: 1,
      );

  _buildWalletText() => Expanded(
      flex: 2,
      child: Container(
        alignment: Alignment.centerLeft,
        child: Column(
          children: [
            AutoSizeText(
              widget.wallet == null
                  ? "-"
                  : "${Format().currencyWithDecimalFormat(widget.wallet!)}",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              minFontSize: 10,
              stepGranularity: 1,
            ),
            Text(
              getTranslatedText("balance"),
              style: TextStyle(color: Colors.white, fontSize: 10.auto),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ));

  _buildLoginRegisterButton() {
    var string = getTranslatedText("login_or_signup").split("/");
    var loginString = string[0];
    var registerString = "/" + string[1];
    return Expanded(
      flex: 2,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.only(top: 10.auto, bottom: 10.auto),
            child: ColorButton(
              onClick: () => widget.onLoginTap!(),
              height: 20.auto,
              title: loginString + registerString,
              border: BorderSide(color: Colors.white, width: 1.5),
              radius: 15.7,
              width: 87.auto,
              isEnabled: true,
            ),
          ),
          Spacer()
        ],
      ),
    );
  }

  _buildHomeIcon(String imagePath, String title, String routePath) => Expanded(
      flex: 1,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          if (widget.userProfile == null && imagePath != "vip") {
            var res = await Navigator.of(context).pushNamed(RoutePath.login);
            if (res != null) widget.onRefreshHomePage!();
          } else {
            var res = await Navigator.of(context).pushNamed(routePath);
            if (res != null) widget.onRefreshHomePage!();
          }
        },
        child: Container(
          //  margin: EdgeInsets.only(left: 20.auto),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: CustomColor.theme_title_text_color,
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(imagePath == "vip" ? 5.auto : 0),
                  child: (imagePath == "withdraw")
                      ? Image.asset(
                          "images/menu/ic_menu_withdraw.png",
                          color: Colors.white,
                        )
                      : Image.asset(
                          imagePath == "vip"
                              ? "images/login_app_bar/vip.png"
                              : "images/home/T2/$imagePath.png",
                        ),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.auto,
                ),
                // minFontSize: 5,
                // stepGranularity: 1,
                maxLines: 1,
              )
            ],
          ),
        ),
      ));
}
