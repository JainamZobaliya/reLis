import 'package:flutter/material.dart';
import 'package:relis/globals.dart';

class TranslatedBook extends StatelessWidget {
  static const routeName = '/TranslatedBookView';
  String? bookName;
  String? bookId;
  dynamic? fileData;

  TranslatedBook({
    this.bookName,
    this.bookId,
    this.fileData,
  });

  @override
  Widget build(BuildContext context) {
    ScrollController transController = new ScrollController();
    return Scaffold(
        backgroundColor: appBackgroundColor,
        appBar: AppBar(
          title: Text("${bookName}"),
          backgroundColor: appBarBackgroundColor,
          shadowColor: appBarShadowColor,
          elevation: 2.0,
        ),
        body: SingleChildScrollView(
          controller: transController,
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 10.00, horizontal: 10.00),
            margin: EdgeInsets.symmetric(vertical: 10.00, horizontal: 0.00),
            width: MediaQuery.of(context).size.width,
            color: mainAppAmber,
            child: Text(
              "${fileData}",
              style: TextStyle(
                // color: Color(0xFFFFFFFF),
                color: mainAppBlue,
                height: 2,
                fontSize: 18,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
                fontStyle: FontStyle.normal,
              ),
            ),
          ),
        ),
    );
  }
}