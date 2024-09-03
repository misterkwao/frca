import 'package:flutter/material.dart';
import 'package:frca/pages/dashboard.dart';
import 'package:frca/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const DashBoard()));
          },
          child: const Icon(Icons.arrow_back_rounded),
        ),
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(
            fontSize: 20,
            color: Color.fromARGB(255, 99, 99, 99),
            fontFamily: 'Montserrat',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: <Widget>[
              GestureDetector(
                onTap: () async {
                  var localStorage = await SharedPreferences.getInstance();
                  await localStorage.setString("verify_status", "false");
                  await localStorage.setString("access_token", "");
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const LoginPage()));
                },
                child: const ListTile(
                  leading: Icon(Icons.exit_to_app_rounded),
                  title: Text(
                    "Logout",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
