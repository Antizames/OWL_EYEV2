// lib/pages/pid/pid_profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart' hide Material;
import 'package:owl/pages/appBar/widgets/customAppBar.dart';
import 'package:owl/pages/sideBarMenu/sidebar_menu.dart';
import 'package:owl/pages/battery/widgets/myCustomSlider.dart';
import 'package:owl/pages/pid/widgets/painter.dart';
import 'package:owl/pages/pid/config/pid_config.dart';

class PidProfilePage extends StatefulWidget {
  const PidProfilePage({super.key});
  @override
  State<PidProfilePage> createState() => _PidProfilePageState();
}

class _PidProfilePageState extends State<PidProfilePage> {
/* ──────────────────────────────────────────────────────────────
 * 0.  Переменные состояния
 * ──────────────────────────────────────────────────────────── */

  // вкладки
  String currentTab = 'PID';

  // выбранные профили
  String selectedProfile     = 'Профиль 1';
  String selectedRateProfile = 'Rate-профиль 1';

  // drop-down’ы
  String rateType        = 'Betaflight';
  String throttleLimit   = 'Выкл';
  String gyroSliderMode  = 'Выкл';
  String dtermSliderMode = 'Выкл';
  String pidMode         = 'ВЫКЛ';
  String tpaMode         = 'ПД';

  // 3-D
  Scene?  scene;
  Object? drone;

  // ==============  RC-tuning значения  ==============
  double rcRateValue        = 0;
  double rollPitchRateValue = 0;
  double rollRateValue      = 0;
  double pitchRateValue     = 0;
  double yawRateValue       = 0;

  double rcExpoValue        = 0;
  double rcPitchExpoValue   = 0;
  double rcYawExpoValue     = 0;

  double throttleMidValue   = 0;
  double throttleExpoValue  = 0;
  double throttleHoverValue = 0;

  // ==============  фильтры, доп. слайдеры  ==============
  final Map<String, double> filterValues = {
    'gyro_notch1_cutoff' : 0,
    'dterm_notch_cutoff' : 0,
    'gyro_notch2_cutoff' : 0,
  };

  int    dynamicNotchRangeValue    = 0;
  double dynamicNotchWidthValue    = 0;
  int    dynamicNotchCountValue    = 0;
  int    dynamicNotchQValue        = 0;
  int    dynamicNotchMinHzValue    = 0;
  int    dynamicNotchMaxHzValue    = 0;
  int    rpmNotchHarmonicsValue    = 0;
  int    rpmNotchMinHzValue        = 0;

  // глобальные слайдеры
  final Map<String, double> sliders = {
    'feedforward_smoothing': 0,
    'boost'                : 0,
    'max_rate_limit'       : 0,
    'transition'           : 0,
    'amplification'        : 0,
    'advance'              : 0,
    'increase_throttle'    : 0,
    'motor_limit'          : 0,
    'idle_value'           : 0,
    'tpa_rate'             : 0,
    'tpa_breakpoint'       : 0,
    'battery_cells'        : 0,
    'trainer_angle_limit'  : 0,
    'absolute_control'     : 0,
  };

  final Map<String, double> filterSliders = {
    'gyro_multiplier'      : 0,
    'dterm_multiplier'     : 0,
    'd_gain'               : 0,
    'pi_gain'              : 0,
    'ff_gain'              : 0,
    'i_gain'               : 0,
    'dmax'                 : 0,
    'damping'              : 0,
    'tracking'             : 0,
    'stick_response'       : 0,
    'dynamic_damping'      : 0,
    'drift'                : 0,
    'pr_damping'           : 0,
    'pr_damp_all'          : 0,
    'master_multiplier'    : 0,
    'roll_pitch_ratio'     : 0,
    'pitch_pi_gain'        : 0,
  };

