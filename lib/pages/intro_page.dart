import 'package:flutter/material.dart';
import 'package:frca/components/general_button.dart';
import 'package:frca/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  //Illustration
                  Image.asset('lib/images/lectures.jpg', height: 240),

                  //Main Text
                  const Text(
                    'Effective and efficient attendance taking.',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  //Sub text
                  const Text(
                    'Explore the modern way of marking class attendances. Utilize tools perfectly curated for being a student an enjoyable one.',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        fontFamily: 'Montserrat'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 150,
                  ),
                  //Buttton to login page
                  GenBtn(
                      btnText: "Continue",
                      func: () async {
                        var localStorage =
                            await SharedPreferences.getInstance();
                            await localStorage.setString("skip", "true");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()));
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
