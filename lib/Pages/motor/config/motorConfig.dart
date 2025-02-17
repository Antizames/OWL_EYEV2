import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_msp/flutter_msp.dart';

class MotorConfig {
  final int minthrottle;
  final int maxthrottle;
  final int mincommand;
  final int motorCount;
  final int motorPoles;
  final bool useDshotTelemetry;
  final bool useEscSensor;

  MotorConfig({
    this.minthrottle = 0,
    this.maxthrottle = 0,
    this.mincommand = 0,
    this.motorCount = 0,
    this.motorPoles = 0,
    this.useDshotTelemetry = false,
    this.useEscSensor = false,
  });

  Uint8List toBytes() {
    final buffer = BytesBuilder();

    // Параметры моторов (16-битные значения)
    buffer.addByte(minthrottle & 0xFF);
    buffer.addByte((minthrottle >> 8) & 0xFF);
    buffer.addByte(maxthrottle & 0xFF);
    buffer.addByte((maxthrottle >> 8) & 0xFF);
    buffer.addByte(mincommand & 0xFF);
    buffer.addByte((mincommand >> 8) & 0xFF);

    // Параметры моторов (8-битные значения)
    buffer.addByte(motorCount);
    buffer.addByte(motorPoles);
    buffer.addByte(useDshotTelemetry ? 1 : 0);
    buffer.addByte(useEscSensor ? 1 : 0);

    return buffer.toBytes();
  }
}

class MotorManager {
  Future<void> saveConfig({
    required int minthrottle,
    required int maxthrottle,
    required int mincommand,
    required int motorCount,
    required int motorPoles,
    required bool useDshotTelemetry,
    required bool useEscSensor,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Сохранение конфигурации в SharedPreferences
    await prefs.setInt('minthrottle', minthrottle);
    await prefs.setInt('maxthrottle', maxthrottle);
    await prefs.setInt('mincommand', mincommand);
    await prefs.setInt('motorCount', motorCount);
    await prefs.setInt('motorPoles', motorPoles);
    await prefs.setBool('useDshotTelemetry', useDshotTelemetry);
    await prefs.setBool('useEscSensor', useEscSensor);

    // Создание объекта конфигурации моторов
    final config = MotorConfig(
      minthrottle: minthrottle,
      maxthrottle: maxthrottle,
      mincommand: mincommand,
      motorCount: motorCount,
      motorPoles: motorPoles,
      useDshotTelemetry: useDshotTelemetry,
      useEscSensor: useEscSensor,
    );

    // Генерация байтов для отправки
    final data = config.toBytes();
    sendToBoard(data);
  }

  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();

    final minthrottle = prefs.getInt('minthrottle') ?? 0;
    final maxthrottle = prefs.getInt('maxthrottle') ?? 0;
    final mincommand = prefs.getInt('mincommand') ?? 0;
    final motorCount = prefs.getInt('motorCount') ?? 0;
    final motorPoles = prefs.getInt('motorPoles') ?? 0;
    final useDshotTelemetry = prefs.getBool('useDshotTelemetry') ?? false;
    final useEscSensor = prefs.getBool('useEscSensor') ?? true;

    print('Loaded Motor Config: minthrottle=$minthrottle, maxthrottle=$maxthrottle, '
        'mincommand=$mincommand, motorCount=$motorCount, motorPoles=$motorPoles, '
        'useDshotTelemetry=$useDshotTelemetry, useEscSensor=$useEscSensor');
  }

  void sendToBoard(Uint8List data) {
    // Определяем код команды для моторов
    const int commandCode = 131; // Например, замените на нужный код команды
    MSPCommunication mspComm = MSPCommunication('COM6');

    // Отправка данных через mspComm
    print("Payload length: ${data.length}");
    mspComm.sendMessageV1(commandCode, data).then((_) {
      print('Motor configuration sent successfully.');
    }).catchError((error) {
      print('Error sending motor configuration: $error');
    });
    if (mspComm.port.isOpen) {
      mspComm.port.close();
    }
  }
}
