import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:owl/pages/configuration/widgets/deformableButton.dart';
import 'package:owl/pages/appBar/widgets/customAppBar.dart';

import 'package:owl/pages/sideBarMenu/sidebar_menu.dart';
class Preset extends StatefulWidget{
  const Preset({super.key});
  @override
  State<Preset> createState() => PresetState();
}
class PresetState extends State<Preset> {
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
  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }
  List<Map<String, String?>> containers = List.generate(
    10,
        (index) => {'author': null, 'description': null}, // Изначально пустые значения
  );

  // Функция для показа диалогового окна с вводом данных
  void _showInputDialog(BuildContext context, int index) {
    final _authorController = TextEditingController();
    final _descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Введите данные для ячейки $index'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _authorController,
                decoration: InputDecoration(labelText: 'Имя автора'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Описание'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  containers[index] = {
                    'author': _authorController.text,
                    'description': _descriptionController.text,
                  };
                });
                Navigator.of(context).pop();
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );
  } // Функция для добавления новых контейнеров
  void _addMoreContainers() {
    setState(() {
      // Добавляем 4 новых контейнера
      containers.addAll(List.generate(4, (index) => {'author': null, 'description': null}));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomAppBar(
            title: 'Пресет',
            leadingIcon: DeformableButton(
              onPressed: () {
                _openSidebarMenu(context);
              },
              child: Icon(Icons.menu, color: Colors.grey.shade600),
              gradient: LinearGradient(
                colors: <Color>[
                  Color.fromARGB(255, 233, 237, 245),
                  Color.fromARGB(255, 233, 237, 245)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            trailingIcon: DeformableButton(
              onPressed: () {
                // Показать диалоговое окно для добавления данных в первую пустую ячейку
                _showInputDialog(context, containers.indexWhere((element) => element['author'] == null));
              },
              child: Icon(Icons.add, color: Colors.grey.shade600),
              gradient: LinearGradient(
                colors: <Color>[
                  Color.fromARGB(255, 233, 237, 245),
                  Color.fromARGB(255, 233, 237, 245)
                ],
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
                    colors: [
                      Color.fromARGB(255, 233, 237, 245),
                      Color.fromARGB(255, 149, 152, 158),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: [
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Два столбца
                        crossAxisSpacing: 15.0,
                        mainAxisSpacing: 15.0,
                        childAspectRatio: 0.9, // Уменьшаем размер контейнеров
                      ),
                      itemCount: containers.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _showInputDialog(context, index),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            color: Colors.black87,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'FPV.WTF MSP-OSD',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0, // Сделаем текст чуть меньше
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Author: ${containers[index]['author'] ?? 'Нажмите для ввода'}',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'Description: ${containers[index]['description'] ?? ''}',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16.0),
                    // Кнопка для добавления новых контейнеров
                    TextButton(
                      onPressed: _addMoreContainers,
                      child: const Text(
                        'Добавить ещё контейнеры',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}




