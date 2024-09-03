import 'package:flutter/material.dart';

// ignore: must_be_immutable
class GenBtn extends StatelessWidget {
  void Function()? func;
  final String? btnText;
  bool? shwSpinner;
  GenBtn({super.key, this.func, this.btnText, this.shwSpinner});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: func,
    style: ElevatedButton.styleFrom(
                minimumSize: const Size(380, 40),
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 15)),
    child: (shwSpinner ?? false) ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    backgroundColor: Colors.white12,
                                    strokeWidth: 4,
                                  ):Text(btnText ?? '',style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white,fontFamily: 'Montserrat Bold')));
  }
}
