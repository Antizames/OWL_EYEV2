import 'package:flutter/material.dart';
import 'dart:math';
class Video extends StatefulWidget{
  const Video({super.key});

  @override
  State<Video> createState() => _VideoState();
}
double roundDouble(double value, int places){
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}
enum VoltageMeterSource { none, escSensor, onboardADC }


class VoltageSliderSetting extends StatelessWidget {
  final String title;
  final double value;
  final double minValue;
  final double maxValue;
  final ValueChanged<double> onChanged;

  const VoltageSliderSetting({
    required this.title,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Slider(
        value: value,
        onChanged: onChanged,
        min: minValue,
        max: maxValue,
        divisions: 5,
        label: value.toString(),
      ),
    );
  }
}
class _VideoState extends State<Video> {
  double _minCellVoltage = 3.3;
  double _maxCellVoltage = 4.2;
  double _warningCellVoltage = 3.6;
  int _batteryCapacity = 0;
  double _voltageMeterScale = 100.0;
  int _dividerValue = 10;
  int _multiplierValue = 1;
  double _amperageMeterScale = 0;

  void _openMenu() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context) {
          return Drawer(
              child: new ListView(
                children: <Widget>[
                  ListTile(
                    title: const Text(
                      'Навигация', style: TextStyle(fontSize: 26),),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                  ),
                  ListTile(title: const Text(
                    'Конфигурация', style: TextStyle(fontSize: 26),),
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/conf');
                      }),
                  ListTile(title: const Text(
                    'Отказобезопасность', style: TextStyle(fontSize: 26),),
                      onTap: () {
                        Navigator.pushNamed(context, '/fail');
                      }),
                  ListTile(title: const Text(
                    'Питание и Батарея', style: TextStyle(fontSize: 26),),
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/poba');
                      }),
                  ListTile(title: const Text(
                    'Порты', style: TextStyle(fontSize: 26),), onTap: () {
                    Navigator.pushReplacementNamed(context, '/port');
                  }),
                  ListTile(title: const Text(
                    'Видео', style: TextStyle(fontSize: 26),), onTap: () {
                    Navigator.pushReplacementNamed(context, '/vid');
                  }),
                  Divider(color: Colors.black87),
                  ListTile(title: const Text(
                    'Сообщить об ошибке', style: TextStyle(fontSize: 26),),
                      onTap: () {}),
                ],));
        })
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                _openMenu();
              },
              icon: Icon(Icons.menu))
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Voltage Meter Source',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Column(
              children: [
                VoltageSliderSetting(
                  title: 'Minimum Cell Voltage',
                  value: _minCellVoltage,
                  minValue: 3.3,
                  maxValue: 3.8,
                  onChanged: (newValue) {
                    setState(() {
                      _minCellVoltage = roundDouble(newValue, 1);
                    });
                  },
                ),
                VoltageSliderSetting(
                  title: 'Maximum Cell Voltage',
                  value: _maxCellVoltage,
                  minValue: 4.0,
                  maxValue: 4.5,
                  onChanged: (newValue) {
                    setState(() {
                      _maxCellVoltage = roundDouble(newValue, 1);
                    });
                  },
                ),
                VoltageSliderSetting(
                  title: 'Warning Cell Voltage',
                  value: _warningCellVoltage,
                  minValue: 3.5,
                  // You can set appropriate min and max values
                  maxValue: 4.2,
                  onChanged: (newValue) {
                    setState(() {
                      _warningCellVoltage = roundDouble(newValue, 2);
                    });
                  },
                ),
              ],
            ),
            // RadioListTile widgets for Current Meter Source

            // Additional settings for Min/Max/Warning Cell Voltage

            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Capacity',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: Text('Battery Capacity (mAh)'),
              subtitle: TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _batteryCapacity = int.parse(value);
                  });
                },
              ),
            ),


            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Voltage Meter',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: Text('Scale'),
              subtitle: Slider(
                value: _voltageMeterScale,
                onChanged: (newValue) {
                  setState(() {
                    _voltageMeterScale = newValue;
                  });
                },
                min: 0,
                max: 200,
                divisions: 20,
                label: _voltageMeterScale.round().toString(),
              ),
            ),
            ListTile(
              title: Text('Divider / Multiplier Value'),
              subtitle: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        // Handle the input value for Divider value
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        // Handle the input value for Multiplier value
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Amperage Meter',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),

              ),
            ),
            ListTile(
              title: Text('Scale'),
              subtitle: Slider(
                value: _amperageMeterScale,
                onChanged: (newValue) {
                  setState(() {
                    _amperageMeterScale = newValue;
                  });
                },
                min: 0,
                max: 200,
                divisions: 20,
                label: _amperageMeterScale.round().toString(),
              ),
            ),
            ListTile(
              title: Text('Offset'),
              subtitle: TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // Handle the input value for Amperage Meter Offset
                },
              ),
            ), // Additional settings for Capacity, Voltage Meter, etc.
          ],
        ),
      ),
    );
  }
}
