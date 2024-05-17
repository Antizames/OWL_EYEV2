import 'package:flutter/material.dart';
import 'package:owl/Pages/failsafe.dart';
import 'package:owl/Pages/powerbattery.dart';
import 'package:owl/Pages/ports.dart';
import 'package:owl/Pages/configuration.dart';
import 'package:owl/Pages/home.dart';
import 'package:owl/Pages/video.dart';
import 'package:owl/Pages/_3D.dart';
import 'package:owl/Pages/servo.dart';
import 'package:owl/Pages/Telemetria.dart';
void main() => runApp(MaterialApp(
  theme: ThemeData(primaryColor: Colors.black12, fontFamily: 'Lato'),
  initialRoute: '/vid',
  routes: {
    '/': (context) => Setup(),
    '/fail': (context) => const FailSafe(),
    '/port': (context) => const Ports(),
    '/poba': (context) => const PowerBattery(),
    '/conf': (context) => Configuration(),
    '/vid': (context) => const Video(),
    '/3d': (context) => const tree_D(),
    '/ser': (context) => const Servo(),
    '/tele': (context) => const Tele(),
  },));