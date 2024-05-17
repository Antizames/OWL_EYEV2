import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class Ports extends StatefulWidget{
  const Ports({super.key});

  @override
  State<Ports> createState() => _PortsState();
}
class _PortsState extends State<Ports> {
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

  bool usmspSwitch = true;
  bool ua1mspSwitch = false;
  bool ua2mspSwitch = false;
  bool ua3mspSwitch = false;
  bool usserSwitch = false;
  bool ua1serSwitch = false;
  bool ua2serSwitch = true;
  bool ua3serSwitch = false;
  String usmspDrop = '115200';
  String ua1mspDrop = '115200';
  String ua2mspDrop = '115200';
  String ua3mspDrop = '115200';
  String ustelLeft = 'Отключено';
  String ustelRight = 'AUTO';
  String usdatLeft = 'Отключено';
  String usdatRight = 'AUTO';
  String usperLeft = 'Отключено';
  String usperRight = 'AUTO';
  String ua1telLeft = 'Отключено';
  String ua1telRight = 'AUTO';
  String ua1datLeft = 'Отключено';
  String ua1datRight = 'AUTO';
  String ua1perLeft = 'Отключено';
  String ua1perRight = 'AUTO';
  String ua2telLeft = 'Отключено';
  String ua2telRight = 'AUTO';
  String ua2datLeft = 'Отключено';
  String ua2datRight = 'AUTO';
  String ua2perLeft = 'Отключено';
  String ua2perRight = 'AUTO';
  String ua3telLeft = 'Отключено';
  String ua3telRight = 'AUTO';
  String ua3datLeft = 'Отключено';
  String ua3datRight = 'AUTO';
  String ua3perLeft = 'Отключено';
  String ua3perRight = 'AUTO';
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
    super.initState();

  }
  @override
  void dispose() {

    super.dispose();
  }
  Widget build(BuildContext context){
    return Scaffold(
        body:
        Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 233, 237, 245), Color.fromARGB(255, 149, 152, 158,)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)), child: SingleChildScrollView(child: Column(children: [
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
              Text('Порты', style: TextStyle(fontSize: 15, color: Colors.black)),
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
          Column(children:[
            const Padding(padding: EdgeInsets.all(10)),
            const Divider(color: Colors.black),
            const Text('USB VCP', style: TextStyle(fontSize: 24),),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children:[
              const   Text('Конфигурация и MSP'),
              Switch(value: usmspSwitch, onChanged: (value){setState(() {
                usmspSwitch = value;
              });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)

            ]),

            Container(width: MediaQuery.of(context).size.width * 0.6, height: 40,
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
                        value: usmspDrop,
                        icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.grey),
                        onChanged: (String? newValue) {
                          setState(() {
                            usmspDrop = newValue!;
                          });
                        },
                        items: <String>['9600','19200','38400','57600','115200','230400','250000','500000','1000000']
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
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children:[
              const Text('Serial Rx'),
              Switch(value: usserSwitch, onChanged: (value){setState(() {
                usserSwitch = value;
              });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,),
            ]),
            const Center(child: Text('Выход телеметрии'),),
            const Padding(padding: EdgeInsets.all(3)),
            Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children: [
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: ustelLeft,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              ustelLeft = newValue!;
                            });
                          },
                          items: <String>['Отключено', 'MAVLink']
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
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: ustelRight,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              ustelRight = newValue!;
                            });
                          },
                          items: <String>['AUTO','9600','19200','38400','57600','115200']
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
            ],),
            const Padding(padding: EdgeInsets.all(5)),
            const Text('Вход датчиков'),
            const Padding(padding: EdgeInsets.all(3)),
            Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children: [
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: usdatLeft,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              usdatLeft = newValue!;
                            });
                          },
                          items: <String>['Отключено', 'GPS']
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
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: usdatRight,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              usdatRight = newValue!;
                            });
                          },
                          items: <String>['AUTO','9600','19200','38400','57600','115200']
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
              ),],),
            const Padding(padding: EdgeInsets.all(5)),
            const Text('Периферия'),
            const Padding(padding: EdgeInsets.all(3)),
            Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children: [
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: usperLeft,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              usperLeft = newValue!;
                            });
                          },
                          items: <String>['Отключено', 'Запись в Blackbox']
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
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: usperRight,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              usperRight = newValue!;
                            });
                          },
                          items: <String>['AUTO','9600','19200','38400','57600','115200']
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
            ],),
          ]),
          const Padding(padding: EdgeInsets.all(10)),
          Column(children:[
            const Padding(padding: EdgeInsets.all(10)),
            const Divider(color: Colors.black),
            const Text('UART1', style: TextStyle(fontSize: 24),),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children:[
              const Text('Конфигурация и MSP'),
              Switch(value: ua1mspSwitch, onChanged: (value){setState(() {
                ua1mspSwitch = value;
              });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)

            ]),

            Container(width: MediaQuery.of(context).size.width * 0.6, height: 40,
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
                        value: ua1mspDrop,
                        icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.grey),
                        onChanged: (String? newValue) {
                          setState(() {
                            ua1mspDrop = newValue!;
                          });
                        },
                        items: <String>['9600','19200','38400','57600','115200','230400','250000','500000','1000000']
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
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children:[
              const Text('Serial Rx'),
              Switch(value: ua1serSwitch, onChanged: (value){setState(() {
                ua1serSwitch = value;
              });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: const Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,),
            ]),
            const Center(child: Text('Выход телеметрии'),),
            const Padding(padding: EdgeInsets.all(3)),
            Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children: [
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: ua1telLeft,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              ua1telLeft = newValue!;
                            });
                          },
                          items: <String>['Отключено', 'MAVLink']
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
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: ua1telRight,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              ua1telRight = newValue!;
                            });
                          },
                          items: <String>['AUTO','9600','19200','38400','57600','115200']
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
            ],),
            const Padding(padding: EdgeInsets.all(5)),
            const Text('Вход датчиков'),
            const Padding(padding: EdgeInsets.all(3)),
            Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children: [
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: ua1datLeft,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              ua1datLeft = newValue!;
                            });
                          },
                          items: <String>['Отключено', 'GPS']
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
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: ua1datRight,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              ua1datRight = newValue!;
                            });
                          },
                          items: <String>['AUTO','9600','19200','38400','57600','115200']
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
              ),],),
            const Padding(padding: EdgeInsets.all(5)),
            const Text('Периферия'),
            const Padding(padding: EdgeInsets.all(3)),
            Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children: [
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: ua1perLeft,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              ua1perLeft = newValue!;
                            });
                          },
                          items: <String>['Отключено', 'Запись в Blackbox']
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
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: ua1perRight,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              ua1perRight = newValue!;
                            });
                          },
                          items: <String>['AUTO','9600','19200','38400','57600','115200']
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
            ],),
          ]),
          const Padding(padding: EdgeInsets.all(10)),
          Column(children:[
            const Padding(padding: EdgeInsets.all(10)),
            const Divider(color: Colors.black),
            const Text('UART2', style: TextStyle(fontSize: 24),),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children:[
              const Text('Конфигурация и MSP'),
              Switch(value: ua2mspSwitch, onChanged: (value){setState(() {
                ua2mspSwitch = value;
              });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: const Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)

            ]),

            Container(width: MediaQuery.of(context).size.width * 0.6, height: 40,
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
                        value: ua2mspDrop,
                        icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.grey),
                        onChanged: (String? newValue) {
                          setState(() {
                            ua2mspDrop = newValue!;
                          });
                        },
                        items: <String>['9600','19200','38400','57600','115200','230400','250000','500000','1000000']
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
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children:[
              const Text('Serial Rx'),
              Switch(value: ua2serSwitch, onChanged: (value){setState(() {
                ua2serSwitch = value;
              });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,),
            ]),
            const Center(child: Text('Выход телеметрии'),),
            const Padding(padding: EdgeInsets.all(3)),
            Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children: [
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: ua2telLeft,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              ua2telLeft = newValue!;
                            });
                          },
                          items: <String>['Отключено', 'MAVLink']
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
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: ua2telRight,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              ua2telRight = newValue!;
                            });
                          },
                          items: <String>['AUTO','9600','19200','38400','57600','115200']
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
            ],),
            const Padding(padding: EdgeInsets.all(5)),
            const Text('Вход датчиков'),
            const Padding(padding: EdgeInsets.all(3)),
            Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children: [
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: ua2datLeft,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              ua2datLeft = newValue!;
                            });
                          },
                          items: <String>['Отключено', 'GPS']
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
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: ua2datRight,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              ua2datRight = newValue!;
                            });
                          },
                          items: <String>['AUTO','9600','19200','38400','57600','115200']
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
              ),],),
            const Padding(padding: EdgeInsets.all(5)),
            const Text('Периферия'),
            const Padding(padding: EdgeInsets.all(3)),
            Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children: [
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: ua2perLeft,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              ua2perLeft = newValue!;
                            });
                          },
                          items: <String>['Отключено', 'Запись в Blackbox']
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
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: ua2perRight,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              ua2perRight = newValue!;
                            });
                          },
                          items: <String>['AUTO','9600','19200','38400','57600','115200']
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
            ],),
          ]),
          const Padding(padding: EdgeInsets.all(10)),
          Column(children:[
            const Padding(padding: EdgeInsets.all(10)),
            const Divider(color: Colors.black),
            const Text('UART3', style: TextStyle(fontSize: 24),),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children:[
              const Text('Конфигурация и MSP'),
              Switch(value: ua3mspSwitch, onChanged: (value){setState(() {
                ua3mspSwitch = value;
              });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: const Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)

            ]),

            Container(width: MediaQuery.of(context).size.width * 0.6, height: 40,
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
                        value: ua3mspDrop,
                        icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.grey),
                        onChanged: (String? newValue) {
                          setState(() {
                            ua3mspDrop = newValue!;
                          });
                        },
                        items: <String>['9600','19200','38400','57600','115200','230400','250000','500000','1000000']
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
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children:[
              const Text('Serial Rx'),
              Switch(value: ua3serSwitch, onChanged: (value){setState(() {
                ua3serSwitch = value;
              });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: const Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,),
            ]),
            const Center(child: Text('Выход телеметрии'),),
            const Padding(padding: EdgeInsets.all(3)),
            Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children: [
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: ua3telLeft,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              ua3telLeft = newValue!;
                            });
                          },
                          items: <String>['Отключено', 'MAVLink']
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
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: ua3telRight,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              ua3telRight = newValue!;
                            });
                          },
                          items: <String>['AUTO','9600','19200','38400','57600','115200']
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
            ],),
            const Padding(padding: EdgeInsets.all(5)),
            const Text('Вход датчиков'),
            const Padding(padding: EdgeInsets.all(3)),
            Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children: [
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: ua3datLeft,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              ua3datLeft = newValue!;
                            });
                          },
                          items: <String>['Отключено', 'GPS']
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
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: ua3datRight,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              ua3datRight = newValue!;
                            });
                          },
                          items: <String>['AUTO','9600','19200','38400','57600','115200']
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
              ),],),
            const Padding(padding: EdgeInsets.all(5)),
            const Text('Периферия'),
            const Padding(padding: EdgeInsets.all(3)),
            Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children: [
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: ua3perLeft,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              ua3perLeft = newValue!;
                            });
                          },
                          items: <String>['Отключено', 'Запись в Blackbox']
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
              Container(width: MediaQuery.of(context).size.width * 0.45, height: 40,
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
                          value: ua3perRight,
                          icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          onChanged: (String? newValue) {
                            setState(() {
                              ua3perRight = newValue!;
                            });
                          },
                          items: <String>['AUTO','9600','19200','38400','57600','115200']
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
            ],),
          ]),
          const Padding(padding: EdgeInsets.all(10)),
        ])))
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