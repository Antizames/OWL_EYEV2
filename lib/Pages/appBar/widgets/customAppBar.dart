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
    return SliverPersistentHeader(
      pinned: false,
      floating: true,
      delegate: _CustomAppBarDelegate(
        title: title,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        middleWidgets: middleWidgets,
        backgroundColor: backgroundColor,
        titleStyle: titleStyle,
      ),
    );
  }
}

class _CustomAppBarDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final List<Widget> middleWidgets;
  final Color backgroundColor;
  final TextStyle? titleStyle;

  _CustomAppBarDelegate({
    required this.title,
    this.leadingIcon,
    this.trailingIcon,
    this.middleWidgets = const [],
    this.backgroundColor = const Color.fromARGB(255, 233, 237, 245),
    this.titleStyle,
  });

  @override
  double get maxExtent => 70;

  @override
  double get minExtent => 0;

  @override
  bool shouldRebuild(_CustomAppBarDelegate oldDelegate) => true;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final bool isCollapsed = shrinkOffset > 10;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: isCollapsed
            ? [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))]
            : [],
      ),
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleButton(leadingIcon),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: middleWidgets.isNotEmpty
                    ? middleWidgets
                    : [
                  Text(
                    title,
                    style: titleStyle ??
                        const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                  ),
                ],
              ),
            ),
          ),
          _buildCircleButton(trailingIcon),
        ],
      ),
    );
  }

  Widget _buildCircleButton(Widget? child) {
    if (child == null) return const SizedBox(width: 40);

    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          // Если это IconButton, вызываем его onPressed, иначе ничего
          if (child is IconButton && child.onPressed != null) {
            child.onPressed!();
          }
        },
        child: SizedBox(
          width: 42,
          height: 42,
          child: Center(
            child: child is IconButton ? child.icon : child,
          ),
        ),
      ),
    );
  }

}
