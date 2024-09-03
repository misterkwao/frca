import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frca/components/general_button.dart';
import 'package:frca/model_and_service/frca_service.dart';
import 'package:frca/pages/reset_pwd.dart';

class OTPPage extends StatefulWidget {
  const OTPPage({super.key});

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final formKey = GlobalKey<FormState>();
  bool showSpinner = false;
  bool disableField = false;

  String pin1 = '';
  String pin2 = '';
  String pin3 = '';
  String pin4 = '';
  String pin5 = '';

  var verifyPin = "valid";

  String getCombinedPin() {
    return pin1 + pin2 + pin3 + pin4 + pin5;
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
                Image.asset('lib/images/pincode.gif'),

                //Header text
                const Row(
                  children: [
                    Expanded(
                      //Text responsiveness
                      child: Text(
                        "Verification Code",
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Montserrat'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                //sub text
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Please check your email. We've sent a code",
                        style: TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 99, 99, 99),
                            fontFamily: 'Montserrat'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                //OTP field
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      //Pincode fields
                      Wrap(
                        spacing: 19,
                        children: [
                          SizedBox(
                            height: 80,
                            width: 54,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              onSaved: (value) {
                                pin1 = value ?? '';
                              },
                              onChanged: (value) {
                                if (value.length == 1) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: InputDecoration(
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 255, 194, 194),
                                        width: 2),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 255, 194, 194),
                                        width: 2,
                                      )),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.blueAccent,
                                        width: 2,
                                      )),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 155, 155, 155),
                                        width: 2,
                                      ))),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    verifyPin == "invalid") {
                                  return '';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            height: 80,
                            width: 54,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              onSaved: (value) {
                                pin2 = value ?? '';
                              },
                              onChanged: (value) {
                                if (value.length == 1) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: InputDecoration(
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 255, 194, 194),
                                        width: 2),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 255, 194, 194),
                                        width: 2,
                                      )),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.blueAccent,
                                        width: 2,
                                      )),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 155, 155, 155),
                                        width: 2,
                                      ))),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    verifyPin == "invalid") {
                                  return '';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            height: 80,
                            width: 54,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              onSaved: (value) {
                                pin3 = value ?? '';
                              },
                              onChanged: (value) {
                                if (value.length == 1) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: InputDecoration(
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 255, 194, 194),
                                        width: 2),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 255, 194, 194),
                                        width: 2,
                                      )),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.blueAccent,
                                        width: 2,
                                      )),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 155, 155, 155),
                                        width: 2,
                                      ))),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    verifyPin == "invalid") {
                                  return '';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            height: 80,
                            width: 54,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              onSaved: (value) {
                                pin4 = value ?? '';
                              },
                              onChanged: (value) {
                                if (value.length == 1) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: InputDecoration(
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 255, 194, 194),
                                        width: 2),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 255, 194, 194),
                                        width: 2,
                                      )),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.blueAccent,
                                        width: 2,
                                      )),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 155, 155, 155),
                                        width: 2,
                                      ))),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    verifyPin == "invalid") {
                                  return '';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            height: 80,
                            width: 54,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              onSaved: (value) {
                                pin5 = value ?? '';
                              },
                              onChanged: (value) {
                                if (value.length == 1) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: InputDecoration(
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 255, 194, 194),
                                        width: 2),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 255, 194, 194),
                                        width: 2,
                                      )),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.blueAccent,
                                        width: 2,
                                      )),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color:
                                            Color.fromARGB(255, 155, 155, 155),
                                        width: 2,
                                      ))),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    verifyPin == "invalid") {
                                  return '';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      //verify button
                      Container(
                        margin: const EdgeInsets.only(top: 80.0),
                        child: GenBtn(
                          btnText: "Verify",
                          shwSpinner: showSpinner,
                          func: () async {
                            setState(() {
                              showSpinner = disableField = true;
                              verifyPin = "valid";
                            });
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              String combinedPin = getCombinedPin();
                              var data =
                                  await verifyCode(int.parse(combinedPin));
                              if (data.containsValue("Code is valid")) {
                                setState(
                                  () => showSpinner = disableField = false,
                                );
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ResetPwd()));
                              }
                              {
                                setState(
                                  () {
                                    showSpinner = disableField = false;
                                    verifyPin = "invalid";
                                    formKey.currentState!.validate();
                                  },
                                );
                              }
                            }
                          },
                        ),
                      )
                    ],
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
