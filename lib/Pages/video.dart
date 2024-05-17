import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class Video extends StatefulWidget{
  const Video({super.key});
  @override
  State<Video> createState() => _VideoState();
}


class _VideoState extends State<Video> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        scrollDirection: Axis.horizontal,
        children: [
            SizedBox(
              width: MediaQuery.of(context).size.width, // Занимает всю ширину экрана
              child: FloatingActionButton(backgroundColor: Colors.white, focusColor: Colors.black, splashColor: Colors.orange,
                onPressed: () {Navigator.pushReplacementNamed(context, '/');},
                child: Column(children: [
                  SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.9,child:
                  SvgPicture.asset('Assets/Images/Drone1.svg'),),
                  const Text('Навигация', style: TextStyle(fontFamily: 'Josefine', fontSize: 24, color: Colors.black),),
                ],)
              ),
            ),

          SizedBox(
            width: MediaQuery.of(context).size.width, // Занимает всю ширину экрана
            child: FloatingActionButton(backgroundColor: Colors.white, focusColor: Colors.black, splashColor: Colors.orange,
                onPressed: () {Navigator.pushReplacementNamed(context, '/3d');},
                child: Column(children: [
                  SizedBox(width: MediaQuery.of(context).size.width*0.9, height: MediaQuery.of(context).size.height * 0.9,child:
                  SvgPicture.asset('Assets/Images/Config.svg'),),
                  const Text('Конфигурация', style: TextStyle(fontFamily: 'Josefine', fontSize: 24, color: Colors.black),),
                ],)
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width, // Занимает всю ширину экрана
            child: FloatingActionButton(backgroundColor: Colors.white, focusColor: Colors.black, splashColor: Colors.orange,
                onPressed: () {Navigator.pushReplacementNamed(context, '/port');},
                child: Column(children: [
                  SizedBox(width: MediaQuery.of(context).size.width*0.95, height: MediaQuery.of(context).size.height * 0.9,child:
                  SvgPicture.asset('Assets/Images/Port.svg'),),
                  const Text('Порты', style: TextStyle(fontFamily: 'Josefine', fontSize: 24, color: Colors.black),),
                ],)
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width, // Занимает всю ширину экрана
            child: FloatingActionButton(backgroundColor: Colors.white, focusColor: Colors.black, splashColor: Colors.orange,
                onPressed: () {Navigator.pushReplacementNamed(context, '/poba');},
                child: Column(children: [
                  SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.9,child:
                  SvgPicture.asset('Assets/Images/Accum.svg'),),
                  const Text('Питание и Батарея', style: TextStyle(fontFamily: 'Josefine', fontSize: 24, color: Colors.black),),
                ],)
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width, // Занимает всю ширину экрана
            child: FloatingActionButton(backgroundColor: Colors.white, focusColor: Colors.black, splashColor: Colors.orange,
                onPressed: () {Navigator.pushReplacementNamed(context, '/ser');},
                child: Column(children: [
                  SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: MediaQuery.of(context).size.height * 0.9,child:
                  SvgPicture.asset('Assets/Images/orig.svg'),),
                  const Text('Сервоприводы', style: TextStyle(fontFamily: 'Josefine', fontSize: 24, color: Colors.black),),
                ],)
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width, // Занимает всю ширину экрана
            child: FloatingActionButton(backgroundColor: Colors.white, focusColor: Colors.black, splashColor: Colors.orange,
                onPressed: () {Navigator.pushReplacementNamed(context, '/tele');},
                child: Column(children: [
                  SizedBox(width: MediaQuery.of(context).size.width*0.9, height: MediaQuery.of(context).size.height * 0.9,child:
                  SvgPicture.asset('Assets/Images/Motor.svg'),),
                  const Text('Моторы', style: TextStyle(fontFamily: 'Josefine', fontSize: 24, color: Colors.black),),
                ],)
            ),
          ),
        ],
      ),
    );
  }
}
