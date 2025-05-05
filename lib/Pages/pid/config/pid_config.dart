// lib/config/pid_config.dart
//
// Все менеджеры используют общий MspSender.send(cmd, payload)
// для автоматического выбора версии MSP и закрытия порта.

import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_msp/flutter_msp.dart';
import 'package:owl/pages/codes/msp_codes.dart';

/* ════════════════════════════════════════════════════════════
 *  Небольшой helper для записи little-endian чисел
 * ════════════════════════════════════════════════════════════ */
extension _BytesWriter on BytesBuilder {
  void u8(int v)  => addByte(v & 0xFF);
  void u16(int v) => add(<int>[v & 0xFF, (v >> 8) & 0xFF]);
  void u32(int v) =>
      add(<int>[v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, (v >> 24) & 0xFF]);
}

/* ────────────────────────────────────────────────────────────
 *  MSP helper
 * ──────────────────────────────────────────────────────────── */

class MspSender {
  static const _portName = 'COM6'; // при желании сделайте настройкой

  /// Отправка пакетa:  MSPv1 — если длина ≤ 255 **и** код ≤ 0xFF
  /// MSPv2 — в остальных случаях (точно как Betaflight-Configurator).
  static Future<void> send(int command, Uint8List payload) async {
    final msp = MSPCommunication(_portName);
    try {
      if (payload.length > 255 || command > 0xFF) {
        await msp.sendMessageV2(command, payload);
      } else {
        await msp.sendMessageV1(command, payload);
      }
    } finally {
      if (msp.port.isOpen) msp.port.close();
    }
  }
}

/* ════════════════════════════════════════════════════════════
 * 1. PID-профиль  (MSP_SET_PID  → 9×u8 = 9 байт)
 * ════════════════════════════════════════════════════════════ */

class PidConfig {
  final List<int> profile; // ровно 9 значений 0-255

  PidConfig({required this.profile}) {
    if (profile.length != 9) {
      throw ArgumentError('PID profile must have exactly 9 values');
    }
  }

  Uint8List toBytes() =>
      Uint8List.fromList(profile.map((e) => e & 0xFF).toList());
}

class PidConfigManager {
  static const _prefsKey = 'pid_profile';

  Future<void> save(PidConfig cfg) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _prefsKey, cfg.profile.map((e) => e.toString()).toList());
    await MspSender.send(MspCodes.MSP_SET_PID, cfg.toBytes());
  }

  Future<PidConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey);
    if (raw == null || raw.length != 9) {
      return PidConfig(profile: List.filled(9, 0));
    }
    return PidConfig(profile: raw.map(int.parse).toList());
  }
}

/* ════════════════════════════════════════════════════════════
 * 2. PID-Advanced  (MSP_SET_PID_ADVANCED ⇢ 65 байт @ API 1.47)
 *    — мы заполняем всё нулями, кроме трёх реально нужных полей.
 * ════════════════════════════════════════════════════════════ */

class PidAdvancedConfig {
  final int deltaMethod;              // byte 6
  final int dtermSetpointTransition;  // byte 8-9  (feedforwardTransition)
  final int dtermSetpointWeight;      // byte 10

  PidAdvancedConfig({
    required this.deltaMethod,
    required this.dtermSetpointTransition,
    required this.dtermSetpointWeight,
  });

  Uint8List toBytes() {
    final b = BytesBuilder();

    /* --- 1. нули до deltaMethod (байты 0-5) --- */
    for (int i = 0; i < 6; i++) b.u8(0);

    /* --- 2. deltaMethod (6) --- */
    b.u8(deltaMethod);

    /* --- 3. vbatPidCompensation (7) — 0 --- */
    b.u8(0);

    /* --- 4. feedforwardTransition (8-9) --- */
    b.u16(dtermSetpointTransition);

    /* --- 5. dtermSetpointWeight (10) --- */
    b.u8(dtermSetpointWeight.clamp(0, 254));

    /* --- 6. оставшиеся 54 байта нулей --- */
    while (b.length < 65) b.u8(0);

    return b.toBytes();
  }
}

class PidAdvancedConfigManager {
  static const _prefsKey = 'pid_adv';

  Future<void> save(PidAdvancedConfig cfg) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, [
      cfg.deltaMethod,
      cfg.dtermSetpointTransition,
      cfg.dtermSetpointWeight,
    ].map((e) => e.toString()).toList());
    await MspSender.send(MspCodes.MSP_SET_PID_ADVANCED, cfg.toBytes());
  }

  Future<PidAdvancedConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? ['0', '0', '0'];
    return PidAdvancedConfig(
      deltaMethod: int.parse(raw[0]),
      dtermSetpointTransition: int.parse(raw[1]),
      dtermSetpointWeight: int.parse(raw[2]),
    );
  }
}

