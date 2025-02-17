import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_msp/flutter_msp.dart';

class MixerConfig {
  final int mixer;
  final int reverseMotorDir;

  MixerConfig({
    this.mixer = 0,
    this.reverseMotorDir = 0,
  });

  Uint8List toBytes() {
    final buffer = BytesBuilder();
    // Добавление 8-битных значений
    buffer.addByte(mixer & 0xFF);
    buffer.addByte(reverseMotorDir & 0xFF);
    return buffer.toBytes();
  }
}

class MixerManager {
  Future<void> saveConfig({
    required int mixer,
    required int reverseMotorDir,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Сохранение конфигурации в SharedPreferences
    await prefs.setInt('mixer', mixer);
    await prefs.setInt('reverseMotorDir', reverseMotorDir);

    // Создание объекта конфигурации миксера
    final config = MixerConfig(
      mixer: mixer,
      reverseMotorDir: reverseMotorDir,
    );

    // Генерация байтов для отправки
    final data = config.toBytes();
    sendToBoard(data);
  }

  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final mixer = prefs.getInt('mixer') ?? 0;
    final reverseMotorDir = prefs.getInt('reverseMotorDir') ?? 0;

    print('Loaded Mixer Config: mixer=$mixer, reverseMotorDir=$reverseMotorDir');
  }

  void sendToBoard(Uint8List data) {
    // Определяем код команды (выберите подходящий код для вашей команды)
    const int commandCode = 43; // Например, замените на нужный код команды для миксера
    MSPCommunication mspComm = MSPCommunication('COM6');
    // Отправка данных через mspComm
    print("Payload length: ${data.length}");
    mspComm.sendMessageV1(commandCode, data).then((_) {
      print('Mixer configuration sent successfully.');
    }).catchError((error) {
      print('Error sending mixer configuration: $error');
    });
    if (mspComm.port.isOpen) {
      mspComm.port.close();
    }
  }
}
