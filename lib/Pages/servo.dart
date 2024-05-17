import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  final List<String> titles = ['CH1','CH2','CH3','CH4','A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','A11','A12'];
  final List<bool> servo1 = [false, false, false, false,false, false, false, false,false, false, false, false,false, false, false, false];
  final List<bool> servo2 = [false, false, false, false,false, false, false, false,false, false, false, false,false, false, false, false];
  final List<bool> servo3 = [false, false, false, false,false, false, false, false,false, false, false, false,false, false, false, false];
  final List<bool> servo4 = [false, false, false, false,false, false, false, false,false, false, false, false,false, false, false, false];
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
              Text('Сервоприводы', style: TextStyle(fontSize: 15, color: Colors.black)),
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
                    child: DropdownButton<String>(
                      isExpanded: true, // Расширяет DropdownButton на весь доступный размер
                      value: s1Rate,
                      icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.grey),
                      onChanged: (String? newValue) {
                        setState(() {
                          s1Rate = newValue!;
                        });
                      },
                      items: <String>["Rate: 100%"]
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
                    child: DropdownButton<String>(
                      isExpanded: true, // Расширяет DropdownButton на весь доступный размер
                      value: s2Rate,
                      icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.grey),
                      onChanged: (String? newValue) {
                        setState(() {
                          s2Rate = newValue!;
                        });
                      },
                      items: <String>["Rate: 100%"]
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
                    child: DropdownButton<String>(
                      isExpanded: true, // Расширяет DropdownButton на весь доступный размер
                      value: s3Rate,
                      icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.grey),
                      onChanged: (String? newValue) {
                        setState(() {
                          s3Rate = newValue!;
                        });
                      },
                      items: <String>["Rate: 100%"]
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
                    child: DropdownButton<String>(
                      isExpanded: true, // Расширяет DropdownButton на весь доступный размер
                      value: s4Rate,
                      icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.grey),
                      onChanged: (String? newValue) {
                        setState(() {
                          s4Rate = newValue!;
                        });
                      },
                      items: <String>["Rate: 100%"]
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
          Divider(color: Colors.black,),
          Padding(padding: EdgeInsets.all(10)),
          Divider(color: Colors.black,),
          Padding(padding: EdgeInsets.all(10)),
        ])))
    );
  }
}
class CheckboxWidget extends StatefulWidget {
  final List<bool> values;
  final List<String> labels;

  const CheckboxWidget({
    Key? key,
    required this.values,
    required this.labels,
  }) : super(key: key);

  @override
  State<CheckboxWidget> createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          // Ряд для текстовых меток
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.labels.length, (index) {
              return Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.labels[index]),
                width: 50,
              );
            }),
          ),
          // Ряд для чекбоксов
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.values.length, (index) {
              return Container(
                padding: const EdgeInsets.all(8.0),
                width: 50,
                height: 50,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.values[index] = !widget.values[index];
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: widget.values[index] ? Colors.orange : Colors.black.withOpacity(0.72),
                      border: Border.all(color: Colors.black),
                    ),
                    child: widget.values[index]
                        ? Icon(Icons.check, color: Colors.black)
                        : null,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
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
      width: MediaQuery.of(context).size.width * 0.4,
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