/* ════════════════════════════════════════════════════════════
 * 3. RC-Tuning  (MSP_SET_RC_TUNING  → 24 байта)
 * ════════════════════════════════════════════════════════════ */

class RcTuningConfig {
  /* u8-поля 0-100 % (хранить можно как double для удобства) */
  final double rcRate,
      rcExpo,
      rollRate,
      pitchRate,
      yawRate,
      rcPitchExpo,
      rcYawExpo,
      throttleMid,
      throttleExpo,
      throttleHover /* API≥1.47 */;

  /* доп. поля */
  final int throttleLimitType;     // u8
  final int throttleLimitPercent;  // u8
  final int ratesType;             // u8
  final int rollRateLimit, pitchRateLimit, yawRateLimit; // u16 ×3

  RcTuningConfig({
    required this.rcRate,
    required this.rcExpo,
    required this.rollRate,
    required this.pitchRate,
    required this.yawRate,
    required this.rcPitchExpo,
    required this.rcYawExpo,
    required this.throttleMid,
    required this.throttleExpo,
    required this.throttleHover,
    this.throttleLimitType = 0,
    this.throttleLimitPercent = 100,
    this.ratesType = 0,
    this.rollRateLimit = 1998,
    this.pitchRateLimit = 1998,
    this.yawRateLimit = 1998,
  });

  Uint8List toBytes() {
    int s(double v) => (v * 100).round().clamp(0, 255);

    final b = BytesBuilder();

    b
      ..u8(s(rcRate))
      ..u8(s(rcExpo))
      ..u8(s(rollRate))
      ..u8(s(pitchRate))
      ..u8(s(yawRate))
    /* dynamic_THR_PID — в API≥1.45 =0 */
      ..u8(0)
      ..u8(s(throttleMid))
      ..u8(s(throttleExpo))
    /* dynamic_THR_breakpoint u16, в API≥1.45 =0 */
      ..u16(0)
      ..u8(s(rcYawExpo))
      ..u8(s(0)) /* rcYawRate — не используем */
      ..u8(s(0)) /* rcPitchRate — не используем */
      ..u8(s(rcPitchExpo))
      ..u8(throttleLimitType)
      ..u8(throttleLimitPercent)
      ..u16(rollRateLimit)
      ..u16(pitchRateLimit)
      ..u16(yawRateLimit)
      ..u8(ratesType)
      ..u8(s(throttleHover));

    return b.toBytes(); // 24 байта
  }
}

class RcTuningConfigManager {
  static const _prefsKey = 'rc_tuning';

  Future<void> save(RcTuningConfig cfg) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, [
      cfg.rcRate,
      cfg.rcExpo,
      cfg.rollRate,
      cfg.pitchRate,
      cfg.yawRate,
      cfg.rcPitchExpo,
      cfg.rcYawExpo,
      cfg.throttleMid,
      cfg.throttleExpo,
      cfg.throttleHover,
    ].map((e) => e.toString()).toList());

    await MspSender.send(MspCodes.MSP_SET_RC_TUNING, cfg.toBytes());
  }

  Future<RcTuningConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? List.filled(10, '0');
    double p(int i) => double.parse(raw[i]);

    return RcTuningConfig(
      rcRate: p(0),
      rcExpo: p(1),
      rollRate: p(2),
      pitchRate: p(3),
      yawRate: p(4),
      rcPitchExpo: p(5),
      rcYawExpo: p(6),
      throttleMid: p(7),
      throttleExpo: p(8),
      throttleHover: p(9),
    );
  }
}

/* ════════════════════════════════════════════════════════════
 * 4. Filter-Config  (MSP_SET_FILTER_CONFIG → 40 байт)
 *    — оставим как было, но заполним «хвост» нулями.
 * ════════════════════════════════════════════════════════════ */

class FilterConfig {
  /* 17 исходных параметров, как у вас */
  final int gyroLpf,
      dtermLpf,
      yawLpf,
      gyroNotch1Hz,
      gyroNotch1Cutoff,
      dtermNotchHz,
      dtermNotchCutoff,
      gyroNotch2Hz,
      gyroNotch2Cutoff,
      dynNotchRange,
      dynNotchWidthPercent,
      dynNotchCount,
      dynNotchQ,
      dynNotchMinHz,
      dynNotchMaxHz,
      rpmNotchHarmonics,
      rpmNotchMinHz;

