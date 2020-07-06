import 'package:flutter/material.dart';
import 'package:innovtion/screens/authScreen.dart';
import 'package:innovtion/screens/base.dart';
import 'package:innovtion/screens/example.dart';
import 'package:innovtion/screens/home.dart';
import 'package:innovtion/screens/splash_screen.dart';
import 'package:innovtion/screens/user_info.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Innovation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
      routes: {
        AuthScreen.routeName: (ctx) => AuthScreen(),
        HomeScreen.routeName: (ctx) => HomeScreen(),
        UserInfoScreen.routeName: (ctx) => UserInfoScreen(),
        ExampleScreen.routeName: (ctx) => ExampleScreen(),
        Base.routeName: (ctx) => Base(),
      },
    );
  }
}
