import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:emma_flutter_sdk/emma_flutter_sdk.dart';

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
    initEMMA();
  }

  Future<void> initEMMA() async {
    try {
      await EmmaFlutterSdk.startSession('emmaflutter2BMRb2NQ0',
          debugEnabled: true);

      await EmmaFlutterSdk.trackExtraUserInfo({'TEST_TAG': 'TEST VALUE'});
    } on PlatformException catch (err) {
      print("Error starting EMMA session: " + err.message);
    }

    setState(() {});
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await EmmaFlutterSdk.getEMMAVersion();
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('EMMA FLUTTER SAMPLE APP'),
        ),
        body: Center(
            child: Column(children: <Widget>[
          RaisedButton(
            onPressed: () async {
              await EmmaFlutterSdk.trackEvent(
                  "2eb78caf404373625020285e92df446b");
            },
            child:
                const Text('Send Test Event', style: TextStyle(fontSize: 20)),
          ),
        ])),
      ),
    );
  }
}