import 'dart:async';
import 'dart:io';

import 'package:emma_flutter_sdk/src/start_session.dart';
import 'package:emma_flutter_sdk/emma_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String platformVersion = 'Unknown';
  // Add the following line
  String? deeplink;

  final GlobalKey<CustomButtonState> startOrderKey =
      GlobalKey<CustomButtonState>();
  final GlobalKey<CustomButtonState> addProductKey =
      GlobalKey<CustomButtonState>();
  final GlobalKey<CustomButtonState> trackOrderKey =
      GlobalKey<CustomButtonState>();
  final GlobalKey<CustomButtonState> cancelOrderKey =
      GlobalKey<CustomButtonState>();

  final startSessionParams = StartSession(
    sessionKey: 'emmaflutter2BMRb2NQ0',
    queueTime: 10,
    isDebug: true,
    customShortPowlinkDomains: ["emma.shortLink.mycompany.com"],
    customPowlinkDomains: ["emma.link.mycompany.com"],
    trackScreenEvents: false,
    familiesPolicyTreatment: (Platform.isAndroid) ? true : false,
  );

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initEMMA()
        .then((value) => initEMMAPush())
        .then((value) => trackUserProfile());
  }

  Future<void> initEMMA() async {
    await EmmaFlutterSdk.shared.startSession(startSessionParams);

    EmmaFlutterSdk.shared
        .setReceivedNativeAdsHandler((List<EmmaNativeAd> nativeAds) {
      nativeAds.forEach((nativeAd) {
        print(nativeAd.toMap());
      });
    });

    EmmaFlutterSdk.shared.setDeepLinkHandler((url) {
      this.deeplink = url;
      print(url);
    });
  }

  Future<void> initEMMAPush() async {
    if (Platform.isAndroid) {
      EmmaFlutterSdk.shared.setPermissionStatusHandler((status) {
        print('Notifications permission status: ' + status.toString());
      });
      await EmmaFlutterSdk.shared.requestNotificationsPermission();
    }

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
      platformVersion = platformVersion;
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
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: const Text(
              'WELCOME TO EMMA',
              style:
                  TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
            ),
            backgroundColor: Color(0xff00a263),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //margin: const EdgeInsets.only(left: 15.0, right: 15.0),
              children: [
                Image(image: AssetImage('images/logo-01.png')),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Title(
                          title: "Deeplink",
                          log: this.deeplink == null
                              ? "No deeplink"
                              : "Deeplink received"),
                      Text(this.deeplink ??
                          "Received deeplink will be displayed here."),
                      Title(title: "Session", log: "Session started"),
                      Text(
                          "Session is required. Usually, it should be triggered when the App is ready."),
                      CustomButton(
                        text: "Start Session",
                        onPressed: () {},
                        isDisabled: true,
                      ),
                      Title(title: "Register User", log: ""),
                      CustomButton(
                        text: "Register User",
                        onPressed: () async {
                          await EmmaFlutterSdk.shared
                              .registerUser("flutteruser", "emma@flutter.dev");
                        },
                      ),
                      Title(title: "Log in User", log: ""),
                      CustomButton(
                        text: "Log in User",
                        onPressed: () async {
                          await EmmaFlutterSdk.shared
                              .loginUser("flutteruser", "emma@flutter.dev");
                        },
                      ),
                      Title(title: "Events and Extras", log: ""),
                      Text("These buttons do not have UI feedback"),
                      CustomButton(
                        text: "Track event",
                        onPressed: () async {
                          await EmmaFlutterSdk.shared.trackEvent(
                              "2eb78caf404373625020285e92df446b",
                              eventAttributes: {"attribute1": "value1"});
                        },
                      ),
                      CustomButton(
                        text: "Add user tag 'TAG'",
                        onPressed: () async {
                          await EmmaFlutterSdk.shared
                              .trackExtraUserInfo({"TAG": "VALUE"});
                        },
                      ),
                      Title(title: "In-App Comunication", log: ""),
                      Text("Try our in-app comunications:"),
                      Table(
                        children: [
                          TableRow(children: [
                            CustomButton(
                                text: "Check for StarView",
                                onPressed: () async {
                                  await EmmaFlutterSdk.shared.inAppMessage(
                                      new EmmaInAppMessageRequest(
                                          InAppType.startview));
                                }),
                            CustomButton(
                                text: "Check for NativeAd",
                                onPressed: () async {
                                  var request = new EmmaInAppMessageRequest(
                                      InAppType.nativeAd);
                                  request.batch = true;
                                  request.templateId = "template1";
                                  await EmmaFlutterSdk.shared
                                      .inAppMessage(request);
                                }),
                          ]),
                          TableRow(children: [
                            CustomButton(
                              text: "Check for Adball",
                              onPressed: () async {
                                var request = new EmmaInAppMessageRequest(
                                    InAppType.adBall);
                                await EmmaFlutterSdk.shared
                                    .inAppMessage(request);
                              },
                            ),
                            CustomButton(
                              text: "Check for Strip",
                              onPressed: () async {
                                var request = new EmmaInAppMessageRequest(
                                    InAppType.strip);
                                await EmmaFlutterSdk.shared
                                    .inAppMessage(request);
                              },
                            ),
                          ]),
                        ],
                      ),
                      (Platform.isAndroid)
                          ? CustomButton(
                              text: "Check for Banner",
                              onPressed: () async {
                                var request = new EmmaInAppMessageRequest(
                                    InAppType.banner);
                                await EmmaFlutterSdk.shared
                                    .inAppMessage(request);
                              })
                          : Container(),
                      Title(title: "Orders and Products", log: ""),
                      Text("Track your orders."),
                      Table(
                        children: [
                          TableRow(children: [
                            CustomButton(
                              key: startOrderKey,
                              text: "Start Order",
                              isDisabled: false,
                              onPressed: () async {
                                var order =
                                    new EmmaOrder("EMMA", 100, "flutteruser");
                                await EmmaFlutterSdk.shared.startOrder(order);
                                setState(() {
                                  startOrderKey.currentState?.setEnabled(false);
                                  addProductKey.currentState?.setEnabled(true);
                                  trackOrderKey.currentState?.setEnabled(true);
                                  cancelOrderKey.currentState
                                      ?.setEnabled(false);
                                });
                              },
                            ),
                            CustomButton(
                              key: addProductKey,
                              text: "Add Product",
                              isDisabled: true,
                              onPressed: () async {
                                var product =
                                    new EmmaProduct('SDK', 'SDK', 1, 100);
                                await EmmaFlutterSdk.shared.addProduct(product);
                                setState(() {
                                  startOrderKey.currentState?.setEnabled(false);
                                  addProductKey.currentState?.setEnabled(false);
                                  trackOrderKey.currentState?.setEnabled(true);
                                  cancelOrderKey.currentState
                                      ?.setEnabled(false);
                                });
                              },
                            ),
                          ]),
                          TableRow(children: [
                            CustomButton(
                              key: trackOrderKey,
                              text: "Track Order",
                              isDisabled: true,
                              onPressed: () async {
                                await EmmaFlutterSdk.shared.trackOrder();
                                setState(() {
                                  trackOrderKey.currentState?.setEnabled(false);
                                  cancelOrderKey.currentState?.setEnabled(true);
                                });
                              },
                            ),
                            CustomButton(
                              key: cancelOrderKey,
                              text: "Cancel Order",
                              isDisabled: true,
                              onPressed: () async {
                                EmmaFlutterSdk.shared.cancelOrder("EMMA");
                                setState(() {
                                  startOrderKey.currentState?.setEnabled(true);
                                  addProductKey.currentState?.setEnabled(false);
                                  trackOrderKey.currentState?.setEnabled(false);
                                  cancelOrderKey.currentState
                                      ?.setEnabled(false);
                                });
                              },
                            ),
                          ])
                        ],
                      ),
                      Platform.isIOS
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Title(title: "IDFA and iOS", log: ""),
                                Text(
                                    "Request tracking with IDFA for iOS devices"),
                                CustomButton(
                                  text: "Request IDFA Tracking",
                                  onPressed: () async {
                                    await EmmaFlutterSdk.shared
                                        .requestTrackingWithIdfa();
                                  },
                                )
                              ],
                            )
                          : Container(),
                      Title(title: "Track Location ", log: ""),
                      CustomButton(
                        text: "Track Location",
                        onPressed: () async {
                          await EmmaFlutterSdk.shared.trackUserLocation();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class InfoSection extends StatelessWidget {
  final String title;
  final String description;
  final String url;
  const InfoSection({
    Key? key,
    required this.title,
    required this.description,
    required this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Divider(),
          InkWell(
            onTap: () {
              _launchURL(this.url);
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        this.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(
                            0xff00a263,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [Text(this.description)],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool? isDisabled;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isDisabled,
  }) : super(key: key);

  @override
  CustomButtonState createState() => CustomButtonState();
}

class CustomButtonState extends State<CustomButton> {
  bool isButtonEnabled = true;

  @override
  void initState() {
    super.initState();
    isButtonEnabled = !(widget.isDisabled ?? false);
  }

  void setEnabled(bool enabled) {
    setState(() {
      isButtonEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: isButtonEnabled ? widget.onPressed : null,
            child: Text(
              widget.text.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isButtonEnabled ? Color(0xff00a263) : Colors.grey,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0)),
            ),
          ),
        ],
      ),
    );
  }
}

class Title extends StatelessWidget {
  final String title;
  final String log;

  const Title({
    Key? key,
    required this.title,
    required this.log,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            this.title,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22.0),
          ),
          Text(this.log)
        ],
      ),
    );
  }
}

// Utils
_launchURL(stringUrl) async {
  final Uri url = Uri.parse(stringUrl);
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
