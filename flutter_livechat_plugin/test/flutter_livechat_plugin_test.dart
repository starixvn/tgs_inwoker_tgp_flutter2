import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_livechat_plugin/flutter_livechat_plugin.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterLivechatPluginPlatform 
    with MockPlatformInterfaceMixin
    /*implements FlutterLivechatPluginPlatform */{

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  // final FlutterLivechatPluginPlatform initialPlatform = FlutterLivechatPluginPlatform.instance;
  //
  // test('$MethodChannelFlutterLivechatPlugin is the default instance', () {
  //   expect(initialPlatform, isInstanceOf<MethodChannelFlutterLivechatPlugin>());
  // });
  //
  // test('getPlatformVersion', () async {
  //   FlutterLivechatPlugin flutterLivechatPlugin = FlutterLivechatPlugin();
  //   MockFlutterLivechatPluginPlatform fakePlatform = MockFlutterLivechatPluginPlatform();
  //   FlutterLivechatPluginPlatform.instance = fakePlatform;
  //
  //   expect(await flutterLivechatPlugin.getPlatformVersion(), '42');
  // });
}
