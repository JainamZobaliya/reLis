import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:relis/globals.dart';
import 'package:flutter/material.dart';

class Authservice {
  Dio dio = new Dio();

  var emailid;

  login(emailId, password) async {
    print('Comes from SignIn');
    print("EmailId: $emailId");
    print("password: $password");
    try {
      return await dio.post('http://localhost:3000/authenticate',
          data: {"emailId": emailId, "password": password},
          options: Options(contentType: Headers.formUrlEncodedContentType));
    } on DioError catch (e) {
      Fluttertoast.showToast(
          msg: e.response?.data['msg'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: appBackgroundColor,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  signUp(var Mappy) async {
    print('Comes from OTP');
    if (Mappy != null) {
      print('Mappy: ${Mappy.runtimeType}');
      print('Mappy: $Mappy');
      print("FirstName: ${Mappy['firstName']}");
      print("LastName: ${Mappy['lastName']}");
      print("EmailId: ${Mappy['emailId']}");
      print("password: ${Mappy['password']}");

      try {
        return await dio.post('http://localhost:3000/adduser',
            data: {
              "firstName": Mappy['firstName'],
              "lastName": Mappy['lastName'],
              "emailId": Mappy['emailId'],
              "password": Mappy['password']
            },
            options: Options(contentType: Headers.formUrlEncodedContentType));
      } on DioError catch (e) {
        Fluttertoast.showToast(
            msg: e.response?.data['msg'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: appBackgroundColor,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      print('Did not receive Reg Data');
    }
  }

  changePassword(emailId, password) async {
    print('Comes from OTP');
    print("EmailId: $emailId");
    print("New password: $password");
    try {
      return await dio.post('http://localhost:3000/changePassword',
          data: {"emailId": emailId, "password": password},
          options: Options(contentType: Headers.formUrlEncodedContentType));
    } on DioError catch (e) {
      Fluttertoast.showToast(
          msg: e.response?.data['msg'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: appBackgroundColor,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

}
