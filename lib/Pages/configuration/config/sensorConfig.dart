import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_msp/flutter_msp.dart';

class SensorConfig {
  final int accHardware;
  final int baroHardware;
  final int magHardware;
  final int sonarHardware;

  SensorConfig({
    this.accHardware = 0,
    this.baroHardware = 0,
    this.magHardware = 0,
    this.sonarHardware = 0,
  });

  Uint8List toBytes() {
    final buffer = BytesBuilder();

    buffer.addByte(accHardware);
    buffer.addByte(baroHardware);
    buffer.addByte(magHardware);
    buffer.addByte(sonarHardware);

    return buffer.toBytes();
  }
}

class SensorManager {
  Future<void> saveConfig({
    required int accHardware,
    required int baroHardware,
    required int magHardware,
    required int sonarHardware,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Сохранение конфигурации в SharedPreferences
    await prefs.setInt('accHardware', accHardware);
    await prefs.setInt('baroHardware', baroHardware);
    await prefs.setInt('magHardware', magHardware);
    await prefs.setInt('sonarHardware', sonarHardware);

    // Создание объекта конфигурации сенсоров
    final config = SensorConfig(
      accHardware: accHardware,
      baroHardware: baroHardware,
      magHardware: magHardware,
      sonarHardware: sonarHardware,
    );

    final data = config.toBytes();
    sendToBoard(data);
  }

  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();

    final accHardware = prefs.getInt('accHardware') ?? 0;
    final baroHardware = prefs.getInt('baroHardware') ?? 0;
    final magHardware = prefs.getInt('magHardware') ?? 0;
    final sonarHardware = prefs.getInt('sonarHardware') ?? 0;

    print('Loaded Sensor Config: accHardware=$accHardware, baroHardware=$baroHardware, '
        'magHardware=$magHardware, sonarHardware=$sonarHardware');
  }
  void sendToBoard(Uint8List data) {
    // Определяем код команды для сенсоров
    const int commandCode = 96; // Например, замените на нужный код команды
    MSPCommunication mspComm = MSPCommunication('COM6');

    // Отправка данных через mspComm
    print("Payload length: ${data.length}");
    mspComm.sendMessageV1(commandCode, data).then((_) {
      print('Sensor configuration sent successfully.');
    }).catchError((error) {
      print('Error sending sensor configuration: $error');
    });
  }
}
