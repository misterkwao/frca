import 'package:flutter/material.dart';
import 'package:frca/components/general_button.dart';
import 'package:frca/model_and_service/frca_service.dart';

import 'package:frca/pages/otp.dart';

class ForgotPwd extends StatefulWidget {
  const ForgotPwd({super.key});

  @override
  State<ForgotPwd> createState() => _ForgotPwdState();
}

class _ForgotPwdState extends State<ForgotPwd> {
  final formKey = GlobalKey<FormState>();
  bool showSpinner = false;
  bool disableField = false;

  // Textfield controller
  TextEditingController emailcontroller = TextEditingController();

  @override
  void dispose() {
    // Dispose of the controllers to prevent memory leaks
    emailcontroller.dispose();
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
                const SizedBox(
                  height: 40,
                ),
                Image.asset('lib/images/privatedata.gif', height: 240),
                const SizedBox(
                  height: 30,
                ),

                //Forgot Password Text
                const Text(
                  "Forgot Password ?",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),

                //Sub Text
                const Text(
                  "Don't worry! it happens. Please enter the email address associated with your account",
                  style: TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(255, 99, 99, 99),
                      fontFamily: 'Montserrat'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 50,
                ),

                //Email field
                Form(
                    key: formKey,
                    child: Column(
                      children: [
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
                          height: 30,
                        ),
                        //Send Button
                        GenBtn(
                            btnText: "Send Email",
                            shwSpinner: showSpinner,
                            func: () async {
                              if (formKey.currentState!.validate()) {
                                setState(
                                  () => showSpinner = disableField = true,
                                );
                                var data =
                                    await forgotPassword(emailcontroller.text);

                                if (!data.containsValue(
                                    "Email has been sent successfully")) {
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
                                          Text(data["detail"].toString(),
                                              style: const TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 16))
                                        ],
                                      ),
                                      backgroundColor: const Color.fromARGB(
                                          255, 255, 119, 110),
                                      padding: const EdgeInsets.all(25),
                                    ),
                                  );
                                } else {
                                  setState(
                                    () => showSpinner = disableField = false,
                                  );
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const OTPPage()));
                                }
                              }
                            }),
                      ],
                    ))
              ],
            ),
          ),
        ),
      )),
    );
  }
}
