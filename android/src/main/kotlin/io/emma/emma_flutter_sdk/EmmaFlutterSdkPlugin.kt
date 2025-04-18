package io.emma.emma_flutter_sdk

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build;
import androidx.annotation.NonNull
import androidx.annotation.Nullable
import io.emma.android.EMMA
import io.emma.android.interfaces.EMMABatchNativeAdInterface
import io.emma.android.interfaces.EMMAInAppMessageInterface
import io.emma.android.interfaces.EMMANativeAdInterface
import io.emma.android.interfaces.EMMAPermissionInterface
import io.emma.android.utils.EMMALog
import io.emma.android.utils.EMMAUtils
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.emma.android.model.*
import io.flutter.plugin.common.PluginRegistry
import kotlin.collections.ArrayList
import kotlin.collections.HashMap

/** EmmaFlutterSdkPlugin */
class EmmaFlutterSdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.NewIntentListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine anad unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel
  private lateinit var applicationContext: Context
  private lateinit var activity: Activity
  private lateinit var assets: FlutterPlugin.FlutterAssets
  private var activityPluginBinding: ActivityPluginBinding? = null


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    applicationContext = flutterPluginBinding.applicationContext
    assets = flutterPluginBinding.flutterAssets
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "emma_flutter_sdk")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getEMMAVersion" -> {
        result.success(EMMA.getInstance().sdkVersion)
      }
      "startSession" -> {
        startSession(call, result)
      }
      "trackEvent" -> {
        trackEvent(call, result)
      }
      "trackExtraUserInfo" -> {
        trackExtraUserInfo(call, result)
      }
      "loginUser" -> {
        loginUser(call, result)
      }
      "registerUser" -> {
        registerUser(call, result)
      }
      "inAppMessage" -> {
        inappMessage(call, result)
      }
      "startPushSystem" -> {
        startPushSystem(call, result)
      }
      "sendInAppImpression" -> {
        sendInAppImpressionOrClick(InAppAction.Impression, call, result)
      }
      "sendInAppClick" -> {
        sendInAppImpressionOrClick(InAppAction.Click, call, result)
      }
      "sendInAppDismissedClick" -> {
        sendInAppImpressionOrClick(InAppAction.DismissedClick, call, result)
      }
      "openNativeAd" -> {
        openNativeAd(call, result)
      }
      "checkForRichPush" -> {
        checkForRichPush(result)
      }
      "startOrder" -> {
        startOrder(call, result)
      }
      "addProduct" -> {
        addProduct(call, result)
      }
      "trackOrder" -> {
        trackOrder(result)
      }
      "cancelOrder" -> {
        cancelOrder(call, result)
      }
      "trackUserLocation" -> {
        trackLocation(result)
      } 
      "setCustomerId" -> {
        setCustomerId(call, result)
      }
      "setUserLanguage" -> {
        setUserLanguage(call, result)
      }
      "areNotificationsEnabled" -> {
        areNotificationsEnabled(result)
      }
      "requestNotificationsPermission" -> {
        requestNotificationPermission(call, result)
      }
      "handleLink" -> {
        handleLink(call, result)
      }
      "isUserTrackingEnabled" -> {
        isUserTrackingEnabled(result)
      }
      "enableUserTracking" -> {
        enableUserTracking(result)
      }
      "disableUserTracking" -> {
        disableUserTracking(call, result)
      }
      else -> {
        EMMALog.w("Method ${call.method} not implemented")
        Utils.runOnMainThread(Runnable { result.notImplemented() })
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun returnError(@NonNull result: Result, methodName: String, @Nullable parameter: String? = null) {
    result.error("METHOD_ERROR", "Error in: $methodName", "Error in parameter: $parameter" ?: null)
  }

  private fun attachBindingActivity(binding: ActivityPluginBinding) {
    activity = binding.activity;
    activityPluginBinding = binding
    binding.addOnNewIntentListener(this)
    EMMA.getInstance().setCurrentActivity(activity)
    processIntentIfNeeded(binding.activity.intent)
  }

  private fun removeBindingActivity() {
    activityPluginBinding?.removeOnNewIntentListener(this)
    activityPluginBinding = null
  }

  override fun onDetachedFromActivity() {
    removeBindingActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
   attachBindingActivity(binding)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    attachBindingActivity(binding)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    removeBindingActivity()
  }

  private fun startSession(@NonNull call: MethodCall, @NonNull result: Result) {
    val sessionKey = call.argument<String>("sessionKey")
            ?: return returnError(result, call.method, "sessionKey")
    val debugEnabled = call.argument<Boolean>("isDebug") ?: false
    val queueTime = call.argument<Int>("queueTime")
    val apiUrl = call.argument<String>("apiUrl")
    val customPowlinkDomains = call.argument<List<String>>("customPowlinkDomains")?.toTypedArray()
    val customShortPowlinkDomains = call.argument<List<String>>("customShortPowlinkDomains")?.toTypedArray()
    val trackScreenEvents = call.argument<Boolean>("trackScreenEvents") ?: false
    val familiesPolicyTreatment = call.argument<Boolean>("familiesPolicyTreatment") ?: false

    val configurationBuilder = EMMA.Configuration.Builder(applicationContext)
      .setSessionKey(sessionKey)
      .setDebugActive(debugEnabled)
      .trackScreenEvents(trackScreenEvents)
      .setFamilyPolicyTreatment(familiesPolicyTreatment)

    queueTime?.takeIf { it > 0 }?.let {
      configurationBuilder.setQueueTime(it)
    }

    apiUrl?.let {
      configurationBuilder.setWebServiceUrl(it)
    }

    customPowlinkDomains?.let {
      configurationBuilder.setPowlinkDomains(*it)
    }

    customShortPowlinkDomains?.let {
      configurationBuilder.setShortPowlinkDomains(*it)
    }

    val configuration = configurationBuilder.build()

    EMMA.getInstance().startSession(configuration)
    result.success(null)
  }

  private fun trackEvent(@NonNull call: MethodCall, @NonNull result: Result) {
    val eventToken = call.argument<String>("eventToken")
            ?: return returnError(result, call.method, "eventToken")
    val eventRequest = EMMAEventRequest(eventToken)

    call.argument<HashMap<String, Any>>("eventAttributes").let { attributes ->
      eventRequest.attributes = attributes
    }

    EMMA.getInstance().trackEvent(eventRequest)
    result.success(null)
  }

  private fun trackExtraUserInfo(@NonNull call: MethodCall, @NonNull result: Result) {
    val userAttributes = call.argument<Map<String, String>>("extraUserInfo")
            ?: return returnError(result, call.method, "extraUserInfo")
    EMMA.getInstance().trackExtraUserInfo(userAttributes)
    result.success(null)
  }

  private fun loginUser(@NonNull call: MethodCall, @NonNull result: Result) {
    val userId = call.argument<String>("userId")
            ?: return returnError(result, call.method, "userId")
    val email = call.argument<String>("email") ?: ""
    EMMA.getInstance().loginUser(userId, email)
    result.success(null)
  }

  private fun registerUser(@NonNull call: MethodCall, @NonNull result: Result) {
    val userId = call.argument<String>("userId")
            ?: return returnError(result, call.method, "userId")
    val email = call.argument<String>("email") ?: ""
    EMMA.getInstance().registerUser(userId, email)
    result.success(null)
  }

  private fun inappMessage(@NonNull call: MethodCall, @NonNull result: Result) {
    val inAppRequestType = call.argument<String>("inAppType")
            ?: return returnError(result, call.method, "inAppType")

    val inappType = EmmaSerializer.getInAppRequestTypeFromString(inAppRequestType)
    if (null == inappType) {
      EMMALog.w("Invalid inapp type $inAppRequestType. Skip request.")
      result.success(null)
      return
    }

    EMMA.getInstance().setCurrentActivity(activity)
    if (EMMACampaign.Type.NATIVEAD == inappType) {
      inappMessageNativeAd(call, result)
    } else {
      val request = EMMAInAppRequest(inappType)
      EMMA.getInstance().getInAppMessage(request)
      result.success(null)
    }
  }

  private fun inappMessageNativeAd(@NonNull call: MethodCall, @NonNull result: Result) {
    val request = EMMANativeAdRequest()
    request.templateId = call.argument<String>("templateId")?:
            return returnError(result, call.method, "templateId")
    request.isBatch = call.argument<Boolean>("batch")
            ?: false

    val listener: EMMAInAppMessageInterface
    if (request.isBatch) {
      listener = object : EMMABatchNativeAdInterface {
        override fun onShown(campaign: EMMACampaign) {
          // Not implemented
        }

        override fun onHide(campaign: EMMACampaign) {
          // Not implemented
        }

        override fun onClose(campaign: EMMACampaign) {
          // Not implemented
        }

        override fun onBatchReceived(nativeAds: List<EMMANativeAd>) {
          onReceiveNativeAds(nativeAds)
        }
      }
    } else {
      listener = object : EMMANativeAdInterface {
        override fun onShown(campaign: EMMACampaign) {
          // Not implemented
        }

        override fun onHide(campaign: EMMACampaign) {
          // Not implemented
        }

        override fun onClose(campaign: EMMACampaign) {
          // Not implemented
        }

        override fun onReceived(nativeAd: EMMANativeAd) {
          onReceiveNativeAds(listOf(nativeAd))
        }
      }
    }

    EMMA.getInstance().getInAppMessage(request, listener)
    result.success(null)
  }

  private fun onReceiveNativeAds(nativeAds: List<EMMANativeAd>) {
    val convertedNativeAds = convertNativeAdsToMap(nativeAds)
    Utils.executeOnMainThread(channel, "Emma#onReceivedNativeAds", convertedNativeAds)
  }

  private fun startPushSystem(@NonNull call: MethodCall, @NonNull result: Result) {

    val notificationIcon = call.argument<String>("notificationIcon")
            ?: return returnError(result, call.method, "notificationIcon")
    val pushIcon = Utils.getNotificationIcon(applicationContext, notificationIcon)

    val defaultChannel  = Utils.getAppName(applicationContext) ?: "EMMA"

    val channelName = call.argument<String>("notificationChannel") ?: defaultChannel
    val notificationChannelId = call.argument<String>("notificationChannelId")

    if (pushIcon == 0) {
      return returnError(result, call.method, "pushIcon")
    }

    val pushOpt = EMMAPushOptions.Builder(activity::class.java, pushIcon)
            .setNotificationChannelName(channelName)

    if (notificationChannelId == null) {
      pushOpt.setNotificationChannelId(notificationChannelId)
    }

    EMMA.getInstance().startPushSystem(pushOpt.build())
    result.success(null)
  }

  private fun convertNativeAdsToMap(@NonNull nativeAds: List<EMMANativeAd>): ArrayList<Map<String, Any>> {
    val mapNativeAds = arrayListOf<Map<String, Any>>()
    for (nativeAd in nativeAds) {
      val nativeAdMap = EmmaSerializer.nativeAdToMap(nativeAd)
      nativeAdMap?.let {
        mapNativeAds.add(nativeAdMap)
      }
    }
    return mapNativeAds
  }

  private fun sendInAppImpressionOrClick(action: InAppAction, @NonNull call: MethodCall, @NonNull result: Result) {

    val type = call.argument<String>("type")
    val campaignId = call.argument<Int>("campaignId")

    if (type == null || campaignId == null) {
      result.success(null)
      EMMALog.w("inApp type or campaign id cannot be null")
      return
    }

    val campaignType = EmmaSerializer.getInAppRequestTypeFromString(type)
    val communicationType = EmmaSerializer.inAppTypeToCommType(campaignType)

    if (campaignType == null || communicationType == null) {
      result.success(null)
      EMMALog.w("Invalid inapp type or campaign id")
      return
    }

    val campaign = EMMACampaign(campaignType)
    campaign.campaignID = campaignId

    if (action == InAppAction.Impression) {
      EMMA.getInstance().sendInAppImpression(communicationType, campaign)
    } else if (action == InAppAction.Click) {
      EMMA.getInstance().sendInAppClick(communicationType, campaign)
    } else {
      EMMA.getInstance().sendInAppDismissedClick(communicationType, campaign)
    }

    result.success(null)
  }

  private fun openNativeAd(@NonNull call: MethodCall, @NonNull result: Result) {
    val id = call.argument<Int>("id")
    val cta = call.argument<String>("cta")
    val showOn = call.argument<String>("showOn")

    val nativeAd = EMMANativeAd()
    nativeAd.campaignID = id
    nativeAd.campaignUrl = cta
    nativeAd.setShowOn(if (showOn != null && showOn == "browser") 1 else 0)
    EMMA.getInstance().openNativeAd(nativeAd)
    result.success(null)
  }

  private fun processIntentIfNeeded(currentIntent: Intent?) {
    currentIntent?.let {
      val action = it.action
      val extras = it.extras
      if (action != null && action == "android.intent.action.VIEW" && extras != null) {
        if (it.data != null ) {
          Utils.executeOnMainThread(channel, "Emma#onDeepLinkReceived", it.data.toString())
        }
      }
    }
  }

  private fun checkForRichPush(@NonNull result: Result) {
    EMMA.getInstance().checkForRichPushUrl()
    result.success(null)
  }

  private fun startOrder(@NonNull call: MethodCall, @NonNull result: Result) {
    val orderId = call.argument<String>("orderId")
    val totalPrice = call.argument<Double>("totalPrice")
    val customerId = call.argument<String>("customerId")
    val coupon = call.argument<String>("coupon")
    val extras = call.argument<HashMap<String, String>>("extras")

    if (!Utils.isValidField(orderId)) {
      EMMALog.e("Param orderId must be mandatory in startOrder method")
      result.success(null)
      return
    }

    if (!Utils.isValidField(totalPrice)) {
      EMMALog.e("Param totalPrice must be mandatory in startOrder method")
      result.success(null)
      return
    }

    if (!Utils.isValidField(customerId)) {
      EMMALog.e("Param customerId must be mandatory in startOrder method")
      result.success(null)
      return
    }

    EMMA.getInstance().startOrder(orderId, customerId, totalPrice!!.toFloat(), coupon, extras)
    result.success(null)
  }

  private fun addProduct(@NonNull call: MethodCall, @NonNull result: Result) {
    val productId = call.argument<String>("productId")
    val productName = call.argument<String>("productName")
    val quantity = call.argument<Int>("quantity")
    val price = call.argument<Double>("price")
    val extras = call.argument<HashMap<String, String>>("extras")

    if (!Utils.isValidField(productId)) {
      EMMALog.e("Param productId must be mandatory in addProduct method")
      result.success(null)
      return
    }

    if (!Utils.isValidField(productName)) {
      EMMALog.e("Param productName must be mandatory in addProduct method")
      result.success(null)
      return
    }

    if (!Utils.isValidField(quantity)) {
      EMMALog.e("Param quantity must be mandatory in addProduct method")
      result.success(null)
      return
    }

    if (!Utils.isValidField(price)) {
      EMMALog.e("Param price must be mandatory in addProduct method")
      result.success(null)
      return
    }

    EMMA.getInstance().addProduct(productId, productName, quantity!!.toFloat(), price!!.toFloat(), extras)
    result.success(null)
  }

  private fun trackOrder(@NonNull result: Result) {
    EMMA.getInstance().trackOrder()
    result.success(null)
  }

  private fun cancelOrder(@NonNull call: MethodCall, @NonNull result: Result) {
    val orderId = call.argument<String>("orderId")

    if (!Utils.isValidField(orderId)) {
      EMMALog.e("Param orderId must be mandatory in cancelOrder method")
      result.success(null)
      return
    }

    EMMA.getInstance().cancelOrder(orderId)
    result.success(null)
  }

  private fun trackLocation(@NonNull result: Result) {
    activity.let {
      EMMA.getInstance().setCurrentActivity(it)
    }
    Utils.runOnMainThread(Runnable {
      EMMA.getInstance().startTrackingLocation()
    })
    result.success(null)
  }

  private fun setCustomerId(@NonNull call: MethodCall, @NonNull result: Result) {
    val customerId = call.argument<String>("customerId")
    if (!Utils.isValidField(customerId)) {
      EMMALog.e("Param customerId must be mandatory in setCustomerId method")
      result.success(null)
      return
    }
    EMMA.getInstance().setCustomerId(customerId);
    result.success(null)
  }

  private fun setUserLanguage(@NonNull call: MethodCall, @NonNull result: Result) {
    val language = call.argument<String>("language")
    if (!Utils.isValidField(language)) {
      EMMALog.e("Param language must be mandatory in setUserLanguage method")
      result.success(null)
      return
    }
    EMMA.getInstance().setUserLanguage(language);
    result.success(null)
  }
  
  private fun areNotificationsEnabled(@NonNull result: Result) {
      result.success(EMMA.getInstance().areNotificationsEnabled())
  }

  private fun requestNotificationPermission(@NonNull call: MethodCall, @NonNull result: Result) {
      if (Build.VERSION.SDK_INT < 33 || EMMAUtils.getTargetSdkVersion(applicationContext) < 33) {
        Utils.executeOnMainThread(channel, "Emma#onPermissionStatus", PermissionStatus.Unsupported.ordinal)
        return
      }

      val permissionListener = object: EMMAPermissionInterface {
          override fun onPermissionGranted(permission: String, isFirstTime: Boolean) {
            Utils.executeOnMainThread(channel, "Emma#onPermissionStatus", PermissionStatus.Granted.ordinal)
          }

          override fun onPermissionDenied(permission: String) {
            Utils.executeOnMainThread(channel, "Emma#onPermissionStatus", PermissionStatus.Denied.ordinal)
          }

          override fun onPermissionWaitingForAction(permission: String) { }

          override fun onPermissionShouldShowRequestPermissionRationale(permission: String) {
            Utils.executeOnMainThread(channel, "Emma#onPermissionStatus", PermissionStatus.ShouldPermissionRationale.ordinal)
          }
      }

      Utils.runOnMainThread {
          EMMA.getInstance().setCurrentActivity(activity);
          EMMA.getInstance().requestNotificationPermission(permissionListener)
      }
      result.success(null)    
  }

  private fun handleLink(@NonNull call: MethodCall, @NonNull result: Result) {
    val url = call.argument<String>("url")
    if (!Utils.isValidField(url)) {
      EMMALog.e("Param url must be mandatory in handleLink method")
      result.success(null)
      return
    }
    EMMA.handleLink(applicationContext, Uri.parse(url))
    result.success(null)
  }

  override fun onNewIntent(intent: Intent): Boolean {
    EMMA.getInstance().onNewNotification(intent, true)
    processIntentIfNeeded(intent)
    return true
  }

  private fun isUserTrackingEnabled(@NonNull result: Result) {
    result.success(EMMA.getInstance().isUserTrackingEnabled)
  }

  private fun enableUserTracking(@NonNull result: Result) {
    EMMA.getInstance().enableUserTracking()
    result.success(null)
  }
    
  private fun disableUserTracking(@NonNull call: MethodCall, @NonNull result: Result) {
    val deleteUser = call.argument<Boolean>("deleteUser") ?: false
    EMMA.getInstance().disableUserTracking(deleteUser)
    result.success(null)
  }
}
