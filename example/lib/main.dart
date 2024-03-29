import 'dart:async';
import 'dart:io' show Platform;

import 'package:emma_flutter_sdk/emma_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initEMMA()
        .then((value) => initEMMAPush())
        .then((value) => trackUserProfile());
  }

  Future<void> initEMMA() async {
    await EmmaFlutterSdk.shared
        .startSession('emmaflutter2BMRb2NQ0', debugEnabled: true);

    EmmaFlutterSdk.shared
        .setReceivedNativeAdsHandler((List<EmmaNativeAd> nativeAds) {
      nativeAds.forEach((nativeAd) {
        print(nativeAd.toMap());
      });
    });

    EmmaFlutterSdk.shared.setDeepLinkHandler((url) {
      print(url);
    });
  }

  Future<void> initEMMAPush() async {
    return await EmmaFlutterSdk.shared.startPushSystem('icimage');
  }

  Future<void> trackUserProfile() async {
    return await EmmaFlutterSdk.shared
        .trackExtraUserInfo({'TEST_TAG': 'TEST VALUE'});
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await EmmaFlutterSdk.shared.getEMMAVersion();
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> sendNativeAdImpression(EmmaNativeAd nativeAd) async {
    return await EmmaFlutterSdk.shared
        .sendInAppImpression(InAppType.nativeAd, nativeAd.id);
  }

  Future<void> sendNativeAdClick(EmmaNativeAd nativeAd) async {
    return await EmmaFlutterSdk.shared
        .sendInAppClick(InAppType.nativeAd, nativeAd.id);
  }

  Future<void> openNativeAd(EmmaNativeAd nativeAd) async {
    return await EmmaFlutterSdk.shared.openNativeAd(nativeAd);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('EMMA FLUTTER SAMPLE APP'),
        ),
        body: Container(
            margin: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Column(children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                onPressed: () async {
                  await EmmaFlutterSdk.shared.trackEvent(
                      "2eb78caf404373625020285e92df446b",
                      eventAttributes: {"attribute1": "value1"});
                },
                child: const Text('Send Test Event',
                    style: TextStyle(fontSize: 20)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                onPressed: () async {
                  await EmmaFlutterSdk.shared
                      .loginUser("1", "emma@flutter.dev");
                },
                child: const Text('Send Login Event',
                    style: TextStyle(fontSize: 20)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                onPressed: () async {
                  await EmmaFlutterSdk.shared
                      .registerUser("1", "emma@flutter.dev");
                },
                child: const Text('Send Register Event',
                    style: TextStyle(fontSize: 20)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                onPressed: () async {
                  var order = new EmmaOrder("EMMA", 100, "1");
                  await EmmaFlutterSdk.shared.startOrder(order);
                  var product = new EmmaProduct('SDK', 'SDK', 1, 100);
                  await EmmaFlutterSdk.shared.addProduct(product);
                  await EmmaFlutterSdk.shared.trackOrder();
                },
                child: const Text('Send Order', style: TextStyle(fontSize: 20)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                onPressed: () async {
                  await EmmaFlutterSdk.shared.inAppMessage(
                      new EmmaInAppMessageRequest(InAppType.startview));
                },
                child: const Text('Check For StartView',
                    style: TextStyle(fontSize: 20)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                onPressed: () async {
                  var request = new EmmaInAppMessageRequest(InAppType.nativeAd);
                  request.batch = true;
                  request.templateId = "template1";
                  await EmmaFlutterSdk.shared.inAppMessage(request);
                },
                child: const Text('Check For NativeAd',
                    style: TextStyle(fontSize: 20)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                onPressed: () async {
                  await EmmaFlutterSdk.shared.checkForRichPush();
                },
                child: const Text('Check For Rich Push (Android only)',
                    style: TextStyle(fontSize: 20)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                onPressed: () async {
                  await EmmaFlutterSdk.shared.requestTrackingWithIdfa();
                },
                child: const Text('Track IDFA (iOS only)',
                    style: TextStyle(fontSize: 20)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                onPressed: () async {
                  await EmmaFlutterSdk.shared.trackUserLocation();
                },
                child: const Text('Track Location',
                    style: TextStyle(fontSize: 20)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                onPressed: () async {
                  if (Platform.isAndroid) {
                    // Request notification permission for Android 13
                    EmmaFlutterSdk.shared.setPermissionStatusHandler((status) {
                      print('Notifications permission status: ' +
                          status.toString());
                    });
                    await EmmaFlutterSdk.shared
                        .requestNotificationsPermission();
                  }
                },
                child: const Text('Notifications Permission (Android only)',
                    style: TextStyle(fontSize: 20)),
              ),
            ])),
      ),
    );
  }
}
