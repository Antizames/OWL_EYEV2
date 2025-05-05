import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_msp/flutter_msp.dart';

class RXConfig {
  int serialrxProvider;
  int stickMax;
  int stickCenter;
  int stickMin;
  int spektrumSatBind;
  int rxMinUsec;
  int rxMaxUsec;
  int rcInterpolation;
  int rcInterpolationInterval;
  int rcInterpolationChannels;
  int airModeActivateThreshold;
  int rxSpiProtocol;
  int rxSpiId;
  int rxSpiRfChannelCount;
  int fpvCamAngleDegrees;
  int rcSmoothingType;
  int rcSmoothingSetpointCutoff;
  int rcSmoothingFeedforwardCutoff;
  int rcSmoothingInputType;
  int rcSmoothingDerivativeType;
  int usbCdcHidType;
  int rcSmoothingAutoFactor;
  int rcSmoothingMode;
  List<int> elrsUid;
  int elrsModelId;

  RXConfig({
    required this.serialrxProvider,
    required this.stickMax,
    required this.stickCenter,
    required this.stickMin,
    required this.spektrumSatBind,
    required this.rxMinUsec,
    required this.rxMaxUsec,
    required this.rcInterpolation,
    required this.rcInterpolationInterval,
    required this.rcInterpolationChannels,
    required this.airModeActivateThreshold,
    required this.rxSpiProtocol,
    required this.rxSpiId,
    required this.rxSpiRfChannelCount,
    required this.fpvCamAngleDegrees,
    required this.rcSmoothingType,
    required this.rcSmoothingSetpointCutoff,
    required this.rcSmoothingFeedforwardCutoff,
    required this.rcSmoothingInputType,
    required this.rcSmoothingDerivativeType,
    required this.usbCdcHidType,
    required this.rcSmoothingAutoFactor,
    required this.rcSmoothingMode,
    required this.elrsUid,
    required this.elrsModelId,
  });

  // Метод для обновления части конфигурации
  void update({
    int? serialrxProvider,
    int? stickMax,
    int? stickCenter,
    int? stickMin,
    int? spektrumSatBind,
    int? rxMinUsec,
    int? rxMaxUsec,
    int? rcInterpolation,
    int? rcInterpolationInterval,
    int? rcInterpolationChannels,
    int? airModeActivateThreshold,
    int? rxSpiProtocol,
    int? rxSpiId,
    int? rxSpiRfChannelCount,
    int? fpvCamAngleDegrees,
    int? rcSmoothingType,
    int? rcSmoothingSetpointCutoff,
    int? rcSmoothingFeedforwardCutoff,
    int? rcSmoothingInputType,
    int? rcSmoothingDerivativeType,
    int? usbCdcHidType,
    int? rcSmoothingAutoFactor,
    int? rcSmoothingMode,
    List<int>? elrsUid,
    int? elrsModelId,
  }) {
    if (serialrxProvider != null) this.serialrxProvider = serialrxProvider;
    if (stickMax != null) this.stickMax = stickMax;
    if (stickCenter != null) this.stickCenter = stickCenter;
    if (stickMin != null) this.stickMin = stickMin;
    if (spektrumSatBind != null) this.spektrumSatBind = spektrumSatBind;
    if (rxMinUsec != null) this.rxMinUsec = rxMinUsec;
    if (rxMaxUsec != null) this.rxMaxUsec = rxMaxUsec;
    if (rcInterpolation != null) this.rcInterpolation = rcInterpolation;
    if (rcInterpolationInterval != null) this.rcInterpolationInterval = rcInterpolationInterval;
    if (rcInterpolationChannels != null) this.rcInterpolationChannels = rcInterpolationChannels;
    if (airModeActivateThreshold != null) this.airModeActivateThreshold = airModeActivateThreshold;
    if (rxSpiProtocol != null) this.rxSpiProtocol = rxSpiProtocol;
    if (rxSpiId != null) this.rxSpiId = rxSpiId;
    if (rxSpiRfChannelCount != null) this.rxSpiRfChannelCount = rxSpiRfChannelCount;
    if (fpvCamAngleDegrees != null) this.fpvCamAngleDegrees = fpvCamAngleDegrees;
    if (rcSmoothingType != null) this.rcSmoothingType = rcSmoothingType;
    if (rcSmoothingSetpointCutoff != null) this.rcSmoothingSetpointCutoff = rcSmoothingSetpointCutoff;
    if (rcSmoothingFeedforwardCutoff != null) this.rcSmoothingFeedforwardCutoff = rcSmoothingFeedforwardCutoff;
    if (rcSmoothingInputType != null) this.rcSmoothingInputType = rcSmoothingInputType;
    if (rcSmoothingDerivativeType != null) this.rcSmoothingDerivativeType = rcSmoothingDerivativeType;
    if (usbCdcHidType != null) this.usbCdcHidType = usbCdcHidType;
    if (rcSmoothingAutoFactor != null) this.rcSmoothingAutoFactor = rcSmoothingAutoFactor;
    if (rcSmoothingMode != null) this.rcSmoothingMode = rcSmoothingMode;
    if (elrsUid != null) this.elrsUid = elrsUid;
    if (elrsModelId != null) this.elrsModelId = elrsModelId;
  }

