import 'package:flutter/material.dart';
import 'package:sivi/conversation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:sivi/dashboard.dart';


void main() {
  runApp(DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo Home Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Dashboard()
    );
  }
}
