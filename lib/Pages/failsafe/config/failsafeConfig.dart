// lib/pages/failsafe/config/failsafeConfig.dart

import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_msp/flutter_msp.dart';
import 'package:owl/pages/codes/msp_codes.dart';

/// Конфигурация приёмника (RX)
class RxConfig {
  final int rxMinUsec;
  final int rxMaxUsec;

  RxConfig({ required this.rxMinUsec, required this.rxMaxUsec });

  Uint8List toBytes() {
    final b = BytesBuilder();
    // === в точном порядке, как Betaflight-GUI ===
    b.addByte(0);                   // serialrx_provider
    b.add(_i16(0));                 // stick_max
    b.add(_i16(0));                 // stick_center
    b.add(_i16(0));                 // stick_min
    b.addByte(0);                   // spektrum_sat_bind

    b.add(_i16(rxMinUsec));         // rx_min_usec
    b.add(_i16(rxMaxUsec));         // rx_max_usec

    b.addByte(0);                   // rcInterpolation
    b.addByte(0);                   // rcInterpolationInterval
    b.add(_i16(0));                 // airModeActivateThreshold
    b.addByte(0);                   // rxSpiProtocol
    b.add(_u32le(0));               // rxSpiId
    b.addByte(0);                   // rxSpiRfChannelCount
    b.addByte(0);                   // fpvCamAngleDegrees
    b.addByte(0);                   // rcInterpolationChannels
    b.addByte(0);                   // rcSmoothingType
    b.addByte(0);                   // rcSmoothingSetpointCutoff
    b.addByte(0);                   // rcSmoothingFeedforwardCutoff
    b.addByte(0);                   // rcSmoothingInputType
    b.addByte(0);                   // rcSmoothingDerivativeType

    return b.toBytes();
  }

  static List<int> _i16(int v) => [v & 0xFF, (v >> 8) & 0xFF];
  static List<int> _u32le(int v) => [
    v & 0xFF,
    (v >> 8) & 0xFF,
    (v >> 16) & 0xFF,
    (v >> 24) & 0xFF,
  ];
}

/// Основные failsafe-параметры
class FailsafeMainConfig {
  final int failsafeThrottle;         // uint16
  final int failsafeOffDelay;         // uint8  (landing time)
  final int failsafeThrottleLowDelay; // uint16
  final int failsafeDelay;            // uint8  (general delay)
  final int failsafeSwitchMode;       // uint8
  final int failsafeProcedure;        // uint8  (0=land,1=drop,2=gps)

  FailsafeMainConfig({
    required this.failsafeThrottle,
    required this.failsafeOffDelay,
    required this.failsafeThrottleLowDelay,
    required this.failsafeDelay,
    required this.failsafeProcedure,
    required this.failsafeSwitchMode,
  });

  Uint8List toBytes() {
    final b = BytesBuilder();
    b.addByte(failsafeDelay);                   // push8
    b.addByte(failsafeOffDelay);                // push8
    b.add(_i16(failsafeThrottle));              // push16
    b.addByte(failsafeSwitchMode);              // push8
    b.add(_i16(failsafeThrottleLowDelay));      // push16
    b.addByte(failsafeProcedure);               // push8
    return b.toBytes();
  }

  static List<int> _i16(int v) => [v & 0xFF, (v >> 8) & 0xFF];
}

/// Поведение каналов при потере RX
class RxFailConfig {
  final int mode;   // 0=Auto,1=Hold,2=Set
  final int value;  // uint16

  RxFailConfig({ required this.mode, required this.value });
}

/// Параметры GPS Rescue
class GpsRescueConfig {
  final int angle;               // uint16
  final int returnAltitude;      // uint16
  final int descentDistance;     // uint16
  final int groundSpeed;         // uint16
  final int throttleMin;         // uint16
  final int throttleMax;         // uint16
  final int throttleHover;       // uint16
  final int sanityChecks;        // uint8
  final int minSats;             // uint8
  final int ascendRate;          // uint16
  final int descendRate;         // uint16
  final int allowArmingWithoutFix; // uint8
  final int altitudeMode;        // uint8
  final int minStartDist;        // uint16
  final int initialClimb;        // uint16

  GpsRescueConfig({
    required this.angle,
    required this.returnAltitude,
    required this.descentDistance,
    required this.groundSpeed,
    required this.throttleMin,
    required this.throttleMax,
    required this.throttleHover,
    required this.sanityChecks,
    required this.minSats,
    required this.ascendRate,
    required this.descendRate,
    required this.allowArmingWithoutFix,
    required this.altitudeMode,
    required this.minStartDist,
    required this.initialClimb,
  });

  Uint8List toBytes() {
    final b = BytesBuilder();
    b.add(_i16(angle));
    b.add(_i16(returnAltitude));
    b.add(_i16(descentDistance));
    b.add(_i16(groundSpeed));
    b.add(_i16(throttleMin));
    b.add(_i16(throttleMax));
    b.add(_i16(throttleHover));
    b.addByte(sanityChecks);
    b.addByte(minSats);
    b.add(_i16(ascendRate));
    b.add(_i16(descendRate));
    b.addByte(allowArmingWithoutFix);
    b.addByte(altitudeMode);
    b.add(_i16(minStartDist));
    b.add(_i16(initialClimb));
    return b.toBytes();
  }