  final Map<String, bool> filterSwitches = {
    'gyro_lowpass1'      : false,
    'gyro_lowpass2'      : false,
    'gyro_notch1'        : false,
    'gyro_notch2'        : false,
    'gyro_rpm'           : false,
    'gyro_dynamic_notch' : false,
    'dterm_lowpass1'     : false,
    'dterm_lowpass2'     : false,
    'dterm_notch'        : false,
    'yaw_lowpass'        : false,
  };

  // бинарные свитчи (PID-контроллер и пр.)
  final Map<String, bool> switches = {
    'softening_i'          : false,
    'antigravity'          : false,
    'iterm_turn'           : false,
    'voltage_compensation' : false,
    'linear_thrust'        : false,
    'yaw_integration'      : false,
  };

  // PID-таблица
  final List<String> axes       = ['Roll', 'Pitch', 'Yaw'];
  final List<Color>  axisColors = [Colors.red, Colors.green, Colors.blue];
  final List<String> pidFields  = ['P', 'I', 'D', 'D Max', 'Derivative', 'Feedforward'];

  Map<String, Map<String, double>> pidValues = {
    'Roll' : {},
    'Pitch': {},
    'Yaw'  : {},
  };

  // списки имён профилей (для MSP-отправки)
  final List<String> profiles     = ['Профиль 1', 'Профиль 2', 'Профиль 3'];
  final List<String> rateProfiles = ['Rate-профиль 1', 'Rate-профиль 2', 'Rate-профиль 3'];

/* ──────────────────────────────────────────────────────────────
 * 1.  initState
 * ──────────────────────────────────────────────────────────── */
  @override
  void initState() {
    super.initState();
    for (final axis in axes) {
      for (final f in pidFields) {
        pidValues[axis]![f] = 0;
      }
    }
  }

