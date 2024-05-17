import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class Tele extends StatefulWidget {
  const Tele({Key? key});

  @override
  _TeleState createState() => _TeleState();
}

class _TeleState extends State<Tele> {
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
  String mixerValue = 'QUAD X';
  String motValue = 'DSHOT600';
  bool mixerSwitch = false;
  bool motSwitch = false;
  bool escSwitch = false;
  bool dirSwitch = true;
  List<LiveData> chartData1 = [];
  List<LiveData> chartData2 = [];
  List<LiveData> chartData3 = [];
  List<LiveData> chartData4 = [];
  late ChartSeriesController _chartSeriesController1;
  late ChartSeriesController _chartSeriesController2;
  late ChartSeriesController _chartSeriesController3;
  late ChartSeriesController _chartSeriesController4;
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
                  Navigator.pushReplacementNamed(context, '/3d');
                },
              ),
              ListTile(
                leading: Icon(Icons.battery_charging_full),
                title: Text('Питание и Батарея'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/poba');
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
                  Navigator.pushReplacementNamed(context, '/tele');
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
    _controllerPoles.text = poles.toStringAsFixed(0);
    _controllerIdle.text = idle.toStringAsFixed(0);
    _controllerMot1.text = motor1.toStringAsFixed(0);
    _controllerMot2.text = motor2.toStringAsFixed(0);
    _controllerMot3.text = motor1.toStringAsFixed(0);
    _controllerMot4.text = motor2.toStringAsFixed(0);
    chartData1 = List.generate(50, (index) => LiveData(index, 0));
    chartData2 = List.generate(50, (index) => LiveData(index, 0));
    chartData3 = List.generate(50, (index) => LiveData(index, 0));
    chartData4 = List.generate(50, (index) => LiveData(index, 0));

    Timer.periodic(const Duration(milliseconds: 100), updateDataSource);
    super.initState();
  }
  void dispose(){
    _controllerPoles.dispose();
    _controllerIdle.dispose();
    _controllerMot1.dispose();
    _controllerMot2.dispose();
    _controllerMot3.dispose();
    _controllerMot4.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 233, 237, 245), Color.fromARGB(255, 149, 152, 158,)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)), child: SingleChildScrollView(child:
          Column(children: [
            const Padding(padding: EdgeInsets.all(20)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              DeformableButton(
                onPressed: (){_openSidebarMenu(context);},
                child: Icon(Icons.menu, color: Colors.grey.shade600),
                gradient: LinearGradient(
                    colors: <Color>[Color.fromARGB(255, 233, 237, 245), Color.fromARGB(255, 149, 152, 158,)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                ),
              ),
              const Column(children: [
                Text('Дрон', style: TextStyle(fontSize: 15, color: Colors.grey),),
                Text('Моторы', style: TextStyle(fontSize: 15, color: Colors.black)),
              ],),
              DeformableButton(
                onPressed: (){print('Button pressed');},
                child: Icon(Icons.save, color: Colors.grey.shade600,),
                gradient: LinearGradient(
                    colors: <Color>[Color.fromARGB(255, 233, 237, 245), Color.fromARGB(255, 149, 152, 158,)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                ),
              ),
            ]),
            const Padding(padding: EdgeInsets.all(10)),
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
                        isExpanded: true, // Расширяет DropdownButton на весь доступный размер
                        value: mixerValue,
                        icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.grey),
                        onChanged: (String? newValue) {
                          setState(() {
                            mixerValue = newValue!;
                          });
                        },
                        items: <String>["QUAD X"]
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
            Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: [Switch(value: mixerSwitch, onChanged: (value){setState(() {
              mixerSwitch = value;
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
                        isExpanded: true, // Расширяет DropdownButton на весь доступный размер
                        value: motValue,
                        icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.grey),
                        onChanged: (String? newValue) {
                          setState(() {
                            motValue = newValue!;
                          });
                        },
                        items: <String>["DSHOT600"]
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
            Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: [Switch(value: motSwitch, onChanged: (value){setState(() {
              motSwitch = value;
            });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
              , Container(child: Text('Motor Stop'),width: MediaQuery.of(context).size.width * 0.6,)],),
            ),
            const Padding(padding: EdgeInsets.all(10)),
            Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: [Switch(value: escSwitch, onChanged: (value){setState(() {
              escSwitch = value;
            });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
              , Container(child: Text('ESC Sensor'),width: MediaQuery.of(context).size.width * 0.6,)],),
            ),
            const Padding(padding: EdgeInsets.all(10)),
            Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: [Switch(value: dirSwitch, onChanged: (value){setState(() {
              dirSwitch = value;
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
          SfCartesianChart(
            series: <LineSeries<LiveData, int>>[
              LineSeries<LiveData, int>(
                onRendererCreated: (ChartSeriesController controller) {
                  _chartSeriesController1 = controller;
                },
                dataSource: chartData1,
                color: const Color.fromRGBO(192, 108, 132, 1),
                xValueMapper: (LiveData data, _) => data.time,
                yValueMapper: (LiveData data, _) => data.speed,
              ),
              LineSeries<LiveData, int>(
                onRendererCreated: (ChartSeriesController controller) {
                  _chartSeriesController2 = controller;
                },
                dataSource: chartData2,
                color: const Color.fromRGBO(132, 192, 108, 1),
                xValueMapper: (LiveData data, _) => data.time,
                yValueMapper: (LiveData data, _) => data.speed,
              ),
              LineSeries<LiveData, int>(
                onRendererCreated: (ChartSeriesController controller) {
                  _chartSeriesController3 = controller;
                },
                dataSource: chartData3,
                color: const Color.fromRGBO(108, 132, 192, 1),
                xValueMapper: (LiveData data, _) => data.time,
                yValueMapper: (LiveData data, _) => data.speed,
              ),
              LineSeries<LiveData, int>(
                onRendererCreated: (ChartSeriesController controller) {
                  _chartSeriesController4 = controller;
                },
                dataSource: chartData4,
                color: const Color.fromRGBO(192, 192, 108, 1),
                xValueMapper: (LiveData data, _) => data.time,
                yValueMapper: (LiveData data, _) => data.speed,
              ),
            ],
            primaryYAxis: const NumericAxis(
              axisLine: const AxisLine(width: 0),
              majorTickLines: const MajorTickLines(size: 0),
              title: AxisTitle(text: ''),
              minimum: -2000,
              maximum: 2000,
            ),
          ),
            const Padding(padding: EdgeInsets.all(10)),
            const Center(child: Text('Motors', style: TextStyle(fontSize: 24),),),
            const Padding(padding: EdgeInsets.all(5)),
            SingleChildScrollView(scrollDirection: Axis.horizontal,child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: [
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

            const Padding(padding: EdgeInsets.all(20)),
        ],),))

      ),
    );
  }
  void updateDataSource(Timer _) {
    final random = math.Random();
    final newData = [
      LiveData(time, (random.nextInt(2000) - 1000) * motor1 / 1000),
      LiveData(time, (random.nextInt(700) - 350) * motor2 / 1000),
      LiveData(time, (random.nextInt(1000) - 500) * motor3 / 1000),
      LiveData(time, (random.nextInt(600) - 300) * motor4 / 1000),
    ];

    setState(() {
      chartData1.add(newData[0]);
      chartData2.add(newData[1]);
      chartData3.add(newData[2]);
      chartData4.add(newData[3]);

      if (chartData1.length > 25) chartData1.removeAt(0);
      if (chartData2.length > 25) chartData2.removeAt(0);
      if (chartData3.length > 25) chartData3.removeAt(0);
      if (chartData4.length > 25) chartData4.removeAt(0);

      _chartSeriesController1.updateDataSource(
        addedDataIndexes: <int>[chartData1.length - 1],
        removedDataIndexes: <int>[0],
      );
      _chartSeriesController2.updateDataSource(
        addedDataIndexes: <int>[chartData2.length - 1],
        removedDataIndexes: <int>[0],
      );
      _chartSeriesController3.updateDataSource(
        addedDataIndexes: <int>[chartData3.length - 1],
        removedDataIndexes: <int>[0],
      );
      _chartSeriesController4.updateDataSource(
        addedDataIndexes: <int>[chartData4.length - 1],
        removedDataIndexes: <int>[0],
      );

      time++;
    });
  }
}

class ColorFillContainer extends StatefulWidget {
  final double sliderValue;

  ColorFillContainer({required this.sliderValue});

  @override
  _ColorFillContainerState createState() => _ColorFillContainerState();
}

class _ColorFillContainerState extends State<ColorFillContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(10),
                right: Radius.circular(10),
              ),
              color: Colors.grey,
              border: Border.all(color: Colors.black, width: 1), // Добавляем черную рамку
            ),
            height: 160,
            width: 80,
            child: Center(
              child: Text(
                (1000 + widget.sliderValue * 1000).toStringAsFixed(0),
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1),borderRadius: BorderRadius.horizontal(
                left: Radius.circular(10),
                right: Radius.circular(10), // Скругление слева
              ),color: Colors.orange,),
              height: 160 * widget.sliderValue,
              width: 80,
              child: Center(child: Text((1000+widget.sliderValue*1000).toStringAsFixed(0),style: TextStyle(fontSize: 20),)),
            ),
          ),
        ],
      ),
    );
  }
}


