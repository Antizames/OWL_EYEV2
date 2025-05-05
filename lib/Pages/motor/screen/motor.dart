import 'package:flutter/material.dart';
import 'package:owl/pages/motor/config/mixerConfig.dart';
import 'package:owl/pages/motor/config/motorConfig.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:owl/pages/motor/config/pidAdvancedConfig.dart';
import 'package:owl/pages/motor/widgets/colorFillContainer.dart';
import 'package:owl/pages/motor/widgets/deformableButton.dart';
import 'package:owl/pages/motor/widgets/liveData.dart';
import 'package:owl/pages/motor/widgets/rollTextField.dart';
import 'package:owl/pages/motor/widgets/verticalSlider.dart';
import 'package:owl/pages/appBar/widgets/customAppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/config/config.dart';

import 'package:owl/pages/sideBarMenu/sidebar_menu.dart';
class Motor extends StatefulWidget {
  const Motor({Key? key});

  @override
  _MotorState createState() => _MotorState();
}

class _MotorState extends State<Motor> {
  late Timer timer;
  final TextEditingController _controllerPoles = TextEditingController();
  final TextEditingController _controllerIdle = TextEditingController();
  final TextEditingController _controllerMot1 = TextEditingController();
  final TextEditingController _controllerMot2 = TextEditingController();
  final TextEditingController _controllerMot3 = TextEditingController();
  final TextEditingController _controllerMot4 = TextEditingController();
  double motor1 = 1000;
  double motor2 = 1000;
  double motor3 = 1000;
  double motor4 = 1000;
  int poles = 14;
  int idle = 0;
  int minX = 0;
  int maxX = 24;
  List<String> mixerOptions = ["Tricopter", "Quad +", "Quad X", "Bicopter", "Gimbal", "Y6", "Hex +", "Flying Wing", "Y4", "Hex X", "Octo X8", "Octo Flat +", "Octo Flat X", "Airplane", "Heli 120", "Heli 90", "V-tail Quad", "Hex H", "PPM to SERVO", "Dualcopter", "Singlecopter", "A-tail Quad", "Custom", "Custom Airplane", "Custom Tricopter", "Quad X 1234", "Octo X8 +"];
  String mixerValue = "QUAD X";
  int mixerIndex = 0;
  List<String> motorOptions = ["Disabled", "Brushed", "DShot150", "DShot300", "DShot600", "Multishot", "OneShot125", "OneShot42", "ProShot1000", "PWM"];
  String motorValue = "Disabled";
  int motorIndex = 0;
  bool motorOn = true;
  bool motorDirection = false;
  bool motorStop = false;
  bool escSensor = false;
  bool bidirDshot = true;
  List<LiveData> chartData1 = [];
  List<LiveData> chartData2 = [];
  List<LiveData> chartData3 = [];
  List<LiveData> chartData4 = [];
  int time = 0;
  void _openSidebarMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => throw UnimplementedError(),
      barrierDismissible: false, // Сделаем нашу затемненную область действующей вручную
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent, // Прозрачный цвет, т.к. обработка вручную
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero);
        final offsetAnimation = animation.drive(tween);

        return Stack(
          children: <Widget>[
            GestureDetector(
              // Затемненный фон за меню
              onTap: () => Navigator.pop(context), // Закрытие меню
              child: FadeTransition(
                opacity: animation,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
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
  void initState() {
    loadConfig().then((_) {
      setState(() {
        _controllerPoles.text = poles.toStringAsFixed(0);
        _controllerIdle.text = idle.toStringAsFixed(0);
        _controllerMot1.text = motor1.toStringAsFixed(0);
        _controllerMot2.text = motor2.toStringAsFixed(0);
        _controllerMot3.text = motor3.toStringAsFixed(0);
        _controllerMot4.text = motor4.toStringAsFixed(0);
      });
    });
    chartData1 = List.generate(25, (index) => LiveData(index, 0));
    chartData2 = List.generate(25, (index) => LiveData(index, 0));
    chartData3 = List.generate(25, (index) => LiveData(index, 0));
    chartData4 = List.generate(25, (index) => LiveData(index, 0));

    timer = Timer.periodic(Duration(milliseconds: 300), updateDataSource);
    super.initState();
  }
  void dispose(){
    _controllerPoles.dispose();
    _controllerIdle.dispose();
    _controllerMot1.dispose();
    _controllerMot2.dispose();
    _controllerMot3.dispose();
    _controllerMot4.dispose();
    timer.cancel();
    super.dispose();
  }
  final MixerManager mixerManager = MixerManager();
  final MotorManager motorManager = MotorManager();
  final PidManager pidManager = PidManager();
  void saveValues() async{
    saveConfig(
      poles: int.parse(_controllerPoles.text),
      idle: int.parse(_controllerIdle.text),
      motor1: double.parse(_controllerMot1.text),
      motor2: double.parse(_controllerMot2.text),
      motor3: double.parse(_controllerMot3.text),
      motor4: double.parse(_controllerMot4.text),
      mixerValue: mixerValue,
      motorValue: motorValue,
      motorOn: motorOn,
      motorDirection: motorDirection,
      motorStop: motorStop,
      escSensor: escSensor,
      bidirDshot: bidirDshot,
    );
    await mixerManager.saveConfig(
      mixer: mixerIndex+1,
      reverseMotorDir: motorDirection ? 1 : 0,
    );
    await motorManager.saveConfig(
      minThrottle: 1070,
      maxThrottle: 2000,
      minCommand: 1000,
      escProtocol: 8, // Например, DSHOT600 (зависит от протокола)
      motorPoles: 3,
      useDshotTelemetry: bidirDshot,
      useEscSensor: escSensor,
      motorStop: motorStop,
    );
    await pidManager.saveFullConfig(
      PidConfig(
        gyroSyncDenom: 2,
        pidProcessDenom: 1,
        useUnsyncedPwm: 0,
        fastPwmProtocol: mixerIndex + 1,
        motorPwmRate: 48000,
        motorIdle: idle,
        gyroUse32kHz: 0,
        motorPwmInversion: 0,
        gyroHighFsr: 1,
        gyroMovementCalibThreshold: 50,
        gyroCalibDuration: 30,
        gyroOffsetYaw: 10,
        gyroCheckOverflow: 1,
        debugMode: 0,
        gyroToUse: 0,
      ),
    );
  }

  Future<void> loadConfig() async {
    await mixerManager.loadConfig();
    await motorManager.loadConfig();
    await pidManager.loadConfig();
    final prefs = await SharedPreferences.getInstance();
    poles = prefs.getInt('poles') ?? 14;
    idle = prefs.getInt('idle') ?? 0;
    motor1 = prefs.getDouble('motor1') ?? 1000.0;
    motor2 = prefs.getDouble('motor2') ?? 1000.0;
    motor3 = prefs.getDouble('motor3') ?? 1000.0;
    motor4 = prefs.getDouble('motor4') ?? 1000.0;

    // Обновляем текстовые контроллеры
    setState(() {
      _controllerPoles.text = poles.toStringAsFixed(0);
      _controllerIdle.text = idle.toStringAsFixed(0);
      _controllerMot1.text = motor1.toStringAsFixed(0);
      _controllerMot2.text = motor2.toStringAsFixed(0);
      _controllerMot3.text = motor3.toStringAsFixed(0);
      _controllerMot4.text = motor4.toStringAsFixed(0);
      mixerValue = prefs.getString('mixerValue') ?? 'QUAD X';
      motorValue = prefs.getString('motorValue') ?? 'DSHOT600';
      motorOn = prefs.getBool('motorOn') ?? false;
      motorDirection = prefs.getBool('motorDirection') ?? false;
      motorStop = prefs.getBool('motorStop') ?? false;
      escSensor = prefs.getBool('escSensor') ?? false;
      bidirDshot = prefs.getBool('bidirDshot') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomAppBar(
            title: 'Моторы',
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
                          end: Alignment.bottomCenter)), child: SingleChildScrollView(child:
              Column(children: [

                const Center(child: Text('Mixer', style: TextStyle(fontSize: 24),),),
                const Padding(padding: EdgeInsets.all(5)),
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
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: mixerOptions[mixerIndex],
                            icon: const Icon(Icons.keyboard_arrow_down),
                            iconSize: 24,
                            elevation: 16,
                            style: const TextStyle(color: Colors.grey),
                            onChanged: (String? newValue) {
                              setState(() {
                                mixerIndex = mixerOptions.indexOf(newValue!); // Сохраняем индекс выбранного элемента
                              });
                            },
                            items: mixerOptions
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],)
                ),
                const Padding(padding: EdgeInsets.all(10)),
                Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: [Switch(value: motorDirection, onChanged: (value){setState(() {
                  motorDirection = value;
                });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: const Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
                  , Container(child: Text('Motor Direction is reversed'),width: MediaQuery.of(context).size.width * 0.6,)],),
                ),
                const Padding(padding: EdgeInsets.all(5)),
                const Center(child: Text('ESC/Motor Features', style: TextStyle(fontSize: 24),),),
                const Padding(padding: EdgeInsets.all(5)),
                Container(width: MediaQuery.of(context).size.width * 0.8, height: 40,
                    decoration: BoxDecoration(color: Colors.black,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(7),
                          right: Radius.circular(7),// Скругление слева
                        ),
                        border: Border.all(color: const Color.fromARGB(255, 109, 113, 120), width: 1)),
                    child: Stack(children: [
                      DropdownButtonHideUnderline( // Убирает подчёркивание у DropdownButton
                        child: ButtonTheme(
                          alignedDropdown: true, // Используется для выравнивания выпадающего списка по ширине кнопки
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: motorOptions[motorIndex],
                            icon: const Icon(Icons.keyboard_arrow_down),
                            iconSize: 24,
                            elevation: 16,
                            style: const TextStyle(color: Colors.grey),
                            onChanged: (String? newValue) {
                              setState(() {
                                motorIndex = motorOptions.indexOf(newValue!); // Сохраняем индекс выбранного элемента
                              });
                            },
                            items: motorOptions
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],)
                ),
                const Padding(padding: EdgeInsets.all(10)),
                Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: [Switch(value: motorStop, onChanged: (value){setState(() {
                  motorStop = value;
                });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
                  , Container(child: Text('Motor Stop'),width: MediaQuery.of(context).size.width * 0.6,)],),
                ),
                const Padding(padding: EdgeInsets.all(10)),
                Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: [Switch(value: escSensor, onChanged: (value){setState(() {
                  escSensor = value;
                });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
                  , Container(child: Text('ESC Sensor'),width: MediaQuery.of(context).size.width * 0.6,)],),
                ),
                const Padding(padding: EdgeInsets.all(10)),
                Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: [Switch(value: bidirDshot, onChanged: (value){setState(() {
                  bidirDshot = value;
                });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
                  , Container(child: Text('Bidirectional DShot'),width: MediaQuery.of(context).size.width * 0.6,)],),
                ),
                const Padding(padding: EdgeInsets.all(10)),
                Text('Motor poles'),
                const Padding(padding: EdgeInsets.all(3)),
                RollTextField(
                  minValue: 0,
                  maxValue: 2000,
                  controller: _controllerPoles,
                  onRollChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        poles = newValue.toInt();
                      });
                    }
                  },
                ),
                const Padding(padding: EdgeInsets.all(10)),
                const Text('Motor Idle'),
                const Padding(padding: EdgeInsets.all(3)),
                RollTextField(
                  minValue: 0,
                  maxValue: 2000,
                  controller: _controllerIdle,
                  onRollChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        poles = newValue.toInt();
                      });
                    }
                  },
                ),
                const Padding(padding: EdgeInsets.all(10)),
                const Center(child: Text('3D ESC/Motor Features', style: TextStyle(fontSize: 24),),),
                const Padding(padding: EdgeInsets.all(5)),
                Container(width: MediaQuery.of(context).size.width*0.8, height: 300,
                child: LineChart(
                  LineChartData(
                    minX: minX.toDouble(),
                    maxX: maxX.toDouble(),
                    minY: -2000,
                    maxY: 2000,
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartData1
                            .where((point) => point.speed != 0)
                            .map((point) => FlSpot(point.time.toDouble(), point.speed.toDouble()))
                            .toList(),
                        isCurved: false,
                        color: Colors.red,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(show: false),
                      ),
                      LineChartBarData(
                        spots: chartData2
                            .where((point) => point.speed != 0)
                            .map((point) => FlSpot(point.time.toDouble(), point.speed.toDouble()))
                            .toList(),
                        isCurved: false,
                        color: Colors.green,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(show: false),
                      ),
                      LineChartBarData(
                        spots: chartData3
                            .where((point) => point.speed != 0)
                            .map((point) => FlSpot(point.time.toDouble(), point.speed.toDouble()))
                            .toList(),
                        isCurved: false,
                        color: Colors.blue,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(show: false),
                      ),
                      LineChartBarData(
                        spots: chartData4
                            .where((point) => point.speed != 0)
                            .map((point) => FlSpot(point.time.toDouble(), point.speed.toDouble()))
                            .toList(),
                        isCurved: false,
                        color: Colors.yellow,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Убираем метки слева
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),   // Убираем метки сверху
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            if (value == minX || value == maxX) {
                              return const SizedBox.shrink(); // Не показывать метки на крайних значениях
                            }
                            return Text(
                              '${value.toInt()}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            );
                          },
                        ),
                      ), // Показываем метки снизу
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: const Border(
                        left: BorderSide.none,   // Убираем левую границу
                        top: BorderSide(width: 1),   // Линия сверху
                        right: BorderSide(width: 1), // Линия справа
                        bottom: BorderSide(width: 1), // Линия снизу
                      ),
                    ),
                  ),
                )),
                const Padding(padding: EdgeInsets.all(10)),
                const Center(child: Text('Motors', style: TextStyle(fontSize: 24),),),
                const Padding(padding: EdgeInsets.all(5)),
                Container(width: MediaQuery.of(context).size.width * 0.8, height: 40, alignment: Alignment.center, child: Switch(value: !motorOn, onChanged: (value){setState(() {
                  motorOn = !value;
                });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
                ),
                const Padding(padding: EdgeInsets.all(5)),
                IgnorePointer(ignoring: motorOn, child:SingleChildScrollView(scrollDirection: Axis.horizontal,child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: [
                  Row(children: [
                    Column(children: [
                      const Text('1', style: TextStyle(fontSize: 20),),
                      const Padding(padding: EdgeInsets.all(3)),
                      ColorFillContainer(sliderValue: motor1/1000 - 1),
                      const Padding(padding: EdgeInsets.all(20)),
                    ],),
                    VerticalSlider(
                      step: 5,
                      minValue: 1000,
                      maxValue: 2000,
                      sliderValue: motor1,
                      onValueChanged: (newValue) {
                        setState(() {
                          motor1 = newValue;
                          _controllerMot1.text = motor1.toStringAsFixed(0); // Обновляем текстовое поле
                        });
                      },
                    ),
                  ],),
                  Row(children: [
                    Column(children: [
                      const Text('2', style: TextStyle(fontSize: 20),),
                      const Padding(padding: EdgeInsets.all(3)),
                      ColorFillContainer(sliderValue: motor2/1000 - 1),
                      const Padding(padding: EdgeInsets.all(20)),
                    ],),
                    VerticalSlider(
                      step: 5,
                      minValue: 1000,
                      maxValue: 2000,
                      sliderValue: motor2,
                      onValueChanged: (newValue) {
                        setState(() {
                          motor2 = newValue;
                          _controllerMot2.text = motor2.toStringAsFixed(0); // Обновляем текстовое поле
                        });
                      },
                    )
                  ],),
                  Row(children: [
                    Column(children: [
                      const Text('3', style: TextStyle(fontSize: 20),),
                      const Padding(padding: EdgeInsets.all(3)),
                      ColorFillContainer(sliderValue: motor3/1000 - 1),
                      const Padding(padding: EdgeInsets.all(20)),
                    ],),
                    VerticalSlider(
                      step: 5,
                      minValue: 1000,
                      maxValue: 2000,
                      sliderValue: motor3,
                      onValueChanged: (newValue) {
                        setState(() {
                          motor3 = newValue;
                          _controllerMot3.text = motor3.toStringAsFixed(0); // Обновляем текстовое поле
                        });
                      },
                    ),
                  ],),
                  Row(children: [
                    Column(children: [
                      const Text('4', style: TextStyle(fontSize: 20),),
                      const Padding(padding: EdgeInsets.all(3)),
                      ColorFillContainer(sliderValue: motor4/1000 - 1),
                      const Padding(padding: EdgeInsets.all(20)),
                    ],),
                    VerticalSlider(
                      step: 5,
                      minValue: 1000,
                      maxValue: 2000,
                      sliderValue: motor4,
                      onValueChanged: (newValue) {
                        setState(() {
                          motor4 = newValue;
                          _controllerMot4.text = motor4.toStringAsFixed(0); // Обновляем текстовое поле
                        });
                      },
                    )
                  ],),
                ],),),
                ),
                const Padding(padding: EdgeInsets.all(20)),
              ],),))
            ]),
          ),
        ],
      ),

    );
  }
  void updateDataSource(Timer _) {
    final random = math.Random();
    setState(() {
      // Подготавливаем новые данные для всех графиков
      final newData = [
        LiveData(time, (random.nextInt(2000) - 1000).toDouble()),
        LiveData(time, (random.nextInt(700) - 350).toDouble()),
        LiveData(time, (random.nextInt(1000) - 500).toDouble()),
        LiveData(time, (random.nextInt(600) - 300).toDouble()),
      ];

      // Добавляем новые точки в каждый из графиков
      chartData1.add(newData[0]);
      chartData2.add(newData[1]);
      chartData3.add(newData[2]);
      chartData4.add(newData[3]);

      // Если длина данных превышает 100, удаляем первые 50 точек
      if (chartData1.length > 5000) {
        chartData1.removeRange(0, 4950);
        chartData2.removeRange(0, 4950);
        chartData3.removeRange(0, 4950);
        chartData4.removeRange(0, 4950);

        // Сдвигаем шкалу X
        minX = (minX + 900).clamp(0, time);
        maxX = (maxX + 4950).clamp(24, time + 4950);
      }

      // Обновляем время
      if (time > 23) {
        minX = time - 23;
        maxX = time+1;
      }

      time++;
    });
  }



}
