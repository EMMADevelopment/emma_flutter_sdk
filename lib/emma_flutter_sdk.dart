import 'dart:async';

import 'package:emma_flutter_sdk/src/defines.dart';
import 'package:emma_flutter_sdk/src/inapp_message_request.dart';
import 'package:emma_flutter_sdk/src/native_ad.dart';
import 'package:emma_flutter_sdk/src/order.dart';
import 'package:emma_flutter_sdk/src/product.dart';
import 'package:emma_flutter_sdk/src/start_session.dart';
import 'package:flutter/services.dart';

export 'src/defines.dart';
export 'src/inapp_message_request.dart';
export 'src/native_ad.dart';
export 'src/order.dart';
export 'src/product.dart';

typedef void ReceivedNativeAdsHandler(List<EmmaNativeAd> nativeAds);
typedef void PermissionStatusHandler(PermissionStatus status);
typedef void DeepLinkHandler(String url);

class EmmaFlutterSdk {
  static EmmaFlutterSdk shared = new EmmaFlutterSdk();

  // method channels
  MethodChannel _channel = const MethodChannel('emma_flutter_sdk');

  // event handlers
  ReceivedNativeAdsHandler? _onReceivedNativeAds;
  PermissionStatusHandler? _onPermissionStatus;
  DeepLinkHandler? _deepLinkHandler;

  String? _pendingDeepLink;

  EmmaFlutterSdk() {
    this._channel.setMethodCallHandler(_manageCallHandler);
  }

  Future<Null> _manageCallHandler(MethodCall call) async {
    if (call.method == "Emma#onReceivedNativeAds" &&
        this._onReceivedNativeAds != null) {
      List<dynamic> nativeAdsMap = call.arguments;
      this._onReceivedNativeAds!(nativeAdsMap
          .map((nativeAdMap) =>
              new EmmaNativeAd.fromMap(nativeAdMap.cast<String, dynamic>()))
          .toList());
    } else if (call.method == "Emma#onPermissionStatus" &&
        this._onPermissionStatus != null) {
      int permissionStatusIndex = call.arguments;
      this._onPermissionStatus!(PermissionStatus.values[permissionStatusIndex]);
    } else if (call.method == "Emma#onDeepLinkReceived") {
      String deeplink = call.arguments;
      if (this._deepLinkHandler != null) {
        this._deepLinkHandler!(deeplink);
      } else {
        this._pendingDeepLink = deeplink;
      }
    }
    return null;
  }

  void setReceivedNativeAdsHandler(ReceivedNativeAdsHandler handler) =>
      _onReceivedNativeAds = handler;

  void setPermissionStatusHandler(PermissionStatusHandler handler) =>
      _onPermissionStatus = handler;

  void setDeepLinkHandler(DeepLinkHandler deepLinkHandler) {
    this._deepLinkHandler = deepLinkHandler;
    String? pendignDeepLink = this._pendingDeepLink;
    if (_pendingDeepLink != null) {
      this._deepLinkHandler!(pendignDeepLink!);
      this._pendingDeepLink = null;
    }
  }

  /// Retrieves current EMMA SDK Version
  Future<String> getEMMAVersion() async {
    final String version = await _channel.invokeMethod('getEMMAVersion');
    return version;
  }

  /// Starts EMMA Session with a [sessionKey].
  ///
  /// You can use [debugEnabled] to enable logging on your device.
  /// This log is only visible on device consoles
  Future<void> startSession(StartSession params) async {
    print(params.toMap());
    return await _channel.invokeMethod('startSession', params.toMap());
  }


  /// Send an event to emma identified by [eventToken].
  /// You can also assign some attributtes to this event with [eventArguments]
  Future<void> trackEvent(String eventToken,
      {Map<String, String>? eventAttributes}) async {
    return await _channel.invokeMethod('trackEvent',
        {'eventToken': eventToken, 'eventAttributes': eventAttributes});
  }

  /// You can complete user profile with extra parameters
  Future<void> trackExtraUserInfo(Map<String, String> extraUserInfo) async {
    return await _channel
        .invokeMethod('trackExtraUserInfo', {'extraUserInfo': extraUserInfo});
  }

  /// Sends a login to EMMA
  /// [userId] is your customer id for this user
  /// [email] is a unique email of this user
  Future<void> loginUser(String userId, String email) async {
    return await _channel
        .invokeMethod('loginUser', {'userId': userId, 'email': email});
  }

  /// Sends register event to EMMA
  /// [userId] is your customer id for this user
  /// [email] is a unique email of this user
  Future<void> registerUser(String userId, String email) async {
    return await _channel
        .invokeMethod('registerUser', {'userId': userId, 'email': email});
  }

