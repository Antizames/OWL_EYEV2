import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_msp/flutter_msp.dart';
class BatteryConfig {
  final double minCellVoltage;
  final double maxCellVoltage;
  final double warningCellVoltage;
  final int capacity;
  final int voltageMeterSource;
  final int currentMeterSource;

  BatteryConfig({
    required this.minCellVoltage,
    required this.maxCellVoltage,
    required this.warningCellVoltage,
    required this.capacity,
    required this.voltageMeterSource,
    required this.currentMeterSource,
  });

  Uint8List toBytes() {
    final buffer = BytesBuilder();

    buffer.addByte((minCellVoltage * 10).round());
    buffer.addByte((maxCellVoltage * 10).round());
    buffer.addByte((warningCellVoltage * 10).round());

    buffer.addByte(capacity & 0xFF);
    buffer.addByte((capacity >> 8) & 0xFF);

    buffer.addByte(voltageMeterSource);
    buffer.addByte(currentMeterSource);

    buffer.addByte(((minCellVoltage * 100).round()) & 0xFF);
    buffer.addByte(((minCellVoltage * 100).round() >> 8) & 0xFF);

    buffer.addByte(((maxCellVoltage * 100).round()) & 0xFF);
    buffer.addByte(((maxCellVoltage * 100).round() >> 8) & 0xFF);

    buffer.addByte(((warningCellVoltage * 100).round()) & 0xFF);
    buffer.addByte(((warningCellVoltage * 100).round() >> 8) & 0xFF);

    return buffer.toBytes();
  }
}

class BatteryManager {
  Future<void> saveConfig({
    required double minCell,
    required double maxCell,
    required double warnCell,
    required int cap,
    required int voltageSource,
    required int currentSource,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('minCell', minCell);
    await prefs.setDouble('maxCell', maxCell);
    await prefs.setDouble('warnCell', warnCell);
    await prefs.setInt('cap', cap);
    await prefs.setInt('voltageSource', voltageSource);
    await prefs.setInt('currentSource', currentSource);

    // Создаём конфигурацию
    final config = BatteryConfig(
      minCellVoltage: minCell,
      maxCellVoltage: maxCell,
      warningCellVoltage: warnCell,
      capacity: cap,
      voltageMeterSource: voltageSource,
      currentMeterSource: currentSource,
    );

    // Генерация байтов и отправка на плату
    final data = config.toBytes();
    sendToBoard(data);
  }

  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final minCell = prefs.getDouble('minCell') ?? 3.7;
    final maxCell = prefs.getDouble('maxCell') ?? 4.2;
    final warnCell = prefs.getDouble('warnCell') ?? 3.3;
    final cap = prefs.getInt('cap') ?? 1000;
    final voltageSource = prefs.getInt('voltageSource') ?? 0;
    final currentSource = prefs.getInt('currentSource') ?? 0;

    print('Loaded Config: '
        'minCell=$minCell, maxCell=$maxCell, warnCell=$warnCell, cap=$cap');
  }

  void sendToBoard(Uint8List data) {
    // Определяем код команды (выберите подходящий код для вашей команды)
    const int commandCode = 33; // Здесь замените на нужный код команды
    MSPCommunication mspComm = MSPCommunication('COM6');
    // Подготовка данных к отправке

    // Отправка данных через mspComm
    print("Payload length: ${data.length}");
    mspComm.sendMessageV1(commandCode, data).then((_) {
      print('Configuration sent successfully.');
    }).catchError((error) {
      print('Error sending configuration: $error');
    });
    if (mspComm.port.isOpen) {
      mspComm.port.close();
    }
  }
}
