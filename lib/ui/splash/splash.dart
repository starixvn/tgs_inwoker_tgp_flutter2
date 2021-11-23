import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tgp_flutter2/environment_config.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/main.dart';
import 'package:tgp_flutter2/provider/provider_widget.dart';
import 'package:tgp_flutter2/base_state.dart';
import 'package:tgp_flutter2/route_path.dart';
import 'package:tgp_flutter2/ui/splash/splash_view_model.dart';

class Splash extends StatefulWidget {
  final String? logoUrl;

  Splash({this.logoUrl});

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends BaseState<Splash> {
  var _vm = SplashViewModel();

  @override
  void initState() {
   /* WidgetsBinding.instance!.addPostFrameCallback((_) {
      _vm.getAuthToken();
      _vm.getApiError();
      _vm.getBrandLogo();
      _vm.getLanguageOption();
    });*/
    super.initState();
  }

  Widget build(BuildContext context) {
 /*   return ProviderWidget<SplashViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();*/
          return Container(
            width: context.screenWidth,
            height: context.screenHeight,
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.logoUrl?.isEmpty ?? true
                      ? Container()
                      : CachedNetworkImage(
                          placeholder: (context, url) => Container(),
                          imageUrl: widget.logoUrl!,
                          //handling error
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(),
                        ),
                  Container(
                    width: context.screenWidth / 2.5,
                    alignment: Alignment.bottomCenter,
                    child: Lottie.asset("loading/loading_t${EnvironmentConfig.template_version}.json"),
                  ),
                ],
              ),
            ),
          );
       // });
  }

  _handleApiState() {
    handleApiState(_vm.getLanguageApiState, isAutoHideLoading: false, isSplashScreen: true, onSuccess: () {
      _navigateToHome();
    });
    handleApiState(_vm.getBrandLogoApiState, isAutoHideLoading: false, isSplashScreen: true, onSuccess: () {});
    handleApiState(_vm.authApiState, isAutoHideLoading: false, isSplashScreen: true, onSuccess: () {});
  }

  _navigateToHome() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(RoutePath.home);
    });
  }
}
