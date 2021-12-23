import 'package:flutter/material.dart';
import 'package:relis/authentication/otp.dart';
import 'package:relis/authentication/signIn.dart';
import 'package:relis/authentication/signUp.dart';
import 'package:relis/globals.dart';
import 'package:relis/profile/showPhoto.dart';
import 'package:relis/view/bookView.dart';
import 'package:relis/view/homePage.dart';
import 'package:relis/view/pageView.dart';
import 'package:relis/profile/profile.dart';
import 'package:relis/view/searchPage.dart';
import 'package:relis/view/splashScreen.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scrollbarTheme: ScrollbarThemeData(
            interactive: true,
            isAlwaysShown: true,
            radius: Radius.circular(10),
            thickness: MaterialStateProperty.all(10.00),
            showTrackOnHover: true,
            thumbColor: MaterialStateProperty.all(Color(0xFF032f4b)),
            trackColor: MaterialStateProperty.all(Color(0x8d032f4b)),
            trackBorderColor: MaterialStateProperty.all(Color(0xFF032f4b)),
            minThumbLength: 10,
          ),
      ),
      initialRoute: SplashPage.routeName,
      // initialRoute: HomePage.routeName,
      debugShowCheckedModeBanner: false,
      routes: {
        SplashPage.routeName: (BuildContext context) => SplashPage(),
        SignUpPage.routeName: (BuildContext context) => SignUpPage(),
        SignInPage.routeName: (BuildContext context) => SignInPage(),
        OTPPage.routeName: (BuildContext context) => OTPPage(),
        HomePage.routeName: (BuildContext context) => HomePage(),
        BookView.routeName: (BuildContext context) => BookView(),
        PageTypeView.routeName: (BuildContext context) => PageTypeView(),
        Profile.routeName: (BuildContext context) => Profile(),
        ShowPhoto.routeName: (BuildContext context) => ShowPhoto(),
        SearchView.routeName: (BuildContext context) => SearchView(),
      },
    );
  }
}

//
// TODO: 1. CarouselScrollIndicator
// TODO: 2.