class LiveData {
  LiveData(this.time, this.speed);

  final int time;
  final num speed;
}
class RollTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(double?) onRollChanged;
  final double maxValue;
  final double minValue;
  RollTextField({
    Key? key,
    required this.controller,
    required this.onRollChanged,
    required this.maxValue,
    required this.minValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      width: MediaQuery.of(context).size.width * 0.8,
      height: 40,
      child: Padding(
        padding: EdgeInsets.only(left: 10),
        child: TextField(
          controller: controller,
          style: TextStyle(color: Colors.grey),
          decoration: InputDecoration(
            border: InputBorder.none, // Удаление стандартной рамки
            hintText: 'Введите значение', // Подсказка, когда поле пустое
            hintStyle: TextStyle(color: Colors.grey),
          ),
          keyboardType: TextInputType.number, // Клавиатура для чисел
          onChanged: (text) {
            var newValue = double.tryParse(text);
            if (newValue != null) {
              if (newValue > maxValue) {
                newValue = maxValue;
                controller.text = newValue.toStringAsFixed(0);
                controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
              } else if(newValue < minValue){
                newValue = minValue;
                controller.text = newValue.toStringAsFixed(0);
                controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
              }
              onRollChanged(newValue);
            } else {
              onRollChanged(null);
            }
          },
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(7),
          right: Radius.circular(7), // Скругление слева
        ),
        border: Border.all(color: Color.fromARGB(255, 109, 113, 120), width: 1),
      ),
    );
  }
}
class MyCustomSlider extends StatefulWidget {
  final double sliderValue;
  final Function(double) onValueChanged; // Добавление callback-функции
  final double maxValue;
  final double minValue;
  final double step;

