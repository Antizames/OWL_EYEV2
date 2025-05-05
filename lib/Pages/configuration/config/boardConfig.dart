import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_msp/flutter_msp.dart';
class BoardAlignmentConfig {
  final int roll;
  final int pitch;
  final int yaw;

  BoardAlignmentConfig({
    this.roll = 0,
    this.pitch = 0,
    this.yaw = 0,
  });

  Uint8List toBytes() {
    final buffer = BytesBuilder();

    // Добавление 16-битных значений
    buffer.addByte(roll & 0xFF);
    buffer.addByte((roll >> 8) & 0xFF);
    buffer.addByte(pitch & 0xFF);
    buffer.addByte((pitch >> 8) & 0xFF);
    buffer.addByte(yaw & 0xFF);
    buffer.addByte((yaw >> 8) & 0xFF);

    return buffer.toBytes();
  }
}

class BoardAlignmentManager {
  Future<void> saveConfig({
    required int roll,
    required int pitch,
    required int yaw,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Сохранение конфигурации в SharedPreferences
    await prefs.setInt('roll', roll);
    await prefs.setInt('pitch', pitch);
    await prefs.setInt('yaw', yaw);

    // Создание объекта конфигурации
    final config = BoardAlignmentConfig(
      roll: roll,
      pitch: pitch,
      yaw: yaw,
    );

    final data = config.toBytes();
    sendToBoard(data);
  }

  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();

    final roll = prefs.getInt('roll') ?? 0;
    final pitch = prefs.getInt('pitch') ?? 0;
    final yaw = prefs.getInt('yaw') ?? 0;

    print('Loaded Board Alignment Config: roll=$roll, pitch=$pitch, yaw=$yaw');
  }
  void sendToBoard(Uint8List data) {
    // Определяем код команды для выравнивания платы
    const int commandCode = 39; // Укажите соответствующий код команды
    MSPCommunication mspComm = MSPCommunication('COM6');

    // Отправка данных через mspComm
    print("Payload length: ${data.length}");
    mspComm.sendMessageV1(commandCode, data).then((_) {
      print('Board alignment configuration sent successfully.');
    }).catchError((error) {
      print('Error sending board alignment configuration: $error');
    });
  }
}