  /* ──────────────────────────────────────────────────────────────
 * 2.  Сохранить всё ⇢ MSP + SharedPreferences
 * ──────────────────────────────────────────────────────────── */
  Future<void> saveAllConfigs() async {
    /* ---------- 1. PID-профиль 9×u8 ---------- */
    final basePid = [
      pidValues['Roll']!['P']!.round().clamp(0, 255),
      pidValues['Roll']!['I']!.round().clamp(0, 255),
      pidValues['Roll']!['D']!.round().clamp(0, 255),
      pidValues['Pitch']!['P']!.round().clamp(0, 255),
      pidValues['Pitch']!['I']!.round().clamp(0, 255),
      pidValues['Pitch']!['D']!.round().clamp(0, 255),
      pidValues['Yaw']!['P']!.round().clamp(0, 255),
      pidValues['Yaw']!['I']!.round().clamp(0, 255),
      pidValues['Yaw']!['D']!.round().clamp(0, 255),
    ];
    await PidConfigManager().save(PidConfig(profile: basePid));

    /* ---------- 2. Advanced-PID (три поля) ---------- */
    await PidAdvancedConfigManager().save(
      PidAdvancedConfig(
        deltaMethod            : 0,
        dtermSetpointTransition: sliders['transition']!.round(),
        dtermSetpointWeight    : sliders['amplification']!.round(),
      ),
    );

    /* ---------- 3. RC-Tuning  ---------- */
    await RcTuningConfigManager().save(
      RcTuningConfig(
        rcRate        : rcRateValue,          // u8 = 0-2.55
        rcExpo        : rcExpoValue,          // u8
        rollRate      : rollRateValue,        // u8
        pitchRate     : pitchRateValue,       // u8
        yawRate       : yawRateValue,         // u8
        rcPitchExpo   : rcPitchExpoValue,     // u8
        rcYawExpo     : rcYawExpoValue,       // u8
        throttleMid   : throttleMidValue,     // u8
        throttleExpo  : throttleExpoValue,    // u8
        throttleHover : throttleHoverValue,   // u8 (для API≥1.47)
      ),
    );

    /* ---------- 4. Фильтры (код не менялся) ---------- */
    await FilterConfigManager().save(
      FilterConfig(
        gyroLpf             : filterSwitches['gyro_lowpass1']! ? 1 : 0,
        dtermLpf            : filterSwitches['dterm_lowpass1']! ? 1 : 0,
        yawLpf              : filterSwitches['yaw_lowpass']!     ? 1 : 0,
        gyroNotch1Hz        : filterSwitches['gyro_notch1']!     ? 150 : 0,
        gyroNotch1Cutoff    : filterValues['gyro_notch1_cutoff']!.round(),
        dtermNotchHz        : filterSwitches['dterm_notch']!     ? 150 : 0,
        dtermNotchCutoff    : filterValues['dterm_notch_cutoff']!.round(),
        gyroNotch2Hz        : filterSwitches['gyro_notch2']!     ? 100 : 0,
        gyroNotch2Cutoff    : filterValues['gyro_notch2_cutoff']!.round(),
        dynNotchRange       : dynamicNotchRangeValue,
        dynNotchWidthPercent: dynamicNotchWidthValue.round(),
        dynNotchCount       : dynamicNotchCountValue,
        dynNotchQ           : dynamicNotchQValue,
        dynNotchMinHz       : dynamicNotchMinHzValue,
        dynNotchMaxHz       : dynamicNotchMaxHzValue,
        rpmNotchHarmonics   : rpmNotchHarmonicsValue,
        rpmNotchMinHz       : rpmNotchMinHzValue,
      ),
    );

    /* ---------- 5. Simplified-Tuning ---------- */
    await SimplifiedTuningConfigManager().save(
      SimplifiedTuningConfig(
        sliderPidsMode        : pidMode == 'RP'      ? 1 : pidMode == 'RPY' ? 2 : 0,
        masterMultiplier      : filterSliders['master_multiplier']!.round(),
        rollPitchRatio        : filterSliders['roll_pitch_ratio']!.round(),
        iGain                 : filterSliders['i_gain']!.round(),
        dGain                 : filterSliders['d_gain']!.round(),
        piGain                : filterSliders['pi_gain']!.round(),
        dMaxGain              : filterSliders['dmax']!.round(),
        feedforwardGain       : filterSliders['ff_gain']!.round(),
        pitchPiGain           : filterSliders['pitch_pi_gain']!.round(),
        dtermFilterMode       : dtermSliderMode == 'Вкл' ? 1 : 0,
        dtermFilterMultiplier : filterSliders['dterm_multiplier']!.round(),
        gyroFilterMode        : gyroSliderMode == 'Вкл' ? 1 : 0,
        gyroFilterMultiplier  : filterSliders['gyro_multiplier']!.round(),
      ),
    );

    /* ---------- 6. Имена профилей ---------- */
    await ProfileNamesConfigManager().save(
      ProfileNamesConfig(pid: profiles, rate: rateProfiles),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Конфигурация успешно сохранена')),
    );
  }
/* ──────────────────────────────────────────────────────────────
 * 3.  BUILD
 * ──────────────────────────────────────────────────────────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              CustomAppBar(
                title: 'Настройки PID',
                leadingIcon: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.grey),
                  onPressed: () => _openSidebarMenu(context),
                ),
                trailingIcon: IconButton(
                  icon: const Icon(Icons.save, color: Colors.grey),
                  onPressed: saveAllConfigs,
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end  : Alignment.bottomCenter,
                      colors: [Color(0xFFE9EDF5), Color(0xFF95989E)],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 60),
                    child: _buildTabContent(),
                  ),
                ),
              ),
            ],
          ),
          // правое вертикальное меню-табы
          Positioned(
            top: kToolbarHeight + 8,
            right: 0,
            child: Container(
              width: 70,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topLeft : Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Column(
                children: ['PID', 'Rate', 'Фильтры']
                    .map((e) => _buildSideTab(e))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

/* ──────────────────────────────────────────────────────────────
 * 4.  Вкладки
 * ──────────────────────────────────────────────────────────── */

