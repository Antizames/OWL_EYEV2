import 'dart:typed_data';
class AttitudeData {
  final double roll;
  final double pitch;
  final double yaw;

  AttitudeData({required this.roll, required this.pitch, required this.yaw});

  factory AttitudeData.fromBytes(Uint8List data) {
    final roll = _toSignedInt16(data[0], data[1]) / 10.0;
    final pitch = _toSignedInt16(data[2], data[3]) / 10.0;
    final yaw = _toSignedInt16(data[4], data[5]) / 10.0;

    return AttitudeData(roll: roll, pitch: pitch, yaw: yaw);
  }

  static int _toSignedInt16(int lo, int hi) {
    int value = (hi << 8) | lo;
    if (value & 0x8000 != 0) value -= 0x10000;
    return value;
  }

  @override
  String toString() => 'AttitudeData(roll: $roll, pitch: $pitch, yaw: $yaw)';
}

class AttitudeManager {
  static const int mspAttitudeCode = 108; // MSP_ATTITUDE

  Future<AttitudeData?> fetchAttitude() async {
    await Future.delayed(Duration(milliseconds: 100)); // эмуляция задержки
    return AttitudeData(
      pitch: 5.0,
      roll: -2.3,
      yaw: 180.0,
    );
  }

}

