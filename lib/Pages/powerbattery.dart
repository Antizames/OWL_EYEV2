import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
class PowerBattery extends StatefulWidget{
  const PowerBattery({super.key});

  @override
  State<PowerBattery> createState() => _PowerBatteryState();
}
class _PowerBatteryState extends State<PowerBattery> {
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
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(13), // Применяем скругление к Material
        bottomRight: Radius.circular(13),
      ),
      child: Material(
        // Это обеспечивает правильные тему и отображение текста кнопок
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8, // ширина панели, например 80% от ширины экрана
          height: MediaQuery.of(context).size.height, // на всю высоту
          color: Colors.white, // Цвет фона контейнера
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(10)),
              ListTile(
                leading: Icon(Icons.navigation),
                title: Text('Навигация'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Конфигурация'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/3d');
                },
              ),
              ListTile(
                leading: Icon(Icons.battery_charging_full),
                title: Text('Батарея'),
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
                leading: Icon(Icons.sports_motorsports),
                title: Text('Серво'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/ser');
                },
              ),
              ListTile(
                leading: Icon(Icons.sports_motorsports),
                title: Text('Моторы'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/tele');
                },
              ),
              ListTile(
                leading: Icon(Icons.report_problem),
                title: Text('Сообщить об ошибке'),
                onTap: () {
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  double maUsed = 90;
  int cells = 2;
  String voltmeterValue = "Onboard ADC";
  String currmeterValue = "Onboard ADC";
  double batteryVolt = 25;
  double batteryAmp = 17.82;
  double minCell = 3.3;
  double maxCell = 4.3;
  double warnCell = 3.5;
  double cap = 0;
  double scale = 110;
  double divider = 10;
  double multiplier = 1;
  double scaleAmp = 400;
  double offset = 0;
  final TextEditingController _controllerMinCell = TextEditingController();
  final TextEditingController _controllerMaxCell = TextEditingController();
  final TextEditingController _controllerWarnCell = TextEditingController();
  final TextEditingController _controllerCap = TextEditingController();
  final TextEditingController _controllerScaleV = TextEditingController();
  final TextEditingController _controllerDiv = TextEditingController();
  final TextEditingController _controllerMulti = TextEditingController();
  final TextEditingController _controllerScaleAmp = TextEditingController();
  final TextEditingController _controllerOffset = TextEditingController();
  @override
  void initState() {
    setState(() {
      batteryVolt *= multiplier;
      batteryVolt /= divider;
    });
    super.initState();
    _controllerMinCell.text = minCell.toStringAsFixed(2);
    _controllerMaxCell.text = maxCell.toStringAsFixed(2);
    _controllerWarnCell.text = warnCell.toStringAsFixed(2);
    _controllerCap.text = cap.toStringAsFixed(0);
    _controllerScaleV.text = scale.toStringAsFixed(0);
    _controllerDiv.text = divider.toStringAsFixed(0);
    _controllerMulti.text = multiplier.toStringAsFixed(0);
    _controllerScaleAmp.text = scaleAmp.toStringAsFixed(0);
    _controllerOffset.text = offset.toStringAsFixed(0);
  }
  @override
  void dispose() {
    _controllerMinCell.dispose();
    _controllerMaxCell.dispose();
    _controllerWarnCell.dispose();
    _controllerCap.dispose();
    _controllerScaleV.dispose();
    _controllerDiv.dispose();
    _controllerMulti.dispose();
    _controllerScaleAmp.dispose();
    _controllerOffset.dispose();
    super.dispose();
  }
  Widget build(BuildContext context){
    return Scaffold(
      body:
        Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
        colors: [Color.fromARGB(255, 233, 237, 245), Color.fromARGB(255, 149, 152, 158,)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter)), child: SingleChildScrollView(child: Column(children: [
          Padding(padding: EdgeInsets.all(20)),
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
            Column(children: [
              Text('Дрон', style: TextStyle(fontSize: 15, color: Colors.grey),),
              Text('Питание и Батарея', style: TextStyle(fontSize: 15, color: Colors.black)),
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
          Padding(padding: EdgeInsets.all(10)),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 80, alignment: Alignment.centerLeft, child: Text('Battery', style: TextStyle(color: Colors.black, fontSize: 24),),),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Voltage Meter Source', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), InfoButton(infoMessage: 'blank message')],),),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 40,
            decoration: BoxDecoration(color: Colors.black,
                borderRadius: BorderRadius.horizontal(
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
                    value: voltmeterValue,
                    icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.grey),
                    onChanged: (String? newValue) {
                      setState(() {
                        voltmeterValue = newValue!;
                      });
                    },
                    items: <String>["Onboard ADC"]
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
        Padding(padding: EdgeInsets.all(10)),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Current Meter Source', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), InfoButton(infoMessage: 'blank message')],),),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 40,
            decoration: BoxDecoration(color: Colors.black,
                borderRadius: BorderRadius.horizontal(
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
                    value: currmeterValue,
                    icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.grey),
                    onChanged: (String? newValue) {
                      setState(() {
                        currmeterValue = newValue!;
                      });
                    },
                    items: <String>["Onboard ADC"]
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
        Padding(padding: EdgeInsets.all(10)),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Minimum Cell Voltage', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), InfoButton(infoMessage: 'blank message')],),),
        RollTextField(
          minValue: 1,
          maxValue: 5,
          controller: _controllerMinCell,
          onRollChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                minCell = newValue;
              });
            }
          },
        ),
        Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
          child:
          MyCustomSlider(
            step: 0.01,
            minValue: 1,
            maxValue: 5,
            sliderValue: minCell,
            onValueChanged: (newValue) {
              setState(() {
                minCell = newValue;
                _controllerMinCell.text = minCell.toStringAsFixed(2); // Обновляем текстовое поле
              });
            },
          ),),
        Padding(padding: EdgeInsets.all(10)),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Maximum Cell Voltage', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), InfoButton(infoMessage: 'blank message')],),),
        RollTextField(
          minValue: 1,
          maxValue: 5,
          controller: _controllerMaxCell,
          onRollChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                maxCell = newValue;
              });
            }
          },
        ),
        Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
          child:
          MyCustomSlider(
            step: 0.01,
            minValue: 1,
            maxValue: 5,
            sliderValue: maxCell,
            onValueChanged: (newValue) {
              setState(() {
                maxCell = newValue;
                _controllerMaxCell.text = maxCell.toStringAsFixed(2); // Обновляем текстовое поле
              });
            },
          ),),
        Padding(padding: EdgeInsets.all(10)),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Warning Cell Voltage', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), InfoButton(infoMessage: 'blank message')],),),
        RollTextField(
          minValue: 1,
          maxValue: 5,
          controller: _controllerWarnCell,
          onRollChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                warnCell = newValue;
              });
            }
          },
        ),
        Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
          child:
          MyCustomSlider(
            step: 0.01,
            minValue: 1,
            maxValue: 5,
            sliderValue: warnCell,
            onValueChanged: (newValue) {
              setState(() {
                warnCell = newValue;
                _controllerWarnCell.text = warnCell.toStringAsFixed(2); // Обновляем текстовое поле
              });
            },
          ),),
        Padding(padding: EdgeInsets.all(10)),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Capacity (mAh)', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), InfoButton(infoMessage: 'blank message')],),),
        RollTextField(
          minValue: 0,
          maxValue: 20000,
          controller: _controllerCap,
          onRollChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                cap = newValue;
              });
            }
          },
        ),
        Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
          child:
          MyCustomSlider(
            step: 10,
            minValue: 0,
            maxValue: 20000,
            sliderValue: cap,
            onValueChanged: (newValue) {
              setState(() {
                cap = newValue;
                _controllerCap.text = cap.toStringAsFixed(0); // Обновляем текстовое поле
              });
            },
          ),),
        Padding(padding: EdgeInsets.all(5)),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 80, alignment: Alignment.centerLeft, child: Text('Voltage Meter', style: TextStyle(color: Colors.black, fontSize: 24),),),
          Container(width: MediaQuery.of(context).size.width * 0.8,decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(7),
              right: Radius.circular(7), // Скругление слева
            ),
            border: Border.all(color: Color.fromARGB(255, 109, 113, 120), width: 1),
          ),child:
          Column(children: [
            Padding(padding: EdgeInsets.all(5)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: [
              Text('Battery',style: TextStyle(color: Colors.grey),),
              Text('${batteryVolt.toStringAsFixed(2)} V',style: TextStyle(color: Colors.orange),),
            ],),
            Padding(padding: EdgeInsets.all(5)),
          ],),),
          Padding(padding: EdgeInsets.all(10)),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Scale', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), InfoButton(infoMessage: 'blank message')],),),
        RollTextField(
          minValue: 10,
          maxValue: 255,
          controller: _controllerScaleV,
          onRollChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                scale = newValue;
              });
            }
          },
        ),
        Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
          child:
          MyCustomSlider(
            step: 1,
            minValue: 10,
            maxValue: 255,
            sliderValue: scale,
            onValueChanged: (newValue) {
              setState(() {
                scale = newValue;
                _controllerScaleV.text = scale.toStringAsFixed(0); // Обновляем текстовое поле
              });
            },
          ),),
        Padding(padding: EdgeInsets.all(10)),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Divider Value', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), InfoButton(infoMessage: 'blank message')],),),
        RollTextField(
          minValue: 1,
          maxValue: 255,
          controller: _controllerDiv,
          onRollChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                if(batteryVolt >= 25.5){
                  showHintDialog(context);
                  setState(() {
                    divider = 255;
                    batteryVolt = 25/divider * multiplier;
                  });

                } else{
                  batteryVolt = batteryVolt * divider / newValue;
                  divider = newValue;
                }
              });
            }
          },
        ),
        Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
          child:
          MyCustomSlider(
            step: 1,
            minValue: 1,
            maxValue: 255,
            sliderValue: divider,
            onValueChanged: (newValue) {
              setState(() {
                if(batteryVolt >= 25.5){
                  showHintDialog(context);
                  setState(() {
                    divider = 255;
                    batteryVolt = 25/divider * multiplier;
                  });

                } else{
                  batteryVolt = batteryVolt * divider / newValue;
                  divider = newValue;
                }
                _controllerDiv.text = divider.toStringAsFixed(0); // Обновляем текстовое поле
              });
            },
          ),),
        Padding(padding: EdgeInsets.all(10)),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Multiplier Value', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), InfoButton(infoMessage: 'blank message')],),),
        RollTextField(
          minValue: 1,
          maxValue: 255,
          controller: _controllerMulti,
          onRollChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                if(batteryVolt >= 25.5){
                  showHintDialog(context);
                  setState(() {
                    multiplier = 1;
                    batteryVolt = 25/divider * multiplier;
                  });

                } else{
                  batteryVolt = batteryVolt / multiplier * newValue;
                  multiplier = newValue;
                }
              });
            }
          },
        ),
        Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
          child:
          MyCustomSlider(
            step: 1,
            minValue: 1,
            maxValue: 255,
            sliderValue: multiplier,
            onValueChanged: (newValue) {
              setState(() {
                if(batteryVolt >= 25.5){
                  showHintDialog(context);
                  setState(() {
                    multiplier = 1;
                    batteryVolt = 25/divider * multiplier;
                  });
                } else{
                  batteryVolt = batteryVolt / multiplier * newValue;
                  multiplier = newValue;
                }
                _controllerMulti.text = multiplier.toStringAsFixed(0); // Обновляем текстовое поле
              });
            },
          ),),
        Padding(padding: EdgeInsets.all(5)),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 80, alignment: Alignment.centerLeft, child: Text('Amperage Meter', style: TextStyle(color: Colors.black, fontSize: 24),),),
          Container(width: MediaQuery.of(context).size.width * 0.8,decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(7),
              right: Radius.circular(7), // Скругление слева
            ),
            border: Border.all(color: Color.fromARGB(255, 109, 113, 120), width: 1),
          ),child:
          Column(children: [
            Padding(padding: EdgeInsets.all(5)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: [
              Text('Battery',style: TextStyle(color: Colors.grey),),
              Text('${batteryAmp} A',style: TextStyle(color: Colors.orange),),
            ],),
            Padding(padding: EdgeInsets.all(5)),
          ],),),
        Padding(padding: EdgeInsets.all(10)),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Scale [1/10th mV/A]', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), InfoButton(infoMessage: 'blank message')],),),
        RollTextField(
          minValue: -16000,
          maxValue: 16000,
          controller: _controllerScaleAmp,
          onRollChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                scaleAmp = newValue;
              });
            }
          },
        ),
        Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
          child:
          MyCustomSlider(
            step: 10,
            minValue: -16000,
            maxValue: 16000,
            sliderValue: scaleAmp,
            onValueChanged: (newValue) {
              setState(() {
                scaleAmp = newValue;
                _controllerScaleAmp.text = scaleAmp.toStringAsFixed(0); // Обновляем текстовое поле
              });
            },
          ),),
        Padding(padding: EdgeInsets.all(10)),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Offset [mA]', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), InfoButton(infoMessage: 'blank message')],),),
        RollTextField(
          minValue: -32000,
          maxValue: 32000,
          controller: _controllerOffset,
          onRollChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                offset = newValue;
              });
            }
          },
        ),
        Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
          child:
          MyCustomSlider(
            step: 10,
            minValue: -32000,
            maxValue: 32000,
            sliderValue: offset,
            onValueChanged: (newValue) {
              setState(() {
                offset = newValue;
                _controllerOffset.text = offset.toStringAsFixed(0); // Обновляем текстовое поле
              });
            },
          ),),
        Padding(padding: EdgeInsets.all(5)),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 80, alignment: Alignment.centerLeft, child: Text('Power State', style: TextStyle(color: Colors.black, fontSize: 24),),),
          Container(width: MediaQuery.of(context).size.width * 0.8,decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(7),
              right: Radius.circular(7), // Скругление слева
            ),
            border: Border.all(color: Color.fromARGB(255, 109, 113, 120), width: 1),
          ),child:
            Column(children: [
              Padding(padding: EdgeInsets.all(5)),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: [
                Text('Connected', style: TextStyle(color: Colors.grey),),
                Text('Yes (Cells: ${cells})', style: TextStyle(color: Colors.orange),),
              ],),
              Padding(padding: EdgeInsets.all(5)),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: [
                Text('Voltage', style: TextStyle(color: Colors.grey),),
                Text('${batteryVolt.toStringAsFixed(2)} V', style: TextStyle(color: Colors.orange),),
              ],),
              Padding(padding: EdgeInsets.all(5)),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: [
                Text('mAh used', style: TextStyle(color: Colors.grey),),
                Text('${maUsed} mAh', style: TextStyle(color: Colors.orange),),
              ],),
              Padding(padding: EdgeInsets.all(5)),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: [
                Text('Amperage', style: TextStyle(color: Colors.grey),),
                Text('${batteryAmp} A', style: TextStyle(color: Colors.orange),),
              ],),
              Padding(padding: EdgeInsets.all(5)),
            ],),),
          Padding(padding: EdgeInsets.all(15)),
        ],),)
    ));
  }
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
        vsync: this, duration: Duration(milliseconds: 200));

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