  const MyCustomSlider({
    Key? key,
    required this.sliderValue,
    required this.onValueChanged,
    required this.maxValue,
    required this.minValue,
    required this.step,
  }) : super(key: key);

  @override
  _MyCustomSliderState createState() => _MyCustomSliderState();
}

class _MyCustomSliderState extends State<MyCustomSlider> {
  late double localSliderValue;
  late double localMaxValue;
  late double localMinValue;
  late double step;
  @override
  void initState() {
    super.initState();
    localSliderValue = widget.sliderValue;
    localMaxValue = widget.maxValue;
    localMinValue = widget.minValue;
    step = widget.step;
  }
  @override
  void didUpdateWidget(MyCustomSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Проверяем, изменилось ли входящее значение
    if (oldWidget.sliderValue != widget.sliderValue) {
      setState(() {
        // Обновляем локальное значение, если входящее значение изменилось
        localSliderValue = widget.sliderValue;
        localMaxValue = widget.maxValue;
        localMaxValue = widget.maxValue;
        step = widget.step;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    // Определение градиента для активной части слайдера
    final LinearGradient activeGradient = LinearGradient(
      colors: [Color.fromARGB(255, 255, 115, 8), Color.fromARGB(255, 252, 128, 33)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Определение градиента для неактивной части слайдера
    final LinearGradient inactiveGradient = LinearGradient(
        colors: [Color.fromARGB(255, 22, 25, 28),Color.fromARGB(255, 22, 24, 26),Color.fromARGB(255, 22, 24, 26), Color.fromARGB(255, 65, 68, 71)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter
    );

    return Center(
      child: SliderTheme(
        data: SliderThemeData(
          // кастомизация бегунка
          thumbShape: _CustomThumbShape(),
          // кастомизация активной части полосы
          activeTrackColor: Colors.transparent,
          inactiveTrackColor: Colors.transparent,
          trackHeight: 8.0,
          overlayColor: Colors.orange.withAlpha(32), // цвет вокруг бегунка при нажатии
          overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0), // форма и размер этого вокруг бегунка
          trackShape: _CustomTrackShape(activeGradient, inactiveGradient), // кастомизация формы и градиента полосы
        ),
        child: Slider(
          min: localMinValue,
          max: localMaxValue,
          divisions: ((localMaxValue - localMinValue)/step).toInt(),
          value: localSliderValue,
          onChanged: (value) {
            setState(() {
              localSliderValue = value;
            });
            widget.onValueChanged(value); // Вызов callback-функции с новым значением
          },
        ),
      ),
    );
  }
}
class VerticalSlider extends StatefulWidget {
  final double sliderValue;
  final Function(double) onValueChanged;
  final double maxValue;
  final double minValue;
  final double step;

  const VerticalSlider({
    Key? key,
    required this.sliderValue,
    required this.onValueChanged,
    required this.maxValue,
    required this.minValue,
    required this.step,
  }) : super(key: key);

  @override
  _VerticalSliderState createState() => _VerticalSliderState();
}

class _VerticalSliderState extends State<VerticalSlider> {
  late double localSliderValue;
  late double localMaxValue;
  late double localMinValue;
  late double step;

  @override
  void initState() {
    super.initState();
    localSliderValue = widget.sliderValue;
    localMaxValue = widget.maxValue;
    localMinValue = widget.minValue;
    step = widget.step;
  }

  @override
  void didUpdateWidget(VerticalSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sliderValue != widget.sliderValue) {
      setState(() {
        localSliderValue = widget.sliderValue;
        localMaxValue = widget.maxValue;
        localMinValue = widget.minValue;
        step = widget.step;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeGradient = LinearGradient(
      colors: [Color.fromARGB(255, 255, 115, 8), Color.fromARGB(255, 252, 128, 33)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final inactiveGradient = LinearGradient(
        colors: [Color.fromARGB(255, 22, 25, 28),Color.fromARGB(255, 22, 24, 26),Color.fromARGB(255, 22, 24, 26), Color.fromARGB(255, 65, 68, 71)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter
    );

    return Center(
      child: Column(children: [
        Padding(padding: EdgeInsets.all(10)),
        RotatedBox(
          quarterTurns: 3,
          child: SliderTheme(
            data: SliderThemeData(
              thumbShape: _CustomThumbShape(),
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              trackHeight: 8.0,
              overlayColor: Colors.orange.withAlpha(32),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
              trackShape: _CustomTrackShape(activeGradient, inactiveGradient),
            ),
            child: Slider(
              min: localMinValue,
              max: localMaxValue,
              divisions: ((localMaxValue - localMinValue) / step).toInt(),
              value: localSliderValue,
              onChanged: (value) {
                setState(() {
                  localSliderValue = value;
                });
                widget.onValueChanged(value);
              },
            ),
          ),
        ),
        Padding(padding: EdgeInsets.all(10))
      ],)
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  // Размеры бегунка
  final double thumbRadius = 16.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(thumbRadius * 2, thumbRadius * 2);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.6); // Устанавливаем цвет тени и степень ее прозрачности
    final double elevation = 2.0; // Высота тени от элемента
    final Path shadowPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: thumbRadius + elevation));
    canvas.drawShadow(shadowPath, shadowPaint.color, elevation, true);

    // Градиент для бегунка
    final Paint thumbPaint = Paint()
      ..shader = LinearGradient(
          colors: [Color.fromARGB(255, 233, 237, 245), Color.fromARGB(255, 149, 152, 158,)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight
      ).createShader(Rect.fromCircle(center: center, radius: thumbRadius));

    final Path thumbPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: thumbRadius));
    canvas.drawPath(thumbPath, thumbPaint);


    canvas.drawPath(thumbPath, thumbPaint);

    // Рисуем синий кружок в середине
    final double blueCircleRadius = thumbRadius / 5; // Допустим, размер синего кружка в 2 раза меньше
    final Paint blueCirclePaint = Paint()
      ..color = Colors.orange; // Цвет синего кружка

    final Path blueCirclePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: blueCircleRadius));

    canvas.drawPath(blueCirclePath, blueCirclePaint);
  }
}

class _CustomTrackShape extends SliderTrackShape {
  final LinearGradient activeGradient;
  final LinearGradient inactiveGradient;

  _CustomTrackShape(this.activeGradient, this.inactiveGradient);

  @override
  void paint(
      PaintingContext context,
      Offset offset, {
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required Animation<double> enableAnimation,
        required Offset thumbCenter,
        bool isDiscrete = false,
        bool isEnabled = false,
        Offset? secondaryOffset,
        required TextDirection textDirection,
      }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final double trackWidth = parentBox.size.width;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double activeTrackStart = offset.dx;
    final double activeTrackEnd = thumbCenter.dx;
    final double inactiveTrackStart = activeTrackEnd;
    final double inactiveTrackEnd = trackWidth + offset.dx;
    final Radius radius = Radius.circular(trackHeight / 2); // Для скругления используется радиус, равный половине высоты трека

    final Paint activePaint = Paint()..shader = activeGradient.createShader(Rect.fromLTRB(activeTrackStart, trackTop, activeTrackEnd, trackTop + trackHeight));
    final Paint inactivePaint = Paint()..shader = inactiveGradient.createShader(Rect.fromLTRB(inactiveTrackStart, trackTop, inactiveTrackEnd, trackTop + trackHeight));

    if (activeTrackEnd > activeTrackStart) {
      context.canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTRB(activeTrackStart, trackTop, activeTrackEnd, trackTop + trackHeight), radius),
          activePaint);
    }

    context.canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTRB(inactiveTrackStart, trackTop, inactiveTrackEnd, trackTop + trackHeight), radius),
        inactivePaint);
  }

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    return Rect.fromLTWH(offset.dx, trackTop, parentBox.size.width, trackHeight);
  }
}
class DeformableButton extends StatefulWidget {
  final Widget child;
  final Gradient gradient;
  final double width;
  final double height;
  final VoidCallback onPressed;

