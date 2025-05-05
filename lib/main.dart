import 'package:flutter/material.dart';
import 'package:owl/pages/battery/screen/powerbattery.dart';
import 'package:owl/pages/port/screen/ports.dart';
import 'package:owl/pages/navigation/screen/navigation.dart';
import 'package:owl/pages/setup/screen/setup.dart';
import 'package:owl/pages/configuration/screen/configuration.dart';
import 'package:owl/pages/servo/screen/servo.dart';
import 'package:owl/pages/motor/screen/motor.dart';
import 'package:owl/pages/preset/screen/preset.dart';
import 'package:owl/pages/model/screen/model.dart';
import 'package:owl/pages/led/screen/led_page.dart';
import 'package:owl/pages/failsafe/screen/failsafe_page.dart';
import 'package:owl/pages/pid/screen/pid_page.dart';
import 'package:owl/pages/gps/screen/gps.dart';
import 'package:owl/pages/secret/screen/secret.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(MaterialApp(
    navigatorKey: navigatorKey, // ← вот тут
    theme: ThemeData(primaryColor: Colors.black12, fontFamily: 'Lato'),
    initialRoute: '/fail',
    routes: {
      '/set': (context) => const Setup(),
      '/': (context) => Navigation(),
      '/port': (context) => const Ports(),
      '/bat': (context) => const PowerBattery(),
      '/conf': (context) => const Configuration(),
      '/ser': (context) => const Servo(),
      '/mot': (context) => const Motor(),
      '/pres': (context) => const Preset(),
      '/mod': (context) => const Model(),
      '/led': (context) => const LedPage(),
      '/fail': (context) => const FailsafePage(),
      '/pid': (context) => const PidProfilePage(),
      '/boss': (context) => const SecretPage(),
      '/gps': (context) => const GpsConfiguratorPage(),
    },
  ));
}
