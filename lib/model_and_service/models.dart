// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  //configuring access tokens
  late String access_token;
  String get user_access_token => access_token;

  void settoken(String access_token) {
    access_token = access_token;
  }
  
}
