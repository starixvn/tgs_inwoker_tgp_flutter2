import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:api/entity/wallet.dart';
import 'package:api/extension/format.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';


class WalletProviderIcon extends StatefulWidget {
  final Wallet wallet;

  WalletProviderIcon({
    required this.wallet,
  });

  @override
  _WalletProviderIconState createState() => _WalletProviderIconState();
}

class _WalletProviderIconState extends BaseState<WalletProviderIcon> {
  @override
  void dispose() {
    super.dispose();
  }

  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(0xff1B1D30),
        borderRadius: BorderRadius.all(Radius.circular(10.auto)),
      ),
      padding: EdgeInsets.all(10.auto),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Container(),
                    imageUrl: "https://stg-t14.rpgp.cc/assets/images/provider/${widget.wallet.gpCode.toString().toLowerCase()}.png",
                    //handling error
                    width: 50.auto,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(),
                  ),
                ),
                Expanded(
                  flex: 0,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "${widget.wallet.title}",
                      style: TextStyle(color: Colors.white, fontSize: 12.5.auto),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 0,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 5.auto, horizontal: 10.auto),
                    decoration: BoxDecoration(
                      color: CustomColor.theme_bar_gradient_1,
                      borderRadius: BorderRadius.all(Radius.circular(15.auto)),
                    ),
                    child: Text(
                      getTranslatedText("transfer_in"),
                      style: TextStyle(fontSize: 8.auto, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  flex: 0,
                  child: Text(
                    Format().doubleToString(widget.wallet.balance ?? 0.0),
                    style: TextStyle(fontSize: 15.auto, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
