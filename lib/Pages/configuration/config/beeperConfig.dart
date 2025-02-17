import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_msp/flutter_msp.dart';

class BeeperConfig {
  int beepers;
  int dshotBeaconTone;
  int dshotBeaconConditions;

  BeeperConfig({
    this.beepers = 0,
    this.dshotBeaconTone = 0,
    this.dshotBeaconConditions = 0,
  });

  Uint8List toBytes() {
    final buffer = BytesBuilder();

    buffer.addByte((beepers >> 24) & 0xFF);
    buffer.addByte((beepers >> 16) & 0xFF);
    buffer.addByte((beepers >> 8) & 0xFF);
    buffer.addByte(beepers & 0xFF);

    buffer.addByte(dshotBeaconTone);

    buffer.addByte((dshotBeaconConditions >> 24) & 0xFF);
    buffer.addByte((dshotBeaconConditions >> 16) & 0xFF);
    buffer.addByte((dshotBeaconConditions >> 8) & 0xFF);
    buffer.addByte(dshotBeaconConditions & 0xFF);

    return buffer.toBytes();
  }

  /// Создание объекта из байтов
  static BeeperConfig fromBytes(Uint8List bytes) {
    final beepers = (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];
    final dshotBeaconTone = bytes[4];
    final dshotBeaconConditions = (bytes[5] << 24) | (bytes[6] << 16) | (bytes[7] << 8) | bytes[8];

    return BeeperConfig(
      beepers: beepers,
      dshotBeaconTone: dshotBeaconTone,
      dshotBeaconConditions: dshotBeaconConditions,
    );
  }
}

class BeeperManager {
  Future<void> saveConfig({
    required int beepers,
    required int dshotBeaconTone,
    required int dshotBeaconConditions,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Сохранение данных в SharedPreferences
    await prefs.setInt('beepers', beepers);
    await prefs.setInt('dshotBeaconTone', dshotBeaconTone);
    await prefs.setInt('dshotBeaconConditions', dshotBeaconConditions);

    // Создание объекта конфигурации
    final config = BeeperConfig(
      beepers: beepers,
      dshotBeaconTone: dshotBeaconTone,
      dshotBeaconConditions: dshotBeaconConditions,
    );

    final data = config.toBytes();
    sendToBoard(data);
  }

  Future<BeeperConfig> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();

    // Загрузка данных из SharedPreferences
    final beepers = prefs.getInt('beepers') ?? 0;
    final dshotBeaconTone = prefs.getInt('dshotBeaconTone') ?? 0;
    final dshotBeaconConditions = prefs.getInt('dshotBeaconConditions') ?? 0;

    print('Loaded Beeper Config: beepers=$beepers, dshotBeaconTone=$dshotBeaconTone, '
        'dshotBeaconConditions=$dshotBeaconConditions');

    return BeeperConfig(
      beepers: beepers,
      dshotBeaconTone: dshotBeaconTone,
      dshotBeaconConditions: dshotBeaconConditions,
    );
  }

  void sendToBoard(Uint8List data) {
    // Код команды для настроек пищалки
    const int commandCode = 184; // Уникальный код для команды пищалки
    MSPCommunication mspComm = MSPCommunication('COM6');

    // Отправка данных через mspComm
    print("Payload length: ${data.length}");
    mspComm.sendMessageV1(commandCode, data).then((_) {
      print('Beeper configuration sent successfully.');
    }).catchError((error) {
      print('Error sending beeper configuration: $error');
    });
  }
}
