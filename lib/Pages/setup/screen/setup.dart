import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:owl/pages/appBar/widgets/customAppBar.dart';
class Setup extends StatefulWidget {
  const Setup({super.key});
  @override
  State<Setup> createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        scrollDirection: Axis.horizontal, // Прокрутка по горизонтали
        children: [
          // Карточка 1
          SizedBox(
            width: MediaQuery.of(context).size.width, // Занимает всю ширину экрана
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              focusColor: Colors.black,
              splashColor: Colors.orange,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: SvgPicture.asset('Assets/Images/Drone1.svg'),
                  ),
                  const Text(
                    'Навигация',
                    style: TextStyle(
                        fontFamily: 'Josefine',
                        fontSize: 24,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          // Карточка 2
          SizedBox(
            width: MediaQuery.of(context).size.width, // Занимает всю ширину экрана
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              focusColor: Colors.black,
              splashColor: Colors.orange,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/conf');
              },
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: SvgPicture.asset('Assets/Images/Config.svg'),
                  ),
                  const Text(
                    'Конфигурация',
                    style: TextStyle(
                        fontFamily: 'Josefine',
                        fontSize: 24,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          // Карточка 3
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              focusColor: Colors.black,
              splashColor: Colors.orange,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/port');
              },
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: SvgPicture.asset('Assets/Images/Port.svg'),
                  ),
                  const Text(
                    'Порты',
                    style: TextStyle(
                        fontFamily: 'Josefine',
                        fontSize: 24,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          // Карточка 4
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              focusColor: Colors.black,
              splashColor: Colors.orange,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/bat');
              },
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: SvgPicture.asset('Assets/Images/Accum.svg'),
                  ),
                  const Text(
                    'Питание и Батарея',
                    style: TextStyle(
                        fontFamily: 'Josefine',
                        fontSize: 24,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          // Карточка 5
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              focusColor: Colors.black,
              splashColor: Colors.orange,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/ser');
              },
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: SvgPicture.asset('Assets/Images/orig.svg'),
                  ),
                  const Text(
                    'Сервоприводы',
                    style: TextStyle(
                        fontFamily: 'Josefine',
                        fontSize: 24,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          // Карточка 6
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              focusColor: Colors.black,
              splashColor: Colors.orange,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/mot');
              },
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: SvgPicture.asset('Assets/Images/Motor.svg'),
                  ),
                  const Text(
                    'Моторы',
                    style: TextStyle(
                        fontFamily: 'Josefine',
                        fontSize: 24,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
