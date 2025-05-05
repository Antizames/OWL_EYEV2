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

  static const List<int> baudRates = [
    0,        // "AUTO" (используется как 0)
    9600,
    19200,
    38400,
    57600,
    115200,
    230400,
    250000,
    400000,
    460800,
    500000,
    921600,
    1000000,
    1500000,
    2000000,
    2470000,
  ];


  SerialPortConfig({
    required this.identifier,
    required this.auxChannelIndex,
    required this.functions,
    required this.mspBaudrate,
    required this.gpsBaudrate,
    required this.telemetryBaudrate,
    required this.blackboxBaudrate,
  });

  Uint8List toBytes() {
    final buffer = BytesBuilder();

    buffer.addByte(identifier);
    final functionMask = _functionsToMask(functions);
    buffer.add(functionMask);
    buffer.addByte(_baudRateToIndex(mspBaudrate));
    buffer.addByte(_baudRateToIndex(gpsBaudrate));
    buffer.addByte(_baudRateToIndex(telemetryBaudrate));
    buffer.addByte(_baudRateToIndex(blackboxBaudrate));
    print("🛠️ MSP Baudrate: ${_baudRateToIndex(mspBaudrate)}");
    print("🛰️ GPS Baudrate: ${_baudRateToIndex(gpsBaudrate)}");
    print("📡 Telemetry Baudrate: ${_baudRateToIndex(telemetryBaudrate)}");
    print("📦 Blackbox Baudrate: ${_baudRateToIndex(blackboxBaudrate)}");


    Uint8List result = buffer.toBytes();
    print("📜 Данные для отправки: ${result.toList()}");
    return result;
  }

  static Uint8List _functionsToMask(List<String> functions) {
    const functionMap = {
      "MSP": 0,
      "GPS": 1,
      "TELEMETRY_FRSKY": 2,
      "TELEMETRY_HOTT": 3,
      "TELEMETRY_MSP": 4,
      "TELEMETRY_LTM": 4, // LTM заменяет MSP
      "TELEMETRY_SMARTPORT": 5,
      "RX_SERIAL": 6,
      "BLACKBOX": 7,
      "TELEMETRY_MAVLINK": 9,
      "ESC_SENSOR": 10,
      "TBS_SMARTAUDIO": 11,
      "TELEMETRY_IBUS": 12,
      "IRC_TRAMP": 13,
      "RUNCAM_DEVICE_CONTROL": 14,
      "LIDAR_TF": 15,
      "FRSKY_OSD": 16,
      "VTX_MSP": 17,
    };

    int mask = 0;
    for (var func in functions) {
      if (functionMap.containsKey(func)) {
        mask |= (1 << functionMap[func]!);
      }
    }

    final buffer = BytesBuilder();
    buffer.addByte(mask & 0xFF); // младший байт
    buffer.addByte((mask >> 8) & 0xFF); // старший байт (если нужно)

    print("🔹 Маска функций: ${buffer.toBytes().toList()} (${functions.join(', ')})");
    return buffer.toBytes();
  }


  static int _baudRateToIndex(int baudRate) {
    final index = baudRates.indexOf(baudRate);
    return index != -1 ? index : 0; // Если нет совпадения, возвращаем "AUTO" (0)
  }


  @override
  String toString() {
    return 'SerialPortConfig(identifier: $identifier, functions: $functions, '
        'mspBaudrate: $mspBaudrate, gpsBaudrate: $gpsBaudrate, '
        'telemetryBaudrate: $telemetryBaudrate, blackboxBaudrate: $blackboxBaudrate)';
  }
}

class SerialConfigManager {
  List<SerialPortConfig> ports = [];

  Future<void> saveConfig() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('ports_count', ports.length);
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

    print('✅ Порты сохранены');
  }

  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final portCount = prefs.getInt('ports_count') ?? 0;
    ports.clear();

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

    print('✅ Загружено ${ports.length} портов');
    for (var port in ports) {
      print('🔹 $port');
    }
  }

  void sendConfig() {
    if (ports.isEmpty) {
      print('⚠️ Нет данных для отправки.');
      return;
    }

    final buffer = BytesBuilder();
    for (var port in ports) {
      buffer.add(port.toBytes());
    }

    final data = buffer.toBytes();
    sendToBoard(data);
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