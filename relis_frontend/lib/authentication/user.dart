import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:relis/authentication/services.dart';
import 'package:relis/globals.dart';

Map<String, dynamic>? user;

var globalUser = [];

var globalUserMap = {};

loadGlobalUserMap(BuildContext context) async {
  await Services().getAllUserDetails(user?["emailId"]).then((val) async {
    if (val != null && val.data['success']) {
      // print(val.data["userList"]);
      // print(val.data["userList"].length);
      // print(val.data["userList"][0]);
      // print(val.data["userList"][0].length);
      globalUser = val.data["userList"][0];
    }
    else{
      showMessageSnackBar(
          context,
          "Error, Can't fetch User Details from db. Please try later...",
          Color(0xFFFF0000));
    }

  });
  for(var gu in globalUser) {
    globalUserMap[gu["emailId"]] = gu;
  }
}

var userType = ["admin", "normal"];






