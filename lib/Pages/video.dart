import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';
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
            Container(
              width: MediaQuery.of(context).size.width, // Занимает всю ширину экрана
              child: FloatingActionButton(backgroundColor: Colors.white, focusColor: Colors.black, splashColor: Colors.orange,
                onPressed: () {Navigator.pushReplacementNamed(context, '/');},
                child: Column(children: [
                  Container(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.9,child:
                  SvgPicture.asset('Assets/Images/Drone1.svg'),),
                  Text('Навигация', style: TextStyle(fontFamily: 'Josefine', fontSize: 24, color: Colors.black),),
                ],)
              ),
            ),

          Container(
            width: MediaQuery.of(context).size.width, // Занимает всю ширину экрана
            child: FloatingActionButton(backgroundColor: Colors.white, focusColor: Colors.black, splashColor: Colors.orange,
                onPressed: () {Navigator.pushReplacementNamed(context, '/3d');},
                child: Column(children: [
                  Container(width: MediaQuery.of(context).size.width*0.9, height: MediaQuery.of(context).size.height * 0.9,child:
                  SvgPicture.asset('Assets/Images/Config.svg'),),
                  Text('Конфигурация', style: TextStyle(fontFamily: 'Josefine', fontSize: 24, color: Colors.black),),
                ],)
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width, // Занимает всю ширину экрана
            child: FloatingActionButton(backgroundColor: Colors.white, focusColor: Colors.black, splashColor: Colors.orange,
                onPressed: () {Navigator.pushReplacementNamed(context, '/port');},
                child: Column(children: [
                  Container(width: MediaQuery.of(context).size.width*0.95, height: MediaQuery.of(context).size.height * 0.9,child:
                  SvgPicture.asset('Assets/Images/Port.svg'),),
                  Text('Порты', style: TextStyle(fontFamily: 'Josefine', fontSize: 24, color: Colors.black),),
                ],)
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width, // Занимает всю ширину экрана
            child: FloatingActionButton(backgroundColor: Colors.white, focusColor: Colors.black, splashColor: Colors.orange,
                onPressed: () {Navigator.pushReplacementNamed(context, '/poba');},
                child: Column(children: [
                  Container(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.9,child:
                  SvgPicture.asset('Assets/Images/Accum.svg'),),
                  Text('Питание и Батарея', style: TextStyle(fontFamily: 'Josefine', fontSize: 24, color: Colors.black),),
                ],)
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width, // Занимает всю ширину экрана
            child: FloatingActionButton(backgroundColor: Colors.white, focusColor: Colors.black, splashColor: Colors.orange,
                onPressed: () {Navigator.pushReplacementNamed(context, '/ser');},
                child: Column(children: [
                  Container(width: MediaQuery.of(context).size.width * 0.9, height: MediaQuery.of(context).size.height * 0.9,child:
                  SvgPicture.asset('Assets/Images/orig.svg'),),
                  Text('Серво', style: TextStyle(fontFamily: 'Josefine', fontSize: 24, color: Colors.black),),
                ],)
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width, // Занимает всю ширину экрана
            child: FloatingActionButton(backgroundColor: Colors.white, focusColor: Colors.black, splashColor: Colors.orange,
                onPressed: () {Navigator.pushReplacementNamed(context, '/tele');},
                child: Column(children: [
                  Container(width: MediaQuery.of(context).size.width*0.9, height: MediaQuery.of(context).size.height * 0.9,child:
                  SvgPicture.asset('Assets/Images/Motor.svg'),),
                  Text('Моторы', style: TextStyle(fontFamily: 'Josefine', fontSize: 24, color: Colors.black),),
                ],)
            ),
          ),
        ],
      ),
    );
  }
}
