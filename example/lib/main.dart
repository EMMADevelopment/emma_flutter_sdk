import 'dart:async';
import 'dart:io' show Platform;

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
                      Title(title: "Deeplink", log: "No deeplink"),
                      Text("Received deeplink will be displayed here."),
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
                        isFirstClick: true,
                        onPressed: () async {
                          await EmmaFlutterSdk.shared
                              .registerUser("1", "emma@flutter.dev");
                        },
                      ),
                      Title(title: "Log in User", log: ""),
                      CustomButton(
                        text: "Log in User",
                        isFirstClick: true,
                        onPressed: () async {
                          await EmmaFlutterSdk.shared
                              .loginUser("1", "emma@flutter.dev");
                        },
                      ),
                      Title(title: "Events and Extras", log: ""),
                      Text("These buttons do not have UI feedback"),
                      CustomButton(
                        text: "Track event",
                        onPressed: () {},
                      ),
                      CustomButton(
                        text: "Add user tag 'TAG'",
                        onPressed: () {},
                      ),
                      Title(title: "In-App Comunication", log: ""),
                      Text("Try our in-app comunications:"),
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
                            var request =
                                new EmmaInAppMessageRequest(InAppType.nativeAd);
                            request.batch = true;
                            request.templateId = "template1";
                            await EmmaFlutterSdk.shared.inAppMessage(request);
                          }),
                      Title(title: "Orders and Products", log: ""),
                      Text("Track your orders."),
                      CustomButton(
                          text: "Start Order",
                          onPressed: () async {
                            var order = new EmmaOrder("EMMA", 100, "1");
                            await EmmaFlutterSdk.shared.startOrder(order);
                            var product = new EmmaProduct('SDK', 'SDK', 1, 100);
                            await EmmaFlutterSdk.shared.addProduct(product);
                            await EmmaFlutterSdk.shared.trackOrder();
                          }),
                      Title(title: "IDFA and iOS", log: ""),
                      Text("Request tracking with IDFA for iOS devices"),
                      CustomButton(
                          text: "Request IDFA Tracking",
                          onPressed: () async {
                            await EmmaFlutterSdk.shared
                                .requestTrackingWithIdfa();
                          }),
                      Title(title: "Track Location ", log: ""),
                      Text("Turn on Location Services"),
                      CustomButton(
                          text: "Track Location",
                          onPressed: () async {
                            await EmmaFlutterSdk.shared.trackUserLocation();
                          }),
                      Title(title: "Notifications Permission", log: ""),
                      Text("Android Only"),
                      CustomButton(
                          text: "ACTIVATE",
                          onPressed: () async {
                            if (Platform.isAndroid) {
                              EmmaFlutterSdk.shared
                                  .setPermissionStatusHandler((status) {
                                print('Notifications permission status: ' +
                                    status.toString());
                              });
                              await EmmaFlutterSdk.shared
                                  .requestNotificationsPermission();
                            }
                          }),
                      //LEARN MORE
                      Title(title: "Learn More", log: ""),
                      Text("Read the docs to discover what to do next:"),
                      infoSection(
                        title: "EMMA SDK",
                        description: "Documentation & Support",
                        url: "https://developer.emma.io/es/home",
                      ),
                      infoSection(
                        title: "iOS",
                        description: "EMMA SDK for iOS",
                        url: "https://github.com/EMMADevelopment/eMMa-iOS-SDK",
                      ),
                      infoSection(
                        title: "Android",
                        description: "EMMA SDK for Android",
                        url:
                            "https://github.com/EMMADevelopment/EMMA-Android-SDK",
                      ),
                      infoSection(
                        title: "Cordova",
                        description: "EMMA SDK for Cordova",
                        url:
                            "https://github.com/EMMADevelopment/Cordova-Plugin-EMMA-SDK",
                      ),
                      infoSection(
                        title: "Ionic",
                        description: "EMMA SDK for Ionic",
                        url:
                            "https://github.com/EMMADevelopment/EMMAIonicExample",
                      ),
                      infoSection(
                        title: "Flutter",
                        description: "EMMA SDK for Flutter",
                        url:
                            "https://github.com/EMMADevelopment/emma_flutter_sdk",
                      ),
                      infoSection(
                        title: "Xamarin",
                        description: "EMMA SDK for Xamarin",
                        url:
                            "https://github.com/EMMADevelopment/EMMA-Xamarin-SDK",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
          /*
            Column(children: <Widget>[
              Container(
                height: 200.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  
                  color: Colors.green,
                  image: DecorationImage(
                    image: AssetImage("../example/images/logo.png"),
                    
                    fit: BoxFit.fill
                  )
                ),
              ),
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
            ])),*/
          ),
    );
  }
}

class infoSection extends StatelessWidget {
  final String title;
  final String description;
  final String url;
  const infoSection({
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
  final bool isDisabled;
  final bool isFirstClick;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isDisabled = false,
    this.isFirstClick = false,
  }) : super(key: key);

  @override
  CustomButtonState createState() => CustomButtonState();
}

class CustomButtonState extends State<CustomButton> {
  bool isButtonEnabled = true;

  @override
  void initState() {
    super.initState();
    if (widget.isDisabled) {
      isButtonEnabled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: isButtonEnabled
                ? () {
                    setState(() {
                      !widget.isFirstClick ? () {} : isButtonEnabled = false;
                    });
                    widget.onPressed();
                  }
                : null,
            child: Text(
              widget.text.toUpperCase(),
              style:
                  TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isButtonEnabled ? Color(0xff00a263) : Colors.green[200],
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

//Utils
_launchURL(stringUrl) async {
  final Uri url = Uri.parse(stringUrl);
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
