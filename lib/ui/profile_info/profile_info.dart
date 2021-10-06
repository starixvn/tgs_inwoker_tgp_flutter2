import 'package:api/entity/profile_info_item.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/profile_info/profile_info_view_model.dart';
import 'package:api/extension/screen_apis.dart';

class ProfileInfo extends StatefulWidget {
  @override
  _ProfileInfoState createState() => _ProfileInfoState();
}

class _ProfileInfoState extends BaseState<ProfileInfo> {
  var _vm = ProfileInfoViewModel();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<ProfileInfoViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: CustomColor.theme_bg_color,
              appBar: CustomAppBar(
                title: getTranslatedText("profile_detail"),
              ),
              body: ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: Container(
                    decoration: BoxDecoration(
                        color: CustomColor.theme_bg_color,
                        borderRadius: new BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        )),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildInfoCard(
                            "basic_info",
                            [ProfileInfoItem.REALNAME, ProfileInfoItem.PHONE_NUMBER, ProfileInfoItem.EMAIL],
                            ["real_ name_verification", "phone_verification", "email_verification"],
                            itemDescriptionList: [
                              _getItemText(_vm.userProfile.realname),
                              _getItemText(_vm.userProfile.phone),
                              _getItemText(_vm.userProfile.email)
                            ],
                          ),
                          _buildInfoCard(
                            "other_info",
                            [ProfileInfoItem.QQ_NUMBER, ProfileInfoItem.WECHAT_NUMBER],
                            ["qq_account", "wechat"],
                            itemDescriptionList: [
                              _getItemText(_vm.userProfile.qq),
                              _getItemText(_vm.userProfile.wechat),
                              //_getItemText(/*_vm.userProfile.memberAddress, isShowSet: true*/)
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10.auto),
                            child: _buildInfoCard(
                                "security_center",
                                [
                                  ProfileInfoItem.LOGIN_PASSWORD,
                                  //ProfileInfoItem.PAY_PASSWORD,
                                  //ProfileInfoItem.RESET_PAY_PASSWORD
                                ],
                                [
                                  "edit_password",
                                  //"pay_password",
                                  //"reset_pay_password"
                                  // if no security will navigate to security answer, else will navigate to edit security answer
                                ],
                                isSecurity: true),
                          )
                        ],
                      ),
                    ),
                  )));
        });
  }

  _buildInfoCard(String title, List<ProfileInfoItem> itemList, List<String> pathList,
          {List<String> itemDescriptionList, bool isSecurity = false}) =>
      Container(
        margin: EdgeInsets.only(left: 10.auto, right: 10.auto, top: 15.auto),
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 5,
          child: Container(
            margin: EdgeInsets.all(20.auto),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTranslatedText(title),
                  style: TextStyle(fontSize: 15.auto),
                ),
                Column(
                    children: List.generate(itemList.length, (index) {
                  return Container(
                    child: !isSecurity
                        ? _buildInfoItem(
                            itemList[index].getImagePath,
                            itemList[index].getDisplayName(context),
                            pathList[index],
                            itemDescription: itemDescriptionList != null ? itemDescriptionList[index] : "",
                          )
                        : _buildInfoItemWithoutText(
                            itemList[index].getImagePath,
                            itemList[index].getDisplayName(context),
                            pathList[index],
                          ),
                  );
                }))
              ],
            ),
          ),
        ),
      );

  _buildInfoItem(String imagePath, String itemTitle, String routePath, {String itemDescription}) {
   /* if (routePath == "phone_verification" && EnvironmentConfig.appTitleName != "HKJP")
      return Container();
    else*/
      return InkWell(
        onTap: () {
          Navigator.of(context).pushNamed("/$routePath");
        },
        highlightColor: Colors.transparent,
        child: Container(
          margin: EdgeInsets.only(top: 20.auto),
          child: Row(
            children: [
              Container(
                  margin: EdgeInsets.only(right: 10.auto),
                  child: ImageIcon(
                    AssetImage(imagePath),
                    size: 20.auto,
                  )
                  /*Image.asset(imagePath,
                  width: 20.auto,
                ),*/
                  ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemTitle,
                    style: TextStyle(fontSize: 15.auto),
                  ),
                  itemDescription != null
                      ? Container(
                          margin: EdgeInsets.only(top: 3.auto),
                          child: Text(
                            itemDescription,
                            style: TextStyle(fontSize: 15.auto, color: CustomColor.theme_button_color),
                          ),
                        )
                      : Container()
                ],
              ),
              Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 13.auto,
              ),
            ],
          ),
        ),
      );
  }

  _buildInfoItemWithoutText(String imagePath, String itemTitle, String routePath) => InkWell(
        onTap: () {
          Navigator.of(context).pushNamed("/$routePath");
        },
        highlightColor: Colors.transparent,
        child: Container(
          margin: EdgeInsets.only(top: 15.auto, bottom: 15.auto),
          child: Row(
            children: [
              Container(
                  margin: EdgeInsets.only(right: 10.auto),
                  child: ImageIcon(
                    AssetImage(imagePath),
                    size: 20.auto,
                  )
                  /*Image.asset(imagePath,
                  width: 20.auto,
                ),*/
                  ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemTitle,
                    style: TextStyle(fontSize: 15.auto),
                  ),
                ],
              ),
              Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 13.auto,
              ),
            ],
          ),
        ),
      );

  _getItemText(String text) {
    if (text != null && text.isNotEmpty)
      return text;
    else
      return getTranslatedText("not_configured");
  }
}
