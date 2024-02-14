import 'package:flutter/material.dart';
class Ports extends StatefulWidget{
  const Ports({super.key});

  @override
  State<Ports> createState() => _PortsState();
}
class _PortsState extends State<Ports> {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text('Порты', style: TextStyle(fontSize: 30, color: Colors.white, fontStyle: FontStyle.italic),),
          centerTitle: true,
          leading: IconButton(
              onPressed: (){
                _openMenu();
              },
              icon: Icon(Icons.menu))
      ),
      body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Column(mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Виртуальный COM9', style: TextStyle(color: Colors.red, fontSize: 30),)]),]
      ),
    );
  }
}