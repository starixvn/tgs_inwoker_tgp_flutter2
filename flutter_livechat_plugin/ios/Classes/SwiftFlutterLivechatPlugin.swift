import Flutter
import UIKit


public class SwiftFlutterLivechatPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_livechat_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterLivechatPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
    switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "beginChat":
            let arguments = call.arguments as! [String:Any]

            let licenseNo = (arguments["licenseNo"] as? String)

            if (licenseNo == ""){
                result(FlutterError(code: "", message: "LICENSE NUMBER EMPTY", details: nil))
           }else{
                LiveChat.licenseId = licenseNo // Set your licence number here

                LiveChat.presentChat()
                result(nil)
            }
        default:
            result(FlutterMethodNotImplemented)
    }
  }
}
