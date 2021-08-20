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
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends BaseState<Splash> {
  var _vm = SplashViewModel();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm.getAuthToken();
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return ProviderWidget<SplashViewModel>(
        model: _vm,
        builder: (ctx, vm, _) {
          _handleApiState();
          return Scaffold(
              resizeToAvoidBottomInset: false,
              body: Container(
                width: context.screenWidth,
                height: context.screenHeight,
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(width: context.screenWidth / 1.5, child: Image.asset("images/login/pg_login_logo.png")),
                      Container(
                        width: context.screenWidth / 2.5,
                        alignment: Alignment.bottomCenter,
                        child: Lottie.asset("loading/loading.json"),
                      ),
                    ],
                  ),
                ),
              ));
        });
  }

  _handleApiState() {
    handleApiState(_vm.authApiState, onSuccess: () {
      _navigateToHome();
    }, isAutoHideLoading: false, onError: (_) {});
  }

  _navigateToHome() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(RoutePath.home);
    });
        }
}
