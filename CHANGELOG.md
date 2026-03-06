# Changelog
## 1.7.0
- Update native SDK dependencies: 4.16.0 for iOS and 4.16.+ for Android.
- Add new method setEmail to set user email.
- Add new method setUserProfile to set customerId, email and tags in a single call.
- Add new method trackUserTags to track user tags.
- Add new method trackPurchase to track purchases with products in a single call.
- Add new method unregisterPushSystem to unregister from push notifications.
- Add new model EmmaPurchaseProduct.
- Add new model EmmaPurchaseRequest for the trackPurchase method.
- Deprecate trackExtraUserInfo method.
- Deprecate startOrder, addProduct and trackOrder methods.
- Remove cancelOrder method.

## 1.6.4
- Update native sdk dependencies: 4.15.7 for Android and 4.15.6 for iOS.
- Fix iOS push notification presentation options to support banner and list on iOS 14+.
- Fix iOS push notification handling to prevent duplicate processing on app launch.

## 1.6.3
- Update iOS SDK dependency to version 4.15.5.
- Fix notificationChannelId only being set when it is not null on Android.

## 1.6.2
- Fixed startSession callback handling on Android.
- Fixed permission request resolution for Android < 13.

## 1.6.1
- Update native sdk dependencies: added new setUserLanguage method that allows users to manually set the language instead of relying on auto-detection.
- Fix cancelOrder, setCustomerId, handleLink and disableUserTracking.

## 1.6.0
- Updated startSession method to include configuration options.
- Added AdBall InApp Message.
- Added Strip InApp Message.
- Added Banner InApp Message (currently only on Android).

## 1.5.0
- Added native version SDK 4.14
- Added inapp dismissed click.
- Updated AGP to v8

## 1.4.0
- Added native version SDK 4.13 and iOS SDK Privacy Manifest and signature.

## 1.3.2
- Fix changed named trackEvent parameter eventArgument to eventAttributes.

## 1.3.1
- Added GDPR methods and fix cancelOrder.

## 1.3.0
- Flutter compatibility with null safety and powlink support.

## 1.2.0
- Update native sdk dependencies and added Android 13 support.

## 1.1.2

- Fix crash version SDK 4.10.0 y 4.10.1 when app started and recover ASA attribution.

## 1.1.1
* Updated SDKs to version 4.10.+

## 1.1.0

* Added purchase methods, track location and request tracking IDFA (iOS)

## 1.0.9

* Added new method checkForRichPush for Android

## 1.0.8

* Added new methods sendInAppImpression and sendInAppClick to send impression or/and click for nativeAd
* Added new method openNativeAd to execute CTA action (open webview on browser or inapp)

## 1.0.7

* Update native dependency to latest version 4.8.0

## 1.0.6

* Inapp message native ad
* Fixes and improves

## 1.0.5

* Send push open
* Rich push support

## 1.0.4

* Fix missing results on iOS plugin
* Start Push System

## 1.0.3

* Login default event
* Register default event
* StartView InApp Message

## 1.0.2

* Update User Profile

## 1.0.1

* Event Tracking

## 1.0.0

* Session Tracking
