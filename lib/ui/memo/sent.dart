import 'dart:ui';
import 'package:api/entity/delivery_box.dart';
import 'package:api/entity/vip.dart';
import 'package:api/extension/format.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tgp_flutter2/custom/color_button.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:tgp_flutter2/custom/outline_border_button.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/my_behavior.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/ui/vip/vipT14.dart';
import 'package:tgp_flutter2/ui/vip/vip_view_model.dart';

import '../../custom/custom_text_form_field.dart';
import '../report/account_report_view.dart';

import 'memo_dialog.dart';
import 'memo_item.dart';
import 'memo_view_model.dart';

class Sent extends StatefulWidget {
  final MemoViewModel vm;

  Sent({required this.vm});

  @override
  _SentState createState() => _SentState();
}

class _SentState extends BaseState<Sent> {
  ScrollController _controller = ScrollController();
  bool isLoading = false;

  @override
  void initState() {
    widget.vm.getDeliveryBoxList();
    _controller.addListener(_scrollListener);
    super.initState();
  }

  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          decoration:
              EnvironmentConfig.template_version == 14 ? BoxDecoration() : BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.auto)),
          padding: EdgeInsets.all(15.auto),
          margin: EnvironmentConfig.template_version == 14 ? EdgeInsets.zero : EdgeInsets.all(10.auto),
          child: Wrap(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Text(
                        getTranslatedText("memo_subject"),
                        style: TextStyle(color: _getTextColor(), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 0,
                    child: Container(
                      child: Text(
                        getTranslatedText("memo_date"),
                        style: TextStyle(color: _getTextColor(), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: context.screenHeight * 0.72,
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: ClampingScrollPhysics(),
                  controller: _controller,
                  children: List.generate(
                    (widget.vm.deliveryBoxList?.length ?? 0), (index){
                    DeliveryBox? delivery = widget.vm.deliveryBoxList?[index];
                    return InkWell(
                      onTap: (){
                        widget.vm.getDeliveryBoxDetails(delivery?.id ?? "").then((_) {
                          print("111");
                          _showDialog(widget.vm.deliveryBoxList![index]);
                        });
                      },
                      child: MemoItem(
                        title: widget.vm.deliveryBoxList?[index].subject ?? "",
                        date: Format().reversedDateFormat(widget.vm.deliveryBoxList?[index].sentOn ?? ""),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getTextColor() => EnvironmentConfig.template_version == 14 ? Colors.white : Colors.black;

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent) {
      setState(() {
        isLoading = true;
      });
      widget.vm.getDeliveryBoxList(isLoadMore: true);
    }
  }

  _showDialog(DeliveryBox delivery) {
    showDialog(
      context: context,
      builder: (BuildContext context) => MemoDialog(
        title: delivery.subject,
        sender: delivery.sender,
        sentOn: delivery.sentOn,
        content: delivery.content,
        showButton: false,
      ),
    );
  }
}
