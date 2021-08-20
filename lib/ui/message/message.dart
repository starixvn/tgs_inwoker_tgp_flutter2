import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/tab_button.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/ui/message/announcement_content.dart';
import 'package:tgp_flutter2/ui/message/message_content.dart';
import 'package:tgp_flutter2/ui/message/message_view_model.dart';

import 'message_item.dart';

class Message extends StatefulWidget {
  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends BaseState<Message> {
  var isEditing = false, isSelected = false, isLoading = false;
  var _vm = MessageViewModel();
  List<String> selectedMessageList = [];
  ScrollController _controller = ScrollController();
  var tab = [
    {"id": "0", "text": "个人讯息"},
    {"id": "1", "text": "公告专区"}
  ];
  var currentTabIndex = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProgressDialog.show(context);
      _vm.getMessageList();
    });
    _controller.addListener(_scrollListener);
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<MessageViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: CustomColor.theme_bg_color,
            appBar: CustomAppBar(
              title: getTranslatedText("message_center"),
            ),
            body: _vm.messageList == null
                ? Container()
                : Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.auto),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: tab.map((item) {
                              return InkWell(
                                  onTap: () => setState(() {
                                        currentTabIndex = int.parse(item['id']);
                                      }),
                                  child: Container(
                                    child: TabButton(
                                      text: getTranslatedText(item["text"])??item["text"],
                                      index: int.parse(item['id']),
                                      currentTabIndex: currentTabIndex,
                                      width: context.screenWidth / 2 - 20.auto,
                                      height: 32.auto,
                                    ),
                                  ));
                            }).toList(), /*[
                              InkWell(
                                  onTap: () {},
                                  child: TabButton(
                                    text: tab[0]["text"],
                                    index: int.parse(tab[0]['id']),
                                    currentTabIndex: currentTabIndex,
                                    width: context.screenWidth / 2 - 20.auto,
                                    height: 32.auto,
                                  )),
                              InkWell(
                                  onTap: () ,
                                  child: TabButton(
                                    text: tab[1]["text"],
                                    index: int.parse(tab[1]['id']),
                                    currentTabIndex: currentTabIndex,
                                    width: context.screenWidth / 2 - 20.auto,
                                    height: 32.auto,
                                  )),
                            ],*/
                          ),
                        ),
                        Expanded(
                            flex: 9,
                            child: currentTabIndex == 0
                                ? MessageContent(
                                    vm: _vm,
                                  )
                                : AnnouncementContent(
                                    vm: _vm,
                                  ))
                      ],
                    ),
                  ),
          );
        });
  }

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent) {
      setState(() {
        isLoading = true;
      });
      _vm.getMessageList(isLoadMore: true);
    }
  }

  _handleApiState() {
    handleApiState(_vm.getMessageListApiState, onSuccess: () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isLoading) {
          setState(() {
            isLoading = false;
          });
        }
      });
    });
    handleApiState(_vm.readMessageApiState, onSuccess: () {});
  }
}