  Widget _buildTabContent() {
    switch (currentTab) {
      case 'Rate':
        return _rateTab();
      case 'Фильтры':
        return _filterTab();
      default:
        return _pidTab();
    }
  }

  // ── PID-вкладка (таб по-умолчанию) ─────────────────────────
  Widget _pidTab() {
    return Column(
      children: [
        _buildSectionTitle('Выбор профилей'),
        _buildStyledContainer(
          child: Row(
            children: [
              const Text('PID:', style: TextStyle(color: Colors.white)),
              const SizedBox(width: 10),
              _buildDropdown(selectedProfile, profiles,
                      (v) => setState(() => selectedProfile = v)),
              const SizedBox(width: 20),
              const Text('Rate:', style: TextStyle(color: Colors.white)),
              const SizedBox(width: 10),
              _buildDropdown(selectedRateProfile, rateProfiles,
                      (v) => setState(() => selectedRateProfile = v)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('PID значения'),
        _buildStyledContainer(child: _buildPidTable()),
        const SizedBox(height: 20),
        _buildSectionTitle('Режим'),
        _buildStyledContainer(
          child: _buildDropdownRow(
            'Режим',
            pidMode,
                (v) => setState(() => pidMode = v),
            options: ['ВЫКЛ', 'RP', 'RPY'],
          ),
        ),
        _buildStyledContainer(
          child: Column(
            children: [
              _buildStyledSlider('Дампинг', filterSliders['damping']!,
                      (v) => setState(() => filterSliders['damping'] = v),
                  subtitle: 'D Gains'),
              _buildStyledSlider('Трекинг', filterSliders['tracking']!,
                      (v) => setState(() => filterSliders['tracking'] = v),
                  subtitle: 'P & I Gains'),
              _buildStyledSlider(
                  'Реакция стиков',
                  filterSliders['stick_response']!,
                      (v) => setState(() => filterSliders['stick_response'] = v),
                  subtitle: 'FF Gains'),
              _buildStyledSlider(
                  'Динамический демпинг',
                  filterSliders['dynamic_damping']!,
                      (v) => setState(
                          () => filterSliders['dynamic_damping'] = v),
                  subtitle: 'D Max'),
              _buildStyledSlider('Дрейф – Колебание', filterSliders['drift']!,
                      (v) => setState(() => filterSliders['drift'] = v),
                  subtitle: 'I Gains'),
              _buildStyledSlider(
                  'Демпфирование по крену',
                  filterSliders['pr_damping']!,
                      (v) => setState(() => filterSliders['pr_damping'] = v),
                  subtitle: 'Тангаж:Крен D'),
              _buildStyledSlider(
                  'Демпфирование по крену (всё)',
                  filterSliders['pr_damp_all']!,
                      (v) => setState(() => filterSliders['pr_damp_all'] = v),
                  subtitle: 'Тангаж:Крен P, I & FF'),
              _buildStyledSlider('Главный множитель',
                  filterSliders['master_multiplier']!,
                      (v) => setState(
                          () => filterSliders['master_multiplier'] = v)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildPidControllerSettings(),
        const SizedBox(height: 20),
        _buildThrottleAndMotorParams(),
        const SizedBox(height: 20),
        _buildTpaAndOtherSettings(),
      ],
    );
  }

  // ── Rate-вкладка ───────────────────────────────────────────
  Widget _rateTab() {
    return Column(
      children: [
        _buildSectionTitle('Тип коэффициентов'),
        _buildStyledContainer(
          child: _buildDropdownRow(
            'Тип',
            rateType,
                (v) => setState(() => rateType = v),
            options: ['Betaflight', 'Actual', 'RaceFlight'],
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Rate-профиль Roll / Pitch / Yaw'),
        _buildStyledContainer(
          child: Column(
            children: List.generate(
              3,
                  (i) => _rateAxisRow(axes[i], axisColors[i]),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Настройки газа'),
        _buildStyledContainer(
          child: Column(
            children: [
              _buildDropdownRow(
                'Предел газа',
                throttleLimit,
                    (v) => setState(() => throttleLimit = v),
                options: ['Выкл', 'Вкл'],
              ),
              const SizedBox(height: 10),
              _buildNumberField('Предел газа %', 100, (_) {}),
              _buildNumberField(
                  'Газ, средняя точка', throttleMidValue,
                      (v) => setState(() => throttleMidValue = v)),
              _buildNumberField(
                  'Газ, экспонента', throttleExpoValue,
                      (v) => setState(() => throttleExpoValue = v)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Предпросмотр кривой газа'),
        _buildStyledContainer(
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.orange),
            ),
            child: const Center(
              child: Text('Кривая газа (заглушка)',
                  style: TextStyle(color: Colors.white54)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Предпросмотр рейтов'),
        _buildStyledContainer(
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.orange),
            ),
            child: const Center(
              child:
              Text('Rate preview (заглушка)', style: TextStyle(color: Colors.white54)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Модель дрона'),
        _buildStyledContainer(
          child: SizedBox(
            height: 200,
            child: Cube(
              interactive: false,
              onSceneCreated: (Scene s) {
                scene = s;
                drone = Object(fileName: 'Assets/3D/drone.obj');
                s.world.add(drone!);
                s.camera.zoom = 10;
              },
            ),
          ),
        ),
      ],
    );
  }

  // ── Filter-вкладка ─────────────────────────────────────────
  Widget _filterTab() {
    return Column(
      children: [
        _buildSectionTitle('Слайдеры фильтрации'),
        _buildStyledContainer(
          child: Column(
            children: [
              _buildSlider(
                'Множитель фильтра Gyro',
                filterSliders['gyro_multiplier']!,
                    (v) => setState(() => filterSliders['gyro_multiplier'] = v),
              ),
              _buildSlider(
                'Множитель фильтра D-Term',
                filterSliders['dterm_multiplier']!,
                    (v) => setState(() => filterSliders['dterm_multiplier'] = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade900,
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Text(
            'ВНИМАНИЕ: слайдеры фильтров могут привести к неустойчивому полёту.\n'
                'Меняйте значения осторожно!',
            style: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Глобальные фильтры (не зависит от профиля)'),
        _buildStyledContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdownRow(
                'Использовать слайдер для Gyro',
                gyroSliderMode,
                    (v) => setState(() => gyroSliderMode = v),
                options: ['Выкл', 'Вкл'],
              ),
              const Divider(color: Colors.white30),
              const Text('Gyro LPF', style: TextStyle(color: Colors.orange)),
              _buildSwitchRow(
                'Low-pass 1',
                filterSwitches['gyro_lowpass1']!,
                    (v) =>
                    setState(() => filterSwitches['gyro_lowpass1'] = v),
              ),
              _buildSwitchRow(
                'Low-pass 2',
                filterSwitches['gyro_lowpass2']!,
                    (v) =>
                    setState(() => filterSwitches['gyro_lowpass2'] = v),
              ),
              const Divider(color: Colors.white30),
              const Text('Gyro Notch', style: TextStyle(color: Colors.orange)),
              _buildSwitchRow(
                'Notch 1',
                filterSwitches['gyro_notch1']!,
                    (v) => setState(() => filterSwitches['gyro_notch1'] = v),
              ),
              _buildSwitchRow(
                'Notch 2',
                filterSwitches['gyro_notch2']!,
                    (v) => setState(() => filterSwitches['gyro_notch2'] = v),
              ),
              const Divider(color: Colors.white30),
              _buildSwitchRow(
                'RPM-фильтр',
                filterSwitches['gyro_rpm']!,
                    (v) => setState(() => filterSwitches['gyro_rpm'] = v),
              ),
              _buildSwitchRow(
                'Dynamic Notch',
                filterSwitches['gyro_dynamic_notch']!,
                    (v) =>
                    setState(() => filterSwitches['gyro_dynamic_notch'] = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('Фильтры, зависящие от профиля'),
        _buildStyledContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdownRow(
                'Слайдер для D-Term',
                dtermSliderMode,
                    (v) => setState(() => dtermSliderMode = v),
                options: ['Выкл', 'Вкл'],
              ),
              const Divider(color: Colors.white30),
              const Text('D-Term LPF', style: TextStyle(color: Colors.orange)),
              _buildSwitchRow(
                'Low-pass 1',
                filterSwitches['dterm_lowpass1']!,
                    (v) =>
                    setState(() => filterSwitches['dterm_lowpass1'] = v),
              ),
              _buildSwitchRow(
                'Low-pass 2',
                filterSwitches['dterm_lowpass2']!,
                    (v) =>
                    setState(() => filterSwitches['dterm_lowpass2'] = v),
              ),
              const Divider(color: Colors.white30),
              _buildSwitchRow(
                'Notch',
                filterSwitches['dterm_notch']!,
                    (v) => setState(() => filterSwitches['dterm_notch'] = v),
              ),
              _buildSwitchRow(
                'Yaw LPF',
                filterSwitches['yaw_lowpass']!,
                    (v) => setState(() => filterSwitches['yaw_lowpass'] = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

/* ──────────────────────────────────────────────────────────────
 * 5.  UI-helpers (контейнеры, поля, слайды…)
 * ──────────────────────────────────────────────────────────── */

  void _openSidebarMenu(BuildContext ctx) {
    showGeneralDialog(
      barrierDismissible: false,
      barrierColor      : Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      context           : ctx,
      pageBuilder       : (_, __, ___) => const SidebarMenu(),
      transitionBuilder : (context, animation, __, child) {
        final slide =
        Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
            .animate(animation);
        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: FadeTransition(
                opacity: animation,
                child:
                Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),
            SlideTransition(position: slide, child: child),
          ],
        );
      },
    );
  }

  Widget _buildSideTab(String label) {
    final sel = label == currentTab;
    return GestureDetector(
      onTap: () => setState(() => currentTab = label),
      child: Container(
        margin : const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color       : sel ? const Color(0xFFFc8021) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border      : Border.all(color: Colors.white24),
        ),
        child: RotatedBox(
          quarterTurns: 3,
          child: Text(
            label,
            style: TextStyle(
              color : sel ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // секция-title
  Widget _buildSectionTitle(String t) => Container(
    alignment: Alignment.centerLeft,
    padding  : const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    child    : Text(t, style: const TextStyle(fontSize: 24)),
  );

  // чёрный контейнер-рамка
  Widget _buildStyledContainer({required Widget child}) => Container(
    width   : MediaQuery.of(context).size.width * .9,
    margin  : const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    padding : const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color       : Colors.black,
      borderRadius: BorderRadius.circular(7),
      border      : Border.all(color: const Color(0xFF6D7178)),
    ),
    child: child,
  );

  // числовое поле
  Widget _buildNumberField(
      String label, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white))),
          SizedBox(
            width: 100,
            child: TextFormField(
              initialValue: value.toStringAsFixed(1),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFc8021)),
                ),
              ),
              onChanged: (txt) {
                final v = double.tryParse(txt.replaceAll(',', '.'));
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }

  // обычный слайдер
  Widget _buildSlider(
      String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white))),
            Text(value.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 6),
        MyCustomSlider(
          sliderValue : value,
          onValueChanged: onChanged,
          maxValue    : 100,
          minValue    : 0,
          step        : 1,
        ),
      ],
    );
  }

  // «красивый» слайдер со вторострочным подзаголовком
  Widget _buildStyledSlider(String label, double value,
      ValueChanged<double> onChanged,
      {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: Colors.white)),
                    if (subtitle != null)
                      Text(subtitle,
                          style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
              Text(value.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 6),
          MyCustomSlider(
            sliderValue: value,
            onValueChanged: onChanged,
            maxValue: 100,
            minValue: 0,
            step: 1,
          ),
        ],
      ),
    );
  }

  // switch-ряды
  Widget _buildSwitchRow(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white70,
            inactiveThumbColor: Colors.grey,
            activeTrackColor: const Color(0xFFFc8021),
            inactiveTrackColor: Colors.white70,
          ),
        ],
      ),
    );
  }

  // выпадашки
  Widget _buildDropdown(String cur, List<String> opts,
      ValueChanged<String> onChanged) =>
      DropdownButton<String>(
        value: cur,
        dropdownColor: Colors.black87,
        style: const TextStyle(color: Colors.white),
        items: opts.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: (v) => onChanged(v!),
      );

  Widget _buildDropdownRow(String label, String val,
      ValueChanged<String> onChanged,
      {required List<String> options}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white))),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: val,
                  dropdownColor: Colors.black87,
                  style: const TextStyle(color: Colors.white),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  onChanged: (v) => onChanged(v!),
                  items: options
                      .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _rateAxisRow(String axis, Color color) {
    // helper, чтобы не дублировать код в switch(currentTab)
    double read(String k) => {
      'Roll' : rollRateValue,
      'Pitch': pitchRateValue,
      'Yaw'  : yawRateValue,
    }[axis]!;

    void write(String k, double v) {
      setState(() {
        switch (axis) {
          case 'Roll': rollRateValue  = v; break;
          case 'Pitch': pitchRateValue = v; break;
          case 'Yaw':  yawRateValue   = v; break;
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(axis, style: TextStyle(color: color, fontSize: 18)),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text('RC Rate', style: TextStyle(color: Colors.white)),
                  ),
                  Expanded(
                    child: _buildNumberField(
                      '',
                      rcRateValue,
                          (v) => setState(() => rcRateValue = v),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text('Rate', style: TextStyle(color: Colors.white)),
                  ),
                  Expanded(
                    child: _buildNumberField(
                      '',
                      read(axis),
                          (v) => write(axis, v),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text('Expo', style: TextStyle(color: Colors.white)),
                  ),
                  Expanded(
                    child: _buildNumberField(
                      '',
                      {
                        'Roll' : rcExpoValue,
                        'Pitch': rcPitchExpoValue,
                        'Yaw'  : rcYawExpoValue,
                      }[axis]!,
                          (v) => setState(() {
                        switch (axis) {
                          case 'Roll': rcExpoValue      = v; break;
                          case 'Pitch': rcPitchExpoValue = v; break;
                          case 'Yaw': rcYawExpoValue    = v; break;
                        }
                      }),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Макс. скорость',
                        style: TextStyle(color: Colors.white54)),
                    Text('0°/с', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const Divider(color: Colors.white30),
      ],
    );
  }
  // PID-таблица
  Widget _buildPidTable() {
    return Column(
      children: axes.asMap().entries.map((e) {
        final axis  = e.value;
        final color = axisColors[e.key];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(axis, style: TextStyle(color: color, fontSize: 18)),
            ...pidFields.map((f) => _buildNumberField(
              f,
              pidValues[axis]![f]!,
                  (v) => setState(() => pidValues[axis]![f] = v),
            )),
            const Divider(color: Colors.grey),
          ],
        );
      }).toList(),
    );
  }

/* ──────────────────────────────────────────────────────────────
 * 6.  Мелкие разделы (как в твоём исходнике)
 * ──────────────────────────────────────────────────────────── */

  Widget _buildPidControllerSettings() => const SizedBox();   // можешь вставить свой код
  Widget _buildThrottleAndMotorParams()   => const SizedBox();
  Widget _buildTpaAndOtherSettings()      => const SizedBox();
}

/* EOF */
