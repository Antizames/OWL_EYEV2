import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Импорты для виджетов из твоего проекта (адаптируй пути при необходимости)
import 'package:owl/pages/appBar/widgets/customAppBar.dart';
import 'package:owl/pages/sideBarMenu/sidebar_menu.dart';
import 'package:owl/pages/battery/widgets/deformableButton.dart';

enum MapType { normal, satellite, terrain }

// Структура данных для спутника (фиктивная для демонстрации)
class SatelliteStatus {
  final String gnss;        // GPS, Glonass, Galileo, SBAS, etc.
  final int id;             // ID спутника
  final double signalPower; // Уровень сигнала (0..1, для прогрессбара)
  final String status;      // Например: "не используется", "использовано", "поиск"
  final String quality;     // Например: "неприродный", "полностью заблокирован"

  SatelliteStatus({
    required this.gnss,
    required this.id,
    required this.signalPower,
    required this.status,
    required this.quality,
  });
}

class GpsConfiguratorPage extends StatefulWidget {
  const GpsConfiguratorPage({Key? key}) : super(key: key);

  @override
  _GpsConfiguratorPageState createState() => _GpsConfiguratorPageState();
}

class _GpsConfiguratorPageState extends State<GpsConfiguratorPage> {
  // ------------- НАСТРОЙКИ GPS -------------
  List<String> gpsProtocols = ['NMEA', 'UBLOX', 'MSP'];
  int selectedProtocolIndex = 1;

  bool autoConfig = false;
  bool useGalileo = false;
  bool setHomeOnce = true;

  List<String> correctionTypes = [
    'Автоопределение',
    'Европейский EGNOS',
    'Североамериканский WAAS',
    'Японская MSAS',
    'Индийский GAGAN',
    'Никакой'
  ];
  int selectedCorrectionIndex = 1;

  TextEditingController magDeclinationController = TextEditingController();

  // ------------- ДАННЫЕ GPS (ТОЛЬКО ДЛЯ ЧТЕНИЯ) -------------
  bool gpsFix = true;
  int satelliteCount = 10;
  double altitude = 0;
  double speed = 0;
  String imuHeading = "0 / 134 град.";
  String gpsLatLon = "47.491941 / 19.053977 град.";
  double distanceToHome = 0;
  double positionalDop = 0;

  // ------------- КАРТА -------------
  final MapController mapController = MapController();
  LatLng _currentCenter = LatLng(47.491941, 19.053977); // Координаты по умолчанию
  MapType _selectedMapType = MapType.normal;

  // Фиктивный список спутников для демонстрации интерфейса
  List<SatelliteStatus> satellites = [
    SatelliteStatus(
      gnss: 'GPS',
      id: 1,
      signalPower: 0.3,
      status: 'не используется',
      quality: 'неприродный',
    ),
    SatelliteStatus(
      gnss: 'GPS',
      id: 15,
      signalPower: 0.9,
      status: 'ИСПОЛЬЗОВАНО',
      quality: 'полностью заблокирован',
    ),
    SatelliteStatus(
      gnss: 'GPS',
      id: 26,
      signalPower: 0.6,
      status: 'ИСПОЛЬЗОВАНО',
      quality: 'заблокирован',
    ),
    SatelliteStatus(
      gnss: 'SBAS',
      id: 3,
      signalPower: 0.2,
      status: 'поиск',
      quality: '...',
    ),
    SatelliteStatus(
      gnss: 'Glonass',
      id: 18,
      signalPower: 1.0,
      status: 'ИСПОЛЬЗОВАНО',
      quality: 'полностью заблокирован',
    ),
    SatelliteStatus(
      gnss: 'Galileo',
      id: 15,
      signalPower: 0.5,
      status: 'поиск',
      quality: 'заблокирован',
    ),
  ];

  @override
  void initState() {
    super.initState();
    loadConfig();
    _parseGpsCoordinates();
  }

