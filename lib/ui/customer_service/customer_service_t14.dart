import 'package:api/NotificationServices/NotificationServiceName.dart';
import 'package:api/NotificationServices/notification_center.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tgp_flutter2/custom/custom_app_bar.dart';
import 'package:tgp_flutter2/custom/custom_progress_dialog.dart';
import 'package:tgp_flutter2/custom/custom_scaffold.dart';
import 'package:tgp_flutter2/custom/custom_toast.dart';
import 'package:api/entity/brand_communication.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/src/gradient_decoration.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/customer_service/customer_service_view_model.dart';
import 'package:tgp_flutter2/ui/customer_service/customer_service_web_view.dart';

class CustomerServiceT14 extends StatefulWidget {
  final Widget liveChatRow;
  final List<Widget> cSRow;

  CustomerServiceT14({
    required this.liveChatRow,
    required this.cSRow,
  });

  @override
  _CustomerServiceT14State createState() => _CustomerServiceT14State();
}

class _CustomerServiceT14State extends BaseState<CustomerServiceT14> {
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    // NotificationCenter().notify(NotificationServiceName().appBarTitle, data: getTranslatedText("customer_service") == "customer_service" ? "Customer Service" : getTranslatedText("customer_service"));
    return Container(
      height: context.screenHeight,
      width: context.screenWidth,
      color: CustomColor.theme_bar_gradient_2,
      child: ListView(
        shrinkWrap: true,
        children: [
          Container(
            padding: EdgeInsets.all(15),
            alignment: Alignment.center,
            child: Text(
              getTranslatedText('customer_service'),
              style: TextStyle(color: Colors.white, fontSize: 15.auto),
            ),
          ),
          widget.liveChatRow,
          ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: widget.cSRow,
          ),
        ],
      ),
    );
  }
}
