import 'dart:math';

import 'package:api/entity/game.dart';
import 'package:api/entity/game_type.dart';
import 'package:api/extension/format.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/ui/home/game/game_view_model.dart';

class Jackpot extends StatefulWidget {
  final GameViewModel vm;
  final ValueChanged<Game> onClickChildGame;

  Jackpot({
    required this.vm,
    required this.onClickChildGame,
  });

  @override
  _JackpotState createState() => _JackpotState();
}

class _JackpotState extends BaseState<Jackpot> {
  var prize;
  var winList = [
    "kin9123***",
    "morisp***",
    "erikfan1***",
    "ritam712***",
    "perriw00***",
    "victorb63***",
    "heryam20***",
    "trwass7***",
    "aajac***",
    "winne19***",
    "k125923***",
    "garysin***",
    "lksj9482***",
    "kwashd7***",
    "lwda***",
    "gwsk12***",
    "946301***",
    "abc7***",
    "mrhr112***",
    "t2943***",
    "smi***",
    "luckybo***",
    "873251***",
    "hh3888***",
    "ttwisn***",
    "vipvi***",
    "cha19***",
    "113847***",
    "tami36***",
    "zzz90***",
    "mus12***",
    "c099***",
    "juicec***",
    "peta5***",
    "onk***",
    "monn0***",
    "pulli52***",
    "matkal***",
    "siumi***",
    "god6***",
    "sk***",
    "asdje2***",
    "ron707***",
    "5013d***",
    "bus01***",
    "fun011***",
    "fivivv***",
    "oopw3***",
    "927364***",
  ];
  var languageCode;

  @override
  void initState() {
    initData();
    prize = _randomGenerator(200000, 5000000);
    super.initState();
  }

