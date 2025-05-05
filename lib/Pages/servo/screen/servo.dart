import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:owl/pages/servo/widgets/deformableButton.dart';
import 'package:owl/pages/servo/widgets/checkBox.dart';
import 'package:owl/pages/servo/widgets/rollTextField.dart';
import 'package:owl/pages/appBar/widgets/customAppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/config/config.dart';
import 'package:owl/pages/servo/config/servoConfig.dart';

import 'package:owl/pages/sideBarMenu/sidebar_menu.dart';
class Servo extends StatefulWidget{
  const Servo({super.key});

  @override
  State<Servo> createState() => _ServoState();
}
class _ServoState extends State<Servo> {
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
              child: SidebarMenu(),
            ),
          ],
        );
      },
    );
  }

  ServoManager servoManager = ServoManager();
  List<String> titles = ['CH1','CH2','CH3','CH4','A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','A11','A12'];
  List<bool> servo1 = [false, false, false, false,false, false, false, false,false, false, false, false,false, false, false, false];
  List<bool> servo2 = [false, false, false, false,false, false, false, false,false, false, false, false,false, false, false, false];
  List<bool> servo3 = [false, false, false, false,false, false, false, false,false, false, false, false,false, false, false, false];
  List<bool> servo4 = [false, false, false, false,false, false, false, false,false, false, false, false,false, false, false, false];
  final TextEditingController _controllerMid1 = TextEditingController();
  final TextEditingController _controllerMin1 = TextEditingController();
  final TextEditingController _controllerMax1 = TextEditingController();
  final TextEditingController _controllerMid2 = TextEditingController();
  final TextEditingController _controllerMin2 = TextEditingController();
  final TextEditingController _controllerMax2 = TextEditingController();
  final TextEditingController _controllerMid3 = TextEditingController();
  final TextEditingController _controllerMin3 = TextEditingController();
  final TextEditingController _controllerMax3 = TextEditingController();
  final TextEditingController _controllerMid4 = TextEditingController();
  final TextEditingController _controllerMin4 = TextEditingController();
  final TextEditingController _controllerMax4 = TextEditingController();
  int mid1 = 1500;
  int min1 = 1000;
  int max1 = 2000;
  int mid2 = 1500;
  int min2 = 1000;
  int max2 = 2000;
  int mid3 = 1500;
  int min3 = 1000;
  int max3 = 2000;
  int mid4 = 1500;
  int min4 = 1000;
  int max4 = 2000;
  String s1Rate = "Rate: 100%";
  String s2Rate = 'Rate: 100%';
  String s3Rate = 'Rate: 100%';
  String s4Rate = 'Rate: 100%';
  @override
  void initState() {
    super.initState();
    loadConfig().then((_) {
      _controllerMid1.text = mid1.toString();
      _controllerMin1.text = min1.toString();
      _controllerMax1.text = max1.toString();
      _controllerMid2.text = mid2.toString();
      _controllerMin2.text = min2.toString();
      _controllerMax2.text = max2.toString();
      _controllerMid3.text = mid3.toString();
      _controllerMin3.text = min3.toString();
      _controllerMax3.text = max3.toString();
      _controllerMid4.text = mid4.toString();
      _controllerMin4.text = min4.toString();
      _controllerMax4.text = max4.toString();
    });
  }

  @override
  void dispose() {
    _controllerMid1.dispose();
    _controllerMin1.dispose();
    _controllerMax1.dispose();
    _controllerMid2.dispose();
    _controllerMin2.dispose();
    _controllerMax2.dispose();
    _controllerMid3.dispose();
    _controllerMin3.dispose();
    _controllerMax3.dispose();
    _controllerMid4.dispose();
    _controllerMin4.dispose();
    _controllerMax4.dispose();
    super.dispose();
  }
  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await servoManager.loadConfig();

    // Очистка старых значений, если они хранились как строки
    if (prefs.containsKey('s1Rate') && prefs.get('s1Rate') is String) {
      await prefs.remove('s1Rate');
    }
    if (prefs.containsKey('s2Rate') && prefs.get('s2Rate') is String) {
      await prefs.remove('s2Rate');
    }
    if (prefs.containsKey('s3Rate') && prefs.get('s3Rate') is String) {
      await prefs.remove('s3Rate');
    }
    if (prefs.containsKey('s4Rate') && prefs.get('s4Rate') is String) {
      await prefs.remove('s4Rate');
    }

    setState(() {
      titles = List.generate(16, (index) => prefs.getString('title_$index') ?? titles[index]);
      servo1 = List.generate(16, (index) => prefs.getBool('servo1_$index') ?? servo1[index]);
      servo2 = List.generate(16, (index) => prefs.getBool('servo2_$index') ?? servo2[index]);
      servo3 = List.generate(16, (index) => prefs.getBool('servo3_$index') ?? servo3[index]);
      servo4 = List.generate(16, (index) => prefs.getBool('servo4_$index') ?? servo4[index]);

      mid1 = prefs.getInt('mid1') ?? mid1;
      min1 = prefs.getInt('min1') ?? min1;
      max1 = prefs.getInt('max1') ?? max1;
      mid2 = prefs.getInt('mid2') ?? mid2;
      min2 = prefs.getInt('min2') ?? min2;
      max2 = prefs.getInt('max2') ?? max2;
      mid3 = prefs.getInt('mid3') ?? mid3;
      min3 = prefs.getInt('min3') ?? min3;
      max3 = prefs.getInt('max3') ?? max3;
      mid4 = prefs.getInt('mid4') ?? mid4;
      min4 = prefs.getInt('min4') ?? min4;
      max4 = prefs.getInt('max4') ?? max4;

      // Загружаем числовые значения и сразу форматируем в "Rate: X%"
      s1Rate = "Rate: ${prefs.getInt('s1Rate') ?? 100}%";
      s2Rate = "Rate: ${prefs.getInt('s2Rate') ?? 100}%";
      s3Rate = "Rate: ${prefs.getInt('s3Rate') ?? 100}%";
      s4Rate = "Rate: ${prefs.getInt('s4Rate') ?? 100}%";
    });
  }

  Future<void> saveValues() async {
    final prefs = await SharedPreferences.getInstance();

    for (int i = 0; i < titles.length; i++) {
      prefs.setString('title_$i', titles[i]);
    }
    for (int i = 0; i < servo1.length; i++) {
      prefs.setBool('servo1_$i', servo1[i]);
    }
    for (int i = 0; i < servo2.length; i++) {
      prefs.setBool('servo2_$i', servo2[i]);
    }
    for (int i = 0; i < servo3.length; i++) {
      prefs.setBool('servo3_$i', servo3[i]);
    }
    for (int i = 0; i < servo4.length; i++) {
      prefs.setBool('servo4_$i', servo4[i]);
    }

    // Сбор данных для серво-приводов
    List<Map<String, dynamic>> servoData = [];
    List<List<bool>> servoList = [servo1, servo2, servo3, servo4]; // Серво-приводы в виде списка булевых значений

// Перебираем все серво-приводы
    for (int i = 0; i < servoList.length; i++) {
      // Ищем индекс активного (true) элемента в списке
      int reversedInputIndex = servoList[i].indexOf(true);

      Map<String, dynamic> servo = {
        'indexOfChannel': i, // Идентификатор канала (index)
        'mid': [mid1, mid2, mid3, mid4][i],
        'min': [min1, min2, min3, min4][i],
        'max': [max1, max2, max3, max4][i],
        'rate': [s1Rate, s2Rate, s3Rate, s4Rate][i],
        'reversedInput': reversedInputIndex >= 0 ? reversedInputIndex : null, // Присваиваем индекс true
      };

      servoData.add(servo);
    }

// Добавляем конфигурацию серво-приводов в менеджер
    for (var servoConfig in servoData) {
      ServoConfig config = ServoConfig(
        indexOfChannelToForward: servoConfig['indexOfChannel'],  // Используем indexOfChannel как идентификатор
        middle: servoConfig['mid'],
        min: servoConfig['min'],
        max: servoConfig['max'],
        rate: 1,
        reversedInputSources: servoConfig['reversedInput'] ?? 0, // Используем reversedInput для активности
      );

      // Добавляем конфигурацию в менеджер
      servoManager.addServoConfig(config); // Используем addServoConfig для добавления конфигурации в список
    }

// Сохраняем конфигурацию серво-приводов
    await servoManager.saveConfig();

// Отправляем конфигурацию

    prefs.setInt('mid1', mid1);
    prefs.setInt('min1', min1);
    prefs.setInt('max1', max1);
    prefs.setInt('mid2', mid2);
    prefs.setInt('min2', min2);
    prefs.setInt('max2', max2);
    prefs.setInt('mid3', mid3);
    prefs.setInt('min3', min3);
    prefs.setInt('max3', max3);
    prefs.setInt('mid4', mid4);
    prefs.setInt('min4', min4);
    prefs.setInt('max4', max4);
    prefs.setInt('s1Rate', int.parse(s1Rate.replaceAll(RegExp(r'[^0-9-]'), '')));
    prefs.setInt('s2Rate', int.parse(s2Rate.replaceAll(RegExp(r'[^0-9-]'), '')));
    prefs.setInt('s3Rate', int.parse(s3Rate.replaceAll(RegExp(r'[^0-9-]'), '')));
    prefs.setInt('s4Rate', int.parse(s4Rate.replaceAll(RegExp(r'[^0-9-]'), '')));

  }

  Widget build(BuildContext context){
    return Scaffold(
        body:CustomScrollView(
          slivers: [
            CustomAppBar(
              title: 'Сервоприводы',
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

                Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color.fromARGB(255, 233, 237, 245), Color.fromARGB(255, 149, 152, 158,)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter)), child: SingleChildScrollView(child: Column(children: [

                  Divider(color: Colors.black,),
                  Padding(padding: EdgeInsets.all(10)),
                  Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children: [
                    Container(
                      height: 120,
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Center(
                          child: Text('Servo1', style: TextStyle(color: Colors.black, fontSize: 24),)),
                      decoration: BoxDecoration(borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(20),
                        right: Radius.circular(20),// Скругление слева
                        // Если вам нужно скругление справа, используйте right: Radius.circular(20)
                      ),),),
                    Column(children: [
                      Row(children: [
                        Text('Mid'),
                        Padding(padding: EdgeInsets.all(5)),
                        RollTextField(
                          minValue: 0,
                          maxValue: 2000,
                          controller: _controllerMid1,
                          onRollChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                mid1 = newValue.toInt();
                              });
                            }
                          },
                        ),
                      ],),
                      Row(children: [
                        Text('Min'),
                        Padding(padding: EdgeInsets.all(5)),
                        RollTextField(
                          minValue: 0,
                          maxValue: 1500,
                          controller: _controllerMin1,
                          onRollChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                min1 = newValue.toInt();
                              });
                            }
                          },
                        ),
                      ],),
                      Row(children: [
                        Text('Max'),
                        Padding(padding: EdgeInsets.all(5)),
                        RollTextField(
                          minValue: 0,
                          maxValue: 3000,
                          controller: _controllerMax1,
                          onRollChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                max1 = newValue.toInt();
                              });
                            }
                          },
                        ),
                      ],),
                    ],)
                  ],),
                  Padding(padding: EdgeInsets.all(5)),
                  CheckboxWidget(values: servo1, labels: titles),
                  Padding(padding: EdgeInsets.all(5)),
                  Text('Direction and rate'),
                  Padding(padding: EdgeInsets.all(5)),
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
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: int.parse(s1Rate.replaceAll(RegExp(r'[^0-9-]'), '')), // Убираем % и берём число
                              icon: const Icon(Icons.keyboard_arrow_down),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.grey),
                              onChanged: (int? newValue) {
                                setState(() {
                                  s1Rate = "Rate: $newValue%"; // Форматируем строку для отображения
                                });
                              },
                              items: List.generate(201, (index) => index - 100) // От -100 до 100
                                  .map<DropdownMenuItem<int>>((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text("Rate: $value%"),
                                );
                              }).toList(),
                            ),

                          ),
                        ),
                      ],)
                  ),
                  Padding(padding: EdgeInsets.all(10)),
                  Divider(color: Colors.black,),
                  Padding(padding: EdgeInsets.all(10)),
                  Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children: [
                    Container(
                      height: 120,
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Center(
                          child: Text('Servo2', style: TextStyle(color: Colors.black, fontSize: 24),)),
                      decoration: BoxDecoration(borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(20),
                        right: Radius.circular(20),// Скругление слева
                        // Если вам нужно скругление справа, используйте right: Radius.circular(20)
                      ),),),
                    Column(children: [
                      Row(children: [
                        Text('Mid'),
                        Padding(padding: EdgeInsets.all(5)),
                        RollTextField(
                          minValue: 0,
                          maxValue: 2000,
                          controller: _controllerMid2,
                          onRollChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                mid2 = newValue.toInt();
                              });
                            }
                          },
                        ),
                      ],),
                      Row(children: [
                        Text('Min'),
                        Padding(padding: EdgeInsets.all(5)),
                        RollTextField(
                          minValue: 0,
                          maxValue: 1500,
                          controller: _controllerMin2,
                          onRollChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                min2 = newValue.toInt();
                              });
                            }
                          },
                        ),
                      ],),
                      Row(children: [
                        Text('Max'),
                        Padding(padding: EdgeInsets.all(5)),
                        RollTextField(
                          minValue: 0,
                          maxValue: 3000,
                          controller: _controllerMax2,
                          onRollChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                max2 = newValue.toInt();
                              });
                            }
                          },
                        ),
                      ],),
                    ],)
                  ],),
                  Padding(padding: EdgeInsets.all(5)),
                  CheckboxWidget(values: servo2, labels: titles),
                  Padding(padding: EdgeInsets.all(5)),
                  Text('Direction and rate'),
                  Padding(padding: EdgeInsets.all(5)),
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
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: int.parse(s1Rate.replaceAll(RegExp(r'[^0-9-]'), '')), // Убираем % и берём число
                              icon: const Icon(Icons.keyboard_arrow_down),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.grey),
                              onChanged: (int? newValue) {
                                setState(() {
                                  s1Rate = "Rate: $newValue%"; // Форматируем строку для отображения
                                });
                              },
                              items: List.generate(201, (index) => index - 100) // От -100 до 100
                                  .map<DropdownMenuItem<int>>((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text("Rate: $value%"),
                                );
                              }).toList(),
                            ),

                          ),
                        ),
                      ],)
                  ),
                  Padding(padding: EdgeInsets.all(10)),
                  Divider(color: Colors.black,),
                  Padding(padding: EdgeInsets.all(10)),
                  Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children: [
                    Container(
                      height: 120,
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Center(
                          child: Text('Servo3', style: TextStyle(color: Colors.black, fontSize: 24),)),
                      decoration: BoxDecoration(borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(20),
                        right: Radius.circular(20),// Скругление слева
                        // Если вам нужно скругление справа, используйте right: Radius.circular(20)
                      ),),),
                    Column(children: [
                      Row(children: [
                        Text('Mid'),
                        Padding(padding: EdgeInsets.all(5)),
                        RollTextField(
                          minValue: 0,
                          maxValue: 2000,
                          controller: _controllerMid3,
                          onRollChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                mid3 = newValue.toInt();
                              });
                            }
                          },
                        ),
                      ],),
                      Row(children: [
                        Text('Min'),
                        Padding(padding: EdgeInsets.all(5)),
                        RollTextField(
                          minValue: 0,
                          maxValue: 1500,
                          controller: _controllerMin3,
                          onRollChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                min3 = newValue.toInt();
                              });
                            }
                          },
                        ),
                      ],),
                      Row(children: [
                        Text('Max'),
                        Padding(padding: EdgeInsets.all(5)),
                        RollTextField(
                          minValue: 0,
                          maxValue: 3000,
                          controller: _controllerMax3,
                          onRollChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                max3 = newValue.toInt();
                              });
                            }
                          },
                        ),
                      ],),
                    ],)
                  ],),
                  Padding(padding: EdgeInsets.all(5)),
                  CheckboxWidget(values: servo3, labels: titles),
                  Padding(padding: EdgeInsets.all(5)),
                  Text('Direction and rate'),
                  Padding(padding: EdgeInsets.all(5)),
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
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: int.parse(s1Rate.replaceAll(RegExp(r'[^0-9-]'), '')), // Убираем % и берём число
                              icon: const Icon(Icons.keyboard_arrow_down),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.grey),
                              onChanged: (int? newValue) {
                                setState(() {
                                  s1Rate = "Rate: $newValue%"; // Форматируем строку для отображения
                                });
                              },
                              items: List.generate(201, (index) => index - 100) // От -100 до 100
                                  .map<DropdownMenuItem<int>>((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text("Rate: $value%"),
                                );
                              }).toList(),
                            ),

                          ),
                        ),
                      ],)
                  ),
                  Padding(padding: EdgeInsets.all(10)),
                  Divider(color: Colors.black,),
                  Padding(padding: EdgeInsets.all(10)),
                  Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children: [
                    Container(
                      height: 120,
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Center(
                          child: Text('Servo4', style: TextStyle(color: Colors.black, fontSize: 24),)),
                      decoration: BoxDecoration(borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(20),
                        right: Radius.circular(20),// Скругление слева
                        // Если вам нужно скругление справа, используйте right: Radius.circular(20)
                      ),),),
                    Column(children: [
                      Row(children: [
                        Text('Mid'),
                        Padding(padding: EdgeInsets.all(5)),
                        RollTextField(
                          minValue: 0,
                          maxValue: 2000,
                          controller: _controllerMid4,
                          onRollChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                mid4 = newValue.toInt();
                              });
                            }
                          },
                        ),
                      ],),
                      Row(children: [
                        Text('Min'),
                        Padding(padding: EdgeInsets.all(5)),
                        RollTextField(
                          minValue: 0,
                          maxValue: 1500,
                          controller: _controllerMin4,
                          onRollChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                min4 = newValue.toInt();
                              });
                            }
                          },
                        ),
                      ],),
                      Row(children: [
                        Text('Max'),
                        Padding(padding: EdgeInsets.all(5)),
                        RollTextField(
                          minValue: 0,
                          maxValue: 3000,
                          controller: _controllerMax4,
                          onRollChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                max4 = newValue.toInt();
                              });
                            }
                          },
                        ),
                      ],),
                    ],)
                  ],),
                  Padding(padding: EdgeInsets.all(5)),
                  CheckboxWidget(values: servo4, labels: titles),
                  Padding(padding: EdgeInsets.all(5)),
                  Text('Direction and rate'),
                  Padding(padding: EdgeInsets.all(5)),
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
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: int.parse(s1Rate.replaceAll(RegExp(r'[^0-9-]'), '')), // Убираем % и берём число
                              icon: const Icon(Icons.keyboard_arrow_down),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.grey),
                              onChanged: (int? newValue) {
                                setState(() {
                                  s1Rate = "Rate: $newValue%"; // Форматируем строку для отображения
                                });
                              },
                              items: List.generate(201, (index) => index - 100) // От -100 до 100
                                  .map<DropdownMenuItem<int>>((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text("Rate: $value%"),
                                );
                              }).toList(),
                            ),

                          ),
                        ),
                      ],)
                  ),
                  Padding(padding: EdgeInsets.all(10)),
                  Divider(color: Colors.black,),
                  Padding(padding: EdgeInsets.all(10)),
                  Divider(color: Colors.black,),
                  Padding(padding: EdgeInsets.all(10)),
                ])))
              ]),
            ),
          ],
        ),

    );
  }
}