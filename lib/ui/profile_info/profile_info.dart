import 'package:api/entity/identity_status.dart';
import 'package:api/entity/profile_info_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
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
    _vm.getUserProfile();
    _vm.getMessagingList();
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<ProfileInfoViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          return CustomScaffold(
            appBar: CustomAppBar(
              title: getTranslatedText("profile_detail"),
            ),
            body: Container(
              height: context.screenHeight,
              color: Colors.transparent,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildInfoCard(
                      "basic_info",
                      [
                        if (_vm.config?.icVerification ?? true) ProfileInfoItem.REALNAME,
                        if ((_vm.config?.smsVerification ?? false) || (_vm.config?.registerShowPhone ?? false))
                          ProfileInfoItem.PHONE_NUMBER,
                        if (_vm.config?.emailVerification ?? true) ProfileInfoItem.EMAIL,
                        ProfileInfoItem.BIRTHDATE,
                      ],
                      itemDescriptionList: [
                        if (_vm.config?.icVerification ?? true) _getRealName(),
                        if ((_vm.config?.smsVerification ?? false) || (_vm.config?.registerShowPhone ?? false))
                          _getItemText(_vm.userProfile.phone),
                        if (_vm.config?.emailVerification ?? true)
                          _getItemText(_vm.userProfile.email, isShowFirstText: false),
                        _getItemText(_vm.userProfile.birthdate, isShowFirstText: false)
                      ],
                    ),
                    _buildOtherInfoCard(),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.auto),
                      child: _buildInfoCard("security_center", [ProfileInfoItem.LOGIN_PASSWORD], isSecurity: true),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  _buildOtherInfoCard() {
    return (_vm.config?.qqWeChat ?? true) || (_vm.config?.customMessaging?.isNotEmpty ?? false)
        ? Container(
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
                      getTranslatedText("other_info"),
                      style: TextStyle(fontSize: 15.auto),
                    ),
                    Column(
                      children: _vm.messagingMap.map((mapItem) {
                        ProfileInfoItem item = mapItem["item"];
                        return Container(
                          child: _buildInfoItem(
                            item.getImagePath() ?? "",
                            item.getDisplayName(context) ?? "",
                            item.getNavigationPath() ?? "",
                            itemDescription: _getItemText(mapItem["text"] ?? ""),
                            isMessaging: true,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Container();
  }

  _buildInfoCard(String title, List<ProfileInfoItem> itemList,
          {List<String>? itemDescriptionList, bool isSecurity = false}) =>
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
            width: context.screenWidth,
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
                            itemList[index].getImagePath()!,
                            itemList[index].getDisplayName(context)!,
                            itemList[index].getNavigationPath()!,
                            itemDescription: itemDescriptionList != null ? itemDescriptionList[index] : "",
                          )
                        : _buildInfoItemWithoutText(
                            itemList[index].getImagePath()!,
                            itemList[index].getDisplayName(context)!,
                            itemList[index].getNavigationPath()!,
                          ),
                  );
                }))
              ],
            ),
          ),
        ),
      );

  _buildInfoItem(String imagePath, String itemTitle, String routePath,
      {String? itemDescription, bool isMessaging = false}) {
    if ((routePath == "phone_verification" &&
            !((_vm.config?.smsVerification ?? false) || (_vm.config?.registerShowPhone ?? false))) ||
        (routePath == "real_name_verification" && !(_vm.config?.icVerification ?? true)) ||
        (routePath == "email_verification" && !(_vm.config?.emailVerification ?? true)))
      return Container();
    else
      return InkWell(
        onTap: () async {
          if (_isDisableEditPhone(routePath))
            return;
          else {
            var result = await Navigator.of(context).pushNamed("/$routePath");
            if (result != null && isMessaging) _vm.getMessagingList();
          }
        },
        highlightColor: Colors.transparent,
        child: Container(
          margin: EdgeInsets.only(top: 20.auto),
          child: Row(
            children: [
              Container(
                  margin: EdgeInsets.only(right: 10.auto),
                  child: imagePath.contains("svg")
                      ? SvgPicture.asset(
                          imagePath,
                          matchTextDirection: true,
                          height: 28.auto,
                        )
                      : ImageIcon(
                          AssetImage(imagePath),
                          size: 20.auto,
                        )),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemTitle,
                    style: TextStyle(fontSize: 15.auto),
                  ),
                  handleNullWidget(
                      itemDescription == null,
                      Container(
                        margin: EdgeInsets.only(top: 3.auto),
                        child: Text(
                          itemDescription!,
                          style: TextStyle(fontSize: 15.auto, color: CustomColor.theme_button_color),
                        ),
                      ))
                ],
              ),
              Spacer(),
              Visibility(
                visible: !_isDisableEditPhone(routePath),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 13.auto,
                ),
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
                  )),
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
              Visibility(
                visible: _isDisableEditPhone(routePath),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 13.auto,
                ),
              ),
            ],
          ),
        ),
      );

  _getRealName() {
    var realName = _vm.userProfile.realname;
    if (realName != null && realName.isNotEmpty) {
      //if (_isShowIcVerificationUpload()) {
      if (_vm.userProfile.identityFormStatus == IdentityStatus.Approve)
        return realName + " (${getTranslatedText("verified")})";
      else if (_vm.userProfile.identityFormStatus == IdentityStatus.WaitingVerify)
        return realName + " (${getTranslatedText("waiting_verify")})";
      else if (_vm.userProfile.identityFormStatus == IdentityStatus.Reject)
        return realName + " (${getTranslatedText("rejected")})";
      // } else
      //return realName;
    } else
      return getTranslatedText("not_configured");
  }

  _getItemText(String? text, {bool isShowFirstText = true}) {
    if (text != null && text.isNotEmpty) {
      if (isShowFirstText)
        return text[0] + "**";
      else
        return text;
    } else
      return getTranslatedText("not_configured");
  }

  _isShowIcVerificationUpload() => (_vm.config?.icVerificationUpload ?? false);

  _isDisableEditPhone(String routePath) =>
      routePath == "phone_verification" &&
      (_vm.userProfile.phone != null) &&
      ((_vm.config?.profileNotAllowChangePhone ?? false));
}
