import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_msp/flutter_msp.dart';

class VoltageMeterConfig {
  final int vbatscale;
  final int vbatresdivval;
  final int vbatresdivmultiplier;
  final int id;

  VoltageMeterConfig({
    required this.vbatscale,
    required this.vbatresdivval,
    required this.vbatresdivmultiplier,
    this.id = 10, // ID по умолчанию равен 1
  });

  Uint8List toBytes() {
    final buffer = BytesBuilder();

    buffer.addByte(id); // ID занимает 1 байт
    buffer.addByte(vbatscale); // Масштаб (8 бит)
    buffer.addByte(vbatresdivval); // Делитель напряжения (8 бит)
    buffer.addByte(vbatresdivmultiplier); // Множитель напряжения (8 бит)

    return buffer.toBytes();
  }
}

class VoltageMeterManager {
  Future<void> saveConfig({
    required int vbatscale,
    required int vbatresdivval,
    required int vbatresdivmultiplier,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Сохраняем данные в SharedPreferences
    await prefs.setInt('vbatscale', vbatscale);
    await prefs.setInt('vbatresdivval', vbatresdivval);
    await prefs.setInt('vbatresdivmultiplier', vbatresdivmultiplier);

    // Создаём конфигурацию
    final config = VoltageMeterConfig(
      vbatscale: vbatscale,
      vbatresdivval: vbatresdivval,
      vbatresdivmultiplier: vbatresdivmultiplier,
    );

    // Генерация байтов и отправка на плату
    final data = config.toBytes();
    sendToBoard(data);
  }


  Future<VoltageMeterConfig> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();

    final config = VoltageMeterConfig(
      vbatscale: prefs.getInt('vbatscale') ?? 0,
      vbatresdivval: prefs.getInt('vbatresdivval') ?? 0,
      vbatresdivmultiplier: prefs.getInt('vbatresdivmultiplier') ?? 0,
    );

    print('Loaded Voltage Meter Config: $config');
    return config;
  }

  void sendToBoard(Uint8List data) {
    const int commandCode = 57; // Укажите соответствующий код команды для Voltage Meter
    MSPCommunication mspComm = MSPCommunication('COM6');
    print("Payload length: ${data.length}");
    mspComm.sendMessageV1(commandCode, data).then((_) {
      print('Voltage meter configuration sent successfully.');
    }).catchError((error) {
      print('Error sending voltage meter configuration: $error');
    });
    if (mspComm.port.isOpen) {
      mspComm.port.close();
    }
  }
}