  const DeformableButton({
    Key? key,
    required this.child,
    this.gradient = const LinearGradient(
        colors: <Color>[Color.fromARGB(255, 233, 237, 245), Color.fromARGB(255, 149, 152, 158,)]
    ),
    this.width = 50.0,
    this.height = 50.0,
    required this.onPressed,
  }) : super(key: key);

  @override
  _DeformableButtonState createState() => _DeformableButtonState();
}

class _DeformableButtonState extends State<DeformableButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 500));

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _borderAnimation = Tween<double>(begin: 50.0, end: 25.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    /* Запуск анимации при наведении мыши или при нажатии для различных платформ может потребоваться дополнительная логика */
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPressed() {
    widget.onPressed();
    _animationController.forward().then((value) => _animationController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (_, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.gradient,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.all(
                  Radius.circular(_borderAnimation.value),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: null,
                  child: Center(child: widget.child),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
class InfoButton extends StatelessWidget {
  final String infoMessage;

  InfoButton({required this.infoMessage});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(infoMessage),
            actions: <Widget>[
              TextButton(
                child: Text('Закрыть'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      ),
      child: Container(decoration: BoxDecoration(
        color: Colors.black54, // Цвет фона кнопки
        borderRadius: BorderRadius.circular(20), // Скругление кнопки
      ),
        width: 21, // Ширина кнопки
        height: 21, // Высота кнопки
        alignment: Alignment.center,
        child:
        Container(
          decoration: BoxDecoration(
            color: Colors.white, // Цвет фона кнопки
            borderRadius: BorderRadius.circular(20), // Скругление кнопки
          ),
          width: 18, // Ширина кнопки
          height: 18, // Высота кнопки
          alignment: Alignment.center, // Позиционирование иконки в центре
          child: Text(
            'i',
            style: TextStyle(
              color: Colors.orange, // Цвет текста
              fontSize: 14, // Размер текста
            ),
          ),
        ),),
    );
  }
}
void showHintDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.2,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Высота окна подгоняется под содержимое
            crossAxisAlignment: CrossAxisAlignment.start, // Выравнивание по левому краю
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end, // Сдвигаем содержимое вниз
                  children: [
                    Container(width: 150, height: 400, child:
                    SvgPicture.asset('Assets/Images/Draf.svg'),),
                    Expanded(child: Text(
                      "Превышаешь лимит в 25.5V. Сбрасываю настройки",style: TextStyle(fontSize: 16),
                    ),)


                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}