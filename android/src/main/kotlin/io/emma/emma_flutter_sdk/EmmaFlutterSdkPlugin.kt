package io.emma.emma_flutter_sdk

import android.app.Application
import android.content.Context
import androidx.annotation.NonNull
import androidx.annotation.Nullable

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.emma.android.EMMA
import io.emma.android.model.EMMAEventRequest
import java.lang.Exception

/** EmmaFlutterSdkPlugin */
class EmmaFlutterSdkPlugin : FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine anad unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel

  private lateinit var applicationContext: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    applicationContext = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "emma_flutter_sdk")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getEMMAVersion" -> {
        result.success(EMMA.getInstance().sdkVersion)
      }
      "startSession" -> {
        var sessionKey = call.argument<String>("sessionKey") ?: return returnError(result, call.method, "sessionKey")
        var debugEnabled = call.argument<Boolean>("debugEnabled") ?: return returnError(result, call.method, "debugEnabled")
        
        val configuration = EMMA.Configuration.Builder(applicationContext)
                .setSessionKey(sessionKey)
                .setQueueTime(25)
                .setDebugActive(debugEnabled)
                .build()

        EMMA.getInstance().startSession(configuration)

        result.success(null);
      }
      "trackEvent" -> {
        var eventToken = call.argument<String>("eventToken") ?: return returnError(result, call.method, "eventToken")
        var eventRequest = EMMAEventRequest(eventToken)

        call.argument<HashMap<String, Any>>("eventAttributes").let { attributes ->
          eventRequest.attributes = attributes
        }

        EMMA.getInstance().trackEvent(eventRequest)
        result.success(null)
      }
      "trackExtraUserInfo" -> {
        var userAttributes = call.argument<Map<String, String>>("extraUserInfo") ?: return returnError(result, call.method, "extraUserInfo")
        EMMA.getInstance().trackExtraUserInfo(userAttributes)
        result.success(null)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun returnError(@NonNull result: Result, methodName: String, @Nullable parameter: String? = null) {
    result.error("METHOD_ERROR", "Error in: $methodName", "Error in parameter: $parameter" ?: null)
  }
}