  // Загрузка настроек из SharedPreferences
  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedProtocolIndex = prefs.getInt('gpsProtocol') ?? 1;
      autoConfig = prefs.getBool('gpsAutoConfig') ?? false;
      useGalileo = prefs.getBool('gpsUseGalileo') ?? false;
      setHomeOnce = prefs.getBool('gpsSetHomeOnce') ?? true;
      selectedCorrectionIndex = prefs.getInt('gpsCorrection') ?? 1;
      magDeclinationController.text = prefs.getString('gpsMagDecl') ?? '0.0';
    });
  }

  // Сохранение настроек
  Future<void> saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gpsProtocol', selectedProtocolIndex);
    await prefs.setBool('gpsAutoConfig', autoConfig);
    await prefs.setBool('gpsUseGalileo', useGalileo);
    await prefs.setBool('gpsSetHomeOnce', setHomeOnce);
    await prefs.setInt('gpsCorrection', selectedCorrectionIndex);
    await prefs.setString('gpsMagDecl', magDeclinationController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Конфигурация сохранена")),
    );
  }

  // Парсинг координат из строки gpsLatLon
  void _parseGpsCoordinates() {
    try {
      final coordsOnly = gpsLatLon.split('град.')[0].trim(); // "47.491941 / 19.053977"
      final parts = coordsOnly.split('/');
      if (parts.length == 2) {
        final latStr = parts[0].trim();
        final lonStr = parts[1].trim();
        final latVal = double.tryParse(latStr);
        final lonVal = double.tryParse(lonStr);
        if (latVal != null && lonVal != null) {
          setState(() {
            _currentCenter = LatLng(latVal, lonVal);
          });
        }
      }
    } catch (e) {
      print("Ошибка разбора gpsLatLon: $e");
    }
  }

  // Открытие бокового меню
  void _openSidebarMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) =>
      throw UnimplementedError(),
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(begin: Offset(-1, 0), end: Offset.zero);
        final offsetAnimation = animation.drive(tween);

        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: FadeTransition(
                opacity: animation,
                child: Container(color: Colors.transparent),
              ),
            ),
            SlideTransition(
              position: offsetAnimation,
              child: SidebarMenu(),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    magDeclinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Фон страницы сделан светло-серым, как на последних скриншотах
    return Scaffold(
      backgroundColor: Color(0xFFE8EBEE),
      body: CustomScrollView(
        slivers: [
          // CustomAppBar
          CustomAppBar(
            title: 'GPS',
            leadingIcon: DeformableButton(
              onPressed: () => _openSidebarMenu(context),
              child: Icon(Icons.menu, color: Colors.grey.shade600),
              gradient: LinearGradient(colors: [Colors.white, Colors.white]),
            ),
            trailingIcon: DeformableButton(
              onPressed: () => saveConfig(),
              child: Icon(Icons.save, color: Colors.grey.shade600),
              gradient: LinearGradient(colors: [Colors.white, Colors.white]),
            ),
          ),
          // Основной контент
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // —————— Заменили Row на Column ——————
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Сначала блок настроек
                        _buildLeftConfigPanel(),
                        SizedBox(height: 16),
                        // Потом карта
                        _buildRightMapPanel(),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Таблица спутников
                    _buildSatelliteSignalTable(),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // Левая панель настроек (стилизована как Card с чёрным фоном)
  Widget _buildLeftConfigPanel() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.black.withOpacity(0.95),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Конфигурация GPS'),
              _buildDropdown(
                'Протокол',
                gpsProtocols,
                selectedProtocolIndex,
                    (index) => setState(() => selectedProtocolIndex = index),
              ),
              _buildSwitch(
                'Автонастройка',
                autoConfig,
                    (val) => setState(() => autoConfig = val),
              ),
              _buildSwitch(
                'Использовать Galileo',
                useGalileo,
                    (val) => setState(() => useGalileo = val),
              ),
              _buildSwitch(
                'Установить "Дом" один раз',
                setHomeOnce,
                    (val) => setState(() => setHomeOnce = val),
              ),
              _buildDropdown(
                'Тип коррекции координат',
                correctionTypes,
                selectedCorrectionIndex,
                    (index) => setState(() => selectedCorrectionIndex = index),
              ),
              _buildTextField('Магнитное склонение [град]', magDeclinationController),
              SizedBox(height: 20),
              _buildSectionTitle('GPS (только для чтения)'),
              _buildReadOnlyRow('3D фикс', gpsFix ? 'True' : 'False'),
              _buildReadOnlyRow('Количество спутников', '$satelliteCount'),
              _buildReadOnlyRow('Высота', '$altitude m'),
              _buildReadOnlyRow('Скорость', '$speed cm/s'),
              _buildReadOnlyRow('Направление IMU / GPS', imuHeading),
              _buildReadOnlyRow('Текущая широта / долгота', gpsLatLon),
              _buildReadOnlyRow('Расст. до дома', '$distanceToHome m'),
              _buildReadOnlyRow('Позиционный DOP', positionalDop.toStringAsFixed(2)),
            ],
          ),
        ),
      ),
    );
  }

  // Правая панель – Карта с кнопками переключения типа карты
  Widget _buildRightMapPanel() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.black.withOpacity(0.95),
      child: SizedBox(
        height: 730,
        child: Stack(
          children: [
            // Карта
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: _currentCenter,
                    zoom: 15.0,
                    interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: _mapUrl,
                      subdomains: ['a', 'b', 'c'],
                    ),
                  ],
                ),
              ),
            ),
            // Кнопки переключения типа карты (используем наш кастомный виджет)
            Positioned(
              bottom: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMapTypeButton('Обычная', () {
                    setState(() => _selectedMapType = MapType.normal);
                  }),
                  SizedBox(height: 8),
                  _buildMapTypeButton('Спутник', () {
                    setState(() => _selectedMapType = MapType.satellite);
                  }),
                  SizedBox(height: 8),
                  _buildMapTypeButton('Рельеф', () {
                    setState(() => _selectedMapType = MapType.terrain);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Таблица спутников – Card с данными
  Widget _buildSatelliteSignalTable() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.black.withOpacity(0.95),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Мощность GPS сигнала',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 8),
            _buildTableHeader(),
            Divider(color: Colors.grey),
            for (var sat in satellites) _buildSatelliteRow(sat),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      children: [
        Expanded(flex: 2, child: Text('Gnss ID', style: _headerStyle)),
        Expanded(flex: 1, child: Text('ID cпут.', style: _headerStyle)),
        Expanded(flex: 3, child: Text('Мощность сигнала', style: _headerStyle)),
        Expanded(flex: 2, child: Text('Статус', style: _headerStyle)),
        Expanded(flex: 2, child: Text('Качество', style: _headerStyle)),
      ],
    );
  }

  TextStyle get _headerStyle =>
      TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white);

  Widget _buildSatelliteRow(SatelliteStatus sat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(sat.gnss, style: TextStyle(color: Colors.white))),
          Expanded(flex: 1, child: Text('${sat.id}', style: TextStyle(color: Colors.white))),
          Expanded(flex: 3, child: _buildSignalBar(sat.signalPower)),
          Expanded(flex: 2, child: _buildColoredLabel(sat.status)),
          Expanded(flex: 2, child: _buildColoredLabel(sat.quality)),
        ],
      ),
    );
  }

  Widget _buildSignalBar(double power) {
    return SizedBox(
      height: 8,
      child: LinearProgressIndicator(
        value: power,
        backgroundColor: Colors.grey.shade300,
        valueColor: AlwaysStoppedAnimation<Color>(_getPowerColor(power)),
      ),
    );
  }

  Color _getPowerColor(double power) {
    if (power < 0.3) {
      return Colors.red;
    } else if (power < 0.7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  Widget _buildColoredLabel(String text) {
    Color bgColor;
    final lower = text.toLowerCase();
    if (lower.contains('не используется') || lower.contains('неприродный')) {
      bgColor = Colors.red;
    } else if (lower.contains('поиск') || lower.contains('заблокирован')) {
      bgColor = Colors.orange;
    } else if (lower.contains('использовано') || lower.contains('полностью')) {
      bgColor = Colors.green;
    } else {
      bgColor = Colors.blueGrey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  String get _mapUrl {
    switch (_selectedMapType) {
      case MapType.normal:
        return 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
      case MapType.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapType.terrain:
        return 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';
    }
  }

  // ---------- Вспомогательные методы UI ----------

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildDropdown(
      String label, List<String> items, int selectedIndex, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: Colors.white)),
        SizedBox(height: 5),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: Color(0xFF6D7178), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                isExpanded: true,
                value: items[selectedIndex],
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
                dropdownColor: Colors.black,
                style: TextStyle(color: Colors.white),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    onChanged(items.indexOf(newValue));
                  }
                },
                items: items.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 16, color: Colors.white))),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white70,
          inactiveThumbColor: Colors.grey,
          activeTrackColor: Color.fromARGB(255, 252, 128, 33),
          inactiveTrackColor: Colors.white70,
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: Colors.white)),
        SizedBox(height: 5),
        Container(
          height: 38,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: Colors.white))),
          SizedBox(width: 8),
          Text(value, style: TextStyle(fontSize: 14, color: Colors.orange)),
        ],
      ),
    );
  }

  // Кастомный виджет для кнопок переключения типа карты
  Widget _buildMapTypeButton(String title, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white, // Выбран белый текст для контраста с чёрным фоном
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
