import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:owl/pages/port/widgets/deformableButton.dart';
import 'package:owl/pages/appBar/widgets/customAppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/config/config.dart';
import 'package:owl/pages/port/config/serialConfig.dart';

import 'package:owl/pages/sideBarMenu/sidebar_menu.dart';
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
              child: SidebarMenu(),
            ),
          ],
        );
      },
    );
  }
  SerialConfigManager serialConfigManager = SerialConfigManager();
  bool usmspActive = true;
  bool ua1mspActive = false;
  bool ua2mspActive = false;
  bool ua3mspActive = false;
  bool usserActive = false;
  bool ua1serActive = false;
  bool ua2serActive = true;
  bool ua3serActive = false;
  String usmspFreq = '115200';
  String ua1mspFreq = '115200';
  String ua2mspFreq = '115200';
  String ua3mspFreq = '115200';
  String ustelMode = 'Отключено';
  String ustelVal = 'AUTO';
  String ussenMode = 'Отключено';
  String ussenVal = 'AUTO';
  String usperMode = 'Отключено';
  String usperVal = 'AUTO';
  String ua1telMode = 'Отключено';
  String ua1telVal = 'AUTO';
  String ua1senMode = 'Отключено';
  String ua1senVal = 'AUTO';
  String ua1perMode = 'Отключено';
  String ua1perVal = 'AUTO';
  String ua2telMode = 'Отключено';
  String ua2telVal = 'AUTO';
  String ua2senMode = 'Отключено';
  String ua2senVal = 'AUTO';
  String ua2perMode = 'Отключено';
  String ua2perVal = 'AUTO';
  String ua3telMode = 'Отключено';
  String ua3telVal = 'AUTO';
  String ua3senMode = 'Отключено';
  String ua3senVal = 'AUTO';
  String ua3perMode = 'Отключено';
  String ua3perVal = 'AUTO';
  @override
  void initState() {
    super.initState();
    loadConfig();
  }
  @override
  void dispose() {

    super.dispose();
  }
  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    serialConfigManager.loadConfig();
  }
  void saveValues() async {
    SerialConfigManager serialConfigManager = SerialConfigManager();

    List<SerialPortConfig> ports = [];
    for (int i = 0; i < 4; i++) {
      ports.add(SerialPortConfig(
        identifier: i == 3? 20:i,
        auxChannelIndex: 0,
        functions: [
          if ([ua1mspActive, ua2mspActive, ua3mspActive, usmspActive][i]) "MSP",

          // Телеметрия: сохраняем конкретное значение вместо просто "TELEMETRY"
          if ([ua1telMode, ua2telMode, ua3telMode, ustelMode][i] == "FrSky") "TELEMETRY_FRSKY",
          if ([ua1telMode, ua2telMode, ua3telMode, ustelMode][i] == "HoTT") "TELEMETRY_HOTT",
          if ([ua1telMode, ua2telMode, ua3telMode, ustelMode][i] == "iBUS") "TELEMETRY_IBUS",
          if ([ua1telMode, ua2telMode, ua3telMode, ustelMode][i] == "LTM") "TELEMETRY_LTM",
          if ([ua1telMode, ua2telMode, ua3telMode, ustelMode][i] == "MAVLink") "TELEMETRY_MAVLINK",
          if ([ua1telMode, ua2telMode, ua3telMode, ustelMode][i] == "SmartPort") "TELEMETRY_SMARTPORT",


          // Вход датчиков (GPS, ESC)
          if ([ua1senMode, ua2senMode, ua3senMode, ussenMode][i] == "GPS") "GPS",
          if ([ua1senMode, ua2senMode, ua3senMode, ussenMode][i] == "ESC") "ESC_SENSOR",

          // Периферия
          if ([ua1perMode, ua2perMode, ua3perMode, usperMode][i] == "Запись в Blackbox") "BLACKBOX",
          if ([ua1perMode, ua2perMode, ua3perMode, usperMode][i] == "Benewake LIDAR") "LIDAR_TF",
          if ([ua1perMode, ua2perMode, ua3perMode, usperMode][i] == "Camera (RunCam Protocol)") "RUNCAM_DEVICE_CONTROL",
          if ([ua1perMode, ua2perMode, ua3perMode, usperMode][i] == "OSD (FrSky Protocol)") "FRSKY_OSD",
          if ([ua1perMode, ua2perMode, ua3perMode, usperMode][i] == "VTX (IRC Tramp)") "IRC_TRAMP",
          if ([ua1perMode, ua2perMode, ua3perMode, usperMode][i] == "VTX (TBS SmartAudio)") "TBS_SMARTAUDIO",
        ],
        // Обработка "AUTO" и преобразование в int
        mspBaudrate: int.parse([ua1mspFreq, ua2mspFreq, ua3mspFreq, usmspFreq][i]),
        gpsBaudrate: [ua1senVal, ua2senVal, ua3senVal, ussenVal][i] == "AUTO"
            ? 0
            : int.parse([ua1senVal, ua2senVal, ua3senVal, ussenVal][i]),
        telemetryBaudrate: [ua1telVal, ua2telVal, ua3telVal, ustelVal][i] == "AUTO"
            ? 0
            : int.parse([ua1telVal, ua2telVal, ua3telVal, ustelVal][i]),
        blackboxBaudrate: [ua1perVal, ua2perVal, ua3perVal, usperVal][i] == "AUTO"
            ? 0
            : int.parse([ua1perVal, ua2perVal, ua3perVal, usperVal][i]),
      ));
    }

    serialConfigManager.ports = ports;
    await serialConfigManager.saveConfig();
    serialConfigManager.sendConfig();
  }




  Widget build(BuildContext context){
    return Scaffold(
      body:CustomScrollView(
        slivers: [
          CustomAppBar(
            title: 'Порты',
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
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color.fromARGB(255, 233, 237, 245), Color.fromARGB(255, 149, 152, 158,)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)), child: SingleChildScrollView(child: Column(children: [

                Column(children:[
                  const Padding(padding: EdgeInsets.all(10)),
                  const Divider(color: Colors.black),
                  const Text('USB VCP', style: TextStyle(fontSize: 24),),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children:[
                    const   Text('Конфигурация и MSP'),
                    Switch(value: usmspActive, onChanged: (value){setState(() {
                      usmspActive = value;
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
                              value: usmspFreq,
                              icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.grey),
                              onChanged: (String? newValue) {
                                setState(() {
                                  usmspFreq = newValue!;
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
                    Switch(value: usserActive, onChanged: (value){setState(() {
                      usserActive = value;
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
                                value: ustelMode,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ustelMode = newValue!;
                                  });
                                },
                                items: <String>['Отключено', 'FrSky', 'HoTT', 'iBUS', 'LTM', 'MAVLink', 'SmartPort']
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
                                value: ustelVal,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ustelVal = newValue!;
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
                                value: ussenMode,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ussenMode = newValue!;
                                  });
                                },
                                items: <String>['Отключено', 'ESC', 'GPS']
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
                                value: ussenVal,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ussenVal = newValue!;
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
                                value: usperMode,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    usperMode = newValue!;
                                  });
                                },
                                items: <String>[
                                  'Отключено',
                                  'Запись в Blackbox',
                                  'Benewake LIDAR',
                                  'Camera (RunCam Protocol)',
                                  'OSD (FrSky Protocol)',
                                  'VTX (IRC Tramp)',
                                  'VTX (TBS SmartAudio)'
                                ].map<DropdownMenuItem<String>>((String value) {
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
                                value: usperVal,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    usperVal = newValue!;
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
                    Switch(value: ua1mspActive, onChanged: (value){setState(() {
                      ua1mspActive = value;
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
                              value: ua1mspFreq,
                              icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.grey),
                              onChanged: (String? newValue) {
                                setState(() {
                                  ua1mspFreq = newValue!;
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
                    Switch(value: ua1serActive, onChanged: (value){setState(() {
                      ua1serActive = value;
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
                                value: ua1telMode,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ua1telMode = newValue!;
                                  });
                                },
                                items: <String>['Отключено', 'FrSky', 'HoTT', 'iBUS', 'LTM', 'MAVLink', 'SmartPort']
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
                                value: ua1telVal,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ua1telVal = newValue!;
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
                                value: ua1senMode,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ua1senMode = newValue!;
                                  });
                                },
                                items: <String>['Отключено', 'ESC', 'GPS']
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
                                value: ua1senVal,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ua1senVal = newValue!;
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
                                value: ua1perMode,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ua1perMode = newValue!;
                                  });
                                },
                                items: <String>[
                                  'Отключено',
                                  'Запись в Blackbox',
                                  'Benewake LIDAR',
                                  'Camera (RunCam Protocol)',
                                  'OSD (FrSky Protocol)',
                                  'VTX (IRC Tramp)',
                                  'VTX (TBS SmartAudio)'
                                ]
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
                                value: ua1perVal,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ua1perVal = newValue!;
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
                    Switch(value: ua2mspActive, onChanged: (value){setState(() {
                      ua2mspActive = value;
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
                              value: ua2mspFreq,
                              icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.grey),
                              onChanged: (String? newValue) {
                                setState(() {
                                  ua2mspFreq = newValue!;
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
                    Switch(value: ua2serActive, onChanged: (value){setState(() {
                      ua2serActive = value;
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
                                value: ua2telMode,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ua2telMode = newValue!;
                                  });
                                },
                                items: <String>['Отключено', 'FrSky', 'HoTT', 'iBUS', 'LTM', 'MAVLink', 'SmartPort']
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
                                value: ua2telVal,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ua2telVal = newValue!;
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
                                value: ua2senMode,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ua2senMode = newValue!;
                                  });
                                },
                                items: <String>['Отключено', 'ESC', 'GPS']
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
                                value: ua2senVal,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ua2senVal = newValue!;
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
                                value: ua2perMode,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ua2perMode = newValue!;
                                  });
                                },
                                items: <String>[
                                  'Отключено',
                                  'Запись в Blackbox',
                                  'Benewake LIDAR',
                                  'Camera (RunCam Protocol)',
                                  'OSD (FrSky Protocol)',
                                  'VTX (IRC Tramp)',
                                  'VTX (TBS SmartAudio)'
                                ]
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
                                value: ua2perVal,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ua2perVal = newValue!;
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
                    Switch(value: ua3mspActive, onChanged: (value){setState(() {
                      ua3mspActive = value;
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
                              value: ua3mspFreq,
                              icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.grey),
                              onChanged: (String? newValue) {
                                setState(() {
                                  ua3mspFreq = newValue!;
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
                    Switch(value: ua3serActive, onChanged: (value){setState(() {
                      ua3serActive = value;
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
                                value: ua3telMode,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ua3telMode = newValue!;
                                  });
                                },
                                items: <String>['Отключено', 'FrSky', 'HoTT', 'iBUS', 'LTM', 'MAVLink', 'SmartPort']
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
                                value: ua3telVal,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ua3telVal = newValue!;
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
                                value: ua3senMode,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ua3senMode = newValue!;
                                  });
                                },
                                items: <String>['Отключено', 'ESC', 'GPS']
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
                                value: ua3senVal,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ua3senVal = newValue!;
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
                                value: ua3perMode,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ua3perMode = newValue!;
                                  });
                                },
                                items: <String>[
                                  'Отключено',
                                  'Запись в Blackbox',
                                  'Benewake LIDAR',
                                  'Camera (RunCam Protocol)',
                                  'OSD (FrSky Protocol)',
                                  'VTX (IRC Tramp)',
                                  'VTX (TBS SmartAudio)'
                                ]
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
                                value: ua3perVal,
                                icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(color: Colors.grey),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    ua3perVal = newValue!;
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
            ]),
          ),
        ],
      ),
    );
  }
}