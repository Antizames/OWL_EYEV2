import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_msp/flutter_msp.dart';

class AmperageMeterConfig {
  final int scale;
  final int offset;
  final int id;

  AmperageMeterConfig({
    required this.scale,
    required this.offset,
    this.id = 10, // ID по умолчанию равен 1
  });

  Uint8List toBytes() {
    final buffer = BytesBuilder();

    buffer.addByte(id); // ID всегда 8-битное
    final byteData = ByteData(4);

    // Добавляем scale (16-битное значение со знаком)
    byteData.setInt16(0, scale, Endian.little);
    buffer.add(byteData.buffer.asUint8List(0, 2));

    // Добавляем offset (16-битное значение со знаком)
    byteData.setInt16(0, offset, Endian.little);
    buffer.add(byteData.buffer.asUint8List(0, 2));

    return buffer.toBytes();
  }

}

class AmperageMeterManager {
  Future<void> saveConfig({
    required int scale,
    required int offset,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Сохраняем данные в SharedPreferences
    await prefs.setInt('amperageScale', scale);
    await prefs.setInt('amperageOffset', offset);

    // Создаём конфигурацию
    final config = AmperageMeterConfig(
      scale: scale,
      offset: offset,
    );

    // Генерация байтов и отправка на плату
    final data = config.toBytes();
    sendToBoard(data);
  }

  Future<AmperageMeterConfig> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();

    final config = AmperageMeterConfig(
      scale: prefs.getInt('amperageScale') ?? 0,
      offset: prefs.getInt('amperageOffset') ?? 0,
    );

    print('Loaded Amperage Meter Config: $config');
    return config;
  }

  void sendToBoard(Uint8List data) {
    const int commandCode = 41; // Укажите соответствующий код команды для Amperage Meter
    MSPCommunication mspComm = MSPCommunication('COM6');
    print("Payload length: ${data.length}");
    mspComm.sendMessageV1(commandCode, data).then((_) {
      print('Amperage meter configuration sent successfully.');
    }).catchError((error) {
      print('Error sending amperage meter configuration: $error');
    });
  }
}
