import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class CustomLoginAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomLoginAppBar({
    required this.onClickLoginButton,
    required this.isLogin,
     this.brandLogoUrl,
  });

  final Function onClickLoginButton;
  final bool isLogin;
  final String? brandLogoUrl;

  @override
  Size get preferredSize => const Size.fromHeight(45);

  /*final List dropDownList = [
    {"id": "0", "text": "真人娱乐"},
    {"id": "1", "text": "棋牌游戏"},
    {"id": "2", "text": "体育电竞"},
    {"id": "3", "text": "彩票游戏"},
    {"id": "4", "text": "老虎机"},
    {"id": "5", "text": "电子游戏"},
    {"id": "6", "text": "捕鱼游戏"},
    {"id": "7", "text": "优惠活动"},
    {"id": "8", "text": "总额度"},
    {"id": "9", "text": "主播赠礼"}
  ];*/

  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: CustomColor.theme_app_bar_color,
      title: (brandLogoUrl?.isEmpty ?? true)
          ? Container()
          : CachedNetworkImage(
              placeholder: (context, url) => Container(),
              imageUrl: brandLogoUrl!,
              //handling error
              height: 30.auto,
              fit: BoxFit.cover,
              color: Colors.white,
              errorWidget: (context, url, error) => Container(),
            ),
      actions: [_getLoginButton()],
    );
  }

  _getLoginButton() => Visibility(
        visible: !isLogin,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.auto, horizontal: 10.auto),
          child: OutlineBorderButton(
            title: "登入",
            onClick: () => onClickLoginButton(),
            isEnabled: true,
            width: 60,
            height: 17,
            color: Colors.white,
            fontSize: 14,
            radius: 5,
            padding: 4,
          ),
        ),
      );

/*_getButton() => Container(
        padding: EdgeInsets.symmetric(vertical: 10.auto, horizontal: 5.auto),
        child: PopupMenuButton(
          child: _buildCheckButton(),
          color: Color(0xff272727).withOpacity(0.9),
          shape: RightTooltipShape(),
          offset: Offset(0, 15),
          padding: EdgeInsets.zero,
          itemBuilder: (context) => List.generate(dropDownList.length, (index) {
            var _index = int.parse(dropDownList[index]["id"]);
            return PopupMenuItem<int>(
              value: _index,
              height: 35.auto,
              child: _buildPopUpMenuItem(context, index),
            );
          }),
          onSelected: (item) => {},
        ),
      );

  _buildCheckButton() => Container(
        width: 60.auto,
        height: 17.auto,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular((5.8).auto), color: CustomColor.theme_button_color),
        child: Text(
          "查询",
          style: TextStyle(fontSize: 14.auto, color: CustomColor.theme_text_grey_color),
          textAlign: TextAlign.center,
        ),
      );

  _buildPopUpMenuItem(BuildContext context, int index) {
    return Container(
      width: context.screenWidth / 2 - 50.auto,
      child: Column(
        children: [
          Row(
           // mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex:2,
                child:  Text(
                  dropDownList[index]["text"],
                  style: TextStyle(fontSize: 10.auto, color: _getFirstColor(index)),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.only(left: 10.auto),
                  child: Text(
                    "0",
                    style: TextStyle(fontSize: 10.auto, color: _getSecondColor(index)),
                    textAlign: TextAlign.start,
                  ),
                ),
              )
            ],
          ),
          Visibility(
            visible: index != 9,
            child: Divider(
              thickness: 1,
              color: CustomColor.theme_text_grey_color,
            ),
          ),
          Visibility(
            visible: index == 9 && isLogin,
            child:  Container(
                height: 30.auto,
                margin: EdgeInsets.only(top: 20.auto, bottom: 10.auto),
                child: ColorButton(
                  title: "登出",
                  onClick: () {},
                  isEnabled: true,
                  radius: 5,
                  fontSize: 10,
                ),
            ),
          ),
        ],
      ),
    );
  }
  
  _getFirstColor(int index){
    if(index==8) return CustomColor.popup_menu_text_brown;
    else if (index == 9) return CustomColor.popup_menu_text_green;
    else return CustomColor.theme_text_grey_color;
  }

  _getSecondColor(int index){
    if(index==8) return CustomColor.popup_menu_text_brown;
    else if (index == 9) return CustomColor.popup_menu_text_green;
    else return CustomColor.popup_menu_text_yellow;
  }*/
}
