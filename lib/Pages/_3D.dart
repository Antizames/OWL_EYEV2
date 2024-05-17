import 'package:flutter/material.dart';
import 'package:flutter_msp/flutter_msp.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class tree_D extends StatefulWidget{
  const tree_D({super.key});
  @override
  State<tree_D> createState() => _3DState();
}
class _3DState extends State<tree_D> {
  double doubledownValue = 6.00;
  double roll = 180;
  double pitch = 180;
  double yaw = 180;
  String Pilot = 'Kolobok';
  String ListStr = 'Сова';
  String dropdownValue = "6.0 kHz";
  String dropdownValue1 = "";
  String dropdownValue2 = "";
  bool switchValue = false;
  bool switchValue1 = false;
  bool switchValue2 = false;
  bool switchValue3 = true;
  bool switchValue4 = true;
  bool switchValue5 = true;
  bool switchValue6 = true;
  bool switchValue7 = true;
  final TextEditingController _controllerRoll = TextEditingController();
  final TextEditingController _controllerPitch = TextEditingController();
  final TextEditingController _controllerYaw = TextEditingController();
  final TextEditingController _controllerPilot = TextEditingController();
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
  @override
  void initState() {
    super.initState();
    _controllerRoll.text = roll.toStringAsFixed(0);
    _controllerPitch.text = pitch.toStringAsFixed(0);
    _controllerYaw.text = yaw.toStringAsFixed(0);
    _controllerPilot.text = Pilot;
  }

  @override
  void dispose() {
    _controllerRoll.dispose();
    _controllerPitch.dispose();
    _controllerYaw.dispose();
    _controllerPilot.dispose();
    super.dispose();
  }
  void send_msp(String message){
      MSPCommunication comm = MSPCommunication('COM5');
      comm.sendMessageV1(11, message).then((_) {
      });
  }

