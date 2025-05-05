import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_msp/flutter_msp.dart';

class NameConfig {
  final String name;

  NameConfig({
    this.name = '',
  });

  Uint8List toBytes() {
    const int MSP_BUFFER_SIZE = 64;
    List<int> buffer = [];
    for (int i = 0; i < name.length && i < MSP_BUFFER_SIZE; i++) {
      buffer.add(name.codeUnitAt(i));
    }
    return Uint8List.fromList(buffer);
  }
}

class NameManager {
  Future<void> saveConfig({
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    final config = NameConfig(
      name: name,
    );
    final data = config.toBytes();
    sendToBoard(data);
  }
  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('name');
    final name = prefs.getInt('name') ?? 0;
    print('Loaded Mixer Config: name=$name');
  }
  void sendToBoard(Uint8List data) {
    const int commandCode = 11;
    MSPCommunication mspComm = MSPCommunication('COM6');
    print("Payload length: ${data.length}");
    mspComm.sendMessageV1(commandCode, data).then((_) {
      print('Mixer configuration sent successfully.');
    }).catchError((error) {
      print('Error sending mixer configuration: $error');
    });
  }
}
