package com.example.flutter_livechat_plugin

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.annotation.NonNull
import com.livechatinc.inappchat.ChatWindowConfiguration
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterLivechatPlugin */
class FlutterLivechatPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var activity : Activity

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_livechat_plugin")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + Build.VERSION.RELEASE)
    } else if (call.method.equals("beginChat")) {
      val licenseNo: String? = call.argument("licenseNo")
//      val customParams: HashMap<String, String> = call.argument("customParams")
//      val groupId: String = call.argument("groupId")
//      val visitorName: String = call.argument("visitorName")
//      val visitorEmail: String = call.argument("visitorEmail")
      if (licenseNo != null) {
        if (licenseNo.trim { it <= ' ' }.equals("", ignoreCase = true)) {
          result.error("LICENSE NUMBER EMPTY", null, null)

        } else {
          val intent =
            Intent(activity, com.livechatinc.inappchat.ChatWindowActivity::class.java)
          val config: Bundle = ChatWindowConfiguration.Builder()
            .setLicenceNumber(licenseNo)
            //                .setGroupId(groupId)
            //                .setVisitorName(visitorName)
            //                .setVisitorEmail(visitorEmail)
            //                .setCustomParams(customParams)
            .build()
            .asBundle()
          intent.putExtras(config)
          activity.startActivity(intent)
          result.success(null)
        }
      }
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }


  override fun onAttachedToActivity(activityPluginBinding: ActivityPluginBinding) {
    activity = activityPluginBinding.activity
  }

  override fun onDetachedFromActivity() {}

  override fun onDetachedFromActivityForConfigChanges() {}

  override fun onReattachedToActivityForConfigChanges(activityPluginBinding: ActivityPluginBinding) {}
}
