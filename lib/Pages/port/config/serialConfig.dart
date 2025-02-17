import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_msp/flutter_msp.dart';

class SerialPortConfig {
  final int identifier;
  final int auxChannelIndex;
  final List<String> functions;
  final int mspBaudrate;
  final int gpsBaudrate;
  final int telemetryBaudrate;
  final int blackboxBaudrate;

  SerialPortConfig({
    required this.identifier,
    required this.auxChannelIndex,
    required this.functions,
    required this.mspBaudrate,
    required this.gpsBaudrate,
    required this.telemetryBaudrate,
    required this.blackboxBaudrate,
  });

  Uint8List toBytes(List<int> baudRates) {
    final buffer = BytesBuilder();

    buffer.addByte(identifier);
    buffer.add(_functionsToMask(functions));
    buffer.addByte(baudRates.indexOf(mspBaudrate));
    buffer.addByte(baudRates.indexOf(gpsBaudrate));
    buffer.addByte(baudRates.indexOf(telemetryBaudrate));
    buffer.addByte(baudRates.indexOf(blackboxBaudrate));

    return buffer.toBytes();
  }

  Uint8List _functionsToMask(List<String> functions) {
    final functionMap = {
      "MSP": 0x01,
      "GPS": 0x02,
      "TELEMETRY": 0x04,
      "BLACKBOX": 0x08,
    };
    int mask = 0;
    for (var func in functions) {
      mask |= functionMap[func] ?? 0;
    }
    return Uint8List(2)..buffer.asByteData().setUint16(0, mask, Endian.big);
  }
}

class SerialConfigManager {
  List<SerialPortConfig> ports = [];

  Future<void> saveConfig() async {
    final prefs = await SharedPreferences.getInstance();

    for (var i = 0; i < ports.length; i++) {
      final port = ports[i];
      await prefs.setInt('port_${i}_identifier', port.identifier);
      await prefs.setInt('port_${i}_auxChannelIndex', port.auxChannelIndex);
      await prefs.setStringList('port_${i}_functions', port.functions);
      await prefs.setInt('port_${i}_mspBaudrate', port.mspBaudrate);
      await prefs.setInt('port_${i}_gpsBaudrate', port.gpsBaudrate);
      await prefs.setInt('port_${i}_telemetryBaudrate', port.telemetryBaudrate);
      await prefs.setInt('port_${i}_blackboxBaudrate', port.blackboxBaudrate);
    }

    // Сохраняем количество портов
    await prefs.setInt('ports_count', ports.length);
  }

  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();

    final portCount = prefs.getInt('ports_count') ?? 0;
    ports.clear(); // Убедимся, что список портов пуст перед загрузкой

    for (var i = 0; i < portCount; i++) {
      final identifier = prefs.getInt('port_${i}_identifier') ?? 0;
      final auxChannelIndex = prefs.getInt('port_${i}_auxChannelIndex') ?? 0;
      final functions = prefs.getStringList('port_${i}_functions') ?? [];
      final mspBaudrate = prefs.getInt('port_${i}_mspBaudrate') ?? 115200;
      final gpsBaudrate = prefs.getInt('port_${i}_gpsBaudrate') ?? 57600;
      final telemetryBaudrate = prefs.getInt('port_${i}_telemetryBaudrate') ?? 38400;
      final blackboxBaudrate = prefs.getInt('port_${i}_blackboxBaudrate') ?? 115200;

      ports.add(
        SerialPortConfig(
          identifier: identifier,
          auxChannelIndex: auxChannelIndex,
          functions: functions,
          mspBaudrate: mspBaudrate,
          gpsBaudrate: gpsBaudrate,
          telemetryBaudrate: telemetryBaudrate,
          blackboxBaudrate: blackboxBaudrate,
        ),
      );
    }

    print('Loaded ${ports.length} ports from preferences.');
    for (var port in ports) {
      print('Port: $port');
    }
  }

  void sendConfig() {
    final buffer = BytesBuilder();

    for (var port in ports) {
      buffer.addByte(port.identifier);

      // Преобразуем функции в битовую маску
      final functionMask = _functionsToMask(port.functions);
      buffer.addByte(functionMask & 0xFF);
      buffer.addByte((functionMask >> 8) & 0xFF);

      // Добавляем скорость передачи для каждого режима
      buffer.addByte(_baudRateToIndex(port.mspBaudrate));
      buffer.addByte(_baudRateToIndex(port.gpsBaudrate));
      buffer.addByte(_baudRateToIndex(port.telemetryBaudrate));
      buffer.addByte(_baudRateToIndex(port.blackboxBaudrate));
    }

    final data = buffer.toBytes();
    sendToBoard(data);
  }

  int _functionsToMask(List<String> functions) {
    // Пример преобразования функций в битовую маску
    const functionMap = {
      "MSP": 0x01,
      "GPS": 0x02,
      "TELEMETRY": 0x04,
      "BLACKBOX": 0x08,
    };
    int mask = 0;
    for (var func in functions) {
      mask |= functionMap[func] ?? 0;
    }
    return mask;
  }

  int _baudRateToIndex(int baudRate) {
    // Пример: преобразование скорости передачи в индекс
    const baudRates = [9600, 19200, 38400, 57600, 115200];
    return baudRates.indexOf(baudRate);
  }

  void sendToBoard(Uint8List data) {
    const int commandCode = 55; // Код команды
    MSPCommunication mspComm = MSPCommunication('COM6');

    print("Payload length: ${data.length}");
    mspComm.sendMessageV1(commandCode, data).then((_) {
      print('Configuration sent successfully.');
    }).catchError((error) {
      print('Error sending configuration: $error');
    });
  }
}