  /// Checks for an InApp Message
  /// You must pass [EmmaInAppMessageRequest] of message you're expecting
  Future<void> inAppMessage(EmmaInAppMessageRequest request) async {
    return await _channel.invokeMethod('inAppMessage', request.toMap());
  }

  /// Init EMMA Push system
  /// You must define [notificationIcon] for Android OS
  /// Optional param [notificationChannel] to define notification channel name for Android OS. Default app name.
  /// Optional param [notificationChannelId] to subscribe an existent channel.
  Future<void> startPushSystem(String notificationIcon,
      {String? notificationChannel, String? notificationChannelId}) async {
    return await _channel.invokeMethod('startPushSystem', {
      'notificationIcon': notificationIcon,
      'notificationChannel': notificationChannel,
      'notificationChannelId': notificationChannelId
    });
  }

  /// Sends impression associated with inapp campaign. This method is mainly used to send native Ad impressions.
  /// Formats startview, banner, adball send impression automatically
  /// [campaignId] The campaign identifier
  Future<void> sendInAppImpression(InAppType inAppType, int campaignId) async {
    String type = inAppType.toString().split(".")[1];
    return await _channel.invokeMethod(
        'sendInAppImpression', {"type": type, "campaignId": campaignId});
  }

  /// Sends click associated with inapp campaign. This method is mainly used to send native ad clicks.
  /// Formats startview, banner, adball send click automatically
  /// [campaignId] The campaign identifier
  Future<void> sendInAppClick(InAppType inAppType, int campaignId) async {
    String type = inAppType.toString().split(".")[1];
    return await _channel.invokeMethod(
        'sendInAppClick', {"type": type, "campaignId": campaignId});
  }

  /// Opens native ad CTA inapp or outapp. This method track native ad click automatically. It is not necessary call to sendInAppClick method.
  /// [nativeAd] The native ad
  Future<void> openNativeAd(EmmaNativeAd nativeAd) async {
    return await _channel.invokeMethod('openNativeAd', nativeAd.toMap());
  }

  /// [Android Only] Checks if rich push is available after push is opened.
  /// This method can be called anywhere in app.
  Future<void> checkForRichPush() async {
    return await _channel.invokeMethod('checkForRichPush');
  }

  /// This method starts the order and save it.
  Future<void> startOrder(EmmaOrder order) async {
    return await _channel.invokeMethod('startOrder', order.toMap());
  }

  /// This method adds one product to the initied order. If you want add multiple
  /// products, you call this method multiples times.
  Future<void> addProduct(EmmaProduct product) async {
    return await _channel.invokeMethod('addProduct', product.toMap());
  }

  /// This method commits the order and send to server.
  Future<void> trackOrder() async {
    return await _channel.invokeMethod('trackOrder');
  }

  /// This method cancel order previously added.
  Future<void> cancelOrder(String orderId) async {
    return await _channel.invokeMethod('cancelOrder', orderId);
  }

  /// [iOS only] This method requests the permission to collect the IDFA.
  Future<void> requestTrackingWithIdfa() async {
    return await _channel.invokeMethod('requestTrackingWithIdfa');
  }

  /// This method allows track location
  Future<void> trackUserLocation() async {
    return await _channel.invokeMethod('trackUserLocation');
  }

  /// This method sends the customerId without using an event.
  Future<void> setCustomerId(String customerId) async {
    return await _channel.invokeMethod('setCustomerId', customerId);
  }

  /// [Android only] This method returns if devices can receive notifications or not.
  Future<bool> areNotificationsEnabled() async {
    return await _channel.invokeMethod('areNotificationsEnabled');
  }

  /// [Android only] This method requests notifications permission on Android 13 or higher devices.
  Future<void> requestNotificationsPermission() async {
    return await _channel.invokeMethod('requestNotificationsPermission');
  }

  // This method processes EMMA powlinks and send click event.
  Future<void> handleLink(String url) async {
    return await _channel.invokeMethod('handleLink', url);
  }

  // GDPR

  // Activates/reactivates user tracking (token, user properties)
  Future<void> enableUserTracking() async {
    return await _channel.invokeMethod('enableUserTracking');
  }

  // Disables user tracking related methods.
  Future<void> disableUserTracking(bool deleteUser) async {
    return await _channel.invokeMethod('disableUserTracking', deleteUser);
  }

  // Checks if user tracking is enabled or disabled.
  Future<bool> isUserTrackingEnabled() async {
    return await _channel.invokeMethod('isUserTrackingEnabled');
  }
}
