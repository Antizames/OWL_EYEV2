import 'package:flutter/material.dart';
class Configuration extends StatefulWidget{
  const Configuration({super.key});

  @override
  State<Configuration> createState() => _ConfigurationState();
}
class _ConfigurationState extends State<Configuration> {
  void _openMenu(){
    Navigator.of(context).push(
        MaterialPageRoute(builder: (BuildContext context){
          return Drawer(
              child: new ListView(
                children: <Widget>[
                  ListTile(
                    title: const Text('Навигация',style: TextStyle(fontSize: 26),),
                    onTap: () {Navigator.pushReplacementNamed(context, '/');},
                  ),
                  ListTile(title: const Text('Конфигурация',style: TextStyle(fontSize: 26),),onTap: () {Navigator.pushReplacementNamed(context, '/conf');}),
                  ListTile(title: const Text('Отказобезопасность',style: TextStyle(fontSize: 26),),onTap: () {Navigator.pushNamed(context, '/fail');}),
                  ListTile(title: const Text('Питание и Батарея',style: TextStyle(fontSize: 26),),onTap: () {Navigator.pushReplacementNamed(context, '/poba');}),
                  ListTile(title: const Text('Порты',style: TextStyle(fontSize: 26),),onTap: () {Navigator.pushReplacementNamed(context, '/port');}),
                  ListTile(title: const Text('Видео',style: TextStyle(fontSize: 26),),onTap: () {Navigator.pushReplacementNamed(context, '/vid');}),
                  Divider(color: Colors.black87),
                  ListTile(title: const Text('Сообщить об ошибке',style: TextStyle(fontSize: 26),),onTap: () {}),
                ],));
        })
    );
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text('Сетуп', style: TextStyle(fontSize: 30, color: Colors.white, fontStyle: FontStyle.italic),),
          centerTitle: true,
          leading: IconButton(
              onPressed: (){
                _openMenu();
              },
              icon: Icon(Icons.menu))
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              child: ListTile(
                title: Text('FC Firmware'),
                subtitle: Text('OWL EYE / STM32F405'),
                leading: Icon(Icons.memory),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text('Update'),
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('CPU Load'),
                subtitle: Text('15%'),
                leading: Icon(Icons.trending_down),
                trailing: Icon(Icons.info_outline),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Arming Disable Flags'),
                subtitle: Text('RX_FAIL SAFE'),
                leading: Icon(Icons.flag),
                trailing: Icon(Icons.help_outline),
              ),
            ),
            Divider(),
            Text(
              'System Health',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8.0,
              children: List.generate(5, (index) {
                return Chip(
                  avatar: CircleAvatar(
                    child: Icon(Icons.check_circle_outline, size: 16.0),
                  ),
                  label: Text('Sensor $index'),
                );
              }),
            ),
            Divider(),
            Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Calibrate Accelerometer'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Reset Settings'),
                ),
              ],
            ),
            // Другие виджеты, соответствующие различным элементам 'Setup tab'…
          ],
        ),
      ),
    );
  }
}