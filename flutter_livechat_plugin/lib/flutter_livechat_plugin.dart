import 'package:flutter/services.dart';

class FlutterLivechatPlugin {
  static const MethodChannel _channel = MethodChannel('flutter_livechat_plugin');

  /// Get platform version
  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// Begin chat by invoking method channel
  static Future<void> beginChat(String licenseNo) async {
    await _channel.invokeMethod('beginChat', <String, dynamic>{
      'licenseNo': licenseNo,
    });
  }
}
