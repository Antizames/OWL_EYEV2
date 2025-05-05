import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_msp/flutter_msp.dart';

class MotorConfig {
  final int minThrottle;
  final int maxThrottle;
  final int minCommand;
  final int motorPoles;
  final bool useDshotTelemetry;
  final bool motorStop;
  final bool useEscSensor;
  final int escProtocol;

  MotorConfig({
    this.minThrottle = 1070,
    this.maxThrottle = 2000,
    this.minCommand = 1000,
    this.motorPoles = 14,
    this.useDshotTelemetry = false,
    this.motorStop = false,
    this.useEscSensor = false,
    this.escProtocol = 0,
  });

  /// 📦 **Конвертация в MSP-байты**
  Uint8List toBytes() {
    final buffer = BytesBuilder();

    buffer.addByte(minThrottle & 0xFF);
    buffer.addByte((minThrottle >> 8) & 0xFF);
    buffer.addByte(maxThrottle & 0xFF);
    buffer.addByte((maxThrottle >> 8) & 0xFF);
    buffer.addByte(minCommand & 0xFF);
    buffer.addByte((minCommand >> 8) & 0xFF);

    buffer.addByte(motorPoles); // 🛠️ Количество полюсов мотора
    buffer.addByte(useDshotTelemetry ? 1 : 0); // 🛠️ Включение DShot Telemetry
    buffer.addByte(motorStop ? 1 : 0); // 🛠️ Остановка моторов на холостом ходу
    buffer.addByte(useEscSensor ? 1 : 0); // 🛠️ Датчик ESC
    buffer.addByte(escProtocol); // 🛠️ Протокол ESC (PWM, DSHOT и т.д.)

    return buffer.toBytes();
  }
}

class MotorManager {
  /// 🔄 **Сохранение настроек и отправка**
  Future<void> saveConfig({
    required int minThrottle,
    required int maxThrottle,
    required int minCommand,
    required int motorPoles,
    required bool useDshotTelemetry,
    required bool motorStop,
    required bool useEscSensor,
    required int escProtocol,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('minThrottle', minThrottle);
    await prefs.setInt('maxThrottle', maxThrottle);
    await prefs.setInt('minCommand', minCommand);
    await prefs.setInt('motorPoles', motorPoles);
    await prefs.setBool('useDshotTelemetry', useDshotTelemetry);
    await prefs.setBool('motorStop', motorStop);
    await prefs.setBool('useEscSensor', useEscSensor);
    await prefs.setInt('escProtocol', escProtocol);

    final config = MotorConfig(
      minThrottle: minThrottle,
      maxThrottle: maxThrottle,
      minCommand: minCommand,
      motorPoles: motorPoles,
      useDshotTelemetry: useDshotTelemetry,
      motorStop: motorStop,
      useEscSensor: useEscSensor,
      escProtocol: escProtocol,
    );
    sendToBoard(config.toBytes());
  }

  /// 🔄 **Загрузка настроек из `SharedPreferences`**
  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();

    final minThrottle = prefs.getInt('minThrottle') ?? 1070;
    final maxThrottle = prefs.getInt('maxThrottle') ?? 2000;
    final minCommand = prefs.getInt('minCommand') ?? 1000;
    final motorPoles = prefs.getInt('motorPoles') ?? 14;
    final useDshotTelemetry = prefs.getBool('useDshotTelemetry') ?? false;
    final motorStop = prefs.getBool('motorStop') ?? false;
    final useEscSensor = prefs.getBool('useEscSensor') ?? false;
    final escProtocol = prefs.getInt('escProtocol') ?? 0;

    print('Loaded Config: minThrottle=$minThrottle, maxThrottle=$maxThrottle, '
        'minCommand=$minCommand, motorPoles=$motorPoles, '
        'useDshotTelemetry=$useDshotTelemetry, motorStop=$motorStop, '
        'useEscSensor=$useEscSensor, escProtocol=$escProtocol');
  }
  void sendToBoard(Uint8List data) {
    // Определяем код команды для моторов
    const int commandCode = 131; // Например, замените на нужный код команды
    MSPCommunication mspComm = MSPCommunication('COM6');

    // Отправка данных через mspComm
    print("Payload length: ${data.length}");
    mspComm.sendMessageV1(commandCode, data).then((_) {
      print('Motor configuration sent successfully.');
    }).catchError((error) {
      print('Error sending motor configuration: $error');
    });
    if (mspComm.port.isOpen) {
      mspComm.port.close();
    }
  }
}
