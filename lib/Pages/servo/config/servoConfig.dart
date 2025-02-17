import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_msp/flutter_msp.dart';

class ServoConfig {
  final int middle;
  final int min;
  final int max;
  final int rate;
  final int indexOfChannelToForward;
  final int reversedInputSources;

  ServoConfig({
    required this.middle,
    required this.min,
    required this.max,
    required this.rate,
    required this.indexOfChannelToForward,
    required this.reversedInputSources,
  });

  // Метод для преобразования конфигурации в байты для отправки
  Uint8List toBytes(int servoIndex) {
    final buffer = BytesBuilder();

    buffer.addByte(servoIndex);
    buffer.addByte(min & 0xFF);
    buffer.addByte((min >> 8) & 0xFF);
    buffer.addByte(max & 0xFF);
    buffer.addByte((max >> 8) & 0xFF);
    buffer.addByte(middle & 0xFF);
    buffer.addByte((middle >> 8) & 0xFF);
    buffer.addByte(rate);

    buffer.addByte(indexOfChannelToForward);
    buffer.addByte(reversedInputSources & 0xFF);
    buffer.addByte((reversedInputSources >> 8) & 0xFF);
    buffer.addByte((reversedInputSources >> 16) & 0xFF);
    buffer.addByte((reversedInputSources >> 24) & 0xFF);

    return buffer.toBytes();
  }
}

class ServoManager {
  List<ServoConfig> servoConfigList = [];

  // Метод для загрузки конфигурации из SharedPreferences
  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final int count = prefs.getInt('servoConfigCount') ?? 0;

    for (int i = 0; i < count; i++) {
      final min = prefs.getInt('servoMin$i') ?? 1000;
      final max = prefs.getInt('servoMax$i') ?? 2000;
      final middle = prefs.getInt('servoMiddle$i') ?? 1500;
      final rate = prefs.getInt('servoRate$i') ?? 100;
      final indexOfChannelToForward = prefs.getInt('servoIndexOfChannelToForward$i') ?? 255;
      final reversedInputSources = prefs.getInt('servoReversedInputSources$i') ?? 0;

      // Обновляем конфигурацию серво в списке
      servoConfigList.add(
        ServoConfig(
          min: min,
          max: max,
          middle: middle,
          rate: rate,
          reversedInputSources: reversedInputSources,
          indexOfChannelToForward: indexOfChannelToForward,
        ),
      );
    }
  }

  // Метод для добавления новой конфигурации серво
  void addServoConfig(ServoConfig config) {
    servoConfigList.add(config);
  }

  // Метод для удаления конфигурации серво по индексу
  void removeServoConfig(int index) {
    if (index >= 0 && index < servoConfigList.length) {
      servoConfigList.removeAt(index);
    }
  }

  // Метод для сохранения конфигурации серво в SharedPreferences
  Future<void> saveConfig() async {
    final prefs = await SharedPreferences.getInstance();

    // Сохраняем количество конфигураций
    await prefs.setInt('servoConfigCount', servoConfigList.length);

    for (int i = 0; i < servoConfigList.length; i++) {
      final servo = servoConfigList[i];
      await prefs.setInt('servoMin$i', servo.min);
      await prefs.setInt('servoMax$i', servo.max);
      await prefs.setInt('servoMiddle$i', servo.middle);
      await prefs.setInt('servoRate$i', servo.rate);
      await prefs.setInt('servoIndexOfChannelToForward$i', servo.indexOfChannelToForward);
      await prefs.setInt('servoReversedInputSources$i', servo.reversedInputSources);
    }
  }

  // Метод для отправки конфигурации серво
  Future<void> sendServoConfigurations() async {
    if (servoConfigList.isEmpty) {
      print('No servo configurations available');
      return;
    }

    int servoIndex = 0;

    // Используем функцию для отправки данных
    Future<void> sendNextServoConfig() async {
      final servoConfiguration = servoConfigList[servoIndex];
      final data = servoConfiguration.toBytes(servoIndex);

      // Отправка данных через MSP
      MSPCommunication mspComm = MSPCommunication('COM6');
      const int commandCode = 212; // Поставьте нужный код команды
      mspComm.sendMessageV1(commandCode, data).then((_) {
        print('Servo $servoIndex configuration sent');
        servoIndex++;

        if (servoIndex < servoConfigList.length) {
          sendNextServoConfig();  // Отправить следующий
        } else {
          print('All servo configurations sent.');
        }
      }).catchError((error) {
        print('Error sending servo configuration: $error');
      });
    }

    // Начать отправку
    sendNextServoConfig();
  }
}