  Uint8List toBytes(String apiVersion) {
    final buffer = BytesBuilder();

    buffer.addByte(serialrxProvider);
    buffer.add(_to16Bit(stickMax));
    buffer.add(_to16Bit(stickCenter));
    buffer.add(_to16Bit(stickMin));
    buffer.addByte(spektrumSatBind);
    buffer.add(_to16Bit(rxMinUsec));
    buffer.add(_to16Bit(rxMaxUsec));
    buffer.addByte(rcInterpolation);
    buffer.addByte(rcInterpolationInterval);
    buffer.add(_to16Bit(airModeActivateThreshold));
    buffer.addByte(rxSpiProtocol);
    buffer.add(_to32Bit(rxSpiId));
    buffer.addByte(rxSpiRfChannelCount);
    buffer.addByte(fpvCamAngleDegrees);
    buffer.addByte(rcInterpolationChannels);
    buffer.addByte(rcSmoothingType);
    buffer.addByte(rcSmoothingSetpointCutoff);
    buffer.addByte(rcSmoothingFeedforwardCutoff);
    buffer.addByte(rcSmoothingInputType);
    buffer.addByte(rcSmoothingDerivativeType);
    buffer.addByte(usbCdcHidType);
    buffer.addByte(rcSmoothingAutoFactor);
    buffer.addByte(rcSmoothingMode);

    // Сохраняем UID в байты
    for (var uid in elrsUid) {
      buffer.addByte(uid);
    }

    buffer.addByte(elrsModelId);

    return buffer.toBytes();
  }

  List<int> _to16Bit(int value) {
    return [
      value & 0xFF,
      (value >> 8) & 0xFF,
    ];
  }

  List<int> _to32Bit(int value) {
    return [
      value & 0xFF,
      (value >> 8) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 24) & 0xFF,
    ];
  }
}

