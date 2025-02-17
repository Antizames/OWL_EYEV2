import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final List<Widget> middleWidgets;
  final Color backgroundColor;
  final TextStyle? titleStyle;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.leadingIcon,
    this.trailingIcon,
    this.middleWidgets = const [],
    this.backgroundColor = const Color.fromARGB(255, 233, 237, 245),
    this.titleStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: false, // Устанавливаем на false для более плавного появления
      pinned: false,
      backgroundColor: backgroundColor,
      expandedHeight: 70.0,
      toolbarHeight: 50.0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: backgroundColor,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                leadingIcon ?? const SizedBox.shrink(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: middleWidgets.isNotEmpty
                      ? middleWidgets
                      : [
                    Text(
                      title,
                      style: titleStyle ??
                          TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ],
                ),
                trailingIcon ?? const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
      leading: null,
      // Добавляем scroll physics
      primary: true,
    );
  }
}

