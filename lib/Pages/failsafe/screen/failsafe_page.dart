// lib/pages/failsafe_page.dart

import 'package:flutter/material.dart';
import 'package:owl/pages/appBar/widgets/customAppBar.dart';
import 'package:owl/pages/sideBarMenu/sidebar_menu.dart';
import 'package:owl/pages/failsafe/config/failsafeConfig.dart';

class FailsafePage extends StatefulWidget {
  const FailsafePage({super.key});

  @override
  State<FailsafePage> createState() => _FailsafePageState();
}

class _FailsafePageState extends State<FailsafePage> {
  // Stage 1 — допустимая длительность импульсов
  double minPulse = 1000;
  double maxPulse = 2000;

  // Stage 1 — поведение каналов
  final List<String> channels = [
    'Крен [A]',
    'Тангаж [E]',
    'Рысканье [R]',
    'Газ [T]',
    ...List.generate(12, (i) => 'AUX ${i + 1}'),
  ];
  final Map<String, String> channelModes = {};

  // Stage 2 — настройки
  String switchStage = 'Этап 1';
  double stage1Delay = 2.0;
  double throttleDelay = 5.0;

  // Stage 2 — процедура
  String failsafeMode = 'Приземление';
  double landingThrottle = 1000;
  double offDelay = 1.5;

  // GPS Rescue
  bool gpsRescue = false;
  double gpsAngle = 45;
  double gpsReturnAltitude = 20;
  double gpsAscendRate = 2.0;
  double gpsDescendRate = 1.5;
  int gpsMinSats = 6;

  final _manager = FailsafeConfigManager();