class RXManager {
  Future<void> saveConfig({
    int? serialrxProvider,
    int? stickMax,
    int? stickCenter,
    int? stickMin,
    int? spektrumSatBind,
    int? rxMinUsec,
    int? rxMaxUsec,
    int? rcInterpolation,
    int? rcInterpolationInterval,
    int? rcInterpolationChannels,
    int? airModeActivateThreshold,
    int? rxSpiProtocol,
    int? rxSpiId,
    int? rxSpiRfChannelCount,
    int? fpvCamAngleDegrees,
    int? rcSmoothingType,
    int? rcSmoothingSetpointCutoff,
    int? rcSmoothingFeedforwardCutoff,
    int? rcSmoothingInputType,
    int? rcSmoothingDerivativeType,
    int? usbCdcHidType,
    int? rcSmoothingAutoFactor,
    int? rcSmoothingMode,
    List<int>? elrsUid,
    int? elrsModelId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final currentConfig = RXConfig(
      serialrxProvider: prefs.getInt('serialrxProvider') ?? 0,
      stickMax: prefs.getInt('stickMax') ?? 1000,
      stickCenter: prefs.getInt('stickCenter') ?? 1500,
      stickMin: prefs.getInt('stickMin') ?? 1000,
      spektrumSatBind: prefs.getInt('spektrumSatBind') ?? 0,
      rxMinUsec: prefs.getInt('rxMinUsec') ?? 1000,
      rxMaxUsec: prefs.getInt('rxMaxUsec') ?? 1000,
      rcInterpolation: prefs.getInt('rcInterpolation') ?? 0,
      rcInterpolationInterval: prefs.getInt('rcInterpolationInterval') ?? 10,
      rcInterpolationChannels: prefs.getInt('rcInterpolationChannels') ?? 0,
      airModeActivateThreshold: prefs.getInt('airModeActivateThreshold') ?? 1000,
      rxSpiProtocol: prefs.getInt('rxSpiProtocol') ?? 0,
      rxSpiId: prefs.getInt('rxSpiId') ?? 0,
      rxSpiRfChannelCount: prefs.getInt('rxSpiRfChannelCount') ?? 0,
      fpvCamAngleDegrees: prefs.getInt('fpvCamAngleDegrees') ?? 0,
      rcSmoothingType: prefs.getInt('rcSmoothingType') ?? 0,
      rcSmoothingSetpointCutoff: prefs.getInt('rcSmoothingSetpointCutoff') ?? 0,
      rcSmoothingFeedforwardCutoff: prefs.getInt('rcSmoothingFeedforwardCutoff') ?? 0,
      rcSmoothingInputType: prefs.getInt('rcSmoothingInputType') ?? 0,
      rcSmoothingDerivativeType: prefs.getInt('rcSmoothingDerivativeType') ?? 0,
      usbCdcHidType: prefs.getInt('usbCdcHidType') ?? 0,
      rcSmoothingAutoFactor: prefs.getInt('rcSmoothingAutoFactor') ?? 0,
      rcSmoothingMode: prefs.getInt('rcSmoothingMode') ?? 0,
      elrsUid: prefs.getStringList('elrsUid')?.map((e) => int.parse(e)).toList() ?? [0],
      elrsModelId: prefs.getInt('elrsModelId') ?? 0,
    );

    currentConfig.update(
      serialrxProvider: serialrxProvider,
      stickMax: stickMax,
      stickCenter: stickCenter,
      stickMin: stickMin,
      spektrumSatBind: spektrumSatBind,
      rxMinUsec: rxMinUsec,
      rxMaxUsec: rxMaxUsec,
      rcInterpolation: rcInterpolation,
      rcInterpolationInterval: rcInterpolationInterval,
      rcInterpolationChannels: rcInterpolationChannels,
      airModeActivateThreshold: airModeActivateThreshold,
      rxSpiProtocol: rxSpiProtocol,
      rxSpiId: rxSpiId,
      rxSpiRfChannelCount: rxSpiRfChannelCount,
      fpvCamAngleDegrees: fpvCamAngleDegrees,
      rcSmoothingType: rcSmoothingType,
      rcSmoothingSetpointCutoff: rcSmoothingSetpointCutoff,
      rcSmoothingFeedforwardCutoff: rcSmoothingFeedforwardCutoff,
      rcSmoothingInputType: rcSmoothingInputType,
      rcSmoothingDerivativeType: rcSmoothingDerivativeType,
      usbCdcHidType: usbCdcHidType,
      rcSmoothingAutoFactor: rcSmoothingAutoFactor,
      rcSmoothingMode: rcSmoothingMode,
      elrsUid: elrsUid,
      elrsModelId: elrsModelId,
    );

    final configBytes = currentConfig.toBytes("1.0");

    // Сохраняем в SharedPreferences
    await prefs.setStringList('configBytes', configBytes.map((byte) => byte.toString()).toList());
  }


Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();

    final serialrxProvider = prefs.getInt('serialrxProvider') ?? 0;
    final stickMax = prefs.getInt('stickMax') ?? 1000;
    final stickCenter = prefs.getInt('stickCenter') ?? 1500;
    final stickMin = prefs.getInt('stickMin') ?? 1000;
    final spektrumSatBind = prefs.getInt('spektrumSatBind') ?? 0;
    final rxMinUsec = prefs.getInt('rxMinUsec') ?? 1000;
    final rxMaxUsec = prefs.getInt('rxMaxUsec') ?? 1000;
    final rcInterpolation = prefs.getInt('rcInterpolation') ?? 0;
    final rcInterpolationInterval = prefs.getInt('rcInterpolationInterval') ?? 10;
    final rcInterpolationChannels = prefs.getInt('rcInterpolationChannels') ?? 0;
    final airModeActivateThreshold = prefs.getInt('airModeActivateThreshold') ?? 1000;
    final rxSpiProtocol = prefs.getInt('rxSpiProtocol') ?? 0;
    final rxSpiId = prefs.getInt('rxSpiId') ?? 0;
    final rxSpiRfChannelCount = prefs.getInt('rxSpiRfChannelCount') ?? 0;
    final fpvCamAngleDegrees = prefs.getInt('fpvCamAngleDegrees') ?? 0;
    final rcSmoothingType = prefs.getInt('rcSmoothingType') ?? 0;
    final rcSmoothingSetpointCutoff = prefs.getInt('rcSmoothingSetpointCutoff') ?? 0;
    final rcSmoothingFeedforwardCutoff = prefs.getInt('rcSmoothingFeedforwardCutoff') ?? 0;
    final rcSmoothingInputType = prefs.getInt('rcSmoothingInputType') ?? 0;
    final rcSmoothingDerivativeType = prefs.getInt('rcSmoothingDerivativeType') ?? 0;
    final usbCdcHidType = prefs.getInt('usbCdcHidType') ?? 0;
    final rcSmoothingAutoFactor = prefs.getInt('rcSmoothingAutoFactor') ?? 0;
    final rcSmoothingMode = prefs.getInt('rcSmoothingMode') ?? 0;
    final elrsUid = prefs.getStringList('elrsUid')?.map((e) => int.parse(e)).toList() ?? [];
    final elrsModelId = prefs.getInt('elrsModelId') ?? 0;

    print('Loaded RXConfig: $serialrxProvider, $stickMax, $stickCenter, ...');
  }
  void sendToBoard(Uint8List data) {
    const int commandCode = 33;  // Укажите свой код команды
    MSPCommunication mspComm = MSPCommunication('COM6');
    print("Payload length: ${data.length}");
    mspComm.sendMessageV1(commandCode, data).then((_) {
      print('RX configuration sent successfully.');
    }).catchError((error) {
      print('Error sending RX configuration: $error');
    });
  }
}
