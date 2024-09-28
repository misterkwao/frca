import 'package:flutter/material.dart';
import 'package:frca/pages/dashboard.dart';
import 'package:frca/pages/intro_page.dart';
import 'package:frca/pages/login_page.dart';
import 'package:frca/pages/not_registered.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
  FlutterNativeSplash.remove();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? navigate;

  @override
  void initState() {
    super.initState();
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    var localStorage = await SharedPreferences.getInstance();
    var pass = localStorage.getString("skip");
    var verifyStatus = localStorage.getString("verify_status");
    var accessToken = localStorage.getString("access_token");
    setState(() {
      if (pass == "true" && accessToken != "" && verifyStatus == "true") {
        navigate = const DashBoard();
      } else if (pass == "true" &&
          accessToken != "" &&
          verifyStatus != "true") {
        navigate = const NotRegistered();
      } else if (pass == "true") {
        navigate = const LoginPage();
      } else {
        navigate = const IntroPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 255, 255)),
        useMaterial3: true,
      ),
      home: navigate ??
          const CircularProgressIndicator(
                                    color: Colors.white,
                                    backgroundColor: Colors.white12,
                                    strokeWidth: 5,
                                  ), // Show a loading indicator while waiting
    );
  }
}
