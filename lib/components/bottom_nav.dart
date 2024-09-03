import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomNavbar extends StatelessWidget {
  void Function(int)? onNavChange;
  int index;
  CustomNavbar({super.key, required this.onNavChange, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(0)),
      child: NavigationBar(
          height: 70,
          elevation: 0,
          indicatorColor: const Color.fromARGB(201, 114, 189, 255),
          backgroundColor: Colors.transparent,
          selectedIndex: index,
          onDestinationSelected: (value) => onNavChange!(value),
          destinations: const [
            NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
              ),
              label: "Home",
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              label: "Settings",
            ),
          ]),
    );
  }
}
