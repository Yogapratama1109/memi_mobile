import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconList = <IconData>[Icons.home, Icons.login_outlined];

    return AnimatedBottomNavigationBar(
      icons: iconList,
      activeIndex: currentIndex,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.softEdge,
      backgroundColor: Colors.white,
      activeColor: const Color(0xFFCBA851),
      inactiveColor: Colors.grey,
      iconSize: 28,
      onTap: onTap,
    );
  }
}
