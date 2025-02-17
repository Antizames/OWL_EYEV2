import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:owl/pages/port/widgets/deformableButton.dart';
import 'package:owl/pages/appBar/widgets/customAppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:owl/config/config.dart';
import 'package:owl/pages/port/config/serialConfig.dart';
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
    saveConfig(
      ua1mspActive: ua1mspActive, // Сохранение ua1mspActive
      ua2mspActive: ua2mspActive, // Сохранение ua2mspActive
      ua3mspActive: ua3mspActive, // Сохранение ua3mspActive
      usserActive: usserActive, // Сохранение usserActive
      ua1serActive: ua1serActive, // Сохранение ua1serActive
      ua2serActive: ua2serActive, // Сохранение ua2serActive
      ua3serActive: ua3serActive, // Сохранение ua3serActive
      usmspFreq: usmspFreq, // Сохранение usmspFreq
      ua1mspFreq: ua1mspFreq, // Сохранение ua1mspFreq
      ua2mspFreq: ua2mspFreq, // Сохранение ua2mspFreq
      ua3mspFreq: ua3mspFreq, // Сохранение ua3mspFreq
      ustelMode: ustelMode, // Сохранение ustelMode
      ustelVal: ustelVal, // Сохранение ustelVal
      ussenMode: ussenMode, // Сохранение ussenMode
      ussenVal: ussenVal, // Сохранение ussenVal
      usperMode: usperMode, // Сохранение usperMode
      usperVal: usperVal, // Сохранение usperVal
      ua1telMode: ua1telMode, // Сохранение ua1telMode
      ua1telVal: ua1telVal, // Сохранение ua1telVal
      ua1senMode: ua1senMode, // Сохранение ua1senMode
      ua1senVal: ua1senVal, // Сохранение ua1senVal
      ua1perMode: ua1perMode, // Сохранение ua1perMode
      ua1perVal: ua1perVal, // Сохранение ua1perVal
      ua2telMode: ua2telMode, // Сохранение ua2telMode
      ua2telVal: ua2telVal, // Сохранение ua2telVal
      ua2senMode: ua2senMode, // Сохранение ua2senMode
      ua2senVal: ua2senVal, // Сохранение ua2senVal
      ua2perMode: ua2perMode, // Сохранение ua2perMode
      ua2perVal: ua2perVal, // Сохранение ua2perVal
      ua3telMode: ua3telMode, // Сохранение ua3telMode
      ua3telVal: ua3telVal, // Сохранение ua3telVal
      ua3senMode: ua3senMode, // Сохранение ua3senMode
      ua3senVal: ua3senVal, // Сохранение ua3senVal
      ua3perMode: ua3perMode, // Сохранение ua3perMode
      ua3perVal: ua3perVal, // Сохранение ua3perVal
    );

    List<Map<String, dynamic>> portsData = [];
    for (int i = 0; i < 4; i++) {
      Map<String, dynamic> port = {
        'identifier': i,
        'auxChannelIndex': 0,
        'functions': [],
        'mspBaudrate': 115200,
        'gpsBaudrate': 57600,
        'telemetryBaudrate': 38400,
        'blackboxBaudrate': 115200,
      };

      // Активируем MSP, если нужно
      if ([ua1mspActive, ua2mspActive, ua3mspActive, usserActive][i]) {
        port['functions'].add('MSP');
        port['mspBaudrate'] = [ua1mspFreq, ua2mspFreq, ua3mspFreq, usmspFreq][i];
      }

      // Проверяем режимы TELEMETRY, GPS, BLACKBOX
      List<String> modes = ['telemetry', 'gps', 'blackbox'];
      List<bool> activeModes = [
        [ua1telMode != "Отключено", ua1senMode != "Отключено", ua1perMode != "Отключено"],
        [ua2telMode != "Отключено", ua2senMode != "Отключено", ua2perMode != "Отключено"],
        [ua3telMode != "Отключено", ua3senMode != "Отключено", ua3perMode != "Отключено"],
        [ustelMode != "Отключено", ussenMode != "Отключено", usperMode != "Отключено"]
      ][i];
      List<String> values = [
        [ua1telVal, ua1senVal, ua1perVal],
        [ua2telVal, ua2senVal, ua2perVal],
        [ua3telVal, ua3senVal, ua3perVal],
        [ustelVal, ussenVal, usperVal]
      ][i];

      for (int j = 0; j < modes.length; j++) {
        if (activeModes[j]) {
          port['functions'].add(modes[j].toUpperCase());
          port['${modes[j]}Baudrate'] =
          values[j] == 'AUTO' ? 115200 : int.tryParse(values[j]) ?? 115200;
        }
      }

      portsData.add(port);
    }

    for (var portData in portsData) {
      SerialPortConfig config = SerialPortConfig(
        identifier: portData['identifier'],
        auxChannelIndex: portData['auxChannelIndex'],
        functions: List<String>.from(portData['functions']),
        mspBaudrate: portData['mspBaudrate'],
        gpsBaudrate: portData['gpsBaudrate'],
        telemetryBaudrate: portData['telemetryBaudrate'],
        blackboxBaudrate: portData['blackboxBaudrate'],
      );

      // Добавляем конфигурацию в менеджер
      serialConfigManager.ports.add(config);
    }

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