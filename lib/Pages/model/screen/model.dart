import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart' hide Material;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:owl/pages/model/widgets/deformableButton.dart';
import 'package:owl/pages/appBar/widgets/customAppBar.dart';
import 'package:owl/pages/model/widgets/myCustomSlider.dart'; // Импортируем ваш слайдер
import 'package:owl/pages/model/widgets/compass.dart';
import 'package:owl/pages/model/widgets/horizon.dart';
class Model extends StatefulWidget {
  const Model({Key? key}) : super(key: key);

  @override
  _ModelState createState() => _ModelState();
}

class _ModelState extends State<Model> {
  Object? drone;
  Scene? scene;

  double pitch = 0;
  double roll = 0;
  double yaw = 0;

  // Пределы для примера
  double pitchMin = -90, pitchMax = 90;
  double rollMin = -180, rollMax = 180;
  double yawMin = -180, yawMax = 180;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomAppBar(
            title: 'Дрон',
            leadingIcon: DeformableButton(
              onPressed: () {
                _openSidebarMenu(context);
              },
              child: Icon(Icons.menu, color: Colors.grey.shade600),
              gradient: const LinearGradient(
                colors: [Color(0xFFE9EDF5), Color(0xFFE9EDF5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            trailingIcon: DeformableButton(
              onPressed: () {
                setState(() {
                  pitch = 0;
                  roll = 0;
                  yaw = 0;
                  _updateDroneRotation();
                });
              },
              child: Icon(Icons.save, color: Colors.grey.shade600),
              gradient: const LinearGradient(
                colors: [Color(0xFFE9EDF5), Color(0xFFE9EDF5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE9EDF5), Color(0xFF95989E)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 50,
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Дрон',
                        style: TextStyle(color: Colors.black, fontSize: 24),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(7),
                          right: Radius.circular(7),
                        ),
                        border: Border.all(color: Color(0xFF6D7178), width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildAngleText('Pitch', pitch),
                                _buildAngleText('Roll', roll),
                                _buildAngleText('Yaw', yaw),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 300,
                              child: Cube(
                                interactive: false,
                                onSceneCreated: (Scene scene) {
                                  this.scene = scene;
                                  drone = Object(fileName: 'Assets/3D/drone.obj');
                                  scene.world.add(drone!);
                                  scene.camera.zoom = 10;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 50,
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Положение',
                        style: TextStyle(color: Colors.black, fontSize: 24),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(7),
                          right: Radius.circular(7),
                        ),
                        border: Border.all(color: Color(0xFF6D7178), width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildCustomSlider("Pitch", pitch, pitchMin, pitchMax, (val) {
                              setState(() {
                                pitch = val;
                                _updateDroneRotation();
                              });
                            }),
                            const SizedBox(height: 10),
                            _buildCustomSlider("Roll", roll, rollMin, rollMax, (val) {
                              setState(() {
                                roll = val;
                                _updateDroneRotation();
                              });
                            }),
                            const SizedBox(height: 10),
                            _buildCustomSlider("Yaw", yaw, yawMin, yawMax, (val) {
                              setState(() {
                                yaw = val;
                                _updateDroneRotation();
                              });
                            }),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround,children: [
                      _buildCompass(),
                      AttitudeIndicator(pitch: pitch, roll: roll),
                    ],),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
  Widget _buildCompass() {
    return CustomPaint(
      size: Size(230, 230), // Размер компаса
      painter: CompassPainter(yaw: yaw),
    );
  }


  Widget _buildAngleText(String label, double value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade400)),
        Text('${value.toStringAsFixed(1)}°', style: const TextStyle(color: Colors.orange)),
      ],
    );
  }

  Widget _buildCustomSlider(
      String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(color: Colors.white)),
            const SizedBox(width: 8),
            Text('${value.toStringAsFixed(1)}°', style: const TextStyle(color: Colors.orange)),
          ],
        ),
        MyCustomSlider(
          sliderValue: value,
          minValue: min,
          maxValue: max,
          step: 1.0,
          onValueChanged: onChanged,
        ),
      ],
    );
  }

  void _updateDroneRotation() {
    if (drone != null) {
      drone!.rotation.setValues(pitch, yaw, roll);
      drone!.updateTransform();
      scene?.update();
    }
  }
}

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
