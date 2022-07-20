import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/ui/message/message_view_model.dart';

import 'message_item.dart';

class MessageView extends StatefulWidget {
  @override
  _MessageViewState createState() => _MessageViewState();
}

class _MessageViewState extends BaseState<MessageView> {
  var isEditing = false, isSelected = false, isLoading = false;
  var _vm = MessageViewModel();
  List<String> selectedMessageList = [];
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //ProgressDialog.show(context, _vm.brandLogoUrl);
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
          return CustomScaffold(
            appBar: CustomAppBar(
              title: getTranslatedText("message_center"),
            ),
            body: _vm.messageList == null
                ? buildProgressDialog(_vm.brandLogoUrl)
                : ListView(controller: _controller, padding: EdgeInsets.all(8.0), children: [
                    Column(
                      children: List.generate(_vm.messageList!.length, (index) {
                        return MessageItem(
                          message: _vm.messageList![index],
                          onReadMessage: (id) {
                            _vm.readMessage([id]); //call api silently
                          },
                        );
                      }),
                    ),
                    Visibility(
                        visible: _vm.endRecord ? false : isLoading,
                        child: Container(
                          alignment: Alignment.center,
                          child: buildLottie(size: 100.0)
                        )),
                    Visibility(
                        visible: _vm.endRecord && _vm.messageList!.isNotEmpty,
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(bottom: 10.auto),
                          child: Text(
                            getTranslatedText("no_more"),
                            style: TextStyle(fontSize: 12.auto, color: CustomColor.theme_text_grey_color),
                          ),
                        ))
                  ]),
          );
        });
  }

  _buildBottomNavigationBar() => Visibility(
        visible: !(selectedMessageList == null || selectedMessageList.isEmpty),
        child: BottomAppBar(
            color: CustomColor.theme_button_color,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    ProgressDialog.show(context, _vm.brandLogoUrl);
                    _vm.readMessage(selectedMessageList);
                    setState(() {
                      selectedMessageList = [];
                      isEditing = false;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.only(top: 10.auto, bottom: 10.auto, left: 15.auto),
                    child: Text(
                      getTranslatedText("mark_as_read"),
                      style: TextStyle(color: CustomColor.theme_text_grey_color, fontSize: 12.auto),
                    ),
                  ),
                ),
                /*InkWell(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.only(top: 10.auto, bottom: 10.auto, right: 15.auto),
                    child: Text(
                      getTranslatedText("delete"),
                      style: TextStyle(color: Colors.white, fontSize: 12.auto),
                    ),
                  ),
                ),*/
              ],
            )),
      );

  /*_onSelected(Message _selectedMessage) {
    setState(() {
      isSelected = !isSelected;
      if (isSelected)
        selectedMessageList.add(_selectedMessage.id);
      else {
        selectedMessageList.removeWhere((element) => element == _selectedMessage.id);
      }
    });
  }*/

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent) {
      setState(() {
        isLoading = true;
      });
      _vm.getMessageList(isLoadMore: true);
    }
  }

  _handleApiState() {
    handleApiState(_vm.getMessageListApiState, isAutoHideLoading: false, onSuccess: () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isLoading) {
          setState(() {
            isLoading = false;
          });
        }
      });
    });
    handleApiState(_vm.readMessageApiState, isAutoHideLoading: false, onSuccess: () {});
  }
}
