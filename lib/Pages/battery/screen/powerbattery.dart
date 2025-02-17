import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:owl/pages/battery/widgets/rollTextField.dart';
import 'package:owl/pages/battery/widgets/deformableButton.dart';
import 'package:owl/pages/battery/widgets/myCustomSlider.dart';
import 'package:owl/pages/appBar/widgets/customAppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/pages/battery/config/batteryConfig.dart';
import 'package:owl/pages/battery/config/voltageMeterConfig.dart';
import 'package:owl/pages/battery/config/amperageMeterConfig.dart';
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
  final BatteryManager batteryManager = BatteryManager();
  final VoltageMeterManager voltageMeterManager = VoltageMeterManager();
  final AmperageMeterManager amperageMeterManager = AmperageMeterManager();
  double maUsed = 90;
  int cells = 2;
  // Списки значений для выбора
  List<String> voltMeterOptions = ["Нет", "Встроенный АЦП", "ESC-датчик"];
  List<String> curMeterOptions = ["Нет", "Встроенный АЦП", "Виртуальный", "ESC-датчик", "Датчик по MSP-порту"];
  String voltMeterValue = "Onboard ADC";
  String curMeterValue = "Onboard ADC";
// Переменные для хранения текущего выбора (индекс в списке)
  int voltMeterIndex = 1; // Изначально выбран "Onboard ADC"
  int curMeterIndex = 1; // Изначально выбран "Onboard ADC"

// Ваши текстовые контроллеры
  final TextEditingController _controllerVolt = TextEditingController();
  final TextEditingController _controllerCur = TextEditingController();

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
    loadConfig().then((_) {
      setState(() {
        _controllerMinCell.text = minCell.toStringAsFixed(2);
        _controllerMaxCell.text = maxCell.toStringAsFixed(2);
        _controllerWarnCell.text = warnCell.toStringAsFixed(2);
        _controllerCap.text = cap.toStringAsFixed(0);
        _controllerScaleV.text = scale.toStringAsFixed(0);
        _controllerDiv.text = divider.toStringAsFixed(0);
        _controllerMulti.text = multiplier.toStringAsFixed(0);
        _controllerScaleAmp.text = scaleAmp.toStringAsFixed(0);
        _controllerOffset.text = offset.toStringAsFixed(0);

      });
    });
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

  void saveValues() async {
    // Сохраняем данные из контроллеров
    final minCell = double.parse(_controllerMinCell.text);
    final maxCell = double.parse(_controllerMaxCell.text);
    final warnCell = double.parse(_controllerWarnCell.text);
    final cap = int.parse(_controllerCap.text);
    final voltageSource = int.parse(_controllerScaleV.text);
    final currentSource = int.parse(_controllerDiv.text);
    // Используем BatteryManager для сохранения и отправки данных
    await batteryManager.saveConfig(
      minCell: minCell,
      maxCell: maxCell,
      warnCell: warnCell,
      cap: cap,
      voltageSource: voltMeterIndex,
      currentSource: curMeterIndex,
    );
    await voltageMeterManager.saveConfig(
      vbatscale: scale.toInt(),
      vbatresdivval: divider.toInt(),
      vbatresdivmultiplier: multiplier.toInt(),
    );
    await amperageMeterManager.saveConfig(
      scale: scaleAmp.toInt(),
      offset: offset.toInt(),
    );
  }

  Future<void> loadConfig() async {
    // Загружаем данные через BatteryManager
    await batteryManager.loadConfig();
    await voltageMeterManager.loadConfig();
    await amperageMeterManager.loadConfig();

    // Получаем данные из SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final minCell = prefs.getDouble('minCell') ?? 3.7;
    final maxCell = prefs.getDouble('maxCell') ?? 4.2;
    final warnCell = prefs.getDouble('warnCell') ?? 3.3;
    final cap = prefs.getInt('cap') ?? 1000;
    final voltageSource = prefs.getInt('voltageSource') ?? 0;
    final currentSource = prefs.getInt('currentSource') ?? 0;
    voltMeterValue = voltMeterOptions[voltageSource];
    curMeterValue = curMeterOptions[currentSource];
    // Инициализируем контроллеры значениями
    _controllerMinCell.text = minCell.toStringAsFixed(2);
    _controllerMaxCell.text = maxCell.toStringAsFixed(2);
    _controllerWarnCell.text = warnCell.toStringAsFixed(2);
    _controllerCap.text = cap.toString();
    _controllerScaleV.text = voltageSource.toString();
    _controllerDiv.text = currentSource.toString();
    _controllerVolt.text = voltMeterValue.toString();
    _controllerCur.text = curMeterValue.toString();
    print('Config loaded: '
        'minCell=$minCell, maxCell=$maxCell, warnCell=$warnCell, cap=$cap');
  }


  Widget build(BuildContext context){
    return Scaffold(
      body:
      CustomScrollView(
        slivers: [
          CustomAppBar(
            title: 'Питание и Батарея',
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
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color.fromARGB(255, 233, 237, 245), Color.fromARGB(255, 149, 152, 158,)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)), child: SingleChildScrollView(child: Column(children: [
                Container(width: MediaQuery.of(context).size.width * 0.8, height: 80, alignment: Alignment.centerLeft, child: Text('Battery', style: TextStyle(color: Colors.black, fontSize: 24),),),
                Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Voltage Meter Source', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),),
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
                            isExpanded: true,
                            value: voltMeterOptions[voltMeterIndex],
                            icon: const Icon(Icons.keyboard_arrow_down),
                            iconSize: 24,
                            elevation: 16,
                            style: const TextStyle(color: Colors.grey),
                            onChanged: (String? newValue) {
                              setState(() {
                                voltMeterIndex = voltMeterOptions.indexOf(newValue!); // Сохраняем индекс выбранного элемента
                              });
                            },
                            items: voltMeterOptions
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
                Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Current Meter Source', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),),
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
                          // Модифицированный виджет для выбора тока
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: curMeterOptions[curMeterIndex],
                            icon: const Icon(Icons.keyboard_arrow_down),
                            iconSize: 24,
                            elevation: 16,
                            style: const TextStyle(color: Colors.grey),
                            onChanged: (String? newValue) {
                              setState(() {
                                curMeterIndex = curMeterOptions.indexOf(newValue!); // Сохраняем индекс выбранного элемента
                              });
                            },
                            items: curMeterOptions
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
                Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Minimum Cell Voltage', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),),
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
                Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Maximum Cell Voltage', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),),
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
                Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Warning Cell Voltage', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),),
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
                Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Capacity (mAh)', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),),
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
                Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Scale', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),),
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
                Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Divider Value', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),),
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
                Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Multiplier Value', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),),
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
                Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Scale [1/10th mV/A]', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),),
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
                Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Offset [mA]', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),),
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
              ),
            ]),
          ),
        ],
      ),
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
                    const Padding(padding: EdgeInsets.all(5)),
                    Expanded(child: Text(
                      "Превышаешь лимит в 25.5V. Сбрасываю настройки",style: TextStyle(fontSize: 24),
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