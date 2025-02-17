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
void main() => runApp(MaterialApp(
  theme: ThemeData(primaryColor: Colors.black12, fontFamily: 'Lato'),
  initialRoute: '/set',
  routes: {
    '/set': (context) => const Setup(),
    '/': (context) => Navigation(),
    '/port': (context) => const Ports(),
    '/bat': (context) => const PowerBattery(),
    '/conf': (context) => const Configuration(),
    '/ser': (context) => const Servo(),
    '/mot': (context) => const Motor(),
    '/pres': (context) => const Preset(),
    '/mod': (context) => Model(),
  },));