  void _openSidebarMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      pageBuilder: (c, a1, a2) => const SidebarMenu(),
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, anim, sec, child) {
        final offset = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
        return SlideTransition(position: offset, child: child);
      },
    );
  }

  Future<void> _saveConfig() async {
    // 1) RxConfig
    final rx = RxConfig(
      rxMinUsec: minPulse.round(),
      rxMaxUsec: maxPulse.round(),
    );

    // 2) RxFailConfig
    final List<RxFailConfig> rxFails = [];
    for (var i = 0; i < channels.length; i++) {
      final ch = channels[i];
      // для первых трёх каналов есть "Авто"
      final defaultMode = i < 3 ? 'Авто' : 'Удержание';
      final modeStr = channelModes[ch] ?? defaultMode;
      final modeCode = modeStr == 'Удержание'
          ? 1
          : modeStr == 'Установить'
          ? 2
          : 0;
      rxFails.add(RxFailConfig(mode: modeCode, value: 0));
    }

    // 3) FailsafeMainConfig
    final mainCfg = FailsafeMainConfig(
      failsafeThrottle:
      failsafeMode == 'Приземление' ? landingThrottle.round() : 0,
      failsafeOffDelay: (offDelay * 10).round(),
      failsafeThrottleLowDelay: (throttleDelay * 10).round(),
      failsafeDelay: (stage1Delay * 10).round(),
      failsafeProcedure: failsafeMode == 'Падение'
          ? 1
          : failsafeMode == 'GPS Rescue'
          ? 2
          : 0,
      failsafeSwitchMode: switchStage == 'Этап 2' ? 1 : 0,
    );

    // 4) GpsRescueConfig
    final gps = GpsRescueConfig(
      angle: gpsAngle.round(),
      returnAltitude: gpsReturnAltitude.round(),
      descentDistance: 0,
      groundSpeed: 0,
      throttleMin: 0,
      throttleMax: 0,
      throttleHover: 0,
      minSats: gpsMinSats,
      sanityChecks: 0,
      ascendRate: (gpsAscendRate * 100).round(),
      descendRate: (gpsDescendRate * 100).round(),
      allowArmingWithoutFix: gpsRescue ? 1 : 0,
      altitudeMode: 0,
      minStartDist: 0,
      initialClimb: 0,
    );

    // 5) Собираем полный конфиг
    final config = FailsafeConfig(
      rxConfig: rx,
      mainConfig: mainCfg,
      rxFailConfigs: rxFails,
      gpsRescue: gps,
      gpsRescueEnabled: gpsRescue,  // ← вот это добавили
    );


    // 6) Сохраняем и отправляем
    try {
      await _manager.save(config);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failsafe настройки отправлены на плату')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при отправке: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          CustomAppBar(
            title: 'Отказобезопасность',
            leadingIcon: IconButton(
              icon: const Icon(Icons.menu, color: Colors.grey),
              onPressed: () => _openSidebarMenu(context),
            ),
            trailingIcon: IconButton(
              icon: const Icon(Icons.save, color: Colors.grey),
              onPressed: _saveConfig,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE9EDF5), Color(0xFF95989E)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildSectionTitle('Допустимая длительность импульсов'),
                  _buildStyledContainer(
                    child: Column(
                      children: [
                        _buildNumberField(
                          'Минимальная длительность',
                          minPulse,
                              (v) => setState(() => minPulse = v),
                        ),
                        const SizedBox(height: 10),
                        _buildNumberField(
                          'Максимальная длительность',
                          maxPulse,
                              (v) => setState(() => maxPulse = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Этап 1 — Поведение каналов'),
                  _buildStyledContainer(
                    child: Column(
                      children: channels.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final channel = entry.value;
                        final options = idx < 3
                            ? const ['Авто', 'Удержание', 'Установить']
                            : const ['Удержание', 'Установить'];
                        final defaultValue = channelModes[channel] ??
                            (idx < 3 ? 'Авто' : 'Удержание');
                        return _buildDropdownRow(
                          channel,
                          defaultValue,
                              (val) => setState(() => channelModes[channel] = val),
                          options: options,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Этап 2 — Настройки'),
                  _buildStyledContainer(
                    child: Column(
                      children: [
                        _buildDropdownRow(
                          'Переключатель failsafe',
                          switchStage,
                              (val) => setState(() => switchStage = val),
                          options: const ['Этап 1', 'Этап 2'],
                        ),
                        const SizedBox(height: 10),
                        _buildNumberField(
                          'Задержка Этапа 1 (сек)',
                          stage1Delay,
                              (v) => setState(() => stage1Delay = v),
                        ),
                        const SizedBox(height: 10),
                        _buildNumberField(
                          'Задержка по газу (сек)',
                          throttleDelay,
                              (v) => setState(() => throttleDelay = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Этап 2 — Поведение'),
                  _buildStyledContainer(
                    child: Column(
                      children: [
                        _buildRadioOption('Падение'),
                        _buildRadioOption('Приземление'),
                        if (failsafeMode == 'Приземление') ...[
                          const SizedBox(height: 10),
                          _buildNumberField(
                            'Газ при посадке',
                            landingThrottle.toDouble(),
                                (v) => setState(() => landingThrottle = v),
                          ),
                          const SizedBox(height: 10),
                          _buildNumberField(
                            'Задержка выключения моторов (сек)',
                            offDelay,
                                (v) => setState(() => offDelay = v),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('GPS-спасение'),
                  _buildStyledContainer(
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: gpsRescue,
                          onChanged: (v) => setState(() => gpsRescue = v),
                          title: const Text(
                            'Включить GPS-спасение',
                            style: TextStyle(color: Colors.white),
                          ),
                          activeColor: Colors.white70,
                          inactiveThumbColor: Colors.grey,
                          activeTrackColor: Color.fromARGB(255, 252, 128, 33),
                          inactiveTrackColor: Colors.white70,
                        ),
                        if (gpsRescue) _buildGpsRescueSettings(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpsRescueSettings() => Column(
    children: [
      _buildNumberField(
        'Макс. угол тангажа',
        gpsAngle.toDouble(),
            (v) => setState(() => gpsAngle = v),
      ),
      _buildNumberField(
        'Возвратная высота (м)',
        gpsReturnAltitude.toDouble(),
            (v) => setState(() => gpsReturnAltitude = v),
      ),
      _buildNumberField(
        'Скорость подъёма (м/с)',
        gpsAscendRate,
            (v) => setState(() => gpsAscendRate = v),
      ),
      _buildNumberField(
        'Скорость спуска (м/с)',
        gpsDescendRate,
            (v) => setState(() => gpsDescendRate = v),
      ),
      _buildNumberField(
        'Мин. число спутников',
        gpsMinSats.toDouble(),
            (v) => setState(() => gpsMinSats = v.toInt()),
      ),
    ],
  );

  Widget _buildSectionTitle(String title) => Container(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    child: Text(title, style: const TextStyle(fontSize: 24, color: Colors.black)),
  );

  Widget _buildStyledContainer({required Widget child}) => Container(
    width: MediaQuery.of(context).size.width * 0.85,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: const Color.fromARGB(255, 109, 113, 120), width: 1),
    ),
    child: child,
  );

  Widget _buildNumberField(
      String label,
      double value,
      ValueChanged<double> onChanged, {
        bool isWarning = false,
      }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: TextStyle(color: isWarning ? Colors.red : Colors.white)),
            ),
            SizedBox(
              width: 100,
              child: TextFormField(
                initialValue: value.toString(),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 252, 128, 33)),
                  ),
                ),
                onChanged: (val) {
                  final num? parsed = num.tryParse(val.replaceAll(',', '.'));
                  if (parsed != null) onChanged(parsed.toDouble());
                },
              ),
            ),
          ],
        ),
      );

  Widget _buildDropdownRow(
      String label,
      String value,
      ValueChanged<String> onChanged, {
        required List<String> options,
      }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white))),
            DropdownButton<String>(
              value: value,
              dropdownColor: Colors.black87,
              style: const TextStyle(color: Colors.white),
              items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
              onChanged: (newVal) {
                if (newVal != null) onChanged(newVal);
              },
            ),
          ],
        ),
      );

  Widget _buildRadioOption(String value) => RadioListTile<String>(
    value: value,
    groupValue: failsafeMode,
    onChanged: (val) => setState(() => failsafeMode = val!),
    title: Text(value, style: const TextStyle(color: Colors.white)),
    activeColor: const Color.fromARGB(255, 252, 128, 33),
  );
}