  initData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var code = _prefs.getString("LANGUAGE_CODE");
    if (code == "zh-TW" || code == "zh-CN")
      languageCode = "zh-CN";
    else
      languageCode = "en-US";
  }

  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: [_buildJackPotItem(), _buildWinList(), _buildRecommendList()],
      ),
    );
  }

  _buildJackPotItem() => Container(
        height: context.screenHeight / 4,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/t11_bg/jackpot.png"),
              fit: BoxFit.cover),
        ),
        padding: EdgeInsets.symmetric(horizontal: 25.auto),
        child: Wrap(
          children: [
            Image.asset("images/home/T11/jackpot.gif"),
            Stack(
              children: [
                Image.asset("images/home/T11/jackpot_text.png"),
                Positioned(
                  left: context.screenWidth / 6,
                  bottom: context.screenHeight / 28,
                  child: Container(
                    width: context.screenWidth / 2.1,
                    height: 48,
                    alignment: Alignment.center,
                    child: Text(
                      "₱  ${Format().currencyWithDecimalFormat(prize)}",
                      style: TextStyle(color: Colors.white, fontSize: 22.auto),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );

  _buildWinList() => Stack(
    children: [
      Container(
          padding: EdgeInsets.symmetric(horizontal: 20.auto),
          alignment: Alignment.center,
          child: Image.asset(
            "images/home/T11/win_list.png",
            width: context.screenWidth,
            fit: BoxFit.fill,
          )),
      Positioned(
        left: 0,
        top: context.screenWidth / 3,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 50.auto),
          width: context.screenWidth,
          height: context.screenWidth / 0.9,
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                  width: context.screenWidth,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(bottom: 10.auto),
                  child: Text(
                    getTranslatedText("win_list"),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.auto,
                    ),
                  )),
              SizedBox(
                width: context.screenWidth,
                height: context.screenWidth / 1.3,
                child: (widget.vm.expandRecommendList?.isEmpty ?? true)
                    ? buildProgressDialog(widget.vm.brandLogoUrl)
                    : ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(right: 20),
                  children: List.generate(winList.length, (index) {
                    return Container(
                      child: _buildWinListItem(winList[index],
                          widget.vm.randomGameData()),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  _buildWinListItem(String name, Game? game) => game == null
      ? Container()
      : Container(
          decoration: BoxDecoration(
            color: Color(0xff232323),
            borderRadius: BorderRadius.circular(10.auto),
            border: Border.all(color: Color(0xff5b5b5b)),
          ),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(bottom: 10.auto),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                    height: 40,
                    width: 40,
                    margin: EdgeInsets.only(right: 10),
                    child: _buildImage(game)),
              ),
              Expanded(
                flex: 5,
                child: RichText(
                  text: TextSpan(
                    text: getTranslatedText("player"),
                    style:
                        TextStyle(fontSize: 10.auto, color: Color(0xff707070)),
                    children: [
                      TextSpan(
                        text: " $name",
                        style: TextStyle(color: Colors.white, fontSize: 8.auto),
                      ),
                      TextSpan(
                        text: "${getTranslatedText("at")}\n",
                        style: TextStyle(
                            fontSize: 10.auto, color: Color(0xff707070)),
                      ),
                      TextSpan(
                        text: game.name,
                        style: TextStyle(color: Colors.white, fontSize: 8.auto),
                      ),
                      TextSpan(
                        text: getTranslatedText("won"),
                        style: TextStyle(
                            fontSize: 10.auto, color: Color(0xff707070)),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  alignment: Alignment.center,
                  child: AutoSizeText(
                    "₱  ${Format().currencyWithDecimalFormat(_randomGenerator(5, 5000))}",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    minFontSize: 10,
                    maxFontSize: 18,
                    stepGranularity: 1,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        );

  _buildRecommendList() => SizedBox(
        width: context.screenWidth,
        child: Container(
          padding: EdgeInsets.only(left: 10.auto),
          child: ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildItem("JILITF", GameType.Slot),
              _buildItem("RTTF", GameType.Slot),
              _buildItem("JDBTF", GameType.Slot),
              _buildItem("JILITF", GameType.Fishing),
              _buildItem("JDBTF", GameType.Fishing),
            ],
          ),
        ),
      );

  _buildItem(String code, GameType type) {
    var displayCode = ((() {
      if (code == "JILITF")
        return "JILI";
      else if (code == "RTTF")
        return "Red Tiger";
      else
        return code;
    }()));
    return (widget.vm.jackpotRecommendGameList["${code}_$type"]?.isEmpty ??
            true)
        ? Container()
        : SizedBox(
            width: context.screenWidth,
            height: context.screenWidth / 1.7,
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  child: Container(
                    margin: EdgeInsets.only(top: 20.auto),
                    padding: EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CustomColor.theme_button_color,
                          CustomColor.theme_button_color,
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "$displayCode ${type.getName(context, false)}",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.auto,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 185,
                  child: _buildGameGridView(code, type),
                ),
              ],
            ),
          );
  }

  _buildGameGridView(String code, GameType type) => GridView.count(
        crossAxisCount: 1,
        shrinkWrap: true,
        childAspectRatio: 185 / 110,
        crossAxisSpacing: 0,
        mainAxisSpacing: 5,
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 10),
        children: (widget.vm.jackpotRecommendGameList["${code}_$type"] ?? [])
            .map<Widget>((item) => Container(
                  height: 160,
                  width: 110,
                  //color: Colors.white,
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    onTap: () => widget.onClickChildGame(item),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 100,
                          height: 160,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                Container(
                                  child: _buildImage(item),
                                ),
                                _buildImageTitle(item),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: -20,
                          left: -20,
                          child: Image.asset(
                            "images/game/T11/stars.png",
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      );

  _getImageUrl(Game game) {
    var gameName = game.code;
    if (gameName == "FishingYiLuFa")
      return EnvironmentConfig.slotGameUrl +
          "${(game.gamePlatformCode ?? "").toUpperCase()}/zh-CN/$gameName.jpg";
    else
      return EnvironmentConfig.slotGameUrl +
          "${(game.gamePlatformCode ?? "").toUpperCase()}/${languageCode ?? "en-US"}/$gameName.jpg";
  }

  _buildImage(Game game, {double size = 100}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5.0),
      child: Container(
        height: size.auto,
        width: size.auto,
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xffd52662)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: CachedNetworkImage(
              placeholder: (context, url) => Container(
                    color: CustomColor.very_light_pink_two,
                  ),
              imageUrl: _getImageUrl(game),
              //handling error
              errorWidget: (_, __, ___) => Container(
                    color: CustomColor.very_light_pink_two,
                  ),
              fit: BoxFit.fill),
        ),
      ),
    );
  }

  _buildImageTitle(Game game) {
    return Container(
      height: 30.auto,
      decoration: BoxDecoration(
          color: Color(0xff232323),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5),
          )),
      alignment: Alignment.center,
      child: AutoSizeText(
        game.name ?? "",
        style: TextStyle(color: Colors.white),
        minFontSize: 5,
        stepGranularity: 1,
        maxLines: 1,
      ),
    );
  }

  _randomGenerator(int min, max) {
    return min + Random().nextDouble() * (max - min);
  }
}
