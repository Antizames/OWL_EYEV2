import 'package:flutter/material.dart';

class Configuration extends StatefulWidget {
  @override
  State<Configuration> createState() => _ConfigurationState();
}

class _ConfigurationState extends State<Configuration> {
  double rotateX = 0; // Угол наклона по оси X
  double rotateY = 0; // Угол наклона по оси Y
  double rotateZ = 0; // Угол наклона по оси Z

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 233, 237, 245), Color.fromARGB(255, 149, 152, 158)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.all(20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      _openSidebarMenu(context);
                    },
                    child: Icon(Icons.menu, color: Colors.grey.shade600),
                  ),
                  const Column(
                    children: [
                      Text('Дрон', style: TextStyle(fontSize: 15, color: Colors.grey)),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      print('Button pressed');
                    },
                    child: Icon(Icons.save, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.all(20)),
              InteractiveViewer(
                boundaryMargin: EdgeInsets.all(50),
                minScale: 0.1,
                maxScale: 2.0,
                child: Transform.rotate(
                  angle: rotateX,
                  child: Transform.rotate(
                    angle: rotateY,
                    child: Transform.rotate(
                      angle: rotateZ,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateModelPosition(double x, double y, double z) {
    setState(() {
      rotateX = x;
      rotateY = y;
      rotateZ = z;
    });
  }
}

void _openSidebarMenu(BuildContext context) {
  // Ваша реализация бокового меню
}
