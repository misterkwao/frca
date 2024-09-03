// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frca/components/general_button.dart';
import 'package:frca/model_and_service/frca_service.dart';
import 'package:frca/pages/dashboard.dart';
import 'package:frca/pages/forgot_password.dart';
import 'package:frca/pages/not_registered.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showSpinner = false;
  bool disableField = false;

  // Textfield controller
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  @override
  void initState() {
    _resetToken();
    super.initState();
  }

  Future<void> _resetToken() async {
    var localStorage = await SharedPreferences.getInstance();
    await localStorage.setString("access_token", '');
  }

  @override
  void dispose() {
    // Dispose of the controllers to prevent memory leaks
    emailcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  String? validateEmail(String? email) {
    RegExp emailRegExp = RegExp(r'^[\w\.-]+@[\w-]+\.\w{2,3}(\.\w{2,3})?$');
    final isEmailValid = emailRegExp.hasMatch(email ?? '');
    if (!isEmailValid) {
      return 'Please enter a valid email';
    }
    return null;
  }

  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
            child: Column(
              children: [
                //Icon
                const Icon(
                  Icons.security,
                  size: 65,
                  color: Color.fromARGB(255, 104, 158, 252),
                ),

                const SizedBox(
                  height: 20,
                ),
                //App text logo
                const Row(
                  children: [
                    Text("FRCA",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.blueAccent,
                            fontFamily: 'Montserrat Bold')),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                //Friendly text
                const Row(
                  children: [
                    Expanded(
                      //For text responsive layout
                      child: Text(
                        "Let's Sign you in.",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Montserrat'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                //Welcome text
                const Row(
                  children: [
                    Expanded(
                      //For text responsive layout
                      child: Text('Welcome back!',
                          style: TextStyle(
                              fontSize: 30, fontFamily: 'Montserrat')),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 35,
                ),

                //Email and password
                Form(
                    key: formKey,
                    child: Column(
                      children: [
                        //Email text field
                        TextFormField(
                          readOnly: disableField,
                          decoration: InputDecoration(
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 255, 194, 194),
                                    width: 2),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 255, 194, 194),
                                    width: 2),
                              ),
                              labelText: "Email",
                              labelStyle: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.grey.shade500),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 216, 216, 216),
                                      width: 2)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 216, 216, 216),
                                      width: 2))),
                          controller: emailcontroller,
                          validator: validateEmail,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(
                          height: 25,
                        ),

                        //Password text field
                        TextFormField(
                          readOnly: disableField,
                          decoration: InputDecoration(
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 255, 194, 194),
                                    width: 2),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 255, 194, 194),
                                    width: 2),
                              ),
                              labelText: "Password",
                              labelStyle: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.grey.shade500),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 216, 216, 216),
                                      width: 2)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 216, 216, 216),
                                      width: 2))),
                          controller: passwordcontroller,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(
                          height: 130,
                        ),

                        //Sign In button
                        GenBtn(
                          func: () async {
                            if (formKey.currentState!.validate()) {
                              setState(
                                () => showSpinner = disableField = true,
                              );

                              var loginData = await login(emailcontroller.text,
                                  passwordcontroller.text);

                              //handling sign in
                              switch (loginData) {
                                case true:
                                  setState(
                                    () => showSpinner = disableField = false,
                                  );
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const DashBoard()));
                                  break;
                                case false:
                                  setState(
                                    () => showSpinner = disableField = false,
                                  );
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const NotRegistered()));

                                default:
                                  setState(
                                    () => showSpinner = disableField = false,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.info_outline_rounded,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Expanded(
                                            child: Text(loginData.toString(),
                                                style: const TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 16)),
                                          )
                                        ],
                                      ),
                                      backgroundColor: const Color.fromARGB(
                                          255, 255, 119, 110),
                                      padding: const EdgeInsets.all(25),
                                    ),
                                  );
                              }
                            }
                          },
                          btnText: 'Sign In',
                          shwSpinner: showSpinner,
                        ),
                      ],
                    )),
                const SizedBox(
                  height: 20,
                ),
                //ForgotPassword

                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ForgotPwd())),
                  child: Text(
                    "Forgot Password ?",
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Montserrat',
                        color: Colors.grey.shade400),
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
