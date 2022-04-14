import 'package:flutter/material.dart';
import 'package:relis/globals.dart';
import 'package:relis/view/splashScreen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ReLis());
}

class ReLis extends StatelessWidget {
  
  Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: FirebaseOptions(      
      apiKey: "AIzaSyBgPY4H6c2I924Ad-RC9UdCzZ9tVMuXMMw",
      authDomain: "audiobook-404e3.firebaseapp.com",
      projectId: "audiobook-404e3",
      storageBucket: "audiobook-404e3.appspot.com",
      messagingSenderId: "629834383464",
      appId: "1:629834383464:web:200d4b7abf8111f1c13bdd",
      measurementId: "G-YF05466XJC"
    ),
  );
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: appTheme,
      initialRoute: SplashPage.routeName,
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapShot) {
          if(snapShot.hasError) {
            print("ReLis>>Initialization Error: ${snapShot.error}");
          }
          if(snapShot.connectionState == ConnectionState.done) {
            return SplashPage();
          }
          return CircularProgressIndicator(
            valueColor:
            new AlwaysStoppedAnimation<Color>(Color(0xFF032f4b)),
          );

        },
      ),
      // initialRoute: HomePage.routeName,
      debugShowCheckedModeBanner: false,
      routes: appRoutes,
    );
  }
}