  @override
  Widget build(BuildContext cotext)
    => Scaffold(
      body:
        Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 233, 237, 245), Color.fromARGB(255, 149, 152, 158,)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),

        child: SingleChildScrollView(child:
        Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          const Padding(padding: EdgeInsets.all(20)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            DeformableButton(
              onPressed: (){_openSidebarMenu(context);},
              child: Icon(Icons.menu, color: Colors.grey.shade600),
              gradient: const LinearGradient(
                  colors: <Color>[Color.fromARGB(255, 233, 237, 245), Color.fromARGB(255, 149, 152, 158,)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
              ),
            ),
            const Column(children: [
              Text('Дрон', style: TextStyle(fontSize: 15, color: Colors.grey),),
              Text('Конфигурация', style: TextStyle(fontSize: 15, color: Colors.black)),
            ],),
            DeformableButton(
              onPressed: (){send_msp(Pilot);},
              child: Icon(Icons.save, color: Colors.grey.shade600,),
              gradient: LinearGradient(
                  colors: <Color>[Color.fromARGB(255, 233, 237, 245), Color.fromARGB(255, 149, 152, 158,)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
              ),
            ),
          ]),
          const Padding(padding: EdgeInsets.all(10)),
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
              child: Stack(children: [
                DropdownButtonHideUnderline( // Убирает подчёркивание у DropdownButton
                  child: ButtonTheme(
                    alignedDropdown: true, // Используется для выравнивания выпадающего списка по ширине кнопки
                    child: DropdownButton<String>(
                      isExpanded: true, // Расширяет DropdownButton на весь доступный размер
                      value: dropdownValue,
                      icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.grey),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                      },
                      items: <String>["6.0 kHz", "${doubledownValue+3} kHz", "${doubledownValue+6} kHz", "${doubledownValue+9} kHz"]
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
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Text('Accelerometer', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),
                Switch(value: switchValue, onChanged: (value){setState(() {
                  switchValue = value;
                });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
              ],),
          ),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Text('Barometer', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),
                Switch(value: switchValue1, onChanged: (value){setState(() {
                  switchValue1 = value;
                });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
              ],),
          ),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Text('Magnetometer', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),
                Switch(value: switchValue2, onChanged: (value){setState(() {
                  switchValue2 = value;
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
                    child: DropdownButton<String>(
                      isExpanded: true, // Расширяет DropdownButton на весь доступный размер
                      value: dropdownValue1,
                      icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.grey),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue1 = newValue!;
                        });
                      },
                      items: <String>[""]
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
                    child: DropdownButton<String>(
                      isExpanded: true, // Расширяет DropdownButton на весь доступный размер
                      value: dropdownValue2,
                      icon: const Icon(Icons.keyboard_arrow_down), // Иконка стрелочки вниз
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.grey),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue2 = newValue!;
                        });
                      },
                      items: <String>[""]
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
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Text('RX_LOST', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),
                Switch(value: switchValue3, onChanged: (value){setState(() {
                  switchValue3 = value;
                });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
              ],),
          ),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Text('RX_SET', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),
                Switch(value: switchValue4, onChanged: (value){setState(() {
                  switchValue4 = value;
                });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
              ],),
          ),
          const Padding(padding: EdgeInsets.all(20)),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 80, alignment: Alignment.centerLeft, child: Text('Beeper Beacon Configuration', style: TextStyle(color: Colors.black, fontSize: 24),),),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Text('RX_LOST_LANDING', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),
                Switch(value: switchValue5, onChanged: (value){setState(() {
                  switchValue5 = value;
                });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
              ],),
          ),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Text('RX_LOST', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),
                Switch(value: switchValue6, onChanged: (value){setState(() {
                  switchValue6 = value;
                });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
              ],),
          ),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 60,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Text('GYRO_CALIBRATED', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),
                Switch(value: switchValue7, onChanged: (value){setState(() {
                  switchValue7 = value;
                });}, activeColor: Colors.white70,  inactiveThumbColor: Colors.grey, activeTrackColor: Color.fromARGB(255,252,128,33), inactiveTrackColor: Colors.white70,)
              ],),
          ),
          const Padding(padding: EdgeInsets.all(20)),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 80, alignment: Alignment.centerLeft, child: Text('Personalization', style: TextStyle(color: Colors.black, fontSize: 24),),),
          Container(width: MediaQuery.of(context).size.width * 0.8, height: 30, alignment: Alignment.centerLeft, child: Row(children: [Text('Craft name', style: TextStyle(color: Colors.black, fontSize: 18),), Padding(padding: EdgeInsets.all(3)), ],),),
          Container(alignment: Alignment.centerLeft, width: MediaQuery.of(context).size.width * 0.8, height: 40,
            child: Padding(padding: EdgeInsets.only(left: 10),child: Text('$ListStr', style: TextStyle(color: Colors.grey),),),
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
    );
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
class MyCustomSlider extends StatefulWidget {
  final double sliderValue;
  final Function(double) onValueChanged; // Добавление callback-функции

  const MyCustomSlider({
    Key? key,
    required this.sliderValue,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  _MyCustomSliderState createState() => _MyCustomSliderState();
}

class _MyCustomSliderState extends State<MyCustomSlider> {
  late double localSliderValue;

  @override
  void initState() {
    super.initState();
    localSliderValue = widget.sliderValue;
  }
  @override
  void didUpdateWidget(MyCustomSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Проверяем, изменилось ли входящее значение
    if (oldWidget.sliderValue != widget.sliderValue) {
      setState(() {
        // Обновляем локальное значение, если входящее значение изменилось
        localSliderValue = widget.sliderValue;
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
          min: 0,
          max: 360,
          divisions: 72,
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
class RollTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(double?) onRollChanged;

  RollTextField({
    Key? key,
    required this.controller,
    required this.onRollChanged,
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
              if (newValue > 360) {
                newValue = 360;
                controller.text = newValue.toStringAsFixed(0);
                controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
              } else if(newValue < 0){
                newValue = 0;
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