import 'package:api/entity/game_type.dart';
import 'package:api/entity/wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:api/extension/list_extension.dart';

class BalancePicker extends StatefulWidget {
  final bool isShow;
  final double? mainWalletBalance;
  final List<Wallet>? walletList;
  final List<GameType> gameTypeList;

  BalancePicker({
    this.isShow = false,
    this.mainWalletBalance,
    this.walletList,
    required this.gameTypeList,
  });

  @override
  _BalancePickerState createState() => _BalancePickerState();
}

class _BalancePickerState extends BaseState<BalancePicker> {
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isShow,
      child: Positioned(
        top: 95.auto,
        right: 20.auto,
        child: Column(
          children: [
            Container(
              width: 10.auto,
              height: 4.9.auto,
              child: CustomPaint(
                painter: CustomShape(
                  CustomColor.grey.withOpacity(0.9),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 10.auto,
                minWidth: context.screenWidth - 150.auto,
                maxHeight: context.screenHeight - 200.auto,
                maxWidth: context.screenWidth - 150.auto,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: CustomColor.grey.withOpacity(0.9),
                ),
                child: ListView(shrinkWrap: true, padding: EdgeInsets.all(10.auto), children: _buildItem()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItem() {
    return [
      _getTotalBalanceText(),
      Divider(color: Colors.white),
      ListView(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: List.generate(widget.gameTypeList.length, (index) {
          List<Wallet> currWalletList =
              widget.walletList!.where((element) => element.gameType == widget.gameTypeList[index]).toList();
          return ListView(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.auto),
                child: Text(
                  getTranslatedText(widget.gameTypeList[index].getName(context, false)),
                  style: TextStyle(
                    color: Color(0xfffde73f),
                  ),
                ),
              ),
              for (var wallet in currWalletList) _getGamePlatformBalanceText(wallet),
            ],
          );
        }),
      )
    ];
  }

  _getTotalBalanceText() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getTranslatedText("balance"),
            style: TextStyle(
              color: CustomColor.theme_button_color,
              fontWeight: FontWeight.bold,
              fontSize: 15.auto,
            ),
          ),
          Text(
            (widget.walletList?.singleWhereOrNull((element) => element.isMainWallet)?.balance ?? 0).toString(),
            style: TextStyle(
              color: CustomColor.theme_button_color,
              fontWeight: FontWeight.bold,
              fontSize: 15.auto,
            ),
          )
        ],
      );

  Widget _getGamePlatformBalanceText(Wallet wallet) => Padding(
        padding: EdgeInsets.only(left: 10.auto, right: 10.auto, bottom: 5.auto),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              wallet.gpCode ?? "",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            Text(
              wallet.balance.toString(),
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
}

class CustomShape extends CustomPainter {
  final Color bgColor;

  CustomShape(this.bgColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = bgColor;
    var x = 12.0, y = 6.0;
    var path = Path();
    path
      ..moveTo(x / 2, 0)
      ..lineTo(0, y)
      ..lineTo(x, y);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
