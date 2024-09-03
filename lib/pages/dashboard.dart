import "package:flutter/material.dart";
import "package:frca/components/bottom_nav.dart";
import "package:frca/pages/activity_page.dart";
import "package:frca/pages/settings.dart";

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {

  //handling navigation
  int selectedPage = 0;
  void navBottomBar(int index){
    setState(() {
      selectedPage = index;
    });
  }

  //pages
  final List<Widget> pages = [const ActivityPage(), const SettingsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[selectedPage],
      bottomNavigationBar: CustomNavbar(onNavChange: (index)=> navBottomBar(index), index: selectedPage),
    );
      
  }
}