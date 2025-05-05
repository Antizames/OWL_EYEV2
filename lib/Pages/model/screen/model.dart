import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart' hide Material;
import 'package:owl/pages/model/config/attitude_config.dart';
import 'package:owl/pages/model/widgets/deformableButton.dart';
import 'package:owl/pages/appBar/widgets/customAppBar.dart';
import 'package:owl/pages/model/widgets/compass.dart';
import 'package:owl/pages/model/widgets/horizon.dart';
import 'dart:async';
import 'package:owl/pages/sideBarMenu/sidebar_menu.dart';
class Model extends StatefulWidget {
  const Model({Key? key}) : super(key: key);

  @override
  _ModelState createState() => _ModelState();
}

class _ModelState extends State<Model> {
  Object? drone;
  Scene? scene;
  AttitudeManager attitudeManager = AttitudeManager();
  Timer? attitudeTimer;

  double pitch = 0;
  double roll = 0;
  double yaw = 0;
  @override
  void initState() {
    super.initState();
    _startAttitudeUpdates();
  }
  @override
  void dispose() {
    attitudeTimer?.cancel();
    super.dispose();
  }
  void _startAttitudeUpdates() {
    attitudeTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      final attitude = await attitudeManager.fetchAttitude();
      if (attitude != null) {
        setState(() {
          pitch = attitude.pitch;
          roll = attitude.roll;
          yaw = attitude.yaw;
          _updateDroneRotation();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomAppBar(
            title: 'Дрон',
            leadingIcon: DeformableButton(
              onPressed: () => _openSidebarMenu(context),
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
              child: Icon(Icons.refresh, color: Colors.grey.shade600),
              gradient: const LinearGradient(
                colors: [Color(0xFFE9EDF5), Color(0xFFE9EDF5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 15),

                /// Блок с ориентацией и моделью
                _buildOrientationCard(context),

                const SizedBox(height: 20),

                /// Горизонт и компас
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCompass(),
                      AttitudeIndicator(pitch: pitch, roll: roll),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// Блок кнопок
                _buildButtonBlock(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrientationCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAngleText("Pitch", pitch),
                  _buildAngleText("Roll", roll),
                  _buildAngleText("Yaw", yaw),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
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
    );
  }

  Widget _buildAngleText(String label, double value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade400)),
        Text('${value.toStringAsFixed(1)}°', style: const TextStyle(color: Colors.orange, fontSize: 16)),
      ],
    );
  }

  Widget _buildCompass() {
    return CustomPaint(
      size: const Size(210, 210),
      painter: CompassPainter(yaw: yaw),
    );
  }

  Widget _buildButtonBlock() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _orangeButton("Калибровать Акселерометр", Icons.align_vertical_bottom, () {}),
          _orangeButton("Калибровать Магнитометр", Icons.explore, () {}),
          _orangeButton("Сбросить настройки", Icons.settings_backup_restore, () {}),
          _orangeButton("Перейти в DFU", Icons.usb, () {}),
        ],
      ),
    );
  }

  Widget _orangeButton(String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  void _updateDroneRotation() {
    if (drone != null) {
      drone!.rotation.setValues(
        _degToRad(pitch),
        _degToRad(yaw),
        _degToRad(roll),
      );
      drone!.updateTransform();
      scene?.update();
    }
  }

  double _degToRad(double deg) => deg * 3.141592653589793 / 180.0;


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
                child: Container(color: Colors.black.withOpacity(0.5)),
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
}
