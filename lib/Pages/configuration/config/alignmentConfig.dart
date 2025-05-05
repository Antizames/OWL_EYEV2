import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_msp/flutter_msp.dart';

class SensorAlignmentConfig {
  final int? alignGyro;
  final int? alignAcc;
  final int? alignMag;
  final int? gyroToUse;
  final int? gyro1Align;
  final int? gyro2Align;

  SensorAlignmentConfig({
    this.alignGyro,
    this.alignAcc,
    this.alignMag,
    this.gyroToUse,
    this.gyro1Align,
    this.gyro2Align,
  });

  Uint8List toBytes() {
    final buffer = BytesBuilder();

    void addValue(int? value) {
      buffer.addByte(value ?? 0);
    }

    // Добавляем данные поочерёдно
    addValue(alignGyro);
    addValue(alignAcc);
    addValue(alignMag);
    addValue(gyroToUse);
    addValue(gyro1Align);
    addValue(gyro2Align);

    return buffer.toBytes();
  }
}

class SensorAlignmentManager {
  Future<void> savePartialConfig(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
    print('Saved $key: $value');
  }

  Future<void> saveFullConfig(SensorAlignmentConfig config) async {
    final prefs = await SharedPreferences.getInstance();

    // Сохраняем значения только если они заданы
    if (config.alignGyro != null) {
      await prefs.setInt('alignGyro', config.alignGyro!);
    }
    if (config.alignAcc != null) {
      await prefs.setInt('alignAcc', config.alignAcc!);
    }
    if (config.alignMag != null) {
      await prefs.setInt('alignMag', config.alignMag!);
    }
    if (config.gyroToUse != null) {
      await prefs.setInt('gyroToUse', config.gyroToUse!);
    }
    if (config.gyro1Align != null) {
      await prefs.setInt('gyro1Align', config.gyro1Align!);
    }
    if (config.gyro2Align != null) {
      await prefs.setInt('gyro2Align', config.gyro2Align!);
    }
    print('Loaded Sensor Alignment Config:');
    print('alignGyro: ${config.alignGyro}');
    print('alignAcc: ${config.alignAcc}');
    print('alignMag: ${config.alignMag}');
    print('gyroToUse: ${config.gyroToUse}');
    print('gyro1Align: ${config.gyro1Align}');
    print('gyro2Align: ${config.gyro2Align}');
    final data = config.toBytes();
    sendToBoard(data);
  }

  Future<SensorAlignmentConfig> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();

    final config = SensorAlignmentConfig(
      alignGyro: prefs.getInt('alignGyro'),
      alignAcc: prefs.getInt('alignAcc'),
      alignMag: prefs.getInt('alignMag'),
      gyroToUse: prefs.getInt('gyroToUse'),
      gyro1Align: prefs.getInt('gyro1Align'),
      gyro2Align: prefs.getInt('gyro2Align'),
    );
    return config;

  }
  void sendToBoard(Uint8List data) {
    const int commandCode = 126; // Укажите соответствующий код команды
    MSPCommunication mspComm = MSPCommunication('COM6');
    print("Payload length: ${data.length}");
    mspComm.sendMessageV1(commandCode, data).then((_) {
      print('Sensor alignment configuration sent successfully.');
    }).catchError((error) {
      print('Error sending sensor alignment configuration: $error');
    });
  }

}
