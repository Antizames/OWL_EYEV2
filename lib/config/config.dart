import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveConfig({
  //Батарея
  double? minCell,
  double? maxCell,
  double? warnCell,
  double? cap,
  double? scale,
  double? divider,
  double? multiplier,
  double? scaleAmp,
  double? offset,
  //Конфигурация
  double? roll,
  double? pitch,
  double? yaw,
  String? pilot,
  String? craft, // Добавлено
  int? pid, // Добавлено
  String? mag, // Добавлено
  String? beacon, // Добавлено
  bool? accelerometer, // Добавлено
  bool? barometer, // Добавлено
  bool? magnetometer, // Добавлено
  bool? rxLost, // Добавлено
  bool? rxSet, // Добавлено
  bool? rxLostLanding, // Добавлено
  bool? rxLostBeacon, // Добавлено
  bool? gyroCalibrated, // Добавлено
  //Моторы
  int? poles,
  int? idle,
  double? motor1,
  double? motor2,
  double? motor3,
  double? motor4,
  String? mixerValue,
  String? motorValue,
  bool? motorOn,
  bool? motorDirection,
  bool? motorStop,
  bool? escSensor,
  bool? bidirDshot,
  //Порты
  bool? usmspActive,
  bool? ua1mspActive,
  bool? ua2mspActive,
  bool? ua3mspActive,
  bool? usserActive,
  bool? ua1serActive,
  bool? ua2serActive,
  bool? ua3serActive,
  String? usmspFreq,
  String? ua1mspFreq,
  String? ua2mspFreq,
  String? ua3mspFreq,
  String? ustelMode,
  String? ustelVal,
  String? ussenMode,
  String? ussenVal,
  String? usperMode,
  String? usperVal,
  String? ua1telMode,
  String? ua1telVal,
  String? ua1senMode,
  String? ua1senVal,
  String? ua1perMode,
  String? ua1perVal,
  String? ua2telMode,
  String? ua2telVal,
  String? ua2senMode,
  String? ua2senVal,
  String? ua2perMode,
  String? ua2perVal,
  String? ua3telMode,
  String? ua3telVal,
  String? ua3senMode,
  String? ua3senVal,
  String? ua3perMode,
  String? ua3perVal,
  //Сервоприводы
  List<String>? titles,
  List<bool>? servo1,
  List<bool>? servo2,
  List<bool>? servo3,
  List<bool>? servo4,
  int? mid1,
  int? min1,
  int? max1,
  int? mid2,
  int? min2,
  int? max2,
  int? mid3,
  int? min3,
  int? max3,
  int? mid4,
  int? min4,
  int? max4,
  String? s1Rate,
  String? s2Rate,
  String? s3Rate,
  String? s4Rate,
}) async {
  final prefs = await SharedPreferences.getInstance();

  // Батарея
  if (minCell != null) await prefs.setDouble('minCell', minCell);
  if (maxCell != null) await prefs.setDouble('maxCell', maxCell);
  if (warnCell != null) await prefs.setDouble('warnCell', warnCell);
  if (cap != null) await prefs.setDouble('cap', cap);
  if (scale != null) await prefs.setDouble('scale', scale);
  if (divider != null) await prefs.setDouble('divider', divider);
  if (multiplier != null) await prefs.setDouble('multiplier', multiplier);
  if (scaleAmp != null) await prefs.setDouble('scaleAmp', scaleAmp);
  if (offset != null) await prefs.setDouble('offset', offset);
// Конфигурация
  if (roll != null) await prefs.setDouble('roll', roll);
  if (pitch != null) await prefs.setDouble('pitch', pitch);
  if (yaw != null) await prefs.setDouble('yaw', yaw);
  if (pilot != null) await prefs.setString('pilot', pilot);
  if (craft != null) await prefs.setString('craft', craft); // Сохранение Craft
  if (pid != null) await prefs.setInt('pid', pid); // Сохранение PID
  if (mag != null) await prefs.setString('mag', mag); // Сохранение MAG
  if (beacon != null) await prefs.setString('beacon', beacon); // Сохранение Beacon
  if (accelerometer != null) await prefs.setBool('accelerometer', accelerometer); // Сохранение Accelerometer
  if (barometer != null) await prefs.setBool('barometer', barometer); // Сохранение Barometer
  if (magnetometer != null) await prefs.setBool('magnetometer', magnetometer); // Сохранение Magnetometer
  if (rxLost != null) await prefs.setBool('rxLost', rxLost); // Сохранение RX_LOST
  if (rxSet != null) await prefs.setBool('rxSet', rxSet); // Сохранение RX_SET
  if (rxLostLanding != null) await prefs.setBool('rxLostLanding', rxLostLanding); // Сохранение RX_LOST_LANDING
  if (rxLostBeacon != null) await prefs.setBool('rxLostBeacon', rxLostBeacon); // Сохранение RX_LOST_BEACON
  if (gyroCalibrated != null) await prefs.setBool('gyroCalibrated', gyroCalibrated); // Сохранение GYRO_CALIBRATED
// Моторы
  if (poles != null) await prefs.setInt('poles', poles);
  if (idle != null) await prefs.setInt('idle', idle);
  if (motor1 != null) await prefs.setDouble('motor1', motor1);
  if (motor2 != null) await prefs.setDouble('motor2', motor2);
  if (motor3 != null) await prefs.setDouble('motor3', motor3);
  if (motor4 != null) await prefs.setDouble('motor4', motor4);
  if (mixerValue != null) await prefs.setString('mixerValue', mixerValue);
  if (bidirDshot != null) await prefs.setBool('bidirDshot', bidirDshot);
  if (motorValue != null) await prefs.setString('motorValue', motorValue);
  if (motorOn != null) await prefs.setBool('motorOn', motorOn);
  if (motorDirection != null) await prefs.setBool('motorDirection', motorDirection);
  if (motorStop != null) await prefs.setBool('motorStop', motorStop);
  if (escSensor != null) await prefs.setBool('escSensor', escSensor);
// Порты
  if (usmspActive != null) await prefs.setBool('usmspActive', usmspActive);
  if (ua1mspActive != null) await prefs.setBool('ua1mspActive', ua1mspActive);
  if (ua2mspActive != null) await prefs.setBool('ua2mspActive', ua2mspActive);
  if (ua3mspActive != null) await prefs.setBool('ua3mspActive', ua3mspActive);
  if (usserActive != null) await prefs.setBool('usserActive', usserActive);
  if (ua1serActive != null) await prefs.setBool('ua1serActive', ua1serActive);
  if (ua2serActive != null) await prefs.setBool('ua2serActive', ua2serActive);
  if (ua3serActive != null) await prefs.setBool('ua3serActive', ua3serActive);
  if (usmspFreq != null) await prefs.setString('usmspFreq', usmspFreq);
  if (ua1mspFreq != null) await prefs.setString('ua1mspFreq', ua1mspFreq);
  if (ua2mspFreq != null) await prefs.setString('ua2mspFreq', ua2mspFreq);
  if (ua3mspFreq != null) await prefs.setString('ua3mspFreq', ua3mspFreq);
  if (ustelMode != null) await prefs.setString('ustelMode', ustelMode);
  if (ustelVal != null) await prefs.setString('ustelVal', ustelVal);
  if (ussenMode != null) await prefs.setString('ussenMode', ussenMode);
  if (ussenVal != null) await prefs.setString('ussenVal', ussenVal);
  if (usperMode != null) await prefs.setString('usperMode', usperMode);
  if (usperVal != null) await prefs.setString('usperVal', usperVal);
  if (ua1telMode != null) await prefs.setString('ua1telMode', ua1telMode);
  if (ua1telVal != null) await prefs.setString('ua1telVal', ua1telVal);
  if (ua1senMode != null) await prefs.setString('ua1senMode', ua1senMode);
  if (ua1senVal != null) await prefs.setString('ua1senVal', ua1senVal);
  if (ua1perMode != null) await prefs.setString('ua1perMode', ua1perMode);
  if (ua1perVal != null) await prefs.setString('ua1perVal', ua1perVal);
  if (ua2telMode != null) await prefs.setString('ua2telMode', ua2telMode);
  if (ua2telVal != null) await prefs.setString('ua2telVal', ua2telVal);
  if (ua2senMode != null) await prefs.setString('ua2senMode', ua2senMode);
  if (ua2senVal != null) await prefs.setString('ua2senVal', ua2senVal);
  if (ua2perMode != null) await prefs.setString('ua2perMode', ua2perMode);
  if (ua2perVal != null) await prefs.setString('ua2perVal', ua2perVal);
  if (ua3telMode != null) await prefs.setString('ua3telMode', ua3telMode);
  if (ua3telVal != null) await prefs.setString('ua3telVal', ua3telVal);
  if (ua3senMode != null) await prefs.setString('ua3senMode', ua3senMode);
  if (ua3senVal != null) await prefs.setString('ua3senVal', ua3senVal);
  if (ua3perMode != null) await prefs.setString('ua3perMode', ua3perMode);
  if (ua3perVal != null) await prefs.setString('ua3perVal', ua3perVal);
//Сервоприводы
  if (titles != null) await prefs.setStringList('titles', titles);
  if (servo1 != null) await prefs.setStringList('servo1', servo1.map((e) => e.toString()).toList());
  if (servo2 != null) await prefs.setStringList('servo2', servo2.map((e) => e.toString()).toList());
  if (servo3 != null) await prefs.setStringList('servo3', servo3.map((e) => e.toString()).toList());
  if (servo4 != null) await prefs.setStringList('servo4', servo4.map((e) => e.toString()).toList());

  // Сохранение значений mid, min, max для каналов 1-4
  if (mid1 != null) await prefs.setInt('mid1', mid1);
  if (min1 != null) await prefs.setInt('min1', min1);
  if (max1 != null) await prefs.setInt('max1', max1);

  if (mid2 != null) await prefs.setInt('mid2', mid2);
  if (min2 != null) await prefs.setInt('min2', min2);
  if (max2 != null) await prefs.setInt('max2', max2);

  if (mid3 != null) await prefs.setInt('mid3', mid3);
  if (min3 != null) await prefs.setInt('min3', min3);
  if (max3 != null) await prefs.setInt('max3', max3);

  if (mid4 != null) await prefs.setInt('mid4', mid4);
  if (min4 != null) await prefs.setInt('min4', min4);
  if (max4 != null) await prefs.setInt('max4', max4);

  // Сохранение rate для каналов 1-4
  if (s1Rate != null) await prefs.setString('s1Rate', s1Rate);
  if (s2Rate != null) await prefs.setString('s2Rate', s2Rate);
  if (s3Rate != null) await prefs.setString('s3Rate', s3Rate);
  if (s4Rate != null) await prefs.setString('s4Rate', s4Rate);
}
