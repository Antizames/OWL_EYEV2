import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_msp/flutter_msp.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:owl/pages/configuration/config/rxConfig.dart';
import 'package:owl/pages/configuration/widgets/rollTextField.dart';
import 'package:owl/pages/configuration/widgets/deformableButton.dart';
import 'package:owl/pages/configuration/widgets/myCustomSlider.dart';
import 'package:owl/pages/appBar/widgets/customAppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/config/config.dart';
import 'package:owl/pages/configuration/config/nameConfig.dart';
import 'package:owl/pages/configuration/config/sensorConfig.dart';
import 'package:owl/pages/motor/config/pidAdvancedConfig.dart';
import 'package:owl/pages/configuration/config/boardConfig.dart';
import 'package:owl/pages/configuration/config/alignmentConfig.dart';
import 'package:owl/pages/configuration/config/beeperConfig.dart';
class Configuration extends StatefulWidget{
  const Configuration({super.key});
  @override
  State<Configuration> createState() => ConfigurationState();
}
class ConfigurationState extends State<Configuration> {
  final NameManager nameManager = NameManager();
  final RXManager rxManager = RXManager();
  final SensorManager sensorManager = SensorManager();
  final BoardAlignmentManager boardManager = BoardAlignmentManager();
  final SensorAlignmentManager alignManager = SensorAlignmentManager();
  final BeeperManager beeperManager = BeeperManager();
  final PidManager pidManager = PidManager();
  double doubledownValue = 6.00;
  double roll = 180;
  final List<int> frequencies = [6, 9, 12, 15]; // Список частот в кГц
  int selectedIndex = 0; // Индекс выбранного элемента
  final List<int> mags = [0, 90, 180, 270]; // Список частот в кГц
  int magIndex = 0; // Индекс выбранного элемента
  double pitch = 180;
  double yaw = 180;
  String Pilot = 'Kolobok';
  String Craft = 'Сова';
  int PID = 6;
  String MAG = "";
  String Beacon = "";
  final List<int> beacons = [1, 2, 3, 4, 5]; // Список частот в кГц
  int beaconIndex = 0; // Индекс выбранного элемента
  bool Accelerometer = false;
  bool Barometer = false;
  bool Magnetometer = false;
  bool RX_LOST = true;
  bool RX_SET = true;
  bool RX_LOST_LANDING = true;
  bool RX_LOST_BEACON = true;
  bool GYRO_CALIBRATED = true;
  final TextEditingController _controllerRoll = TextEditingController();
  final TextEditingController _controllerPitch = TextEditingController();
  final TextEditingController _controllerYaw = TextEditingController();
  final TextEditingController _controllerPilot = TextEditingController();
  final TextEditingController _controllerCraft = TextEditingController();
  void _openSidebarMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => throw UnimplementedError(),
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero);
        final offsetAnimation = animation.drive(tween);

        return Stack(
          children: <Widget>[
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: FadeTransition(
                opacity: animation,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            SlideTransition(
              position: offsetAnimation,
              child: _buildSidebarMenu(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSidebarMenu(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(13), // Применяем скругление к Material
        bottomRight: Radius.circular(13),
      ),
      child: Material(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height, // на всю высоту
          color: Colors.white, // Цвет фона контейнера
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(10)),
              ListTile(
                leading: const Icon(Icons.navigation),
                title: const Text('Навигация'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.microchip),
                title: Text('Конфигурация'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/conf');
                },
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.phoenixSquadron),
                title: Text('Дрон'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/mod');
                },
              ),
              ListTile(
                leading: Icon(Icons.battery_charging_full),
                title: Text('Питание и Батарея'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/bat');
                },
              ),
              ListTile(
                leading: Icon(Icons.cable),
                title: Text('Порты'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/port');
                },
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.gears),
                title: Text('Сервоприводы'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/ser');
                },
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.fan),
                title: Text('Моторы'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/mot');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  void initState() {
    super.initState();

    loadConfig().then((_) {
      setState(() {
        _controllerRoll.text = roll.toStringAsFixed(0);
        _controllerPitch.text = pitch.toStringAsFixed(0);
        _controllerYaw.text = yaw.toStringAsFixed(0);
        _controllerPilot.text = Pilot;
        _controllerCraft.text = Craft;
        // и т.д.
      });
    });
  }


  @override
  void dispose() {
    _controllerRoll.dispose();
    _controllerPitch.dispose();
    _controllerYaw.dispose();
    _controllerPilot.dispose();
    super.dispose();
  }

  void saveValues() async{
    saveConfig(
      roll: double.parse(_controllerRoll.text),
      pitch: double.parse(_controllerPitch.text),
      yaw: double.parse(_controllerYaw.text),
      pilot: _controllerPilot.text,
      craft: _controllerCraft.text, // Добавьте контроллер для Craft
      pid: frequencies[selectedIndex], // Добавьте контроллер для PID
      mag: mags[magIndex].toString(), // Сохранение значения MAG
      beacon: Beacon, // Сохранение значения Beacon
      accelerometer: Accelerometer, // Сохранение значения Accelerometer
      barometer: Barometer, // Сохранение значения Barometer
      magnetometer: Magnetometer, // Сохранение значения Magnetometer
      rxLost: RX_LOST, // Сохранение значения RX_LOST
      rxSet: RX_SET, // Сохранение значения RX_SET
      rxLostLanding: RX_LOST_LANDING, // Сохранение значения RX_LOST_LANDING
      rxLostBeacon: RX_LOST_BEACON, // Сохранение значения RX_LOST_BEACON
      gyroCalibrated: GYRO_CALIBRATED, // Сохранение значения GYRO_CALIBRATED
    );
    await nameManager.saveConfig(
      name: _controllerPilot.text,
    );
    await boardManager.saveConfig(
      roll: roll.toInt(),
      pitch: pitch.toInt(),
      yaw: yaw.toInt(),
    );
    await sensorManager.saveConfig(
      accHardware: Accelerometer ? 1: 0,
      baroHardware: Barometer ? 1: 0,
      magHardware: Magnetometer ? 1: 0,
      sonarHardware: 0,
    );
    await beeperManager.saveConfig(
      beepers: int.parse('$RX_LOST$RX_SET$RX_LOST_LANDING$RX_LOST_BEACON$GYRO_CALIBRATED', radix: 2),
      dshotBeaconTone: beacons[beaconIndex],
      dshotBeaconConditions: int.parse('110', radix: 2),
    );
    await alignManager.savePartialConfig('alignMag', magIndex);
    await pidManager.savePartialConfig('gyroSyncDenom', 12);
    await pidManager.savePartialConfig('pidProcessDenom', frequencies[selectedIndex]);
  }
  Future<void> loadConfig() async {
    nameManager.loadConfig();
    sensorManager.loadConfig();
    boardManager.loadConfig();
    alignManager.loadConfig();
    beeperManager.loadConfig();
    final prefs = await SharedPreferences.getInstance();

    roll = prefs.getDouble('roll') ?? 180.0;
    pitch = prefs.getDouble('pitch') ?? 180.0;
    yaw = prefs.getDouble('yaw') ?? 180.0;
    Pilot = prefs.getString('pilot') ?? 'Kolobok';
    Craft = prefs.getString('craft') ?? 'Сова';
    PID = prefs.getInt('pid') ?? 6;
    MAG = prefs.getString('mag') ?? "";
    Beacon = prefs.getString('beacon') ?? "";
    Accelerometer = prefs.getBool('accelerometer') ?? false;
    Barometer = prefs.getBool('barometer') ?? false;
    Magnetometer = prefs.getBool('magnetometer') ?? false;
    RX_LOST = prefs.getBool('rxLost') ?? true;
    RX_SET = prefs.getBool('rxSet') ?? true;
    RX_LOST_LANDING = prefs.getBool('rxLostLanding') ?? true;
    RX_LOST_BEACON = prefs.getBool('rxLostBeacon') ?? true;
    GYRO_CALIBRATED = prefs.getBool('gyroCalibrated') ?? true;
  }

  @override
  Widget build(BuildContext cotext)
    => Scaffold(
      body:CustomScrollView(
        slivers: [
          CustomAppBar(
            title: 'Конфигурация',
            leadingIcon: DeformableButton(
              onPressed: (){_openSidebarMenu(context);},
              child: Icon(Icons.menu, color: Colors.grey.shade600),
              gradient: LinearGradient(
                  colors: <Color>[Color.fromARGB(255, 233, 237, 245), Color.fromARGB(255, 233, 237, 245)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
              ),
            ),

            trailingIcon: DeformableButton(
              onPressed: (){saveValues();},
              child: Icon(Icons.save, color: Colors.grey.shade600,),
              gradient: LinearGradient(
                  colors: <Color>[Color.fromARGB(255, 233, 237, 245), Color.fromARGB(255, 233, 237, 245)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
              ),
            ),

          ),
          SliverList(
            delegate: SliverChildListDelegate([
              // Ваш контент
              Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color.fromARGB(255, 233, 237, 245), Color.fromARGB(255, 149, 152, 158,)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)),

                child: SingleChildScrollView(child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 80, alignment: Alignment.centerLeft, child: Text('System Configuration', style: TextStyle(color: Colors.black, fontSize: 24),),),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Gyro update', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),),
                  Container(alignment: Alignment.centerLeft, width: MediaQuery.of(context).size.width * 0.8, height: 40,
                    child: Padding(padding: EdgeInsets.only(left: 10),child: Text('12.00 kHz', style: TextStyle(color: Colors.grey),),),
                    decoration: BoxDecoration(color: Colors.black,
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(7),
                          right: Radius.circular(7),
                        ),
                        border: Border.all(color: Color.fromARGB(255, 109, 113, 120), width: 1)),
                  ),
                  const Padding(padding: EdgeInsets.all(10)),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('PID', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],)),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 40,
                      decoration: BoxDecoration(color: Colors.black,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(7),
                            right: Radius.circular(7),// Скругление слева
                          ),
                          border: Border.all(color: Color.fromARGB(255, 109, 113, 120), width: 1)),
                      child: Stack(
                        children: [
                          DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true, // Выравнивание выпадающего списка
                              child: DropdownButton<int>(
                                isExpanded: true, // Расширяет DropdownButton на весь доступный размер
                                value: selectedIndex, // Текущий выбранный индекс
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (int? newIndex) {
                                  if (newIndex != null) {
                                    setState(() {
                                      selectedIndex = newIndex; // Обновляем выбранный индекс
                                    });
                                  }
                                },
                                items: List.generate(
                                  frequencies.length,
                                      (index) => DropdownMenuItem<int>(
                                    value: index,
                                    child: Text('${frequencies[index]} kHz'), // Отображаемое значение
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                  ),
                  const Padding(padding: EdgeInsets.all(10)),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [Text('Accelerometer', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),
                        Switch(value: Accelerometer, onChanged: (value){setState(() {
                          Accelerometer = value;
                        });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
                      ],),
                  ),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [Text('Barometer', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),
                        Switch(value: Barometer, onChanged: (value){setState(() {
                          Barometer = value;
                        });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
                      ],),
                  ),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [Text('Magnetometer', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),
                        Switch(value: Magnetometer, onChanged: (value){setState(() {
                          Magnetometer = value;
                        });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
                      ],),
                  ),
                  const Padding(padding: EdgeInsets.all(10)),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 80, alignment: Alignment.centerLeft, child: Text('Board and Sensor Aligment', style: TextStyle(color: Colors.black, fontSize: 24),),),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 40, alignment: Alignment.centerLeft, child: Row(children: [Text('Roll Degrees', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),),
                  const Padding(padding: EdgeInsets.all(10)),
                  RollTextField(
                    controller: _controllerRoll,
                    onRollChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          roll = newValue;
                        });
                      }
                    },
                  ),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
                    child:
                    MyCustomSlider(
                      sliderValue: roll,
                      onValueChanged: (newValue) {
                        setState(() {
                          roll = newValue;
                          _controllerRoll.text = roll.toStringAsFixed(0); // Обновляем текстовое поле
                        });
                      },
                    ),),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 40, alignment: Alignment.centerLeft, child: Row(children: [Text('Pitch Degrees', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),),
                  const Padding(padding: EdgeInsets.all(10)),
                  RollTextField(
                    controller: _controllerPitch,
                    onRollChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          pitch = newValue;
                        });
                      }
                    },
                  ),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
                    child:
                    MyCustomSlider(
                      sliderValue: pitch,
                      onValueChanged: (newValue) {
                        setState(() {
                          pitch = newValue;
                          _controllerPitch.text = pitch.toStringAsFixed(0); // Обновляем текстовое поле
                        });
                      },
                    ),),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 40, alignment: Alignment.centerLeft, child: Row(children: [Text('Yaw Degrees', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),),
                  const Padding(padding: EdgeInsets.all(10)),
                  RollTextField(
                    controller: _controllerYaw,
                    onRollChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          yaw = newValue;
                        });
                      }
                    },
                  ),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
                    child:
                    MyCustomSlider(
                      sliderValue: yaw,
                      onValueChanged: (newValue) {
                        setState(() {
                          yaw = newValue;
                          _controllerYaw.text = yaw.toStringAsFixed(0); // Обновляем текстовое поле
                        });
                      },
                    ),),
                  const Padding(padding: EdgeInsets.all(10)),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('MAG Alignment', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 40,
                      decoration: BoxDecoration(color: Colors.black,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(7),
                            right: Radius.circular(7),// Скругление слева
                          ),
                          border: Border.all(color: Color.fromARGB(255, 109, 113, 120), width: 1)),
                      child: Stack(children: [
                        DropdownButtonHideUnderline( // Убирает подчёркивание у DropdownButton
                          child: ButtonTheme(
                            alignedDropdown: true, // Используется для выравнивания выпадающего списка по ширине кнопки
                            child: DropdownButton<int>(
                              isExpanded: true, // Расширяет DropdownButton на весь доступный размер
                              value: magIndex, // Текущий выбранный индекс
                              icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.grey),
                              onChanged: (int? newIndex) {
                                if (newIndex != null) {
                                  setState(() {
                                    magIndex = newIndex; // Обновляем выбранный индекс
                                  });
                                }
                              },
                              items: List.generate(
                                mags.length,
                                    (index) => DropdownMenuItem<int>(
                                  value: index,
                                  child: Text('CW ${mags[index]}°'), // Отображаемое значение
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],)
                  ),
                  const Padding(padding: EdgeInsets.all(20)),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 80, alignment: Alignment.centerLeft, child: Text('Dshot Beacon Configuration', style: TextStyle(color: Colors.black, fontSize: 24),),),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Beacon Tone', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 40,
                      decoration: BoxDecoration(color: Colors.black,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(7),
                            right: Radius.circular(7),// Скругление слева
                          ),
                          border: Border.all(color: Color.fromARGB(255, 109, 113, 120), width: 1)),
                      child: Stack(children: [
                        DropdownButtonHideUnderline( // Убирает подчёркивание у DropdownButton
                          child: ButtonTheme(
                            alignedDropdown: true, // Используется для выравнивания выпадающего списка по ширине кнопки
                            child: DropdownButton<int>(
                              isExpanded: true, // Расширяет DropdownButton на весь доступный размер
                              value: beaconIndex, // Текущий выбранный индекс
                              icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.grey),
                              onChanged: (int? newIndex) {
                                if (newIndex != null) {
                                  setState(() {
                                    beaconIndex = newIndex; // Обновляем выбранный индекс
                                  });
                                }
                              },
                              items: List.generate(
                                beacons.length,
                                    (index) => DropdownMenuItem<int>(
                                  value: index,
                                  child: Text('${beacons[index]}'), // Отображаемое значение
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],)
                  ),
                  const Padding(padding: EdgeInsets.all(10)),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [Text('RX_LOST', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),
                        Switch(value: RX_LOST, onChanged: (value){setState(() {
                          RX_LOST = value;
                        });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
                      ],),
                  ),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [Text('RX_SET', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),
                        Switch(value: RX_SET, onChanged: (value){setState(() {
                          RX_SET = value;
                        });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
                      ],),
                  ),
                  const Padding(padding: EdgeInsets.all(20)),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 80, alignment: Alignment.centerLeft, child: Text('Beeper Beacon Configuration', style: TextStyle(color: Colors.black, fontSize: 24),),),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [Text('RX_LOST_LANDING', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),
                        Switch(value: RX_LOST_LANDING, onChanged: (value){setState(() {
                          RX_LOST_LANDING = value;
                        });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
                      ],),
                  ),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [Text('RX_LOST_BEACON', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),
                        Switch(value: RX_LOST_BEACON, onChanged: (value){setState(() {
                          RX_LOST_BEACON = value;
                        });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
                      ],),
                  ),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [Text('GYRO_CALIBRATED', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),
                        Switch(value: GYRO_CALIBRATED, onChanged: (value){setState(() {
                          GYRO_CALIBRATED = value;
                        });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
                      ],),
                  ),
                  const Padding(padding: EdgeInsets.all(20)),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 80, alignment: Alignment.centerLeft, child: Text('Personalization', style: TextStyle(color: Colors.black, fontSize: 24),),),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Craft name', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),),
                  Container(alignment: Alignment.centerLeft, width: MediaQuery.of(context).size.width * 0.8, height: 40,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: TextField(
                        controller: _controllerCraft,
                        style: TextStyle(color: Colors.grey),
                        decoration: InputDecoration(
                          border: InputBorder.none, // Удаление стандартной рамки
                          hintText: 'Введите значение', // Подсказка, когда поле пустое
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onChanged: (text) {
                          var newValue = double.tryParse(text);
                          if (newValue != null) {
                            _controllerCraft.text = newValue.toStringAsFixed(0);
                          }
                        },
                      ),
                    ),
                    decoration: BoxDecoration(color: Colors.black,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(7),
                          right: Radius.circular(7),// Скругление слева
                          // Если вам нужно скругление справа, используйте right: Radius.circular(20)
                        ),
                        border: Border.all(color: Color.fromARGB(255, 109, 113, 120), width: 1)),
                  ),
                  const Padding(padding: EdgeInsets.all(10)),
                  Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Pilot name', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),),
                  Container(
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 40,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: TextField(
                        controller: _controllerPilot,
                        style: TextStyle(color: Colors.grey),
                        decoration: InputDecoration(
                          border: InputBorder.none, // Удаление стандартной рамки
                          hintText: 'Введите значение', // Подсказка, когда поле пустое
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onChanged: (text) {
                          var newValue = double.tryParse(text);
                          if (newValue != null) {
                            _controllerPilot.text = newValue.toStringAsFixed(0);
                          }
                        },
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(7),
                        right: Radius.circular(7), // Скругление слева
                      ),
                      border: Border.all(color: Color.fromARGB(255, 109, 113, 120), width: 1),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(30)),
                ],),)
                ,)
            ]),
          ),
        ],
      ),

    );
  }




