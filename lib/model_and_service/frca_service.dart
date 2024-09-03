import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

//Student login

//I'm doing this because i'm feeling lazy to use provider
var resetId;

Future<dynamic> login(String email, String password) async {
  try {
    // To get access token
    final response = await http.post(
      Uri.parse('https://frcaservice.koyeb.app/api/v1/student_auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      },
      body: {'username': email, 'password': password},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      // Store access token on device
      var localStorage = await SharedPreferences.getInstance();
      await localStorage.setString("access_token", data["access_token"]);

      // Request to check user bio verification status
      var accessToken = data["access_token"];
      final verificationCheck = await http.get(
        Uri.parse('https://frcaservice.koyeb.app/api/v1/student'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (verificationCheck.statusCode == 200) {
        var status = jsonDecode(verificationCheck.body);

        if (status["profile"]["is_face_enrolled"]) {
          //this is because i want to store the value as a string
          await localStorage.setString("verify_status", "true");
        }
        return status["profile"]["is_face_enrolled"];
      } else {
        return 'Failed to verify bio verification status.';
      }
    } else {
      // If the server did not return a 200 OK response, handle error
      var data = jsonDecode(response.body);
      return data["detail"];
    }
  } catch (e) {
    // Catch any exceptions and return an error message
    return 'An error occurred';
  }
}

Future getStudentProfile() async {
  try {
    // Get the access token
    var localStorage = await SharedPreferences.getInstance();
    var accessToken = localStorage.getString("access_token");

    // Check if the access token is available
    if (accessToken == null) {
      return 'Access token not found';
    }

    // Make the API request
    final response = await http.get(
      Uri.parse('https://frcaservice.koyeb.app/api/v1/student'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    // Parse the response body
    final jsonData = jsonDecode(response.body);

    // Check the status code and return appropriate response
    if (response.statusCode == 200) {
      return jsonData;
    } else {
      return jsonData;
    }
  } catch (e) {
    // Catch any exceptions and return an error message
    return 'Oops! Something went wrong';
  }
}

Future<bool> initFacialRecog(image) async {
  var localStorage = await SharedPreferences.getInstance();
  var accessToken = localStorage.getString("access_token");

  if (accessToken == null) {
    //print('Access token is null');
  }

  FormData data = FormData.fromMap({
    "file": await MultipartFile.fromFile(
      image.path,
      filename: "image.jpg",
    ),
  });

  Dio dio = Dio();

  try {
    // This is done because facial recognition could complete but may return false and this is also done to prevent duplication of facial encodings
    final verificationCheck = await http.get(
      Uri.parse('https://frcaservice.koyeb.app/api/v1/student'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (verificationCheck.statusCode == 200) {
      var status = jsonDecode(verificationCheck.body);
      if (status["profile"]["is_face_enrolled"]) {
        //this is because i want to store the value as a string
        await localStorage.setString("verify_status", "true");
        return true;
      } else {
        // ignore: unused_local_variable
        final response = await dio.post(
          'https://frcaservice.koyeb.app/api/v1/student/enroll-face',
          data: data,
          options: Options(
            headers: {
              'Content-Type': 'multipart/form-data',
              'Accept': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );

        await localStorage.setString("verify_status", "true");
        return true;
      }
    } else {
      return false;
    }
  } catch (e) {
    //print('File upload error: $e');
    return false;
  }
}

Future<String> markAttendance(image, classID) async {
  var localStorage = await SharedPreferences.getInstance();
  var accessToken = localStorage.getString("access_token");

  if (accessToken == null) {
    //print('Access token is null');
  }

  FormData data = FormData.fromMap({
    "file": await MultipartFile.fromFile(
      image.path,
      filename: "image.jpg",
    ),
  });

  Dio dio = Dio();

  try {
    // ignore: unused_local_variable
    final response = await dio.post(
      'https://frcaservice.koyeb.app/api/v1/student/attendance/class',
      queryParameters: {"id": classID},
      data: data,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
    return "success";
  } catch (e) {
    // print('File upload error: $e');
    return "failure";
  }
}

Future<String> markTestAttendance(image, classID) async {
  var localStorage = await SharedPreferences.getInstance();
  var accessToken = localStorage.getString("access_token");

  if (accessToken == null) {
    //print('Access token is null');
  }

  FormData data = FormData.fromMap({
    "file": await MultipartFile.fromFile(
      image.path,
      filename: "image.jpg",
    ),
  });

  Dio dio = Dio();

  try {
    // ignore: unused_local_variable
    final response = await dio.post(
      'https://frcaservice.koyeb.app/api/v1/student/attendance/assessment',
      queryParameters: {"id": classID},
      data: data,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
    return "success";
  } catch (e) {
    // print('File upload error: $e');
    return "failure";
  }
}

Future<dynamic> forgotPassword(String email) async {
  try {
    Dio dio = Dio();
    // Make the API request with a custom validateStatus
    final response = await dio.post(
      'https://frcaservice.koyeb.app/api/v1/student_auth/forgot-password',
      data: {"email": email},
      options: Options(
        headers: {
          'Content-Type': 'application/json', // Ensuring correct content type
        },
        validateStatus: (status) {
          // Accept all status codes, or you can limit to specific ones
          return status != null &&
              status < 500; // Accepts status codes less than 500
        },
      ),
    );

    // Check the status code and handle the response
    if (response.statusCode == 200) {
      resetId = response.data["reset_id"];
      return response.data;
    } else if (response.statusCode == 400) {
      // Handle the specific case where the status code is 400
      return response.data;
    } else {
      return response.data;
    }
  } catch (e) {
    // Catch any exceptions and return an error message
    return 'Oops! Something went wrong';
  }
}

Future<dynamic> verifyCode(int code) async {
  try {
    Dio dio = Dio();
    // Make the API request with a custom validateStatus
    final response = await dio.post(
      'https://frcaservice.koyeb.app/api/v1/student_auth/verify-code',
      queryParameters: {"reset_id": resetId},
      data: {"code": code},
      options: Options(
        headers: {
          'Content-Type': 'application/json', // Ensuring correct content type
        },
        validateStatus: (status) {
          // Accept all status codes, or you can limit to specific ones
          return status != null &&
              status < 500; // Accepts status codes less than 500
        },
      ),
    );

    // Check the status code and handle the response
    if (response.statusCode == 200) {
      resetId = response.data["reset_id"];
      return response.data;
    } else if (response.statusCode == 400) {
      // Handle the specific case where the status code is 400
      return response.data;
    } else {
      return response.data;
    }
  } catch (e) {
    // Catch any exceptions and return an error message
    return 'Oops! Something went wrong';
  }
}

Future<dynamic> resetPassword(String newPassword) async {
  try {
    Dio dio = Dio();
    // Make the API request with a custom validateStatus
    final response = await dio.patch(
      'https://frcaservice.koyeb.app/api/v1/student_auth/reset-password',
      queryParameters: {"reset_id": resetId},
      data: {"new_password": newPassword},
      options: Options(
        headers: {
          'Content-Type': 'application/json', // Ensuring correct content type
        },
        validateStatus: (status) {
          // Accept all status codes, or you can limit to specific ones
          return status != null &&
              status < 500; // Accepts status codes less than 500
        },
      ),
    );

    // Check the status code and handle the response
    if (response.statusCode == 200) {
      return response.data;
    } else if (response.statusCode == 400) {
      // Handle the specific case where the status code is 400
      return response.data;
    } else {
      return response.data;
    }
  } catch (e) {
    // Catch any exceptions and return an error message
    return 'Oops! Something went wrong';
  }
}

Future<dynamic> markAsRead(notifyID) async {
  try {
    var localStorage = await SharedPreferences.getInstance();
    var accessToken = localStorage.getString("access_token");
    Dio dio = Dio();
    // Make the API request with a custom validateStatus
    final response = await dio.patch(
      'https://frcaservice.koyeb.app/api/v1/student/update-notification',
      queryParameters: {"id": notifyID},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $accessToken', // Ensuring correct content type
        },
        validateStatus: (status) {
          // Accept all status codes, or you can limit to specific ones
          return status != null &&
              status < 500; // Accepts status codes less than 500
        },
      ),
    );

    // Check the status code and handle the response
    if (response.statusCode == 200) {
      return response.data;
    } else if (response.statusCode == 400) {
      // Handle the specific case where the status code is 400
      return response.data;
    } else {
      return response.data;
    }
  } catch (e) {
    print(e);
    // Catch any exceptions and return an error message
    return 'Oops! Something went wrong';
  }
}
