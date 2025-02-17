import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_msp/flutter_msp.dart';

class PidConfig {
  final int gyroSyncDenom;
  final int pidProcessDenom;
  final int useUnsyncedPwm;
  final int fastPwmProtocol;
  final int motorPwmRate;
  final int motorIdle;
  final int gyroUse32kHz;
  final int motorPwmInversion;
  final int gyroHighFsr;
  final int gyroMovementCalibThreshold;
  final int gyroCalibDuration;
  final int gyroOffsetYaw;
  final int gyroCheckOverflow;
  final int debugMode;
  final int gyroToUse;

  PidConfig({
    this.gyroSyncDenom = 0,
    this.pidProcessDenom = 0,
    this.useUnsyncedPwm = 0,
    this.fastPwmProtocol = 0,
    this.motorPwmRate = 0,
    this.motorIdle = 0,
    this.gyroUse32kHz = 0,
    this.motorPwmInversion = 0,
    this.gyroHighFsr = 0,
    this.gyroMovementCalibThreshold = 0,
    this.gyroCalibDuration = 0,
    this.gyroOffsetYaw = 0,
    this.gyroCheckOverflow = 0,
    this.debugMode = 0,
    this.gyroToUse = 0,
  });

  Uint8List toBytes() {
    final buffer = BytesBuilder();

    // Добавляем 8-битные значения
    buffer.addByte(gyroSyncDenom);
    buffer.addByte(pidProcessDenom);
    buffer.addByte(useUnsyncedPwm);
    buffer.addByte(fastPwmProtocol);

    // Добавляем 16-битные значения
    buffer.addByte(motorPwmRate & 0xFF);
    buffer.addByte((motorPwmRate >> 8) & 0xFF);
    buffer.addByte(motorIdle & 0xFF);
    buffer.addByte((motorIdle >> 8) & 0xFF);

    buffer.addByte(gyroUse32kHz);
    buffer.addByte(motorPwmInversion);
    buffer.addByte(gyroHighFsr);
    buffer.addByte(gyroMovementCalibThreshold);
    buffer.addByte(gyroCalibDuration & 0xFF);
    buffer.addByte((gyroCalibDuration >> 8) & 0xFF);
    buffer.addByte(gyroOffsetYaw & 0xFF);
    buffer.addByte((gyroOffsetYaw >> 8) & 0xFF);
    buffer.addByte(gyroCheckOverflow);
    buffer.addByte(debugMode);
    buffer.addByte(gyroToUse);

    return buffer.toBytes();
  }
}

class PidManager {
  Future<void> savePartialConfig(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
    print('Saved $key: $value');
  }

  Future<void> saveFullConfig(PidConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gyroSyncDenom', config.gyroSyncDenom);
    await prefs.setInt('pidProcessDenom', config.pidProcessDenom);
    await prefs.setInt('useUnsyncedPwm', config.useUnsyncedPwm);
    await prefs.setInt('fastPwmProtocol', config.fastPwmProtocol);
    await prefs.setInt('motorPwmRate', config.motorPwmRate);
    await prefs.setInt('motorIdle', config.motorIdle);
    await prefs.setInt('gyroUse32kHz', config.gyroUse32kHz);
    await prefs.setInt('motorPwmInversion', config.motorPwmInversion);
    await prefs.setInt('gyroHighFsr', config.gyroHighFsr);
    await prefs.setInt('gyroMovementCalibThreshold', config.gyroMovementCalibThreshold);
    await prefs.setInt('gyroCalibDuration', config.gyroCalibDuration);
    await prefs.setInt('gyroOffsetYaw', config.gyroOffsetYaw);
    await prefs.setInt('gyroCheckOverflow', config.gyroCheckOverflow);
    await prefs.setInt('debugMode', config.debugMode);
    await prefs.setInt('gyroToUse', config.gyroToUse);

    final data = config.toBytes();
    sendToBoard(data);
  }

  Future<PidConfig> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final config = PidConfig(
      gyroSyncDenom: prefs.getInt('gyroSyncDenom') ?? 0,
      pidProcessDenom: prefs.getInt('pidProcessDenom') ?? 0,
      useUnsyncedPwm: prefs.getInt('useUnsyncedPwm') ?? 0,
      fastPwmProtocol: prefs.getInt('fastPwmProtocol') ?? 0,
      motorPwmRate: prefs.getInt('motorPwmRate') ?? 0,
      motorIdle: prefs.getInt('motorIdle') ?? 0,
      gyroUse32kHz: prefs.getInt('gyroUse32kHz') ?? 0,
      motorPwmInversion: prefs.getInt('motorPwmInversion') ?? 0,
      gyroHighFsr: prefs.getInt('gyroHighFsr') ?? 0,
      gyroMovementCalibThreshold: prefs.getInt('gyroMovementCalibThreshold') ?? 0,
      gyroCalibDuration: prefs.getInt('gyroCalibDuration') ?? 0,
      gyroOffsetYaw: prefs.getInt('gyroOffsetYaw') ?? 0,
      gyroCheckOverflow: prefs.getInt('gyroCheckOverflow') ?? 0,
      debugMode: prefs.getInt('debugMode') ?? 0,
      gyroToUse: prefs.getInt('gyroToUse') ?? 0,
    );
    print('Loaded PID Config: $config');
    return config;
  }

  void sendToBoard(Uint8List data) {
    const int commandCode = 131;
    MSPCommunication mspComm = MSPCommunication('COM6');
    print("Payload length: ${data.length}");
    mspComm.sendMessageV1(commandCode, data).then((_) {
      print('PID configuration sent successfully.');
    }).catchError((error) {
      print('Error sending PID configuration: $error');
    });
    if (mspComm.port.isOpen) {
      mspComm.port.close();
    }
  }
}