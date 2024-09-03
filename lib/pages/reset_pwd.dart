import 'package:flutter/material.dart';
import 'package:frca/components/general_button.dart';
import 'package:frca/model_and_service/frca_service.dart';
import 'package:frca/pages/login_page.dart';

class ResetPwd extends StatefulWidget {
  const ResetPwd({super.key});

  @override
  State<ResetPwd> createState() => _ResetPwdState();
}

class _ResetPwdState extends State<ResetPwd> {
  final formKey = GlobalKey<FormState>();
  bool showSpinner = false;
  bool disableField = false;

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

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

              Image.asset('lib/images/privatedata.gif', height: 240),
              const SizedBox(
                height: 30,
              ),

              //Some text
              const Text(
                'Set new password',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),

              //Sub Text
              const Text(
                "Your new password must be different from previously used passwords",
                style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 99, 99, 99),
                    fontFamily: 'Montserrat'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),

              //form
              Form(
                  key: formKey,
                  child: Column(
                    children: [
                      //password
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
                        controller: passwordController,
                        obscureText: false,
                        validator: (password) {
                          if (password == null || password.isEmpty) {
                            return 'Please enter your password';
                          } else if (password.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      const SizedBox(
                        height: 25,
                      ),

                      //Confirm Password
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
                            labelText: "Confirm password",
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
                        controller: confirmPasswordController,
                        obscureText: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          } else if (passwordController.text !=
                              confirmPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      const SizedBox(
                        height: 35,
                      ),

                      //Reset button
                      GenBtn(
                        btnText: 'Reset password',
                        shwSpinner: showSpinner,
                        func: () async {
                          if (formKey.currentState!.validate()) {
                            setState(
                              () => showSpinner = disableField = true,
                            );
                            var data = await resetPassword(
                                confirmPasswordController.text);
                            if (data
                                .containsValue("Password reset successful")) {
                              setState(
                                () => showSpinner = disableField = false,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                          'Password reset successful.\nLet sign you in.',
                                          style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 17,
                                              color: Colors.white))
                                    ],
                                  ),
                                  backgroundColor:
                                      Color.fromARGB(255, 114, 189, 255),
                                  padding: EdgeInsets.all(25),
                                ),
                              );
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()));
                            } else {
                              setState(
                                () => showSpinner = disableField = false,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.info_outline_rounded,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Text(data.toString(),
                                          style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 17,
                                              color: Colors.white))
                                    ],
                                  ),
                                  backgroundColor:
                                      const Color.fromARGB(255, 255, 119, 110),
                                  padding: const EdgeInsets.all(25),
                                ),
                              );
                            }
                          }
                        },
                      )
                    ],
                  )),
            ],
          ),
        ),
      ))),
    );
  }
}