  static List<int> _i16(int v) => [v & 0xFF, (v >> 8) & 0xFF];
}

/// Общий класс конфигурации failsafe
class FailsafeConfig {
  final RxConfig rxConfig;
  final FailsafeMainConfig mainConfig;
  final List<RxFailConfig> rxFailConfigs;
  final GpsRescueConfig gpsRescue;
  final bool gpsRescueEnabled;   // ← добавлено!

  FailsafeConfig({
    required this.rxConfig,
    required this.mainConfig,
    required this.rxFailConfigs,
    required this.gpsRescue,
    required this.gpsRescueEnabled, // ←
  });
}

/// Менеджер для сохранения и отправки на плату
class FailsafeConfigManager {
  static const _prefsRx     = 'failsafe_rx';
  static const _prefsMain   = 'failsafe_main';
  static const _prefsRxFail = 'failsafe_rxfail';
  static const _prefsGps    = 'failsafe_gps';

  Future<void> save(FailsafeConfig cfg) async {
    final prefs = await SharedPreferences.getInstance();

    // 1) RX Config
    await prefs.setStringList(
      _prefsRx,
      [cfg.rxConfig.rxMinUsec.toString(), cfg.rxConfig.rxMaxUsec.toString()],
    );
    await _send(MspCodes.MSP_SET_RX_CONFIG, cfg.rxConfig.toBytes());

    // 2) Main failsafe
    await prefs.setStringList(_prefsMain, [
      cfg.mainConfig.failsafeThrottle.toString(),
      cfg.mainConfig.failsafeOffDelay.toString(),
      cfg.mainConfig.failsafeThrottleLowDelay.toString(),
      cfg.mainConfig.failsafeDelay.toString(),
      cfg.mainConfig.failsafeProcedure.toString(),
      cfg.mainConfig.failsafeSwitchMode.toString(),
    ]);
    await _send(MspCodes.MSP_SET_FAILSAFE_CONFIG, cfg.mainConfig.toBytes());

    // 3) RX-fail per channel
    await prefs.setStringList(_prefsRxFail, [
      for (final r in cfg.rxFailConfigs) r.mode.toString(),
      for (final r in cfg.rxFailConfigs) r.value.toString(),
    ]);
    for (var i = 0; i < cfg.rxFailConfigs.length; i++) {
      final r = cfg.rxFailConfigs[i];
      final buf = BytesBuilder()
        ..addByte(i)
        ..addByte(r.mode)
        ..add(_i16(r.value));
      await _send(MspCodes.MSP_SET_RXFAIL_CONFIG, buf.toBytes());
    }

    // 4) GPS Rescue parameters
    await prefs.setStringList(_prefsGps, [
      cfg.gpsRescue.angle.toString(),
      cfg.gpsRescue.returnAltitude.toString(),
      cfg.gpsRescue.descentDistance.toString(),
      cfg.gpsRescue.groundSpeed.toString(),
      cfg.gpsRescue.throttleMin.toString(),
      cfg.gpsRescue.throttleMax.toString(),
      cfg.gpsRescue.throttleHover.toString(),
      cfg.gpsRescue.sanityChecks.toString(),
      cfg.gpsRescue.minSats.toString(),
      cfg.gpsRescue.ascendRate.toString(),
      cfg.gpsRescue.descendRate.toString(),
      cfg.gpsRescue.allowArmingWithoutFix.toString(),
      cfg.gpsRescue.altitudeMode.toString(),
      cfg.gpsRescue.minStartDist.toString(),
      cfg.gpsRescue.initialClimb.toString(),
    ]);
    await _send(MspCodes.MSP_SET_GPS_RESCUE, cfg.gpsRescue.toBytes());

    // 5) Включить/выключить фичу GPS Rescue
    //    В Betaflight FEATURE_GPS_RESCUE == (1 << 13)
    final int featureMask = cfg.gpsRescueEnabled ? (1 << 13) : 0;
    // упакуем в little-endian 32 бита
    final featureBuf = BytesBuilder()..add(_u32le(featureMask));
    await _send(MspCodes.MSP_SET_FEATURE_CONFIG, featureBuf.toBytes());
  }

  Future<void> _send(int cmd, Uint8List data) async {
    final msp = MSPCommunication('COM6');
    try {
      await msp.sendMessageV1(cmd, data);
    } finally {
      if (msp.port.isOpen) msp.port.close();
    }
  }

  static List<int> _i16(int v) => [v & 0xFF, (v >> 8) & 0xFF];
  static List<int> _u32le(int v) => [
    v & 0xFF,
    (v >> 8) & 0xFF,
    (v >> 16) & 0xFF,
    (v >> 24) & 0xFF,
  ];
}