  FilterConfig({
    required this.gyroLpf,
    required this.dtermLpf,
    required this.yawLpf,
    required this.gyroNotch1Hz,
    required this.gyroNotch1Cutoff,
    required this.dtermNotchHz,
    required this.dtermNotchCutoff,
    required this.gyroNotch2Hz,
    required this.gyroNotch2Cutoff,
    required this.dynNotchRange,
    required this.dynNotchWidthPercent,
    required this.dynNotchCount,
    required this.dynNotchQ,
    required this.dynNotchMinHz,
    required this.dynNotchMaxHz,
    required this.rpmNotchHarmonics,
    required this.rpmNotchMinHz,
  });

  Uint8List toBytes() {
    final b = BytesBuilder();

    void addI16(int v) => b.u16(v);

    addI16(gyroLpf);
    addI16(dtermLpf);
    addI16(yawLpf);
    addI16(gyroNotch1Hz);
    addI16(gyroNotch1Cutoff);
    addI16(dtermNotchHz);
    addI16(dtermNotchCutoff);
    addI16(gyroNotch2Hz);
    addI16(gyroNotch2Cutoff);
    b
      ..u8(dynNotchRange)
      ..u8(dynNotchWidthPercent)
      ..u8(dynNotchCount)
      ..u8(0); // dterm_lowpass_type (нам не нужен)
    addI16(dynNotchQ);
    addI16(dynNotchMinHz);
    b
      ..u8(rpmNotchHarmonics)
      ..u8(rpmNotchMinHz);
    addI16(dynNotchMaxHz);

    /* Добиваем до 40 байт нулями */
    while (b.length < 40) b.u8(0);

    return b.toBytes();
  }
}

class FilterConfigManager {
  static const _prefsKey = 'filter_cfg';

  Future<void> save(FilterConfig cfg) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, [
      cfg.gyroLpf,
      cfg.dtermLpf,
      cfg.yawLpf,
      cfg.gyroNotch1Hz,
      cfg.gyroNotch1Cutoff,
      cfg.dtermNotchHz,
      cfg.dtermNotchCutoff,
      cfg.gyroNotch2Hz,
      cfg.gyroNotch2Cutoff,
      cfg.dynNotchRange,
      cfg.dynNotchWidthPercent,
      cfg.dynNotchCount,
      cfg.dynNotchQ,
      cfg.dynNotchMinHz,
      cfg.dynNotchMaxHz,
      cfg.rpmNotchHarmonics,
      cfg.rpmNotchMinHz,
    ].map((e) => e.toString()).toList());

    await MspSender.send(MspCodes.MSP_SET_FILTER_CONFIG, cfg.toBytes());
  }

  Future<FilterConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? List.filled(17, '0');
    int p(int i) => int.parse(raw[i]);

    return FilterConfig(
      gyroLpf: p(0),
      dtermLpf: p(1),
      yawLpf: p(2),
      gyroNotch1Hz: p(3),
      gyroNotch1Cutoff: p(4),
      dtermNotchHz: p(5),
      dtermNotchCutoff: p(6),
      gyroNotch2Hz: p(7),
      gyroNotch2Cutoff: p(8),
      dynNotchRange: p(9),
      dynNotchWidthPercent: p(10),
      dynNotchCount: p(11),
      dynNotchQ: p(12),
      dynNotchMinHz: p(13),
      dynNotchMaxHz: p(14),
      rpmNotchHarmonics: p(15),
      rpmNotchMinHz: p(16),
    );
  }
}

/* ════════════════════════════════════════════════════════════
 * 5. Simplified-Tuning sliders (MSP_SET_SIMPLIFIED_TUNING)
 *    — строго тот же порядок, что в Betaflight.
 * ════════════════════════════════════════════════════════════ */

class SimplifiedTuningConfig {
  // блок PID-слайдеров
  final int sliderPidsMode,
      masterMultiplier,
      rollPitchRatio,
      iGain,
      dGain,
      piGain,
      dMaxGain,
      feedforwardGain,
      pitchPiGain;

  // блок D-term
  final int dtermFilterMode, dtermFilterMultiplier;

  // блок Gyro
  final int gyroFilterMode, gyroFilterMultiplier;

  SimplifiedTuningConfig({
    required this.sliderPidsMode,
    required this.masterMultiplier,
    required this.rollPitchRatio,
    required this.iGain,
    required this.dGain,
    required this.piGain,
    required this.dMaxGain,
    required this.feedforwardGain,
    required this.pitchPiGain,
    required this.dtermFilterMode,
    required this.dtermFilterMultiplier,
    required this.gyroFilterMode,
    required this.gyroFilterMultiplier,
  });

