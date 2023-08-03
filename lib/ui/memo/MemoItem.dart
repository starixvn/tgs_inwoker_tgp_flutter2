import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:flutter/material.dart';

import '../../base_state.dart';
import '../../custom/custom_text_form_field.dart';
import '../../environment_config.dart';
// import 'memo_view_model.dart';

class MemoItem extends StatefulWidget {
  final String title;
  final String date;
  final VoidCallback? onRead;

  MemoItem({required this.title, required this.date, required this.onRead});

  @override
  _MemoItemState createState() => _MemoItemState();
}

class _MemoItemState extends BaseState<MemoItem> {
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Divider(
          thickness: (0.5).auto,
          color: Color(0xffeaeaea),
        ),
        InkWell(
          onTap: (){
            if(widget.onRead!=null) widget.onRead;

          },
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  child: Text(
                    widget.title,
                    style: TextStyle(color: _getTextColor()),
                  ),
                ),
              ),
              Expanded(
                flex: 0,
                child: Container(
                  child: Text(
                    widget.date,
                    style: TextStyle(color: _getTextColor()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getTextColor() => EnvironmentConfig.template_version == 14 ? Colors.white : Colors.black;

  // _showDetailsDialog() => showDialog(
  //     context: context,
  //     builder: (BuildContext context) => MessageDialog(
  //       messageList: [
  //         _getMessageSubject(),
  //         widget.message.createdOn == null ? "" : Format().dateTimezoneFormat(widget.message.createdOn!),
  //         _getMessageContent(),
  //       ],
  //     ));
}