  Uint8List toBytes() {
    final b = BytesBuilder();

    /* --- 1. PID-sliders (9 байт + 2×u32 zero) --- */
    b
      ..u8(sliderPidsMode)
      ..u8(masterMultiplier)
      ..u8(rollPitchRatio)
      ..u8(iGain)
      ..u8(dGain)
      ..u8(piGain)
      ..u8(dMaxGain)
      ..u8(feedforwardGain)
      ..u8(pitchPiGain)
      ..u32(0)
      ..u32(0);

    /* --- 2. D-term slider (2 u8 + 2×u16 zeros + 2×u32 zeros) --- */
    b
      ..u8(dtermFilterMode)
      ..u8(dtermFilterMultiplier)
      ..u16(0)
      ..u16(0)
      ..u16(0)
      ..u16(0)
      ..u32(0)
      ..u32(0);

    /* --- 3. Gyro slider (2 u8 + 2×u16 zeros + 2×u32 zeros) --- */
    b
      ..u8(gyroFilterMode)
      ..u8(gyroFilterMultiplier)
      ..u16(0)
      ..u16(0)
      ..u16(0)
      ..u16(0)
      ..u32(0)
      ..u32(0);

    return b.toBytes(); // 17 + 18 + 18 = 53 байта
  }
}

class SimplifiedTuningConfigManager {
  static const _prefsKey = 'simp_tune';

  Future<void> save(SimplifiedTuningConfig cfg) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, [
      cfg.sliderPidsMode,
      cfg.masterMultiplier,
      cfg.rollPitchRatio,
      cfg.iGain,
      cfg.dGain,
      cfg.piGain,
      cfg.dMaxGain,
      cfg.feedforwardGain,
      cfg.pitchPiGain,
      cfg.dtermFilterMode,
      cfg.dtermFilterMultiplier,
      cfg.gyroFilterMode,
      cfg.gyroFilterMultiplier,
    ].map((e) => e.toString()).toList());

    await MspSender.send(MspCodes.MSP_SET_SIMPLIFIED_TUNING, cfg.toBytes());
  }

  Future<SimplifiedTuningConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? List.filled(13, '0');
    int p(int i) => int.parse(raw[i]);

    return SimplifiedTuningConfig(
      sliderPidsMode: p(0),
      masterMultiplier: p(1),
      rollPitchRatio: p(2),
      iGain: p(3),
      dGain: p(4),
      piGain: p(5),
      dMaxGain: p(6),
      feedforwardGain: p(7),
      pitchPiGain: p(8),
      dtermFilterMode: p(9),
      dtermFilterMultiplier: p(10),
      gyroFilterMode: p(11),
      gyroFilterMultiplier: p(12),
    );
  }
}

/* ════════════════════════════════════════════════════════════
 * 6. Profile / Rate names  — без изменений
 * ════════════════════════════════════════════════════════════ */

class ProfileNamesConfig {
  final List<String> pid;
  final List<String> rate;

  ProfileNamesConfig({required this.pid, required this.rate});

  Uint8List _pack(List<String> names) {
    final b = BytesBuilder();
    for (final n in names) {
      b.add(Uint8List.fromList(n.codeUnits));
      b.addByte(0); // null-terminator
    }
    return b.toBytes();
  }

  Uint8List get pidBytes => _pack(pid);
  Uint8List get rateBytes => _pack(rate);
}

class ProfileNamesConfigManager {
  static const _pidKey = 'names_pid', _rateKey = 'names_rate';

  Future<void> save(ProfileNamesConfig cfg) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_pidKey, cfg.pid);
    await prefs.setStringList(_rateKey, cfg.rate);

    // MSP2_SET_TEXT всегда посылаем v2 (код > 0xFF)
    await _sendText(cfg.pidBytes, MspCodes.PID_PROFILE_NAME);
    await _sendText(cfg.rateBytes, MspCodes.RATE_PROFILE_NAME);
  }

  Future<ProfileNamesConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ProfileNamesConfig(
      pid: prefs.getStringList(_pidKey) ?? [],
      rate: prefs.getStringList(_rateKey) ?? [],
    );
  }

  Future<void> _sendText(Uint8List data, int subCmd) async {
    final full = Uint8List(data.length + 1);
    full[0] = subCmd;
    full.setRange(1, full.length, data);

    await MspSender.send(MspCodes.MSP2_SET_TEXT, full); // будет MSPv2
  }
}
